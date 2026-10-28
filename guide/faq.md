# Questions fréquentes

Les questions qu'un débutant pose avant, pendant et après l'installation, avec une réponse courte et le chapitre où creuser. Pour les mots techniques, voir le glossaire.

## Pour comprendre

### Hermes, c'est quoi par rapport à ChatGPT ou Claude Code ?
ChatGPT est un service de discussion que l'on consulte dans un navigateur. Hermes est un logiciel que vous installez sur votre machine : il garde une mémoire, utilise des outils, répond sur des messageries comme Telegram et travaille à heure fixe. Il n'a pas de modèle à lui : il appelle celui du fournisseur que vous choisissez, y compris des modèles Claude ou GPT. Chapitres 1 et 2.

### Qu'est-ce qu'un « agent », concrètement ?
Un modèle de langage qui peut agir : lire des fichiers, chercher sur le web, lancer des commandes, se souvenir. Plus on lui donne d'outils, plus il peut faire, et plus il faut l'encadrer. Chapitres 4 et 5.

### Hermes est-il gratuit ?
Le logiciel est libre, sous licence MIT : le télécharger et l'utiliser ne coûte rien. Le modèle, lui, est un service du fournisseur choisi, et il a un coût qui dépend de ce fournisseur et de votre usage (sauf en local, voir plus bas). Chapitre 2.

### À quoi peut-il servir dans une petite entreprise ?
À des tâches répétitives où une personne garde la main : veille, brouillons de réponse, relances, comptes rendus, surveillance, classement. Ce sont des scénarios types, pas des résultats garantis. Chapitre 12.

## Installation et matériel

### Faut-il un ordinateur puissant ?
Avec un modèle dans le nuage, non : le calcul se fait chez le fournisseur et vous n'avez pas de carte graphique à acheter. La puissance compte surtout si vous faites tourner le modèle chez vous : la mémoire vive passe avant tout, et la doc signale des réponses plus lentes sans carte graphique. Chapitres 1 et 2.

### Est-ce que cela marche sous Windows ?
Oui : la doc fournit un installeur PowerShell (`install.ps1`) et un paquet pour Windows 11, et WSL2 est aussi pris en charge. Sous WSL2, activez systemd puis installez le service, comme le recommande la page WSL de la doc ; sans systemd, lancez la passerelle au premier plan (`hermes gateway run`). Chapitre 1.

### Faut-il laisser la machine allumée en permanence ?
Seulement si l'agent doit travailler seul : répondre sur une messagerie ou lancer des tâches programmées. C'est la passerelle (gateway) qui doit tourner. Pour parler à l'agent depuis votre poste, quand vous travaillez, votre ordinateur suffit. Chapitres 1 et 3.

### Comment mettre à jour sans tout casser ?
`hermes update --check`, puis `hermes update --plan`, puis `hermes update`, avec une sauvegarde avant (`--backup`). Après, lancez `hermes doctor` et `hermes gateway status`. Chapitre 1.

## Modèle et abonnements

### Puis-je utiliser mon abonnement ChatGPT, Claude ou Gemini ?
Cela dépend de l'abonnement. D'après la doc (état du 4 octobre 2026) : ChatGPT oui par connexion OAuth ; Claude Max oui, mais décompté des crédits supplémentaires ; Claude Pro non par OAuth (clé d'API ou plugin officiel expérimental) ; Gemini : pas de voie documentée par abonnement, clé d'API seulement. Ces règles changent : relisez la doc avant de choisir. Chapitre 2.

### Quel modèle choisir ?
La doc n'en désigne pas un : la liste évolue vite. Un critère simple : le modèle doit offrir au moins 64 000 jetons de contexte. Mettez le plus puissant sur l'agent qui coordonne, un modèle plus léger sur les tâches simples. `hermes model` affiche les choix de votre version. Chapitre 2.

### Mon agent consomme énormément : que vérifier ?
Mesurez d'abord : `/usage` dans la conversation, `hermes insights` dans le terminal. Les causes fréquentes : une conversation devenue très longue (faites `/compress` ou `/new`), un changement de modèle en cours de route (le cache du fournisseur est perdu), des compétences ou fichiers de contexte volumineux relus souvent. Chapitre 9.

### Peut-on utiliser un modèle en local ?
Oui : choisissez « Custom endpoint » dans `hermes model` et indiquez l'adresse de votre serveur (Ollama, LM Studio, llama.cpp, vLLM, ou tout serveur compatible avec l'API OpenAI). Aucune donnée ne quitte la machine, mais il faut une machine capable et un contexte d'au moins 64 000 jetons. Pour débuter en entreprise, commencez par le nuage. Chapitre 2.

### Que se passe-t-il si mon fournisseur tombe en panne ?
Configurez un fournisseur de secours : `hermes fallback add`. Hermes y bascule pour le tour en cours, sans perdre la conversation. Chapitre 2.

## Fiabilité

### Il oublie mes consignes : pourquoi ?
Les causes, de la plus fréquente à la plus rare : mauvais modèle réellement utilisé (`/model`), conversation trop longue (`/usage`, puis `/compress` ou `/new`), mémoire lue seulement à la session suivante. Ce qui doit tenir longtemps va dans le SOUL ou une compétence, pas dans la discussion. Chapitres 4 et 8.

### Il ne retient pas mon nom ni mes préférences
La mémoire ajoutée en cours de session n'apparaît qu'à la **prochaine** session, c'est voulu. Elle est aussi bornée : elle garde des faits choisis, pas vos conversations. Pour retrouver un échange ancien, demandez à l'agent de chercher dans les sessions passées. Chapitres 4 et 8.

### SOUL, compétence, mémoire : que mettre où ?
Le SOUL dit qui est l'agent et comment il parle. Une compétence décrit une procédure étape par étape. La mémoire garde de petits faits utiles. Un fait qui doit rester exact (tarif, adresse) va dans un fichier, jamais dans la mémoire. Chapitre 4.

### Mon agent ne répond plus sur Telegram
Dans l'ordre : `hermes gateway status`, puis `hermes logs gateway -n 100`. Causes courantes : jeton révoqué, identifiant non autorisé (message « unauthorized »), deux profils sur le même jeton. Après correction, `hermes gateway restart`. Chapitre 8.

### Ma tâche programmée n'envoie rien
La cause la plus fréquente : la passerelle ne tourne pas, car c'est elle qui déclenche les tâches. Vérifiez ensuite `hermes cron list`, l'heure de la machine, la destination, et un éventuel résultat vide (`[SILENT]`). Chapitres 6 et 8.

## Langue

### Peut-il répondre en français ?
Oui, mais ne confondez pas deux choses. La langue des **réponses de l'agent** se règle dans le SOUL (une ligne suffit : voir `exemples/SOUL.md`) ou dans votre demande. L'**interface** a des textes en français, selon la doc officielle : `hermes config set display.language fr` (fichier `locales/fr.yaml` dans le code, avec un complément pour l'interface en mode texte). Cela traduit les textes fixes (demandes d'approbation, quelques réponses de la passerelle, astuces) ; cela ne traduit ni les réponses de l'agent, ni les journaux, ni la sortie des outils. Les noms des commandes `/` restent en anglais, leurs descriptions sont traduites. Redémarrez la passerelle ensuite. Chapitre 4.

### Comprend-il mes messages vocaux en français ?
Les messages vocaux Telegram sont transcrits, mais la doc indique que la langue de transcription est `en` par défaut. Réglez `hermes config set stt.language fr`, puis `hermes gateway restart`. Chapitre 3.

## Données et sécurité

### Est-ce que mes données partent quelque part ?
D'après la doc officielle, Hermes ne collecte pas de télémétrie ni de statistiques d'usage. Vos messages vont au fournisseur de modèle que vous avez choisi (réglez aussi les tâches annexes, chapitre 9, pour qu'elles ne se rabattent pas sur un autre) ; vos conversations, votre mémoire et vos compétences sont stockées chez vous, dans `~/.hermes/`. Les outils que vous activez (recherche web, transcription hébergée) envoient leurs requêtes à leurs propres services. Avec un modèle local, rien ne sort. Chapitre 2.

### Peut-il envoyer des mails ou agir tout seul ?
Seulement si vous lui en donnez les moyens. Au début, laissez-le préparer et faites valider par une personne, avec un plugin ou `approvals.deny` pour bloquer l'envoi direct. Chapitres 5 et 13.

### Une page web ou un mail peut-il lui donner des ordres ?
C'est l'injection d'instructions : le modèle lit ce texte comme un autre. Aucun réglage n'immunise. La parade tient à l'architecture : peu d'outils pour l'agent qui lit l'extérieur, validation humaine de tout ce qui sort. Chapitre 5.

### Comment partager l'agent avec ma famille ou mon équipe ?
Ajoutez les identifiants dans `TELEGRAM_ALLOWED_USERS` (séparés par des virgules), ou faites passer la personne par l'appairage (`hermes pairing approve telegram <code>`). Attention : tous partagent le même agent, sa mémoire et ses outils. Pour séparer les données ou les droits, créez un profil par personne, avec son propre bot. Chapitres 3 et 4.

### Que faire si une clé a fuité ?
Révoquez-la **d'abord** chez le fournisseur (ou BotFather pour un jeton Telegram), puis remplacez-la dans `~/.hermes/.env`, et lancez `hermes gateway restart`. Si elle a été copiée dans un dépôt git ou un message, considérez-la comme compromise même après suppression. Pensez aussi aux archives `hermes backup`, qui contiennent vos clés. Chapitres 5 et 8.

### Comment tout arrêter d'urgence ?
`hermes pause` arrête les nouvelles tâches et les nouveaux tours de la passerelle, sans tuer le travail en cours ; `hermes resume` lève l'arrêt. Pour arrêter le service lui-même : `hermes gateway stop`. Révoquer la clé du modèle coupe aussi l'agent à la source. Chapitres 3 et 8.

### Comment sauvegarder, et restaurer ?
`hermes backup` crée une archive complète (`--quick` pour l'état critique), `hermes import <archive.zip>` la restaure. Rangez l'archive comme un secret. Faites-en une avant toute mise à jour. Chapitres 1 et 8.

## Aller plus loin

### Je viens d'OpenClaw : puis-je migrer ?
Oui : installez et activez le plugin (`hermes plugins install agent-importers`, puis `hermes plugins enable agent-importers`), puis `hermes import-agent openclaw`, en commençant par `--dry-run` pour simuler. Les secrets ne sont pas importés par défaut. Chapitre 7.

### Où demander de l'aide ?
Lancez `hermes doctor`, puis relisez les journaux. Pour demander à quelqu'un, `hermes dump` produit un résumé de votre installation à copier. Sinon, les tickets du projet sur GitHub, avec votre système, la version (`hermes --version`) et le message d'erreur complet. Chapitre 8.

### Que vérifier avant de le laisser travailler seul ?
La liste de contrôle du chapitre 13 : accès, outils, sorties, secrets, surveillance, sauvegarde et arrêt d'urgence.

## Sources

- https://hermes-agent.nousresearch.com/docs/reference/faq
- https://hermes-agent.nousresearch.com/docs/user-guide/configuration
- https://hermes-agent.nousresearch.com/docs/user-guide/features/language-packs
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram
- https://hermes-agent.nousresearch.com/docs/user-guide/security
- https://hermes-agent.nousresearch.com/docs/getting-started/installation
- https://hermes-agent.nousresearch.com/docs/getting-started/updating
