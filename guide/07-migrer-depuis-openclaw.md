# 7. Migrer depuis OpenClaw

Ce chapitre s'adresse à celles et ceux qui utilisent déjà OpenClaw (ou ses anciens noms, Clawdbot et Moltbot) et veulent reprendre leur configuration, leur mémoire et leurs compétences dans Hermes.

> **Sur le terrain.** Dans notre installation, nous n'utilisons pas OpenClaw nous-mêmes : ce chapitre s'appuie sur la documentation officielle, et nous n'avons pas fait cette migration. Les commandes ont été relues dans la documentation et dans l'aide en ligne (`--help`), pas exécutées. Lancez toujours la simulation d'abord.

## Que fait la commande de migration ?

`hermes claw migrate` lit votre dossier OpenClaw, puis importe ce qui a un équivalent dans Hermes. Par défaut, elle lit `~/.openclaw/`. Les anciens dossiers `~/.clawdbot/` et `~/.moltbot/` sont détectés automatiquement. Si votre installation est ailleurs :

```bash
hermes claw migrate --source <chemin du dossier OpenClaw>
```

Elle montre toujours un aperçu complet avant de modifier quoi que ce soit, puis demande confirmation.

## Comment simuler d'abord ?

```bash
hermes claw migrate --dry-run
```

Cette commande affiche ce qui serait importé et s'arrête là. Rien n'est modifié. Lisez la liste en entier, notamment les conflits : par défaut, la migration refuse de s'appliquer si le plan contient des conflits avec des fichiers Hermes existants.

## Qu'est-ce qui est importé ?

D'après la documentation :

- **Personnalité et mémoire** : `SOUL.md`, la mémoire à long terme, le profil utilisateur et les notes quotidiennes. Les entrées sont fusionnées avec celles qui existent déjà, sans doublons. Les instructions d'espace de travail (`AGENTS.md`) ne sont copiées que si vous indiquez `--workspace-target`.
- **Compétences (skills)** : celles de l'espace de travail et les compétences partagées, placées dans `~/.hermes/skills/openclaw-imports/`. En cas de nom identique, l'option `--skill-conflict` choisit : `skip` (par défaut), `overwrite` ou `rename`.
- **Modèle et fournisseurs** : le modèle par défaut et les fournisseurs personnalisés.
- **Comportement de l'agent** : nombre de tours, niveau de raisonnement, compression du contexte, fuseau horaire, délai d'exécution des commandes.
- **Serveurs MCP** et réglages de voix (synthèse vocale).
- **Messageries** : jeton Telegram et liste des personnes autorisées, ainsi que Discord, Slack, Signal, Matrix, Mattermost, WhatsApp (identifiants autorisés).
- **Autres réglages** : mode d'approbation des commandes, liste de commandes autorisées, réglages du navigateur.

## Qu'est-ce qui n'est pas importé par défaut ?

Les secrets. Aucun préréglage n'importe les clés d'API ni les jetons sans que vous le demandiez :

```bash
hermes claw migrate --migrate-secrets
```

Sans cette option, il faudra recréer vos clés et votre jeton Telegram dans Hermes (chapitre 3 pour le jeton). Même avec l'option, seules les clés d'une liste restreinte sont copiées, et les secrets stockés dans un fichier ou obtenus par une commande ne peuvent pas être résolus automatiquement : ils sont signalés, et vous les ajoutez à la main.

Ne sont pas non plus repris tels quels, mais archivés dans `~/.hermes/migration/openclaw/<horodatage>/archive/` pour relecture : les anciennes tâches planifiées (à recréer avec `hermes cron create`, voir chapitre 6), le fichier `HEARTBEAT.md`, les plugins, les webhooks, la liste multi-agents (à refaire avec des profils) et les réglages avancés de canaux. Les minuteurs de remise à zéro de session ne sont pas importés non plus.

WhatsApp est un cas à part : la liaison se fait par QR code, elle ne se migre pas. Il faut refaire l'appairage avec `hermes whatsapp`.

## Quelles options connaître ?

| Option | Effet |
|---|---|
| `--dry-run` | Aperçu seul, sans modification |
| `--preset full` ou `user-data` | Tout ce qui est compatible, ou sans la configuration d'infrastructure (`full` par défaut) |
| `--migrate-secrets` | Inclut les clés d'API et jetons autorisés |
| `--overwrite` | Écrase les fichiers Hermes en cas de conflit |
| `--skill-conflict` | `skip`, `overwrite` ou `rename` |
| `--workspace-target` | Dossier où placer `AGENTS.md` |
| `--no-backup` | Pas de sauvegarde préalable de `~/.hermes/` |
| `--yes` | Pas de demande de confirmation |

Par défaut, une sauvegarde de `~/.hermes/` est écrite avant l'application, dans `~/.hermes/backups/` (restaurable avec `hermes import`). Gardez-la : ne mettez `--no-backup` que si vous savez pourquoi.

## Comment migrer, dans l'ordre ?

1. `hermes claw migrate --dry-run`, puis lecture de l'aperçu.
2. `hermes claw migrate`, en validant l'aperçu quand il est conforme. Ajoutez `--migrate-secrets` seulement si vous voulez reprendre les clés.
3. Relire le rapport de fin de migration (éléments importés, ignorés, en conflit).

## Que vérifier après la migration ?

1. Le rapport : comptez les éléments importés, ignorés et en conflit.
2. Les fichiers archivés : tout ce qui est dans le dossier `archive/` demande une reprise manuelle.
3. Une nouvelle session : compétences et mémoire importées ne jouent que dans les nouvelles sessions, pas dans celle en cours.
4. Les clés : `hermes status` indique si les fournisseurs sont bien authentifiés.
5. La messagerie : si des jetons ont été importés, redémarrez la passerelle (`hermes gateway restart`) et écrivez au bot.
6. WhatsApp : refaire l'appairage si vous l'utilisiez.
7. Le ménage, une fois tout validé : `hermes claw cleanup` renomme les anciens dossiers OpenClaw en `.pre-migration/`, pour éviter toute confusion entre les deux états.

## Que faire en cas de problème ?

- « OpenClaw directory not found » : indiquez le dossier avec `--source`.
- Aucune clé trouvée : elles peuvent être dans plusieurs endroits selon votre version d'OpenClaw. Si elles sont en référence de fichier ou de commande, ajoutez-les à la main avec `hermes config set`.
- Compétences invisibles : démarrez une nouvelle session, ou tapez `/skills` pour vérifier qu'elles sont chargées.
- Voix non migrée : réglez-la à la main avec `hermes config set`.

Si vous venez de Claude Code ou de Codex CLI plutôt que d'OpenClaw, la documentation prévoit une autre commande, `hermes import-agent`.

## Sources

- https://hermes-agent.nousresearch.com/docs/guides/migrate-from-openclaw
- Aide en ligne : `hermes claw --help` et `hermes claw migrate --help`
