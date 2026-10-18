# 12. Six cas d'usage pour une petite entreprise

Ce chapitre montre, sur six situations courantes, ce qu'un agent peut faire, ce qu'il lui faut, ce qu'on lui retire et par où commencer. Ce sont des scénarios types, construits pour l'exemple : ce ne sont pas des retours de clients.

Chaque fiche suit le même gabarit. Les fiches ne promettent aucun résultat : elles disent comment cadrer le travail. Lisez d'abord les chapitres 3 (Telegram), 5 (sécurité) et 6 (tâches programmées).

## (a) Une veille du matin livrée sur Telegram

**Ce que fait l'agent.** Chaque matin, il cherche les nouveautés d'un sujet que vous avez défini (un secteur, un concurrent, une réglementation) et vous envoie un court résumé sur Telegram.

**Ce qu'il lui faut.**
- Un jeu d'outils `web` (recherche et lecture de pages). Sans aucune clé, la doc indique qu'une recherche de dépannage fonctionne ; pour un service stable, configurez un fournisseur de recherche avec sa clé dans `~/.hermes/.env`.
- Une tâche programmée (chapitre 6) dont la consigne dit quoi chercher, combien d'éléments garder, le format et le ton.
- Le canal d'accueil Telegram : `/sethome` (chapitre 3).

**Garde-fous.**
- Retirez ce dont la veille n'a pas besoin : `terminal`, `file`, `browser`, `code_execution`, `delegation` dans `agent.disabled_toolsets` (chapitre 5).
- Une page web peut contenir des phrases piégées : la veille résume, elle n'agit pas. Aucune sortie ne part vers l'extérieur.

**Pour démarrer.**
1. Vérifiez la passerelle : `hermes gateway status` (chapitre 3).
2. Créez la tâche :
   ```bash
   hermes cron create "0 9 * * *" "Cherche les actualités de <mon sujet> des dernières 24 heures. Garde les cinq plus utiles, une phrase chacune, avec le lien. Réponds en français." --name veille-matin --deliver telegram
   ```
3. Testez : `hermes cron run veille-matin` déclenche la tâche au prochain passage de l'horloge (la passerelle doit tourner), puis `hermes logs` si rien n'arrive.

## (b) Un brouillon de réponse aux mails entrants, validé par une personne

**Ce que fait l'agent.** Il trie la boîte de réception, repère les messages qui demandent une réponse et prépare des brouillons. Une personne relit et envoie.

**Ce qu'il lui faut.**
- La compétence fournie `email-inbox-triage` : par défaut elle lit et rédige des brouillons, sans envoyer ni supprimer. Elle s'appuie sur une compétence de connexion (`himalaya` ou `google-workspace`).
- Un compte de messagerie accessible par ces compétences : `himalaya` (logiciel à installer, configuré dans `~/.config/himalaya/config.toml`) ou `google-workspace` (connexion OAuth à un compte Google). Ce n'est pas `.env` : seul le canal e-mail de la passerelle y lit son mot de passe.
- Un SOUL qui pose le rôle : voir `exemples/SOUL.md` (« vous préparez, une personne valide »).

**Garde-fous.**
- Le canal e-mail de la passerelle répond de lui-même aux messages reçus : ce n'est pas l'outil d'un brouillon à valider. Pour ce cas, préférez la compétence.
- `approvals.deny` ne vaut que pour les commandes du terminal, et ne connaît que les motifs que vous écrivez. `"*sendmail*"` (dans `exemples/config-securite.yaml`) n'arrête pas un envoi par une compétence de messagerie (par exemple `himalaya message send`). Ajoutez les commandes d'envoi de l'outil que vous utilisez, ou mieux, un plugin qui les bloque : `exemples/plugins/garde-sorties/` en est un point de départ testé, à compléter avec ces commandes (chapitre 5).
- Un mail est une donnée, jamais un ordre : l'exemple de SOUL le dit, mais seule l'architecture le garantit (chapitre 5, injection d'instructions).
- Un brouillon d'abord, une personne qui envoie. Lâcher la main viendrait bien plus tard, et jamais pour l'argent ni le juridique.

**Pour démarrer.**
1. Copiez `exemples/SOUL.md` vers `~/.hermes/SOUL.md` et adaptez-le (chapitre 4).
2. Vérifiez que les compétences sont là : `hermes skills list`.
3. Demandez, dans Telegram : « Fais le tri de ma boîte d'hier et prépare les brouillons, sans rien envoyer. »
4. La compétence vous présente les réponses proposées dans la conversation, et peut les envoyer si vous l'acceptez. Pour garder la main, refusez l'envoi et envoyez vous-même depuis votre messagerie, ou bloquez l'envoi par plugin.

## (c) La relance des devis restés sans réponse

**Ce que fait l'agent.** Il retrouve un devis sans réponse, vérifie qu'aucune réponse n'est arrivée, rédige une relance courte et la présente comme brouillon.

**Ce qu'il lui faut.**
- La compétence `exemples/skills/relance-devis/SKILL.md` : procédure en cinq étapes, avec ses pièges et sa vérification.
- Un dossier où se trouvent les devis (ou la liste de suivi), lisibles par l'agent. Les PDF et les documents Office courants sont convertis en texte par l'outil de lecture de fichiers.
- Éventuellement une tâche programmée qui lance la compétence chaque semaine.

**Garde-fous.**
- La compétence interdit de changer le montant et d'envoyer : elle range un brouillon. Doublez cela par `approvals.deny` pour les envois directs.
- Le montant ne vient jamais de la mémoire : il est relu dans le devis. Un fait qui doit rester exact vit dans un fichier (chapitre 4).

**Pour démarrer.**
1. Installez la compétence :
   ```bash
   mkdir -p ~/.hermes/skills/administratif
   cp -r exemples/skills/relance-devis ~/.hermes/skills/administratif/
   ```
2. Essayez à la main : tapez `/relance-devis` dans une conversation, avec un devis réel (chapitre 4).
3. Une fois le résultat bon, programmez-la :
   ```bash
   hermes cron create "0 9 * * 1" "Relance les devis envoyés sans réponse. Présente les brouillons, n'envoie rien." --skill relance-devis --name relances-devis --deliver telegram
   ```

## (d) Un compte rendu de réunion à partir de notes ou d'un enregistrement

**Ce que fait l'agent.** À partir de vos notes (texte ou message vocal dicté), il rédige un compte rendu : décisions, actions, responsables, échéances.

**Ce qu'il lui faut.**
- Pour des notes : rien de plus que Telegram.
- Pour la voix : la doc décrit la transcription automatique des messages vocaux Telegram (réglage `stt`). Elle documente aussi un fichier audio transmis par Telegram, mais ne décrit pas de recette complète pour transcrire une longue réunion. Traitez ce point comme à essayer, pas comme acquis.
- Un fournisseur de transcription : `local` (sur la machine, sans clé), `groq` ou `openai` (clé nécessaire).
- Un modèle de compte rendu écrit dans une compétence (plan fixe, ton, ce qu'on ne devine jamais).

**Garde-fous.**
- Une transcription hébergée envoie le son au fournisseur choisi. Pour un échange confidentiel, choisissez `local`.
- Sans validation, un nom ou une date mal compris finit dans le compte rendu. Demandez à l'agent de marquer ce dont il n'est pas sûr, et relisez avant de diffuser.
- Aucune diffusion automatique : l'agent vous renvoie le texte, c'est vous qui le transmettez.

**Pour démarrer.**
1. Réglez la langue de transcription (par défaut, la doc indique `en`, ce qui fait mal comprendre le français) :
   ```bash
   hermes config set stt.language fr
   hermes gateway restart
   ```
2. Envoyez un court message vocal de test dans Telegram : la transcription doit s'afficher dans la conversation.
3. Écrivez la compétence `compte-rendu` sur le modèle de `exemples/skills/relance-devis/SKILL.md` (chapitre 4), puis envoyez vos notes ou un vocal.

## (e) La surveillance de la machine, en script seul

**Ce que fait l'agent.** Il ne fait rien : un petit script contrôle l'espace disque et n'envoie un message que si le seuil est dépassé. Aucun modèle n'est appelé.

**Ce qu'il lui faut.**
- Le script `exemples/scripts/surveillance-disque.sh`, à placer dans `~/.hermes/scripts/`.
- Une tâche programmée en mode `--no-agent`, livrée sur Telegram (chapitre 6).
- La passerelle active.

**Garde-fous.**
- Pas de modèle : rien à injecter, rien à dépenser en réflexion.
- Un script en erreur ou trop long envoie une alerte : il ne reste pas silencieux.
- Le script ne reçoit pas les clés de fournisseur d'Hermes. Gardez-le en lecture seule : il mesure, il ne répare pas.
- Limite documentée : si la passerelle est arrêtée, rien ne part (chapitre 6, « Quelles sont les limites ? »).

**Pour démarrer.**
1. Copiez le script et rendez-le lisible par la tâche :
   ```bash
   cp exemples/scripts/surveillance-disque.sh ~/.hermes/scripts/
   ```
2. Créez la tâche :
   ```bash
   hermes cron create "every 1h" --no-agent --script surveillance-disque.sh --deliver telegram --name disque
   ```
3. Pour vérifier que le message arrive, baissez temporairement le `SEUIL` du script, lancez `hermes cron run disque`, puis remettez la bonne valeur.

## (f) Le tri et le classement de documents dans un dossier

**Ce que fait l'agent.** Il lit les documents déposés dans un dossier (factures, contrats, courriers), propose un nom et un rangement, et déplace seulement ce que vous avez validé.

**Ce qu'il lui faut.**
- Le jeu d'outils `file` (lecture, écriture, recherche). Les PDF, `.docx` et `.xlsx` sont convertis en texte ; un PDF qui n'est qu'une image scannée peut ne pas être lisible (voir la page de la doc sur l'extraction de documents).
- Un dossier de travail dédié : réglez `terminal.cwd` dans `config.yaml` (chapitre 4).
- Une compétence qui décrit vos règles de nommage et de classement.

**Garde-fous.**
- Limitez les écritures des outils de fichiers à ce dossier avec `HERMES_WRITE_SAFE_ROOT`, en y incluant le dossier personnel de Hermes. Cela ne couvre pas le terminal, or ce cas déplace des fichiers : retirez aussi le jeu d'outils `terminal`, ou isolez-le dans Docker avec seulement ce dossier monté (chapitre 5).
- Interdisez la suppression : `"rm *"` dans `approvals.deny`. Vérifié avec `hermes approvals test` : `rm facture.pdf` et `rm -rf ./archives` sont refusés, `mv facture.pdf rangement/` passe. Cela réduit le risque sans le supprimer : un script, un interpréteur ou `find -delete` passent à côté d'un motif. Pour une vraie garantie, retirez `terminal` et `code_execution`, ou isolez l'exécution dans Docker avec seulement une copie du dossier.
- Commencez en deux temps : l'agent liste ce qu'il compte faire, une personne valide, puis il exécute. Travaillez d'abord sur une copie du dossier.
- Retirez `web`, `browser` et `cronjob` : le rôle n'en a pas besoin.

**Pour démarrer.**
1. Préparez une copie d'essai du dossier, et la liste des règles de classement.
2. Réglez le dossier de travail et les refus (voir `exemples/config-securite.yaml` pour le gabarit).
3. Demandez : « Liste ce que tu rangerais où, sans rien déplacer. » Relisez.
4. Validez, puis demandez l'exécution.

Quand les fiches tournent, passez à la liste de contrôle du chapitre 13 avant de laisser l'agent travailler seul.

## Sources

- https://hermes-agent.nousresearch.com/docs/user-guide/features/cron
- https://hermes-agent.nousresearch.com/docs/user-guide/features/web-search
- https://hermes-agent.nousresearch.com/docs/user-guide/features/document-extraction
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/email
- https://hermes-agent.nousresearch.com/docs/user-guide/skills/bundled/email/email-email-inbox-triage
- https://hermes-agent.nousresearch.com/docs/user-guide/configuration
- https://hermes-agent.nousresearch.com/docs/reference/toolsets-reference
- https://hermes-agent.nousresearch.com/docs/guides/secure-hermes-on-a-work-machine
