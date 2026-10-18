# 13. Liste de contrôle : avant de laisser l'agent travailler seul

Cette liste sert de dernier contrôle avant de laisser l'agent répondre ou agir sans que vous soyez là. Cochez chaque case après l'avoir vérifiée vous-même, pas de mémoire : chaque ligne donne la commande ou le réglage, et le chapitre qui l'explique.

Une règle d'ensemble : ce qui doit tenir se règle dans la configuration ou dans un plugin, pas dans une consigne (chapitre 5).

## Accès : qui peut parler à l'agent ?

- [ ] Seuls vos identifiants sont autorisés. Dans `~/.hermes/.env` : `TELEGRAM_ALLOWED_USERS=<identifiants séparés par des virgules>` (chapitre 3).
- [ ] Personne n'a ouvert le bot à tous : ni `GATEWAY_ALLOW_ALL_USERS` ni `TELEGRAM_ALLOW_ALL_USERS` dans `~/.hermes/.env`, ni `allow_all_users` dans `config.yaml`. Contrôle : `grep -i allow_all_users ~/.hermes/.env ~/.hermes/config.yaml` ne doit rien afficher à `true` (chapitres 3 et 5).
- [ ] Les personnes appairées sont connues : `hermes pairing list`. Retirez celles qui n'ont plus à y être : `hermes pairing revoke telegram <identifiant>` (chapitre 3).
- [ ] Un compte non autorisé n'obtient rien : écrivez au bot depuis un autre compte Telegram. Par défaut, il répond par un code d'appairage (que vous n'approuverez pas) et n'exécute rien. Pour qu'il ignore en silence : `unauthorized_dm_behavior: ignore` dans `config.yaml` (chapitre 3).
- [ ] Un seul bot par jeton : aucun autre profil ni autre machine n'utilise le même jeton (chapitres 3 et 4).

## Outils : que peut-il faire ?

- [ ] Les jeux d'outils inutiles sont retirés : `agent.disabled_toolsets` dans `config.yaml` (par exemple `computer_use`, `cronjob`, `delegation`). Contrôle : `hermes tools list` (chapitre 5).
- [ ] Le mode d'approbation est voulu : `approvals.mode: smart` (défaut) ou `manual`. Jamais `off` hors d'un environnement jetable (chapitre 5).
- [ ] `approvals.deny` contient vos interdits, motifs entre guillemets (modèle : `exemples/config-securite.yaml`, chapitre 5).
- [ ] `command_allowlist` est relue : elle ne contient que ce que vous avez choisi d'autoriser « toujours ». Une entrée comme `recursive delete` autorise toute une catégorie (chapitre 5).
- [ ] Les écritures des outils de fichiers sont limitées si le rôle le permet : `HERMES_WRITE_SAFE_ROOT`, en incluant le dossier personnel de Hermes. Le terminal n'est pas couvert : retirez-le ou isolez-le (chapitre 5).
- [ ] Si l'agent lit du contenu extérieur : l'exécution est isolée, `terminal.backend: docker` (chapitre 5).

## Sorties : que peut-il envoyer ?

- [ ] Le plugin garde-fou est activé : `hermes plugins list`, puis `hermes plugins enable <nom>` si besoin (chapitre 5).
- [ ] Il a été chargé : un plugin ne se lit qu'au démarrage, donc `hermes gateway restart` après toute modification (chapitre 5).
- [ ] Il est testé dans la vraie messagerie, pas seulement au terminal : demandez à l'agent, dans Telegram, ce que le plugin doit bloquer, et constatez le blocage (chapitres 5 et 8).
- [ ] Toute sortie vers l'extérieur (mail, publication, paiement) attend une validation humaine au début : l'agent prépare, une personne valide (chapitres 5 et 12).
- [ ] Les écritures de compétences sont validées si vous le souhaitez : `skills.write_approval: true`, puis `/skills pending` (chapitre 4).
- [ ] Le contenu extérieur (mails, pages web) est traité comme une donnée : l'agent qui le lit a le moins d'outils possible (chapitre 5).

## Secrets : où sont les clés ?

- [ ] Les clés et jetons sont dans `~/.hermes/.env`, jamais dans `config.yaml`, un dépôt git ni un message (chapitres 2 et 5).
- [ ] Vous savez où se révoque chaque clé : la page du fournisseur pour une clé d'API, BotFather pour le jeton Telegram (chapitre 8).
- [ ] Le masquage des clés dans les sorties est actif : `security.redact_secrets` n'a pas été désactivé (chapitre 5).
- [ ] Les identifiants de sites passent par `hermes vault`, pas par une phrase dans la conversation (chapitre 5).
- [ ] Une archive `hermes backup` est rangée comme un secret : elle contient vos clés (chapitre 8).

## Surveillance : comment saurez-vous que ça va mal ?

- [ ] `hermes doctor` ne signale rien, et vous le relancez après chaque mise à jour (chapitres 1 et 8).
- [ ] Après une mise à jour, vous enchaînez : `hermes doctor`, `hermes gateway status`, `hermes pm status`, puis `hermes gateway restart` si la configuration ne semble pas prise en compte (chapitres 1 et 8).
- [ ] Le journal est relu, au début chaque jour : `hermes logs`, `hermes logs gateway -n 100`, `hermes logs errors` (chapitre 8).
- [ ] Les tâches programmées sont actives : `hermes cron list`, `hermes cron status`, `hermes cron doctor` (chapitre 6).
- [ ] Vous mesurez la consommation : `hermes insights`, et `/usage` dans une conversation (chapitre 9).
- [ ] Une alerte vous prévient si le disque se remplit : `exemples/scripts/surveillance-disque.sh` (chapitres 6 et 12).
- [ ] La passerelle redémarre seule avec la machine : `hermes gateway install` (chapitre 3).

## Sauvegarde et arrêt d'urgence

- [ ] Une sauvegarde complète existe avant tout changement : `hermes backup` (ou `hermes backup --quick` pour l'état critique). `hermes update --backup` en fait une avant la mise à jour (chapitres 1 et 8).
- [ ] Vous avez essayé de la restaurer au moins une fois sur une machine de test : `hermes import <archive.zip>`. Une sauvegarde jamais restaurée reste une hypothèse.
- [ ] Vous connaissez l'arrêt d'urgence : `hermes pause` (option `--reason` pour laisser un motif) arrête les nouvelles tâches et les nouveaux tours, sans tuer le travail en cours ; `hermes resume` le lève (chapitre 8).
- [ ] Vous savez aussi arrêter la passerelle : `hermes gateway stop` (chapitre 3).
- [ ] Quelqu'un d'autre que vous connaît ces deux commandes, ou elles sont écrites près de la machine.

Une case non cochée n'est pas une catastrophe : c'est la liste de ce qu'il reste à faire avant de s'absenter.

## Sources

- https://hermes-agent.nousresearch.com/docs/guides/secure-hermes-on-a-work-machine
- https://hermes-agent.nousresearch.com/docs/user-guide/security
- https://hermes-agent.nousresearch.com/docs/user-guide/configuration
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram
- https://hermes-agent.nousresearch.com/docs/getting-started/updating
- https://hermes-agent.nousresearch.com/docs/reference/faq
- https://hermes-agent.nousresearch.com/docs/guides/cron-troubleshooting
