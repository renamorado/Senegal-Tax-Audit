# VS Code Stata Tasks

This workspace-local setup lets VS Code launch Stata on Windows without PowerShell automation, `Add-Type`, window pasting, `sendkeys`, AutoHotkey, `WScript.Shell`, or Stata All in One.

It is project-agnostic because it relies only on VS Code task variables like `${workspaceFolder}`, `${file}`, and `${selectedText}`, plus automatic Stata executable detection, the optional `STATA_EXE` environment variable for batch mode, and a workspace-local persistent broker for keep-open runs.

## Tasks

### `Stata: Run selection`

- Reads the current selection from `${selectedText}` through the `VSCODE_SELECTED_TEXT` environment variable.
- Writes a UTF-8 temporary do-file into `.vscode/stata-tmp/`.
- Adds a generated comment header and `cd "<source do-file folder>"`.
- Launches Stata in batch mode on the temporary do-file.
- Fails with a clear error if no text is selected.

### `Stata: Run selection (keep Stata open)`

- Reads the current selection from `${selectedText}` through the `VSCODE_SELECTED_TEXT` environment variable.
- Writes a UTF-8 temporary do-file into `.vscode/stata-tmp/`.
- Sends that temporary do-file to a persistent Stata GUI session owned by `.vscode/stata_broker.py`.
- Reuses the same Stata window across repeated keep-open runs in the same workspace whenever possible.
- Fails with a clear error if no text is selected.

### `Stata: Run current do-file`

- Launches the active `${file}` directly.
- Uses Stata batch mode with `/e do <file>`.

### `Stata: Run current do-file (keep Stata open)`

- Launches the active `${file}` directly.
- Sends the active `${file}` to a persistent Stata GUI session owned by `.vscode/stata_broker.py`.
- Reuses the same Stata window across repeated keep-open runs in the same workspace whenever possible.

## How portability works

- All task references are workspace-relative under `.vscode/`.
- The launcher never hardcodes project-specific repo paths.
- The active do-file path comes from `${file}`.
- The selected code comes from `${selectedText}`.
- Temporary selection files are written under `.vscode/stata-tmp/`, not beside the source file.
- Batch-mode Stata is resolved from `STATA_EXE` first, then common default install locations.
- Keep-open mode uses a workspace-local persistent broker under `.vscode/stata-runtime/`.

## Setup

1. Copy the `.vscode` folder into any repo.
2. Install `pywin32` if you want the keep-open tasks to reuse one Stata GUI session.
3. Optionally define the `STATA_EXE` environment variable if your Stata executable is not in a common default location for batch tasks.
4. Run one of the VS Code tasks from the Command Palette or Tasks UI.

Example:

```powershell
pip install pywin32
```

## Stata executable resolution

Batch-mode launches check these locations in order after `STATA_EXE`:

1. `C:\Program Files\StataNow19\StataMP-64.exe`
2. `C:\Program Files\StataNow19\StataSE-64.exe`
3. `C:\Program Files\Stata19\StataMP-64.exe`
4. `C:\Program Files\Stata19\StataSE-64.exe`
5. `C:\Program Files\Stata18\StataMP-64.exe`
6. `C:\Program Files\Stata18\StataSE-64.exe`
7. `C:\Program Files\Stata17\StataMP-64.exe`
8. `C:\Program Files\Stata17\StataSE-64.exe`

If none are found, the batch launcher exits with a message telling you to define `STATA_EXE`.

Keep-open launches do not use `STATA_EXE`; they use the registered Stata Automation object exposed by the local Stata installation.
If that Automation object is not registered on the machine, keep-open tasks fall back to a direct GUI launch. That keeps Stata open, but it does not guarantee reuse of a single Stata instance.

## Persistent broker behavior

- Keep-open tasks auto-start `.vscode/stata_broker.py` the first time you run them.
- The broker listens only on `127.0.0.1`.
- It owns one persistent Stata GUI session per workspace and serializes requests in FIFO order.
- Broker runtime state is stored under `.vscode/stata-runtime/`.
- If you close the Stata window manually, the broker starts a new Stata session the next time it needs one.
- Manual commands typed directly into the Stata window are out of band and can interfere with the exact timing of queued task runs.

## Troubleshooting

### No Python launcher found

If the VS Code task cannot find `py`, install the Windows Python launcher or change the task `command` from `py` to a working Python executable on your machine.

### Missing `pywin32`

If a keep-open task says that the broker failed to start, install `pywin32`:

```powershell
pip install pywin32
```

### Stata Automation not registered

If the broker log says the COM ProgID `stata.StataOLEApp` is unavailable or reports `Invalid class string`, this Stata installation does not currently expose the Automation object needed for true single-instance reuse.

In that case, the keep-open tasks fall back to a direct GUI launch. You can still run code, but repeated keep-open runs may open additional Stata instances. Restoring true broker reuse requires a local Stata installation or registration state that exposes the Automation object.

### No Stata executable found

Set `STATA_EXE` to the full path of your Stata executable for batch mode, for example:

```powershell
$env:STATA_EXE = 'C:\Program Files\StataNow19\StataMP-64.exe'
```

Or define it permanently in Windows environment variables.

### No selected text

`Stata: Run selection` only runs highlighted text. If nothing is selected, the launcher exits with a clear error instead of running the whole file.

### Stata opens and closes immediately

Use `Stata: Run current do-file (keep Stata open)` if you want the GUI to stay open after the do-file runs. On Windows, the batch task intentionally uses `/e do <file>`, which asks Stata to exit when it finishes.

## Keep-open behavior on Windows

This setup uses:

- batch mode: `Stata... /e do <file>`
- keep-open mode: persistent Automation broker plus `cd "..."` and `do "..."` inside one visible Stata GUI session

The `/e` behavior is documented by StataCorp for Windows batch execution. For single-instance keep-open reuse, the broker uses Stata's official Windows Automation interface because StataCorp documents that each new `StataOLEApp` object launches a new Stata instance; reusing one instance therefore requires a persistent broker process that keeps the same Automation object alive across task invocations.
If that Automation object is unavailable on the local machine, the launcher degrades to direct GUI `do <file>` behavior instead of failing hard.

Reference:

- StataCorp, "How do I run Stata for Windows in batch mode?": https://www.stata.com/support/faqs/windows/batch-mode/
- StataCorp, "Using Stata Automation": https://www.stata.com/automation/

## Notes

This workspace still has older Stata extension settings in `.vscode/settings.json`. Those settings are outside the scope of this task-based launcher and were not changed here.
