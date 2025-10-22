*****************************************************************************************
**         Project name: ALGORITHMS AND BUREAUCRATS: EVIDENCE FROM TEX AUDIT SELECTION IN SENEGAL
**		   Authors: Pierre Bachas, Anne Brockmeyer, Alipio Ferreira, Bassirou Sarr
**		   March 2025
*****************************************************************************************

*****************
** DESCRIPTION   **
*****************

*This script creates summary statistics

set more off
clear all 

*****************
** DIRECTORIES **
*****************
	if strpos("`c(username)'","49354415") { 										// Alipio's computer
		global rootdir "C:\Users\49354415\Dropbox\Trabalho\2017 WB\Senegal tax audits"
	}

		global rawdata "$rootdir"
		global analysisdata "$rootdir\Analysis all data\replication_package\Working data"
		global wastedata "$rootdir\Analysis all data\replication_package\Intermediate data"
		global output "$rootdir\Analysis all data\replication_package\Output"
		global code "$rootdir\Analysis all data\replication_package\Code Prepare Analysis Data"

local date: disp  c(current_date)
di "`date'"
set scheme s1color


* initialize Stata
clear all
set more off
set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "Enquête Fiscalité_WIDE.csv"
local dtafile "Enquête Fiscalité.dta"
local corrfile "Enquête Fiscalité_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum username allows_comments duration today caseid bureau raison proprietaire adresse telephone secteur lencal nonconsa nonconsex sans_enquete_autrepr"
local text_fields2 "sans_enquete_explain q1 q1_other q2 q2_other q6 q6_other q45 comfin instanceid instancename"
local date_fields1 ""
local datetime_fields1 "submissiondate starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
*import delimited "`csvfile'", delimiter(comma) bindquote(strict) encoding(UTF-8) clear 
*import delimited "C:\Users\alipi\Dropbox\Trabalho\2017 WB\Senegal tax audits\Taxpayer Survey\Survey results\Enquête Fiscalité_WIDE2.txt", delimiter(comma) bindquote(strict) encoding(UTF-8) clear 
import delimited "$rawdata/Taxpayer Survey/Survey results/Enquête Fiscalité_WIDE.txt", bindquote(strict) encoding(UTF-8) clear 

*******************************************************************************
*RENAME VARIABLES
*******************************************************************************

	*destring variables
	foreach v in superviseur enqueteur q3 q4 q5 q6 q7 q8 q9 q10 q11 q12 q13 q14 q15 q16 q17 q18 q19 q20 q21 q22 q23 q24 q25 q26 q27 q28 q28a q29 q29a q30 q31 q32 q33 q34 q35 q36 q37 q38 q39 q40 q41 q42 q43 q44 consent noncons sans_enquete {
	destring `v', force replace 
	}

	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable superviseur "Nom du superviseur"
	note superviseur: "Nom du superviseur"
	label define superviseur 10 "MOUSTAPHA SADIO" 20 "CHEIKH GAYE" 30 "SOULEYMANE DIALLO" 40 "MOHAMADOU LAM" 50 "OMAR SECK"
	label values superviseur superviseur

	label variable enqueteur "Nom de l'enqueteur"
	note enqueteur: "Nom de l'enqueteur"
	label define enqueteur 10 "MOUSTAPHA SADIO" 11 "ABDOULAYE DIATTA" 12 "DAOUDA SOUMARE" 13 "NAFI MBAYE" 14 "LANSANA MANE" 15 "TIDIANE MBAYE" 20 "CHEIKH GAYE" 21 "HINDOU THIAM" 22 "CHEIKH MBENGUE" 23 "NDEYE SIGA BESSANE" 24 "NOUROU FAYE" 25 "NIASSA NDIAYE" 30 "SOULEYMANE DIALLO" 31 "NDEYE AMY FAYE DENIS" 32 "SOUKEYNA LY" 33 "AMADOU LAMARANA DIALLO" 34 "MALICK LY" 35 "CHEIKH SADIBOU SECK" 40 "MOHAMADOU LAM" 41 "ABDOULAYE NIANG" 42 "IBRAHIMA TAMBA" 43 "AMADOU DIA" 44 "DIEYNABA BOUBOU TRAORE" 50 "OMAR SECK" 51 "FATOU KINE GUEYE" 52 "FILY CISSOKHO" 53 "MATAR BARRY" 54 "IBRAHIMA DIALLO"
	label values enqueteur enqueteur

	label variable id_1 "Entrez l'identifiant de l'entreprise"
	note id_1: "Entrez l'identifiant de l'entreprise"

	label variable id_2 "Confirmez l'identifiant de l'entreprise"
	note id_2: "Confirmez l'identifiant de l'entreprise"

	label variable consent "Votre entreprise \${RAISON} situé à \${ADRESSE} dont le telephone est \${TELEPHO"
	note consent: "Votre entreprise \${RAISON} situé à \${ADRESSE} dont le telephone est \${TELEPHONE} et qui s'active dans le(la) \${SECTEUR} a été sélectionnée pour répondre à une enquête sur la fiscalité au Sénégal. Cette étude est menée par des chercheurs associés à la Banque Mondiale, et son but est d'évaluer l'expérience des entreprises sénégalaises avec l'administration fiscale. Nous vous assurons que vos informations seront traitées avec la plus grande confidentialité. Les réponses individuelles ne seront jamais partagées avec la DGID. L'étude pourra servir à fournir des recommandations à l'administration fiscale pour améliorer sa relation avec les contribuables. Notre conversation aujourd'hui ne prendra pas plus de 10-15 minutes, et nous vous remercions de votre temps ! Pour toute question, vous aurez le droit de ne pas répondre si vous le souhaitez. Êtes-vous d'accord pour participer à cet entretien sous ces conditions ?"
	label define consent 1 "Oui" 2 "Non / Refus" 3 "Sans enquête / Envoyer le récapitulatif journalier"
	label values consent consent

	label variable noncons "Enqueteur : Pour l’enquête n'as pas eu lieu ? (Motif Refus)"
	note noncons: "Enqueteur : Pour l’enquête n'as pas eu lieu ? (Motif Refus)"
	label define noncons 1 "Répondant cible refusé (initial)" 2 "Aucun repondant disponible pendant toute la période d'enquête" 3 "Refus final de participer" 4 "Répondant cible Malade" -77 "Autre à préciser"
	label values noncons noncons

	label variable nonconsa "Autre raison pour laquelle l’enquête n'as pas eu lieu"
	note nonconsa: "Autre raison pour laquelle l’enquête n'as pas eu lieu"

	label variable nonconsex "Compléter ou donner plus de précisions à ces informations si besoin."
	note nonconsex: "Compléter ou donner plus de précisions à ces informations si besoin."

	label variable sans_enquete "Enqueteur : Pour l’enquête n'as pas eu lieu ? (Motif Envoi récapitulatif journal"
	note sans_enquete: "Enqueteur : Pour l’enquête n'as pas eu lieu ? (Motif Envoi récapitulatif journalier)"
	label define sans_enquete 1 "A pris un RV (preciser)" 2 "Repondant cible absent temporaire" 3 "Pas de Contact/Mauvais Contact" 4 "Répondant cible non disponible temporairement" 5 "Aucun contact avec quiconque au téléphone après plusieurs tentatives" 6 "Entreprise non-trouvée après plusieurs recherche" 7 "Entreprise fermée/ aucun contact possible" -77 "Autre à préciser"
	label values sans_enquete sans_enquete

	label variable sans_enquete_autrepr "Autre raison pour laquelle l’enquête n'as pas eu lieu"
	note sans_enquete_autrepr: "Autre raison pour laquelle l’enquête n'as pas eu lieu"

	label variable sans_enquete_explain "Compléter ou donner plus de précisions à ces informations si besoin."
	note sans_enquete_explain: "Compléter ou donner plus de précisions à ces informations si besoin."

	label variable tel_used "Numéro de téléphone avec lequel l'entreprise a été jointe"
	note tel_used: "Numéro de téléphone avec lequel l'entreprise a été jointe"

	label variable q1 "1. Quelle est votre fonction dans l'entreprise ? Choisissez l'option qui mieux d"
	note q1: "1. Quelle est votre fonction dans l'entreprise ? Choisissez l'option qui mieux décrit votre fonction."

	label variable q1_other "Specify other."
	note q1_other: "Specify other."

	label variable q2 "2. Pouvez-vous choisir sur cette liste le secteur d'activité principal de votre "
	note q2: "2. Pouvez-vous choisir sur cette liste le secteur d'activité principal de votre entreprise ?"

	label variable q2_other "Specify other."
	note q2_other: "Specify other."

	label variable q3 "3. Quel était le nombre total d'employés de l'entreprise à temps plein en décemb"
	note q3: "3. Quel était le nombre total d'employés de l'entreprise à temps plein en décembre 2019 ?"

	label variable q4 "4. Quel était le nombre total d'employés de l'entreprise à temps partiel en déce"
	note q4: "4. Quel était le nombre total d'employés de l'entreprise à temps partiel en décembre 2019 ?"

	label variable q5 "5. Quel pourcentage de votre chiffre d'affaires percevez-vous sous forme de paie"
	note q5: "5. Quel pourcentage de votre chiffre d'affaires percevez-vous sous forme de paiement en cash/espèces ? Obs : par « paiements en espèces » on considère seulement les paiements en billets ou monnaies."

	label variable q6 "6. Quelle est la situation de votre entreprise suite à la situation économique c"
	note q6: "6. Quelle est la situation de votre entreprise suite à la situation économique créée par la pandémie ?"

	label variable q6_other "Specify other."
	note q6_other: "Specify other."

	label variable q7 "7. Par rapport au chiffre d'affaires perçu entre avril et juin 2019 (deuxième tr"
	note q7: "7. Par rapport au chiffre d'affaires perçu entre avril et juin 2019 (deuxième trimestre), combien votre chiffre d'affaires entre avril et juin 2020 a-t-il changé – baisse ou augmentation en pourcentage ?"
	label define q7 999 "Pas de réponse" 1 "Il a baissé entre 80% et 100%" 2 "Il a baissé entre 50% et 80%" 3 "Il a baissé entre 20% et 50%" 4 "Il a baissé entre 0% et 20%" 5 "Il n'a pas beaucoup changé" 6 "Il a augmenté entre 0 et 20%" 7 "Il a augmenté entre 20% et 50%" 8 "Il a augmenté entre 50% et 80%" 9 "Il a augmenté plus de 80%"
	label values q7 q7

	label variable q8 "8. Report de loyers ou factures d'électricité/eau/téléphone"
	note q8: "8. Report de loyers ou factures d'électricité/eau/téléphone"
	label define q8 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q8 q8

	label variable q9 "9. Report de paiement de dettes, intérêts, ou renégociation de dettes"
	note q9: "9. Report de paiement de dettes, intérêts, ou renégociation de dettes"
	label define q9 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q9 q9

	label variable q10 "10. Crédit bonifié ou garanti par l'Etat à travers les banques"
	note q10: "10. Crédit bonifié ou garanti par l'Etat à travers les banques"
	label define q10 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q10 q10

	label variable q11 "11. Crédit sans garanti de l'Etat"
	note q11: "11. Crédit sans garanti de l'Etat"
	label define q11 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q11 q11

	label variable q12 "12. Remise de paiement d'impôts en guise de subvention pour le paiement des sala"
	note q12: "12. Remise de paiement d'impôts en guise de subvention pour le paiement des salaires"
	label define q12 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q12 q12

	label variable q13 "13. Remise de dette fiscale constatée au 31 décembre 2019"
	note q13: "13. Remise de dette fiscale constatée au 31 décembre 2019"
	label define q13 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q13 q13

	label variable q14 "14. Subventions directes"
	note q14: "14. Subventions directes"
	label define q14 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q14 q14

	label variable q15 "15. Selon votre expérience, les vérifications générales ont lieu tous les… combi"
	note q15: "15. Selon votre expérience, les vérifications générales ont lieu tous les… combien d'années ?"
	label define q15 999 "Je ne sais pas" 1 "Tous les ans." 2 "Tous les deux ans" 3 "Tous les trois ans" 4 "Tous les quatre ans" 5 "Tous les cinq ans" 6 "Tous les six ans" 7 "Tous les sept ans" 8 "Tous les huit ans" 9 "Tous les neuf ans" 10 "Tous les dix ans ou plus rarement que ça"
	label values q15 q15

	label variable q16 "16. Selon votre expérience, les contrôles sur pièces ont lieu tous le… combien d"
	note q16: "16. Selon votre expérience, les contrôles sur pièces ont lieu tous le… combien d'années ?"
	label define q16 999 "Je ne sais pas" 1 "Tous les ans." 2 "Tous les deux ans" 3 "Tous les trois ans" 4 "Tous les quatre ans" 5 "Tous les cinq ans" 6 "Tous les six ans" 7 "Tous les sept ans" 8 "Tous les huit ans" 9 "Tous les neuf ans" 10 "Tous les dix ans ou plus rarement que ça"
	label values q16 q16

	label variable q17 "17. Le dernier contrôle remonte à longtemps"
	note q17: "17. Le dernier contrôle remonte à longtemps"
	label define q17 0 "Je ne sais pas" 1 "Réduit les chances" 2 "Cela n'a pas d'importance" 3 "Augmente les chances"
	label values q17 q17

	label variable q18 "18. Le chiffre d'affaires déclaré par l'entreprise est très bas"
	note q18: "18. Le chiffre d'affaires déclaré par l'entreprise est très bas"
	label define q18 0 "Je ne sais pas" 1 "Réduit les chances" 2 "Cela n'a pas d'importance" 3 "Augmente les chances"
	label values q18 q18

	label variable q19 "19. Le chiffre d'affaires déclaré par l'entreprise est très élevé"
	note q19: "19. Le chiffre d'affaires déclaré par l'entreprise est très élevé"
	label define q19 0 "Je ne sais pas" 1 "Réduit les chances" 2 "Cela n'a pas d'importance" 3 "Augmente les chances"
	label values q19 q19

	label variable q20 "20. Le profit déclaré est très bas"
	note q20: "20. Le profit déclaré est très bas"
	label define q20 0 "Je ne sais pas" 1 "Réduit les chances" 2 "Cela n'a pas d'importance" 3 "Augmente les chances"
	label values q20 q20

	label variable q21 "21. Le profit déclaré est très élevé"
	note q21: "21. Le profit déclaré est très élevé"
	label define q21 0 "Je ne sais pas" 1 "Réduit les chances" 2 "Cela n'a pas d'importance" 3 "Augmente les chances"
	label values q21 q21

	label variable q22 "22. L'entreprise fait beaucoup d'importations ou d'exportations"
	note q22: "22. L'entreprise fait beaucoup d'importations ou d'exportations"
	label define q22 0 "Je ne sais pas" 1 "Réduit les chances" 2 "Cela n'a pas d'importance" 3 "Augmente les chances"
	label values q22 q22

	label variable q23 "23. Pensez-vous que la DGID se base principalement sur des recoupements de donné"
	note q23: "23. Pensez-vous que la DGID se base principalement sur des recoupements de données entre différents contribuables afin de choisir les contrôles ? obs : il s’agit de comparaisons des données déclarés par l’entreprise avec d’autres données, comme par exemple des données bancaires ou des transactions"
	label define q23 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q23 q23

	label variable q24 "24. Pensez-vous que la DGID utilise des algorithmes de risque sophistiqués afin "
	note q24: "24. Pensez-vous que la DGID utilise des algorithmes de risque sophistiqués afin de détecter les entreprises qui trichent ?"
	label define q24 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q24 q24

	label variable q25 "25. Lorsque des entreprises de votre secteur d'activité économique sont contrôlé"
	note q25: "25. Lorsque des entreprises de votre secteur d'activité économique sont contrôlées, est-ce que vous vous préparez à être contrôlé aussi ?"
	label define q25 0 "Je ne sais pas" 1 "Non" 2 "Oui" 3 "Je ne suis pas au courant quand d'autres entreprises sont contrôlées"
	label values q25 q25

	label variable q26 "26. Lorsque des entreprises de la même taille que la vôtre sont contrôlées, est-"
	note q26: "26. Lorsque des entreprises de la même taille que la vôtre sont contrôlées, est-ce que vous vous préparez à être contrôlé aussi ?"
	label define q26 0 "Je ne sais pas" 1 "Non" 2 "Oui" 3 "Je ne suis pas au courant quand d'autres entreprises sont contrôlées"
	label values q26 q26

	label variable q27 "27. Lorsque des entreprises situées près de vos locaux sont contrôlées, est-ce q"
	note q27: "27. Lorsque des entreprises situées près de vos locaux sont contrôlées, est-ce que vous vous préparez à être contrôlé aussi ?"
	label define q27 0 "Je ne sais pas" 1 "Non" 2 "Oui" 3 "Je ne suis pas au courant quand d'autres entreprises sont contrôlées"
	label values q27 q27

	destring q28, force replace
	label variable q28 "28. A quelle année remonte le dernier contrôle sur pièces dont votre entreprise "
	note q28: "28. A quelle année remonte le dernier contrôle sur pièces dont votre entreprise a fait objet ?"
	label define q28 0 "D'après moi l'entreprise n'a jamais fait objet d'un contrôle sur pièce" 1 "Je ne sais pas, mais l'entreprise a fait objet d'un contrôle sur pièce" 2 "Année"
	label values q28 q28

	label variable q28a "Preciser l'année a laquelle remonte le dernier contrôle sur pièces dont votre en"
	note q28a: "Preciser l'année a laquelle remonte le dernier contrôle sur pièces dont votre entreprise a fait objet"

	label variable q29 "29. A quelle année remonte la dernière Vérification Générale dont votre entrepri"
	note q29: "29. A quelle année remonte la dernière Vérification Générale dont votre entreprise a fait objet ?"
	label define q29 0 "D'après moi l'entreprise n'a jamais fait objet d'une vérification générale" 1 "Je ne sais pas, mais l'entreprise a fait objet d'une vérification générale" 2 "Année"
	label values q29 q29

	label variable q29a "Preciser l'année a laquelle remonte la dernière Vérification Générale dont votre"
	note q29a: "Preciser l'année a laquelle remonte la dernière Vérification Générale dont votre entreprise a fait objet"

	label variable q30 "30. Combien de semaines a duré cette vérification générale entre le premier et l"
	note q30: "30. Combien de semaines a duré cette vérification générale entre le premier et le dernier contact ? Obs si nécessaire : le premier contact est le moment où l'entreprise a été informée par la DGID qu'elle était l'objet d'un contrôle. Le dernier contact est la dernière question ou réponse de la DGID dans le cadre du contrôle, ou le moment de la réception d'un titre de perception."

	label variable q31 "31. ...connaissances techniques ?"
	note q31: "31. ...connaissances techniques ?"

	label variable q32 "32. ...honnêteté ?"
	note q32: "32. ...honnêteté ?"

	label variable q33 "33. ...rapidité/efficacité ?"
	note q33: "33. ...rapidité/efficacité ?"

	label variable q34 "34. Dans l'ensemble des contrôles faits dans des entreprises comme la vôtre, que"
	note q34: "34. Dans l'ensemble des contrôles faits dans des entreprises comme la vôtre, quel pourcentage de cas finissent par avoir un paiement informel fait aux inspecteurs, selon votre avis personnel ?"

	label variable q35 "35. Dans votre carrière professionnelle, avez-vous déjà vécu, directement ou par"
	note q35: "35. Dans votre carrière professionnelle, avez-vous déjà vécu, directement ou par personne interposée, une situation où l'inspecteur des impôts a reçu un paiement informel ?"
	label define q35 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q35 q35

	label variable q36 "36. Est-ce que certains cas étaient liés à une vérification générale ?"
	note q36: "36. Est-ce que certains cas étaient liés à une vérification générale ?"
	label define q36 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q36 q36

	label variable q37 "37. Est-ce que certains cas étaient liés à un contrôle sur pièces ?"
	note q37: "37. Est-ce que certains cas étaient liés à un contrôle sur pièces ?"
	label define q37 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q37 q37

	label variable q38 "38. Pensez à la dernière fois que vous avez vécu cette expérience. De combien a "
	note q38: "38. Pensez à la dernière fois que vous avez vécu cette expérience. De combien a été ce «paiement informel» en Franc CFA ? Obs : le paiement peut avoir eu lieu sous la forme d’un cadeau"

	label variable q39 "39. Grâce à ce paiement, quelle a été la réduction du redressement que l'entrepr"
	note q39: "39. Grâce à ce paiement, quelle a été la réduction du redressement que l'entreprise a dû payer à la fin ?"

	label variable q40 "40. Tricher sur les déclarations d'impôts augmente les chances de se faire contr"
	note q40: "40. Tricher sur les déclarations d'impôts augmente les chances de se faire contrôler."
	label define q40 1 "Je ne sais pas" 2 "Entièrement en désaccord" 3 "Modérément en désaccord" 4 "Neutre" 5 "Modérément d'accord" 6 "Entièrement d'accord"
	label values q40 q40

	label variable q41 "41. Lors d'une vérification générale, les inspecteurs réussissent à découvrir to"
	note q41: "41. Lors d'une vérification générale, les inspecteurs réussissent à découvrir tout le montant dissimulé par l'entreprise contrôlée."
	label define q41 1 "Je ne sais pas" 2 "Entièrement en désaccord" 3 "Modérément en désaccord" 4 "Neutre" 5 "Modérément d'accord" 6 "Entièrement d'accord"
	label values q41 q41

	label variable q42 "42. Si le chef de l'entreprise a un ami à la DGID, son entreprise sera rarement "
	note q42: "42. Si le chef de l'entreprise a un ami à la DGID, son entreprise sera rarement contrôlée."
	label define q42 1 "Je ne sais pas" 2 "Entièrement en désaccord" 3 "Modérément en désaccord" 4 "Neutre" 5 "Modérément d'accord" 6 "Entièrement d'accord"
	label values q42 q42

	label variable q43 "43. Il est difficile de tricher au Sénégal sans que la DGID le découvre."
	note q43: "43. Il est difficile de tricher au Sénégal sans que la DGID le découvre."
	label define q43 1 "Je ne sais pas" 2 "Entièrement en désaccord" 3 "Modérément en désaccord" 4 "Neutre" 5 "Modérément d'accord" 6 "Entièrement d'accord"
	label values q43 q43

	label variable q44 "44. Des contrôles choisis par un algorithme de risque sont plus justes que des c"
	note q44: "44. Des contrôles choisis par un algorithme de risque sont plus justes que des contrôles choisis directement par les inspecteurs."
	label define q44 1 "Je ne sais pas" 2 "Entièrement en désaccord" 3 "Modérément en désaccord" 4 "Neutre" 5 "Modérément d'accord" 6 "Entièrement d'accord"
	label values q44 q44

	label variable q45 "45. Nous avons fini et vous remercions pour votre temps. Aimeriez-vous ajouter q"
	note q45: "45. Nous avons fini et vous remercions pour votre temps. Aimeriez-vous ajouter quelque chose ?"

	label variable comfin "Commentaire final"
	note comfin: "Commentaire final"

*******************************************************************************
*SAVE 
*******************************************************************************	
	
	save "$wastedata/results", replace

*******************************************************************************
*******************************************************************************
*SECOND WAVE
*******************************************************************************
*******************************************************************************
* initialize Stata
clear all
set more off
set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "Enquête Fiscalité Seconde vague_WIDE.csv"
local dtafile "Enquête Fiscalité Seconde vague.dta"
local corrfile "Enquête Fiscalité Seconde vague_WIDE.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum username allows_comments duration today caseid bureau raison proprietaire adresse telephone secteur lencal nonconsa nonconsex sans_enquete_autrepr"
local text_fields2 "sans_enquete_explain q1 q1_other q2 q2_other q6 q6_other q45 comfin instanceid instancename"
local date_fields1 ""
local datetime_fields1 "submissiondate starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
*import delimited "`csvfile'", delimiter(comma) bindquote(strict) encoding(UTF-8) clear 
*import delimited "C:\Users\alipi\Dropbox\Trabalho\2017 WB\Senegal tax audits\Taxpayer Survey\Survey results\Enquête Fiscalité_WIDE2.txt", delimiter(comma) bindquote(strict) encoding(UTF-8) clear 
import delimited "$rawdata/Taxpayer Survey\Survey results/Enquête Fiscalité Seconde vague_WIDE.csv.txt", bindquote(strict) encoding(UTF-8) clear 

*******************************************************************************
*RENAME VARIABLES
*******************************************************************************

	*destring variables
	foreach v in superviseur enqueteur q3 q4 q5 q6 q7 q8 q9 q10 q11 q12 q13 q14 q15 q16 q17 q18 q19 q20 q21 q22 q23 q24 q25 q26 q27 q28 q28a q29 q29a q30 q31 q32 q33 q34 q35 q36 q37 q38 q39 q40 q41 q42 q43 q44 consent noncons sans_enquete {
	destring `v', force replace 
	}

	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable superviseur "Nom du superviseur"
	note superviseur: "Nom du superviseur"
	label define superviseur 10 "MOUSTAPHA SADIO" 20 "CHEIKH GAYE" 30 "SOULEYMANE DIALLO" 40 "MOHAMADOU LAM" 50 "OMAR SECK"
	label values superviseur superviseur

	label variable enqueteur "Nom de l'enqueteur"
	note enqueteur: "Nom de l'enqueteur"
	label define enqueteur 10 "MOUSTAPHA SADIO" 11 "ABDOULAYE DIATTA" 12 "DAOUDA SOUMARE" 13 "NAFI MBAYE" 14 "LANSANA MANE" 15 "TIDIANE MBAYE" 20 "CHEIKH GAYE" 21 "HINDOU THIAM" 22 "CHEIKH MBENGUE" 23 "NDEYE SIGA BESSANE" 24 "NOUROU FAYE" 25 "NIASSA NDIAYE" 30 "SOULEYMANE DIALLO" 31 "NDEYE AMY FAYE DENIS" 32 "SOUKEYNA LY" 33 "AMADOU LAMARANA DIALLO" 34 "MALICK LY" 35 "CHEIKH SADIBOU SECK" 40 "MOHAMADOU LAM" 41 "ABDOULAYE NIANG" 42 "IBRAHIMA TAMBA" 43 "AMADOU DIA" 44 "DIEYNABA BOUBOU TRAORE" 50 "OMAR SECK" 51 "FATOU KINE GUEYE" 52 "FILY CISSOKHO" 53 "MATAR BARRY" 54 "IBRAHIMA DIALLO"
	label values enqueteur enqueteur

	label variable id_1 "Entrez l'identifiant de l'entreprise"
	note id_1: "Entrez l'identifiant de l'entreprise"

	label variable id_2 "Confirmez l'identifiant de l'entreprise"
	note id_2: "Confirmez l'identifiant de l'entreprise"

	label variable consent "Votre entreprise \${RAISON} situé à \${ADRESSE} dont le telephone est \${TELEPHO"
	note consent: "Votre entreprise \${RAISON} situé à \${ADRESSE} dont le telephone est \${TELEPHONE} et qui s'active dans le(la) \${SECTEUR} a été sélectionnée pour répondre à une enquête sur la fiscalité au Sénégal. Cette étude est menée par des chercheurs associés à la Banque Mondiale, et son but est d'évaluer l'expérience des entreprises sénégalaises avec l'administration fiscale. Nous vous assurons que vos informations seront traitées avec la plus grande confidentialité. Les réponses individuelles ne seront jamais partagées avec la DGID. L'étude pourra servir à fournir des recommandations à l'administration fiscale pour améliorer sa relation avec les contribuables. Notre conversation aujourd'hui ne prendra pas plus de 10-15 minutes, et nous vous remercions de votre temps ! Pour toute question, vous aurez le droit de ne pas répondre si vous le souhaitez. Êtes-vous d'accord pour participer à cet entretien sous ces conditions ?"
	label define consent 1 "Oui" 2 "Non / Refus" 3 "Sans enquête / Envoyer le récapitulatif journalier"
	label values consent consent

	label variable noncons "Enqueteur : Pour l'enquête n'as pas eu lieu ? (Motif Refus)"
	note noncons: "Enqueteur : Pour l'enquête n'as pas eu lieu ? (Motif Refus)"
	label define noncons 1 "Répondant cible refusé (initial)" 2 "Aucun repondant disponible pendant toute la période d'enquête" 3 "Refus final de participer" 4 "Répondant cible Malade" -77 "Autre à préciser"
	label values noncons noncons

	label variable nonconsa "Autre raison pour laquelle l'enquête n'as pas eu lieu"
	note nonconsa: "Autre raison pour laquelle l'enquête n'as pas eu lieu"

	label variable nonconsex "Compléter ou donner plus de précisions à ces informations si besoin."
	note nonconsex: "Compléter ou donner plus de précisions à ces informations si besoin."

	label variable sans_enquete "Enqueteur : Pour l'enquête n'as pas eu lieu ? (Motif Envoi récapitulatif journal"
	note sans_enquete: "Enqueteur : Pour l'enquête n'as pas eu lieu ? (Motif Envoi récapitulatif journalier)"
	label define sans_enquete 1 "A pris un RV (preciser)" 2 "Repondant cible absent temporaire" 3 "Pas de Contact/Mauvais Contact" 4 "Répondant cible non disponible temporairement" 5 "Aucun contact avec quiconque au téléphone après plusieurs tentatives" 6 "Entreprise non-trouvée après plusieurs recherche" 7 "Entreprise fermée/ aucun contact possible" -77 "Autre à préciser"
	label values sans_enquete sans_enquete

	label variable sans_enquete_autrepr "Autre raison pour laquelle l'enquête n'as pas eu lieu"
	note sans_enquete_autrepr: "Autre raison pour laquelle l'enquête n'as pas eu lieu"

	label variable sans_enquete_explain "Compléter ou donner plus de précisions à ces informations si besoin."
	note sans_enquete_explain: "Compléter ou donner plus de précisions à ces informations si besoin."

	label variable tel_used "Numéro de téléphone avec lequel l'entreprise a été jointe"
	note tel_used: "Numéro de téléphone avec lequel l'entreprise a été jointe"

	label variable q1 "1. Quelle est votre fonction dans l'entreprise ? Choisissez l'option qui mieux d"
	note q1: "1. Quelle est votre fonction dans l'entreprise ? Choisissez l'option qui mieux décrit votre fonction."

	label variable q1_other "Specify other."
	note q1_other: "Specify other."

	label variable q2 "2. Pouvez-vous choisir sur cette liste le secteur d'activité principal de votre "
	note q2: "2. Pouvez-vous choisir sur cette liste le secteur d'activité principal de votre entreprise ?"

	label variable q2_other "Specify other."
	note q2_other: "Specify other."

	label variable q3 "3. Quel était le nombre total d'employés de l'entreprise à temps plein en décemb"
	note q3: "3. Quel était le nombre total d'employés de l'entreprise à temps plein en décembre 2019 ?"

	label variable q4 "4. Quel était le nombre total d'employés de l'entreprise à temps partiel en déce"
	note q4: "4. Quel était le nombre total d'employés de l'entreprise à temps partiel en décembre 2019 ?"

	label variable q5 "5. Quel pourcentage de votre chiffre d'affaires percevez-vous sous forme de paie"
	note q5: "5. Quel pourcentage de votre chiffre d'affaires percevez-vous sous forme de paiement en cash/espèces ? Obs : par « paiements en espèces » on considère seulement les paiements en billets ou monnaies."

	label variable q6 "6. Quelle est la situation de votre entreprise suite à la situation économique c"
	note q6: "6. Quelle est la situation de votre entreprise suite à la situation économique créée par la pandémie ?"

	label variable q6_other "Specify other."
	note q6_other: "Specify other."

	label variable q7 "7. Par rapport au chiffre d'affaires perçu entre avril et juin 2019 (deuxième tr"
	note q7: "7. Par rapport au chiffre d'affaires perçu entre avril et juin 2019 (deuxième trimestre), combien votre chiffre d'affaires entre avril et juin 2020 a-t-il changé – baisse ou augmentation en pourcentage ?"
	label define q7 999 "Pas de réponse" 1 "Il a baissé entre 80% et 100%" 2 "Il a baissé entre 50% et 80%" 3 "Il a baissé entre 20% et 50%" 4 "Il a baissé entre 0% et 20%" 5 "Il n'a pas beaucoup changé" 6 "Il a augmenté entre 0 et 20%" 7 "Il a augmenté entre 20% et 50%" 8 "Il a augmenté entre 50% et 80%" 9 "Il a augmenté plus de 80%"
	label values q7 q7

	label variable q8 "8. Report de loyers ou factures d'électricité/eau/téléphone"
	note q8: "8. Report de loyers ou factures d'électricité/eau/téléphone"
	label define q8 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q8 q8

	label variable q9 "9. Report de paiement de dettes, intérêts, ou renégociation de dettes"
	note q9: "9. Report de paiement de dettes, intérêts, ou renégociation de dettes"
	label define q9 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q9 q9

	label variable q10 "10. Crédit bonifié ou garanti par l'Etat à travers les banques"
	note q10: "10. Crédit bonifié ou garanti par l'Etat à travers les banques"
	label define q10 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q10 q10

	label variable q11 "11. Crédit sans garanti de l'Etat"
	note q11: "11. Crédit sans garanti de l'Etat"
	label define q11 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q11 q11

	label variable q12 "12. Remise de paiement d'impôts en guise de subvention pour le paiement des sala"
	note q12: "12. Remise de paiement d'impôts en guise de subvention pour le paiement des salaires"
	label define q12 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q12 q12

	label variable q13 "13. Remise de dette fiscale constatée au 31 décembre 2019"
	note q13: "13. Remise de dette fiscale constatée au 31 décembre 2019"
	label define q13 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q13 q13

	label variable q14 "14. Subventions directes"
	note q14: "14. Subventions directes"
	label define q14 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q14 q14

	label variable q15 "15. Selon votre expérience, les vérifications générales ont lieu tous les… combi"
	note q15: "15. Selon votre expérience, les vérifications générales ont lieu tous les… combien d'années ?"
	label define q15 999 "Je ne sais pas" 1 "Tous les ans." 2 "Tous les deux ans" 3 "Tous les trois ans" 4 "Tous les quatre ans" 5 "Tous les cinq ans" 6 "Tous les six ans" 7 "Tous les sept ans" 8 "Tous les huit ans" 9 "Tous les neuf ans" 10 "Tous les dix ans ou plus rarement que ça"
	label values q15 q15

	label variable q16 "16. Selon votre expérience, les contrôles sur pièces ont lieu tous le… combien d"
	note q16: "16. Selon votre expérience, les contrôles sur pièces ont lieu tous le… combien d'années ?"
	label define q16 999 "Je ne sais pas" 1 "Tous les ans." 2 "Tous les deux ans" 3 "Tous les trois ans" 4 "Tous les quatre ans" 5 "Tous les cinq ans" 6 "Tous les six ans" 7 "Tous les sept ans" 8 "Tous les huit ans" 9 "Tous les neuf ans" 10 "Tous les dix ans ou plus rarement que ça"
	label values q16 q16

	label variable q17 "17. Le dernier contrôle remonte à longtemps"
	note q17: "17. Le dernier contrôle remonte à longtemps"
	label define q17 0 "Je ne sais pas" 1 "Réduit les chances" 2 "Cela n'a pas d'importance" 3 "Augmente les chances"
	label values q17 q17

	label variable q18 "18. Le chiffre d'affaires déclaré par l'entreprise est très bas"
	note q18: "18. Le chiffre d'affaires déclaré par l'entreprise est très bas"
	label define q18 0 "Je ne sais pas" 1 "Réduit les chances" 2 "Cela n'a pas d'importance" 3 "Augmente les chances"
	label values q18 q18

	label variable q19 "19. Le chiffre d'affaires déclaré par l'entreprise est très élevé"
	note q19: "19. Le chiffre d'affaires déclaré par l'entreprise est très élevé"
	label define q19 0 "Je ne sais pas" 1 "Réduit les chances" 2 "Cela n'a pas d'importance" 3 "Augmente les chances"
	label values q19 q19

	label variable q20 "20. Le profit déclaré est très bas"
	note q20: "20. Le profit déclaré est très bas"
	label define q20 0 "Je ne sais pas" 1 "Réduit les chances" 2 "Cela n'a pas d'importance" 3 "Augmente les chances"
	label values q20 q20

	label variable q21 "21. Le profit déclaré est très élevé"
	note q21: "21. Le profit déclaré est très élevé"
	label define q21 0 "Je ne sais pas" 1 "Réduit les chances" 2 "Cela n'a pas d'importance" 3 "Augmente les chances"
	label values q21 q21

	label variable q22 "22. L'entreprise fait beaucoup d'importations ou d'exportations"
	note q22: "22. L'entreprise fait beaucoup d'importations ou d'exportations"
	label define q22 0 "Je ne sais pas" 1 "Réduit les chances" 2 "Cela n'a pas d'importance" 3 "Augmente les chances"
	label values q22 q22

	label variable q23 "23. Pensez-vous que la DGID se base principalement sur des recoupements de donné"
	note q23: "23. Pensez-vous que la DGID se base principalement sur des recoupements de données entre différents contribuables afin de choisir les contrôles ? obs : il s'agit de comparaisons des données déclarés par l'entreprise avec d'autres données, comme par exemple des données bancaires ou des transactions"
	label define q23 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q23 q23

	label variable q24 "24. Pensez-vous que la DGID utilise des algorithmes de risque sophistiqués afin "
	note q24: "24. Pensez-vous que la DGID utilise des algorithmes de risque sophistiqués afin de détecter les entreprises qui trichent ?"
	label define q24 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q24 q24

	label variable q25 "25. Lorsque des entreprises de votre secteur d'activité économique sont contrôlé"
	note q25: "25. Lorsque des entreprises de votre secteur d'activité économique sont contrôlées, est-ce que vous vous préparez à être contrôlé aussi ?"
	label define q25 0 "Je ne sais pas" 1 "Non" 2 "Oui" 3 "Je ne suis pas au courant quand d'autres entreprises sont contrôlées"
	label values q25 q25

	label variable q26 "26. Lorsque des entreprises de la même taille que la vôtre sont contrôlées, est-"
	note q26: "26. Lorsque des entreprises de la même taille que la vôtre sont contrôlées, est-ce que vous vous préparez à être contrôlé aussi ?"
	label define q26 0 "Je ne sais pas" 1 "Non" 2 "Oui" 3 "Je ne suis pas au courant quand d'autres entreprises sont contrôlées"
	label values q26 q26

	label variable q27 "27. Lorsque des entreprises situées près de vos locaux sont contrôlées, est-ce q"
	note q27: "27. Lorsque des entreprises situées près de vos locaux sont contrôlées, est-ce que vous vous préparez à être contrôlé aussi ?"
	label define q27 0 "Je ne sais pas" 1 "Non" 2 "Oui" 3 "Je ne suis pas au courant quand d'autres entreprises sont contrôlées"
	label values q27 q27

	destring q28, force replace
	label variable q28 "28. A quelle année remonte le dernier contrôle sur pièces dont votre entreprise "
	note q28: "28. A quelle année remonte le dernier contrôle sur pièces dont votre entreprise a fait objet ?"
	label define q28 0 "D'après moi l'entreprise n'a jamais fait objet d'un contrôle sur pièce" 1 "Je ne sais pas, mais l'entreprise a fait objet d'un contrôle sur pièce" 2 "Année"
	label values q28 q28

	label variable q28a "Preciser l'année a laquelle remonte le dernier contrôle sur pièces dont votre en"
	note q28a: "Preciser l'année a laquelle remonte le dernier contrôle sur pièces dont votre entreprise a fait objet"

	label variable q29 "29. A quelle année remonte la dernière Vérification Générale dont votre entrepri"
	note q29: "29. A quelle année remonte la dernière Vérification Générale dont votre entreprise a fait objet ?"
	label define q29 0 "D'après moi l'entreprise n'a jamais fait objet d'une vérification générale" 1 "Je ne sais pas, mais l'entreprise a fait objet d'une vérification générale" 2 "Année"
	label values q29 q29

	label variable q29a "Preciser l'année a laquelle remonte la dernière Vérification Générale dont votre"
	note q29a: "Preciser l'année a laquelle remonte la dernière Vérification Générale dont votre entreprise a fait objet"

	label variable q30 "30. Combien de semaines a duré cette vérification générale entre le premier et l"
	note q30: "30. Combien de semaines a duré cette vérification générale entre le premier et le dernier contact ? Obs si nécessaire : le premier contact est le moment où l'entreprise a été informée par la DGID qu'elle était l'objet d'un contrôle. Le dernier contact est la dernière question ou réponse de la DGID dans le cadre du contrôle, ou le moment de la réception d'un titre de perception."

	label variable q31 "31. ...connaissances techniques ?"
	note q31: "31. ...connaissances techniques ?"

	label variable q32 "32. ...honnêteté ?"
	note q32: "32. ...honnêteté ?"

	label variable q33 "33. ...rapidité/efficacité ?"
	note q33: "33. ...rapidité/efficacité ?"

	label variable q34 "34. Dans l'ensemble des contrôles faits dans des entreprises comme la vôtre, que"
	note q34: "34. Dans l'ensemble des contrôles faits dans des entreprises comme la vôtre, quel pourcentage de cas finissent par avoir un paiement informel fait aux inspecteurs, selon votre avis personnel ?"

	label variable q35 "35. Dans votre carrière professionnelle, avez-vous déjà vécu, directement ou par"
	note q35: "35. Dans votre carrière professionnelle, avez-vous déjà vécu, directement ou par personne interposée, une situation où l'inspecteur des impôts a reçu un paiement informel ?"
	label define q35 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q35 q35

	label variable q36 "36. Est-ce que certains cas étaient liés à une vérification générale ?"
	note q36: "36. Est-ce que certains cas étaient liés à une vérification générale ?"
	label define q36 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q36 q36

	label variable q37 "37. Est-ce que certains cas étaient liés à un contrôle sur pièces ?"
	note q37: "37. Est-ce que certains cas étaient liés à un contrôle sur pièces ?"
	label define q37 0 "Je ne sais pas" 1 "Non" 2 "Oui"
	label values q37 q37

	label variable q38 "38. Pensez à la dernière fois que vous avez vécu cette expérience. De combien a "
	note q38: "38. Pensez à la dernière fois que vous avez vécu cette expérience. De combien a été ce «paiement informel» en Franc CFA ? Obs : le paiement peut avoir eu lieu sous la forme d'un cadeau"

	label variable q39 "39. Grâce à ce paiement, quelle a été la réduction du redressement que l'entrepr"
	note q39: "39. Grâce à ce paiement, quelle a été la réduction du redressement que l'entreprise a dû payer à la fin ?"

	label variable q40 "40. Tricher sur les déclarations d'impôts augmente les chances de se faire contr"
	note q40: "40. Tricher sur les déclarations d'impôts augmente les chances de se faire contrôler."
	label define q40 1 "Je ne sais pas" 2 "Entièrement en désaccord" 3 "Modérément en désaccord" 4 "Neutre" 5 "Modérément d'accord" 6 "Entièrement d'accord"
	label values q40 q40

	label variable q41 "41. Lors d'une vérification générale, les inspecteurs réussissent à découvrir to"
	note q41: "41. Lors d'une vérification générale, les inspecteurs réussissent à découvrir tout le montant dissimulé par l'entreprise contrôlée."
	label define q41 1 "Je ne sais pas" 2 "Entièrement en désaccord" 3 "Modérément en désaccord" 4 "Neutre" 5 "Modérément d'accord" 6 "Entièrement d'accord"
	label values q41 q41

	label variable q42 "42. Si le chef de l'entreprise a un ami à la DGID, son entreprise sera rarement "
	note q42: "42. Si le chef de l'entreprise a un ami à la DGID, son entreprise sera rarement contrôlée."
	label define q42 1 "Je ne sais pas" 2 "Entièrement en désaccord" 3 "Modérément en désaccord" 4 "Neutre" 5 "Modérément d'accord" 6 "Entièrement d'accord"
	label values q42 q42

	label variable q43 "43. Il est difficile de tricher au Sénégal sans que la DGID le découvre."
	note q43: "43. Il est difficile de tricher au Sénégal sans que la DGID le découvre."
	label define q43 1 "Je ne sais pas" 2 "Entièrement en désaccord" 3 "Modérément en désaccord" 4 "Neutre" 5 "Modérément d'accord" 6 "Entièrement d'accord"
	label values q43 q43

	label variable q44 "44. Des contrôles choisis par un algorithme de risque sont plus justes que des c"
	note q44: "44. Des contrôles choisis par un algorithme de risque sont plus justes que des contrôles choisis directement par les inspecteurs."
	label define q44 1 "Je ne sais pas" 2 "Entièrement en désaccord" 3 "Modérément en désaccord" 4 "Neutre" 5 "Modérément d'accord" 6 "Entièrement d'accord"
	label values q44 q44

	label variable q45 "45. Nous avons fini et vous remercions pour votre temps. Aimeriez-vous ajouter q"
	note q45: "45. Nous avons fini et vous remercions pour votre temps. Aimeriez-vous ajouter quelque chose ?"

	label variable comfin "Commentaire final"
	note comfin: "Commentaire final"

*******************************************************************************
*SAVE 
*******************************************************************************	
	
	save "$wastedata/results_deuxiemevague", replace
	
*******************************************************************************
*******************************************************************************
*CLEAN AND CONSOLIDATE DATASETS
*******************************************************************************
*******************************************************************************

********************************************************************************
*Obtain the code of the firm in the survey 
********************************************************************************
use "$rawdata\Programme_2021\data_proc\finaldataset", clear 
	//Originally "$generaldata\Programme_2021\data_proc\finaldataset"
clonevar ninea_str = ninea
tostring ninea_str, replace force
gen l = length(ninea_str)
tostring l, gen(l_str)

	gen firm_code = l_str  if l == 7 
	replace firm_code = l_str + "0" if l == 6 
	replace firm_code = l_str + "00" if l == 5 
	replace firm_code = l_str + "000" if l == 4 	

	label var firm_code "Code de l'entreprise"

*Decode the firm's ID based on the rule established for anonymization. 	
forvalues i = 1/8 {
	replace firm_code = firm_code + "8" if substr(ninea_str, `i', 1) == "0" 
	replace firm_code = firm_code + "5" if substr(ninea_str, `i', 1) == "1" 
	replace firm_code = firm_code + "6" if  substr(ninea_str, `i', 1) == "2" 
	replace firm_code = firm_code + "2" if  substr(ninea_str, `i', 1) == "3"
	replace firm_code = firm_code + "3" if  substr(ninea_str, `i', 1) == "4"
	replace firm_code = firm_code + "1" if  substr(ninea_str, `i', 1) == "5"
	replace firm_code = firm_code + "0" if  substr(ninea_str, `i', 1) == "6"
	replace firm_code = firm_code + "4" if  substr(ninea_str, `i', 1) == "7"
	replace firm_code = firm_code + "9" if  substr(ninea_str, `i', 1) == "8" 
	replace firm_code = firm_code + "7"	if  substr(ninea_str, `i', 1) == "9"
}

keep ninea firm_code raison center
bys firm_code : gen n = _n
keep if n == 1
drop n

tempfile crossover
sa `crossover', replace 

********************************************************************************
*Read Original Survey sample documents 
********************************************************************************	
import excel "$rawdata/Taxpayer Survey/Sample/Echantillon Enquête 2020 Deuxième Vague toutes entreprises.xlsx", clear firstrow

gen firm_code = Codedelentreprise 
gen second = 1 

bys firm_code: gen n = _n
drop if n > 1 
drop n


tempfile second
sa `second', replace 

import excel "$rawdata/Taxpayer Survey/Sample/Echantillon Enquête 2020 v2.xlsx", clear firstrow

gen firm_code = Codedelentreprise 

bys firm_code: gen n = _n
drop if n > 1 
drop n

append using `second'

bys firm_code: gen n = _n
drop if n > 1 
drop n

keep firm_code Prioritaire second 
gen sample = 1 

tempfile sample
sa `sample', replace 

********************************************************************************
*Read Survey results
********************************************************************************	
use "$wastedata\results_deuxiemevague", clear 

gen deuxiemevague = 1 

append using "$wastedata\results", force

replace deuxiemevague = 0 if deuxiemevague == . 

graph set window fontface "Times New Roman"

*******************************************************************************
*Analyse the execution rate of the survey 
*******************************************************************************
gen demarre = 1 

gen realise = 0 
foreach c in q15 q16 q17 q18 q19 q20 q21 q22 q23 q24 q30 q31 q32 q33 q34 q35 q36 q37 q38 q39 q40 q41 q42 q43 q44 {
replace realise = 1 if `c' != . 
}

*Drop duplicates keeping the row that contains data
gsort id_1 -q33
bys id_1: egen realisequestion = max(realise)
drop if realisequestion == 1 & realise == 0 
bys id_1: gen ntimes = _N
bys id_1: gen ntimes2 = _n
keep if ntimes2 == 1
drop ntimes* realisequestion

gen date = substr(starttime, 1, strpos(starttime, " ") - 1)
replace date = trim(date)

gen month = ""
replace month = "9" if strpos(date, "/09/2020") > 0 | strpos(date, "/set/2020") > 0
replace month = "10" if strpos(date, "/10/2020") > 0 | strpos(date, "/out/2020") > 0
replace month = "2" if strpos(date, "/02/2021") > 0 | strpos(date, "/fev/2021") > 0
replace month = "3" if strpos(date, "/03/2021") > 0 | strpos(date, "/mar/2021") > 0


destring month, replace 

gen day = ""
replace day = subinstr(date, "/09/2020", "", .) if strpos(date, "/09/2020") > 0
replace day = subinstr(date, "/set/2020", "", .) if strpos(date, "/set/2020") > 0
replace day = subinstr(date, "/10/2020", "", .) if strpos(date, "/10/2020") > 0
replace day = subinstr(date, "/out/2020", "", .) if strpos(date, "/out/2020") > 0
replace day = subinstr(date, "/02/2021", "", .) if strpos(date, "/02/2021") > 0
replace day = subinstr(date, "/fev/2021", "", .) if strpos(date, "/fev/2021") > 0
replace day = subinstr(date, "/03/2021", "", .) if strpos(date,"/03/2021") > 0
replace day = subinstr(date, "/mar/2021", "", .) if strpos(date, "/mar/2021") > 0

destring day, replace 

gen date2 = mdy(month, day, 2020)
drop date
rename date2 date 
format date %td

clonevar firm_code = id_1
tostring firm_code, replace force 

merge 1:1 firm_code using `crossover'
drop if _merge == 2
drop _merge 

merge 1:1 firm_code using `sample'
drop _merge 

*****
*Statistics 
*****
replace realise = 0 if realise == . 
tab Priorit, sum(realise)

*******************************************************************************
*Graphs for the responses 
*******************************************************************************

keep ninea id_1 bureau raison raisonsociale deuxiemevague telephone bureau proprietaire q1 q2 q3 q4 q5 q6 q7 q8 q9 q10 q11 q12 q13 q14 q15 q16 q17 q18 q19 q20 q21 q22 q23 q24 q25 q26 q27 q28 q28a q29 q29a q30 q31 q32 q33 q34 q35 q36 q37 q38 q39 q40 q41 q42 q43 q44 q45 *other enqueteur deuxiemevague realise

replace q1 = "6" if q1 == "other"
replace q2 = "6" if q2 == "other"
destring q1, replace force
destring q2, replace force

label define q1  1 "Directeur/PDG" 2 "Comptable interne" 3 "Comptable externe" 4 "Directeur financier" 5 "Employé" 6 "Autres" 7 "Assistant administratif", replace
label values q1 q1

*Correct q1 based on "autres"
replace q1_other = lower(q1_other)

replace q1 = 1 if strpos(q1_other, "directrice") > 0 | strpos(q1_other, "directeur") > 0 | strpos(q1_other, "président") > 0 | strpos(q1_other, "president") > 0  | strpos(q1_other, "entrepreneur") > 0  | strpos(q1_other, "responsable administratif") > 0  | strpos(q1_other, "gérant") > 0  | strpos(q1_other, "chef de service administratif") > 0  | strpos(q1_other, "charge des affaires administratives") > 0  | strpos(q1_other, "chef du personnel") > 0  | strpos(q1_other, "gestionnaire") > 0 | strpos(q1_other, "administrateur") > 0 | strpos(q1_other, "responsable") > 0  | strpos(q1_other, "responsabe") > 0 

replace q1 = 2 if strpos(q1_other, "omptable") > 0 | strpos(q1_other, "conseiller") > 0 | strpos(q1_other, "comptable") > 0    

replace q1 = 3 if strpos(q1_other, "consultant") > 0 | strpos(q1_other, "conseiller") > 0 | strpos(q1_other, "comptable") > 0  | strpos(q1_other, "responsable administratif") > 0  | strpos(q1_other, "gérant") > 0  

replace q1 = 4 if strpos(q1_other, "tresorier") > 0 | strpos(q1_other, "le responsable financier") > 0  | strpos(q1_other, "technicien en audit et fiscalité") > 0 

replace q1 = 7 if strpos(q1_other, "ssistan") > 0 | strpos(q1_other, "secrétaire") > 0  | strpos(q1_other, "secrÉtaire") > 0 | q1_other == "technicien" | strpos(q1_other, "secretaire") > 0 | strpos(q1_other, "responsable de l administrateur") > 0

#delim ;
label define q2 0  "Agriculture" 1 "Pêche" 2 "Extraction" 3 "Services financiers" 
4 "Services immobiliers"
5 "Services comptables et juridiques"
6 "Consulting"
7 "BTP et ingénierie civile"
8 "Services de santé"
9 "Industrie"
10 "Administration publique"
11 "Commerce (détail)"
12 "Transport"
13 "Autres"
;
#delim cr

label values q2 q2 

#delim ;
label define q6 999 "Pas de réponse"
1 "Mon entreprise continue ses activités malgré la situation"
2 "Mon entreprise est fermée pour le moment mais va ouvrir une fois que la situation s'améliore"
3 "Mon entreprise a été rachetée par une autre entreprise"
4 "Mon entreprise a été clôturée."
5 "Autres"
;
#delim cr
label values q6 q6

gen id = 1 

tostring ninea, force replace 
order ninea id_1 bureau raison raisonsociale

	*Cleaned raisonsociale
	replace raisonsociale = ustrupper( ustrregexra( ustrnormalize(raisonsociale, "nfd" ) , "\p{Mark}", "" ) )	
	replace raisonsociale = trim(raisonsociale)
	replace raisonsociale = subinstr(raisonsociale, "<", "", .)
	replace raisonsociale = subinstr(raisonsociale, ">", "", .)	
	replace raisonsociale = subinstr(raisonsociale, ">", "", .)	
	replace raisonsociale = subinstr(raisonsociale, "(", "", .)	
	replace raisonsociale = subinstr(raisonsociale, ")", "", .)		
	replace raisonsociale = subinstr(raisonsociale,`"""', "", .)	
	replace raisonsociale = subinstr(raisonsociale,`"-"', "", .)			
	replace raisonsociale = subinstr(raisonsociale, "  ", " ", .)	
	replace raisonsociale = subinstr(raisonsociale, "  ", " ", .)	
	replace raisonsociale = subinstr(raisonsociale, "L' ", "", .)	
	replace raisonsociale = subinstr(raisonsociale, "L'", "", .)			
	replace raisonsociale = subinstr(raisonsociale, "'", "", .)		
	replace raisonsociale = trim(raisonsociale)
	
	*Some manual inputs
	quietly do "$code\AUX Manually input nineas.do"
	recast str2045 raisonsociale 

	preserve

	    use "$wastedata/RetrievedNineaAuditsfinal", clear
			//Originally "$generaldata/Programme_2019/waste/RetrievedNineaAuditsfinal"
		rename Audits_raisonsociale raisonsociale
		replace raisonsociale = ustrupper( ustrregexra( ustrnormalize(raisonsociale, "nfd" ) , "\p{Mark}", "" ) )	
		replace raisonsociale = trim(raisonsociale)
		replace raisonsociale = subinstr(raisonsociale, "<", "", .)
		replace raisonsociale = subinstr(raisonsociale, ">", "", .)	
		replace raisonsociale = subinstr(raisonsociale, ">", "", .)	
		replace raisonsociale = subinstr(raisonsociale, "(", "", .)	
		replace raisonsociale = subinstr(raisonsociale, ")", "", .)		
		replace raisonsociale = subinstr(raisonsociale,`"""', "", .)	
		replace raisonsociale = subinstr(raisonsociale,`"-"', "", .)			
		replace raisonsociale = subinstr(raisonsociale, "  ", " ", .)	
		replace raisonsociale = subinstr(raisonsociale, "  ", " ", .)	
		replace raisonsociale = subinstr(raisonsociale, "L' ", "", .)	
		replace raisonsociale = subinstr(raisonsociale, "L'", "", .)			
		replace raisonsociale = subinstr(raisonsociale, "'", "", .)		
		replace raisonsociale = trim(raisonsociale)
		
		bys raisonsociale: gen n = _n
		keep if n == 1
		drop n 
		
		tostring ninea, replace force
		
		tempfile listmatchit
		sa `listmatchit', replace 
	   
	restore 
	
	merge m:1 raisonsociale using `listmatchit'
	drop if _merge == 2 
	drop _merge
	
	clonevar firmid = ninea
	drop raisonsociale 

	rename bureau bureau_survey

	gsort firmid -realise
	by firmid: gen n = _n 
	keep if n == 1 
	drop n
	
sa "$analysisdata\taxpayersurvey", replace 	