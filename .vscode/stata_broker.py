#!/usr/bin/env python3
"""Persistent broker that reuses one visible Stata Automation session."""

from __future__ import annotations

import argparse
import atexit
import json
import os
import queue
import secrets
import socketserver
import threading
import traceback
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any

import pythoncom
import win32com.client


SESSION_FILENAME = "session.json"
LOG_FILENAME = "broker.log"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Persistent Stata Automation broker for VS Code tasks."
    )
    parser.add_argument(
        "--runtime-dir",
        required=True,
        help="Workspace-local directory for session metadata and logs.",
    )
    return parser.parse_args()


def now_iso() -> str:
    return datetime.now().isoformat(timespec="seconds")


def stata_quote_text(text: str) -> str:
    return text.replace('"', '""')


@dataclass
class BrokerRequest:
    action: str
    payload: dict[str, Any]
    event: threading.Event = field(default_factory=threading.Event)
    response: dict[str, Any] | None = None


class LocalOnlyTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True
    daemon_threads = True


class BrokerRequestHandler(socketserver.StreamRequestHandler):
    def handle(self) -> None:
        raw_line = self.rfile.readline()
        if not raw_line:
            return

        try:
            request = json.loads(raw_line.decode("utf-8"))
        except json.JSONDecodeError:
            self._write_response(
                {"status": "error", "error": "Malformed JSON request."}
            )
            return

        if request.get("token") != self.server.auth_token:
            self._write_response(
                {"status": "error", "error": "Unauthorized broker request."}
            )
            return

        queued_request = BrokerRequest(
            action=request.get("action", ""),
            payload=request.get("payload", {}),
        )
        self.server.broker.enqueue(queued_request)
        queued_request.event.wait()
        self._write_response(
            queued_request.response
            or {"status": "error", "error": "No broker response."}
        )

    def _write_response(self, response: dict[str, Any]) -> None:
        self.wfile.write((json.dumps(response) + "\n").encode("utf-8"))


class StataBroker:
    def __init__(
        self,
        runtime_dir: Path,
        host: str,
        port: int,
        auth_token: str,
    ) -> None:
        self.runtime_dir = runtime_dir
        self.host = host
        self.port = port
        self.auth_token = auth_token
        self.session_path = self.runtime_dir / SESSION_FILENAME
        self.log_path = self.runtime_dir / LOG_FILENAME
        self.request_queue: queue.Queue[BrokerRequest | None] = queue.Queue()
        self.ready_event = threading.Event()
        self.shutdown_event = threading.Event()
        self.log_lock = threading.Lock()
        self.worker_error: str | None = None
        self.stata = None
        self.stata_session_id = ""
        self.worker_thread = threading.Thread(
            target=self._worker_loop,
            name="stata-broker-worker",
            daemon=True,
        )

    def start(self) -> None:
        self.worker_thread.start()
        self.ready_event.wait(timeout=30)
        if self.worker_error:
            raise RuntimeError(self.worker_error)
        if not self.ready_event.is_set():
            raise RuntimeError("Timed out while starting the Stata broker worker.")

    def stop(self) -> None:
        self.shutdown_event.set()
        self.request_queue.put(None)
        self.worker_thread.join(timeout=5)
        self._remove_session_file()

    def enqueue(self, request: BrokerRequest) -> None:
        self.request_queue.put(request)

    def log(self, message: str) -> None:
        line = f"[{now_iso()}] {message}\n"
        with self.log_lock:
            with self.log_path.open("a", encoding="utf-8") as handle:
                handle.write(line)

    def _worker_loop(self) -> None:
        pythoncom.CoInitialize()
        try:
            self._ensure_stata()
            self.ready_event.set()
            self.log("Broker worker ready.")
            while not self.shutdown_event.is_set():
                request = self.request_queue.get()
                if request is None:
                    break
                try:
                    request.response = self._dispatch_request(
                        request.action,
                        request.payload,
                    )
                except Exception:
                    error_text = traceback.format_exc()
                    self.log(f"Unhandled broker error:\n{error_text}")
                    request.response = {
                        "status": "error",
                        "error": "Unhandled broker error while processing the request.",
                    }
                finally:
                    request.event.set()
        except Exception:
            self.worker_error = traceback.format_exc()
            self.log(f"Broker startup failed:\n{self.worker_error}")
            self.ready_event.set()
        finally:
            self._release_stata()
            self._remove_session_file()
            pythoncom.CoUninitialize()

    def _dispatch_request(self, action: str, payload: dict[str, Any]) -> dict[str, Any]:
        if action != "run":
            return {
                "status": "error",
                "error": f"Unsupported broker action: {action}",
            }

        target_do_file = Path(payload["target_do_file"]).resolve()
        cwd = Path(payload["cwd"]).resolve()
        source_file = Path(payload["source_file"]).resolve()

        if not target_do_file.exists():
            return {
                "status": "error",
                "error": f"Target do-file does not exist: {target_do_file}",
            }
        if not source_file.exists():
            return {
                "status": "error",
                "error": f"Source do-file does not exist: {source_file}",
            }

        self._ensure_stata()
        self.log(f"Running {target_do_file} with working directory {cwd}")
        run_error = self._run_do_file(cwd, target_do_file)
        if run_error is not None:
            return {"status": "error", "error": run_error}

        return {
            "status": "ok",
            "message": f"Completed in the persistent Stata session: {target_do_file}",
            "broker_pid": os.getpid(),
            "broker_port": self.port,
            "stata_session_id": self.stata_session_id,
        }

    def _execute_command(self, command: str) -> int:
        result = self.stata.DoCommand(command)
        if result is None:
            return 0
        return int(result)

    def _run_do_file(self, cwd: Path, target_do_file: Path) -> str | None:
        commands = [
            (
                f'cd "{stata_quote_text(str(cwd))}"',
                f"changing directory to {cwd}",
            ),
            (
                f'do "{stata_quote_text(str(target_do_file))}"',
                f"running {target_do_file}",
            ),
        ]

        for attempt in range(2):
            try:
                self._ensure_stata()
                for command, description in commands:
                    rc = self._execute_command(command)
                    if rc != 0:
                        return f"Stata returned code {rc} while {description}."
                return None
            except Exception:
                if attempt == 1:
                    raise
                self.log(
                    "Stata command failed; recreating the Stata session and retrying."
                )
                self._release_stata()

        return "Unknown broker error."

    def _ensure_stata(self) -> None:
        if self.stata is None:
            self._start_stata()
            return

        try:
            self.stata.MacroValue("c(version)")
        except Exception:
            self.log(
                "Detected a closed or unavailable Stata window; starting a new one."
            )
            self._release_stata()
            self._start_stata()

    def _start_stata(self) -> None:
        self.log("Starting Stata Automation session.")
        try:
            self.stata = win32com.client.Dispatch("stata.StataOLEApp")
        except Exception as exc:
            if "Invalid class string" in str(exc):
                raise RuntimeError(
                    "Stata Automation is not registered on this machine. "
                    "The COM ProgID 'stata.StataOLEApp' is unavailable."
                ) from exc
            raise

        # Stata should already appear, but make a best effort to ensure the GUI is visible.
        try:
            self.stata.Visible = 1
        except Exception:
            try:
                self.stata.UtilShowStata()
            except Exception:
                pass

        self.stata_session_id = secrets.token_hex(8)
        self._write_session_file()
        self.log(f"Stata session ready: {self.stata_session_id}")

    def _release_stata(self) -> None:
        if self.stata is None:
            return
        self.stata = None
        self.stata_session_id = ""

    def _write_session_file(self) -> None:
        session_payload = {
            "host": self.host,
            "port": self.port,
            "token": self.auth_token,
            "pid": os.getpid(),
            "started_at": now_iso(),
            "stata_session_id": self.stata_session_id,
            "log_path": str(self.log_path),
        }
        temp_path = self.session_path.with_suffix(".tmp")
        temp_path.write_text(json.dumps(session_payload, indent=2), encoding="utf-8")
        temp_path.replace(self.session_path)

    def _remove_session_file(self) -> None:
        try:
            self.session_path.unlink()
        except FileNotFoundError:
            return
        except OSError:
            return


def main() -> None:
    args = parse_args()
    runtime_dir = Path(args.runtime_dir).resolve()
    runtime_dir.mkdir(parents=True, exist_ok=True)

    host = "127.0.0.1"
    auth_token = secrets.token_hex(24)
    server = LocalOnlyTCPServer((host, 0), BrokerRequestHandler)
    broker = StataBroker(
        runtime_dir=runtime_dir,
        host=host,
        port=server.server_address[1],
        auth_token=auth_token,
    )

    server.broker = broker
    server.auth_token = auth_token
    atexit.register(broker.stop)

    broker.start()
    broker.log("Broker server entering serve_forever loop.")

    try:
        server.serve_forever(poll_interval=0.5)
    except KeyboardInterrupt:
        broker.log("Broker interrupted; shutting down.")
    finally:
        server.shutdown()
        server.server_close()
        broker.stop()


if __name__ == "__main__":
    main()
