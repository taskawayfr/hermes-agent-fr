# 10. Quelle machine, et où l'héberger ?

Ce chapitre vous aide à choisir où faire tourner Hermes : votre poste, une petite machine chez vous, un serveur loué, Docker (y compris sur un NAS), Windows ou Android. Il détaille Docker, le cas qui pose le plus de questions, et dit ce que change le choix d'un modèle local. Le chapitre 1 donne l'installation de base ; celui-ci tranche entre les options.

## Comment choisir ? L'arbre de décision

Posez-vous deux questions.

**1. L'agent doit-il travailler quand vous n'êtes pas là ?** (répondre sur Telegram, lancer des tâches programmées, chapitres 3 et 6)

- Non, vous lui parlez depuis votre poste quand vous travaillez : installez-le sur le poste. Passez au paragraphe « Poste de travail ».
- Oui : il faut une machine allumée en permanence, avec la passerelle (gateway) qui tourne. Passez à la question 2.

**2. Où mettre cette machine ?**

- Une machine à vous, chez vous ou au bureau : petite machine allumée en permanence, ou NAS avec Docker.
- Un serveur loué (VPS) : pas de panne de courant ni de box à surveiller, mais vous administrez un serveur sur Internet.

Ensuite, indépendamment : le **modèle** est-il dans le nuage (fournisseur, chapitre 2) ou en local ? Le modèle local change les besoins en mémoire (voir plus bas).

## Quelles sont les options, une par une ?

### Poste de travail (Mac, Linux, Windows)

- **Ce que dit la doc.** Niveau 1 (prioritaire) : macOS Apple Silicon, Windows 10 et 11, Linux et WSL2. Sur Mac Intel, l'installeur « Hermes-Setup » ne fonctionne pas ; la doc indique d'autres voies (page `platform-support`).
- **Pour qui.** Vous parlez à l'agent quand vous travaillez.
- **Pièges.** La passerelle s'arrête avec la session ou le poste ; un agent sur messagerie ne répond plus quand l'ordinateur dort. Les tâches programmées sont déclenchées par la passerelle, pas par une simple discussion dans un terminal (chapitre 6).

### Petite machine allumée en permanence chez soi

- **Ce que dit la doc.** Rien de spécifique sur le matériel : c'est une installation ordinaire (`install.sh`) plus la passerelle en service (`hermes gateway install`, chapitre 3). La doc de l'application de bureau cite « a Mini behind Tailscale » comme exemple de machine distante.
- **Pour qui.** Un dirigeant ou un petit service qui veut un agent joignable en permanence sans administrer un serveur public.
- **Pièges.** Coupures de courant et de box ; mise en veille de la machine à désactiver ; mises à jour à surveiller (chapitre 1).

> **Sur le terrain (octobre 2026).** Notre Hermes tourne sur un Mac mini allumé en permanence ; on lui parle surtout par Telegram.

### Serveur loué (VPS)

- **Ce que dit la doc.** Linux, installation par script ou par Docker. Pour un serveur sans session ouverte, la doc de la passerelle conseille le service système : `sudo hermes gateway install --system`, puis `sudo hermes gateway start --system` (page `messaging`, déjà vue au chapitre 3).
- **Pour qui.** Celui qui veut une machine toujours disponible, indépendante de son domicile, et qui sait administrer un serveur.
- **Pièges.**
  - Connectez-vous en SSH. La doc déconseille les consoles intégrées au navigateur de certains hébergeurs : elles transmettent mal les caractères spéciaux (`:` devient `;`) et corrompent silencieusement les commandes et les clés collées.
  - N'ouvrez aucun port sur Internet sans en comprendre le risque. La doc raconte que des tableaux de bord exposés sans authentification ont servi de porte d'entrée à une campagne d'attaque en juin 2026 ; l'authentification est désormais obligatoire dès qu'il y a une adresse accessible de l'extérieur (page `docker`).
  - Sur un serveur, tout ce que l'agent peut faire, il le fait sur une machine publique : revoyez le chapitre 5.

### Docker (y compris NAS)

Voir la section suivante, détaillée.

### Windows : natif, WSL2, application de bureau

- **Natif** (PowerShell, sans droits administrateur). La doc indique que la messagerie, les tâches programmées, le navigateur, les serveurs MCP et les modèles locaux fonctionnent en natif. La passerelle démarre à l'ouverture de session (`hermes gateway install` crée une tâche planifiée, pas un service Windows) : elle s'arrête donc à la déconnexion.
- **WSL2** (un Linux dans Windows). À préférer si vous voulez un environnement identique à Linux (la page WSL cite aussi le terminal intégré du tableau de bord ; la page Windows natif dit qu'il fonctionne aussi en natif, à vérifier selon votre version). Pièges : WSL est une machine virtuelle à part, `localhost` n'y désigne pas Windows ; pour joindre un modèle local lancé côté Windows, la doc recommande sous Windows 11 le mode réseau « mirrored » (`networkingMode=mirrored` dans `%USERPROFILE%\.wslconfig`, puis `wsl --shutdown`). La VM WSL ne reste active que si quelque chose l'utilise : pour une passerelle permanente, la doc propose une tâche planifiée qui maintient WSL ouvert.
- **Application de bureau (Desktop).** Même agent que la ligne de commande (mêmes réglages, clés, sessions). `hermes desktop` l'ouvre si Hermes est déjà installé. Elle peut aussi piloter un Hermes installé sur une autre machine (« Remote gateway »).
- **Piège : le pare-feu.** Si un modèle local tourne sur Windows et Hermes dans WSL, le serveur doit écouter sur `0.0.0.0` et le pare-feu Windows doit laisser passer le port (page WSL).

### Android (Termux)

- **Ce que dit la doc.** Niveau 2 (au mieux), appareils aarch64 seulement. La page `termux` affiche en tête un avertissement : le paquet **ne fonctionne pas actuellement**, une correction est annoncée. Vérifiez la page avant d'essayer.
- **Pour qui.** Curiosité et essais, pas un agent d'entreprise.
- **Pièges.** Android peut arrêter les processus en arrière-plan : à éviter pour un agent autonome (page `platform-support`).

## Docker en pratique

Deux usages différents, à ne pas confondre : **Hermes dans Docker** (l'agent tourne dans un conteneur, cette section) et **Docker comme terminal de l'agent** (l'agent tourne sur votre machine mais exécute ses commandes dans un conteneur : chapitre 5).

Installation Docker : pas de `hermes update`. On met à jour en lançant une nouvelle image (page `platform-support`).

### Quelle image, quel volume ?

- Image officielle : `nousresearch/hermes-agent`. Étiquettes : `latest` et `stable` (version validée), `main` (développement), `X.Y.Z` (version précise). Pour une production, évitez `main`.
- Toutes vos données vivent dans un seul dossier monté dans le conteneur sur `/opt/data` : configuration (`config.yaml`), clés (`.env`), `SOUL.md`, sessions, mémoires, compétences, tâches programmées (`cron/`), journaux. L'image elle-même ne contient rien à vous : c'est ce qui rend la mise à jour sans risque pour vos données.
- Sauvegardez ce dossier. La doc ne propose pas de commande de sauvegarde propre à Docker ; copiez le dossier (conteneur arrêté de préférence) ou lancez `hermes backup` dans le conteneur (commande décrite au chapitre 8, non testée en Docker par la doc consultée).

### Première configuration

```sh
mkdir -p ~/.hermes
docker run -it --rm \
  -v ~/.hermes:/opt/data \
  nousresearch/hermes-agent setup
```

L'assistant écrit vos clés dans `~/.hermes/.env`. À faire une seule fois. La doc conseille d'y brancher dès ce moment une messagerie.

### Lancer la passerelle en permanence

```sh
docker run -d \
  --name hermes \
  --restart unless-stopped \
  -v ~/.hermes:/opt/data \
  -p 8642:8642 \
  nousresearch/hermes-agent gateway run
```

Le port 8642 sert l'interface compatible OpenAI et le point de santé : il est facultatif si vous n'utilisez que Telegram ou une autre messagerie. Dans l'image officielle, la passerelle est supervisée : si elle plante, elle redémarre en quelques secondes sans perdre le conteneur.

### Discuter, surveiller

```sh
docker run -it --rm \
  -v ~/.hermes:/opt/data \
  nousresearch/hermes-agent
```

```sh
docker logs --tail 50 hermes          # Recent logs
docker run -it --rm nousresearch/hermes-agent:latest --version   # Verify version
docker stats hermes                    # Resource usage
```

Pour lancer une commande Hermes dans le conteneur qui tourne : `docker exec hermes hermes <commande>` (la doc précise que l'exécution se fait alors sous l'utilisateur `hermes`, pas en root).

### Mettre à jour

La doc : on tire la nouvelle image et on recrée le conteneur. Le dossier de données est conservé, et la configuration est migrée automatiquement au démarrage, avec des sauvegardes horodatées de `config.yaml` et `.env` quand une migration a lieu.

```sh
docker pull nousresearch/hermes-agent:latest
docker rm -f hermes
docker run -d \
  --name hermes \
  --restart unless-stopped \
  -v ~/.hermes:/opt/data \
  nousresearch/hermes-agent gateway run
```

Avec Docker Compose :

```sh
docker compose pull
docker compose up -d
```

Après la mise à jour, appliquez la vérification du chapitre 1 : une mise à jour peut changer ce que les outils trouvent dans leur environnement (chapitre 8).

### Mémoire et ressources

Chiffres de la page `docker` : minimum 1 Go de mémoire et 1 cœur, recommandé 2 à 4 Go et 2 cœurs. Le navigateur (chapitre 11) est la fonction la plus gourmande : avec lui, prévoyez au moins 2 Go, et ajoutez `--shm-size=1g` à `docker run` (sans cela, les outils navigateur échouent). Pour fixer des plafonds : `--memory=4g --cpus=2`.

### Sur un NAS

La doc cite UGOS, Synology et unRAID. Le piège du NAS : le dossier de données est un montage dont le propriétaire est un utilisateur du NAS que le conteneur ne peut pas modifier, d'où des erreurs « Permission denied ». La réponse documentée est de faire tourner l'agent sous le même utilisateur que le dossier, avec `PUID` et `PGID` :

```sh
docker run -d \
  --name hermes \
  -e PUID=1000 -e PGID=10 \
  -v /volume1/docker/hermes:/opt/data \
  nousresearch/hermes-agent gateway run
```

(Les nombres sont un exemple de la doc : mettez ceux de l'utilisateur propriétaire de votre dossier.) Ne rendez pas le dossier lisible par tous : il contient vos clés.

Autre piège : sur les dossiers partagés à travers une machine virtuelle (Docker Desktop sur Mac ou Windows, OrbStack) ou sur un partage réseau (NFS, SMB), la base de sessions (`state.db`) peut se corrompre. Remède de la doc : un volume Docker nommé (`-v hermes-data:/opt/data`), ou la clé `database.journal_mode: delete` dans `config.yaml`, à poser avant de créer la base (elle ne convertit pas une base existante). `hermes doctor` ne détecte que certains cas (partages de machine virtuelle) ; un partage réseau NFS ou SMB ne l'est pas : évitez-le pour `/opt/data` (page `docker`, section « Filesystem requirements »).

### Joindre un modèle local depuis Docker

Si le serveur de modèle (Ollama, vLLM) tourne sur la machine hôte, `localhost` dans le conteneur ne la désigne pas. La doc donne `host.docker.internal:11434` sur Mac et Windows, `127.0.0.1:11434` sur Linux avec `--network host`, ou un réseau Docker commun si Ollama est lui aussi dans un conteneur (section « Connecting to local inference servers »).

## Modèle dans le nuage ou en local : ce que ça change pour le matériel

- **Modèle dans le nuage** (chapitre 2). La machine n'a presque rien à calculer : n'importe quelle machine de la liste ci-dessus suffit, et c'est le choix le plus simple pour un agent permanent.
- **Modèle en local.** C'est la machine qui calcule. La doc fixe un seuil : Hermes exige au moins 64 000 jetons de contexte pour l'usage avec outils et refuse de démarrer sinon (page `providers`). Ollama démarre par défaut avec un contexte plus petit sur les cartes modestes, il faut donc l'agrandir (par exemple `OLLAMA_CONTEXT_LENGTH=64000 ollama serve`, même page).
- Mémoire nécessaire : la page `local-ollama-setup` indique par exemple 8 Go minimum pour les petits modèles (3B) et 32 Go et plus recommandés pour les grands (27B et plus), et note que la machine peut tourner sans carte graphique, plus lentement. La page `local-llm-on-mac` donne les mêmes ordres de grandeur sur Apple Silicon et un exemple de modèle de 9 milliards de paramètres. Pour les chiffres précis, lisez ces pages : ils dépendent du modèle et changent vite.
- Piège majeur de ces pages : un modèle sans appel d'outils ne sait que discuter. Hermes agit par appels d'outils (fichiers, commandes, navigateur) : choisissez un modèle qui les gère.
- Sur machine sans carte graphique, les réponses sont lentes : la doc conseille d'allonger le délai d'attente (`HERMES_API_TIMEOUT` dans `.env`).
- L'application de bureau propose un chemin simplifié (Settings, Providers, Local Models), mais seulement dans ses versions de test (canary) ; ailleurs, la page `local-models` indique de passer par `--local`.
- Rappel du chapitre 9 : un modèle local ne coûte pas de jetons au fournisseur, mais le contexte lourd (outils, fichiers) ralentit chaque réponse.

## Sources

- https://hermes-agent.nousresearch.com/docs/getting-started/platform-support
- https://hermes-agent.nousresearch.com/docs/getting-started/installation
- https://hermes-agent.nousresearch.com/docs/user-guide/docker
- https://hermes-agent.nousresearch.com/docs/user-guide/windows-native
- https://hermes-agent.nousresearch.com/docs/user-guide/windows-wsl-quickstart
- https://hermes-agent.nousresearch.com/docs/user-guide/desktop
- https://hermes-agent.nousresearch.com/docs/user-guide/local-models
- https://hermes-agent.nousresearch.com/docs/guides/local-llm-on-mac
- https://hermes-agent.nousresearch.com/docs/guides/local-ollama-setup
- https://hermes-agent.nousresearch.com/docs/integrations/providers
- https://hermes-agent.nousresearch.com/docs/getting-started/termux
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging
