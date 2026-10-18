# 3. Parler à l'agent depuis Telegram

Ce chapitre explique comment relier Hermes à Telegram, pour discuter avec votre agent depuis votre téléphone, et comment faire tourner ce lien en continu sur la machine.

## Qu'est-ce que la passerelle (gateway) ?

La passerelle (gateway) est un processus qui tourne en arrière-plan sur la machine où Hermes est installé. Elle se connecte à vos messageries, gère les conversations et lance aussi les tâches programmées (chapitre 6). Tant qu'elle ne tourne pas, votre agent ne répond pas sur Telegram.

Telegram n'est pas la seule option. La documentation décrit aussi Discord, Slack, WhatsApp, Signal, SMS, e-mail, Mattermost, Matrix et d'autres. Le principe est le même pour toutes : un jeton ou des identifiants, une liste de personnes autorisées, puis la passerelle. Ce chapitre suit le cas Telegram.

## Comment créer le bot Telegram ?

Tout bot Telegram est créé auprès de @BotFather, le bot officiel de Telegram qui gère les bots.

1. Dans Telegram, cherchez `@BotFather` (ou ouvrez `t.me/BotFather`).
2. Envoyez `/newbot`.
3. Choisissez un nom affiché (il peut être quelconque).
4. Choisissez un nom d'utilisateur, unique et terminé par `bot` (par exemple `mon_hermes_bot`).
5. BotFather répond avec un jeton (token), une longue suite de chiffres et de lettres. Copiez-le.

Ce jeton donne le contrôle du bot à quiconque le possède. Ne le partagez pas et ne l'écrivez dans aucun document. S'il fuit, envoyez `/revoke` à BotFather pour en obtenir un nouveau.

Réglages facultatifs, toujours auprès de BotFather : `/setdescription` (texte d'accueil), `/setabouttext`, `/setuserpic` (avatar), `/setcommands` (menu des commandes).

## Comment trouver votre identifiant Telegram ?

Hermes contrôle l'accès avec l'identifiant numérique de chaque personne, pas avec son nom d'utilisateur. Écrivez à `@userinfobot` sur Telegram : il répond tout de suite avec votre numéro. Notez-le.

## Comment brancher le jeton dans Hermes ?

La voie recommandée est l'assistant interactif :

```bash
hermes gateway setup
```

Choisissez Telegram, collez le jeton, puis indiquez votre identifiant. L'assistant écrit la configuration à votre place.

Vous pouvez aussi renseigner à la main le fichier `~/.hermes/.env` :

```bash
TELEGRAM_BOT_TOKEN=<le jeton donné par BotFather>
TELEGRAM_ALLOWED_USERS=123456789
```

Ce fichier contient des secrets. Ne le copiez pas dans un dépôt ni dans un message.

## Comment limiter qui peut parler au bot ?

Par défaut, la passerelle refuse toute personne qui n'est ni dans une liste autorisée, ni validée par appairage. C'est voulu : un agent a souvent accès à des outils sensibles.

Le réglage s'appelle `TELEGRAM_ALLOWED_USERS`. Il prend les identifiants numériques séparés par des virgules :

```bash
TELEGRAM_ALLOWED_USERS=123456789,987654321
```

Il existe aussi un réglage valable pour toutes les messageries, `GATEWAY_ALLOWED_USERS`. Évitez `GATEWAY_ALLOW_ALL_USERS=true` : la documentation le déconseille pour un bot qui a accès à un terminal, car n'importe qui trouvant le bot pourrait lancer des commandes sur votre machine.

### Autre méthode : l'appairage

Au lieu de collecter les identifiants à l'avance, vous pouvez laisser la personne écrire au bot. Elle reçoit un code à usage unique, qu'elle vous transmet. Vous l'approuvez sur la machine :

```bash
hermes pairing approve telegram <le code>
hermes pairing list
hermes pairing revoke telegram <identifiant>
hermes pairing clear-pending
```

Les codes expirent au bout d'une heure. L'approbation joue tout de suite, sans redémarrer la passerelle.

## Comment démarrer la passerelle ?

Pour un premier essai, lancez-la au premier plan :

```bash
hermes gateway run
```

Écrivez à votre bot sur Telegram. S'il répond, la liaison fonctionne. Arrêtez avec `Ctrl+C`.

## Comment la faire tourner en permanence ?

Installez-la comme service. Sur macOS, c'est un service launchd ; sur Linux, un service systemd utilisateur :

```bash
hermes gateway install
hermes gateway start
```

Sur un serveur Linux qui doit redémarrer seul au démarrage de la machine, deux options documentées :

```bash
sudo loginctl enable-linger $USER      # service utilisateur qui survit à la déconnexion
sudo hermes gateway install --system   # service système, lancé au démarrage
```

Commandes de gestion :

```bash
hermes gateway stop
hermes gateway restart
hermes gateway status
```

Sur macOS, le service mémorise votre variable PATH au moment de l'installation. Si vous installez un outil après coup, relancez `hermes gateway install` pour la mettre à jour.

Journaux : sur macOS, `tail -f ~/.hermes/logs/gateway.log` ; sur Linux, `journalctl --user -u hermes-gateway -f`.

> **Sur le terrain.** Dans notre installation, après une mise à jour d'Hermes, un `hermes gateway restart` a parfois été nécessaire pour que la configuration soit prise en compte.

## Comment vérifier que tout va bien ?

1. `hermes gateway status` indique si le service tourne.
2. Envoyez un message au bot : une réponse doit arriver en quelques secondes.
3. Si rien ne se passe, lisez le journal de la passerelle (voir ci-dessus).

Pour les tâches programmées, il faut aussi un « canal d'accueil » (home channel). Envoyez `/sethome` au bot dans la conversation où vous voulez recevoir les résultats.

## Et les messages vocaux ?

Oui. Un message vocal envoyé sur Telegram est transcrit automatiquement, puis traité comme du texte. Le fournisseur de transcription configuré dans Hermes peut être `local` (sur la machine, sans clé), `groq` ou `openai` (ces deux-là demandent une clé). Dans l'autre sens, une réponse en voix est envoyée comme message vocal Telegram ; avec le fournisseur gratuit par défaut, il faut `ffmpeg` installé pour ce format.

## Quels pièges éviter ?

- Le bot reste muet : vérifiez que votre identifiant est bien dans `TELEGRAM_ALLOWED_USERS` et que la passerelle tourne.
- Dans un groupe, le mode confidentialité de Telegram est actif par défaut : le bot ne voit que les commandes et les réponses à ses messages. Il se règle auprès de BotFather (`/mybots`, puis Bot Settings, Group Privacy). Après changement, retirez le bot du groupe et ajoutez-le de nouveau.
- Un jeton, une seule passerelle : deux processus sur le même jeton se gênent.

## Sources

- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
- https://hermes-agent.nousresearch.com/docs/guides/team-telegram-assistant
