# 8. Dépannage

Ce chapitre répond aux pannes les plus fréquentes, avec pour chacune la marche à suivre. Commencez toujours par la boîte à outils de diagnostic ci-dessous.

## Quels outils de diagnostic utiliser en premier ?

```bash
hermes doctor           # contrôle la configuration et les dépendances
hermes doctor --fix     # tente de réparer automatiquement
hermes status           # état des composants (ajoutez --full pour tout voir)
hermes logs             # derniers messages du journal de l'agent
hermes logs gateway -n 100   # 100 dernières lignes du journal de la passerelle
hermes logs errors      # journal des erreurs
```

`hermes logs` accepte aussi `-f` (suivre en direct), `--since 1h` (depuis une heure) et `--level ERROR`. `hermes logs list` montre les journaux disponibles.

Pour demander de l'aide à quelqu'un, `hermes dump` produit un résumé de votre installation, facile à copier. `hermes debug share` envoie un rapport à un service de dépôt de texte, après confirmation : relisez-le, et utilisez `--local` pour l'afficher sans rien envoyer.

La doc propose aussi cet ordre en cas de doute : `hermes doctor`, `hermes model`, `hermes setup`, `hermes sessions list`, `hermes --continue`, `hermes gateway status`.

## La commande `hermes` est introuvable après l'installation

Cause : votre terminal n'a pas rechargé son chemin de recherche (PATH).

```bash
source ~/.zshrc        # ou ~/.bashrc
which hermes
ls ~/.local/bin/hermes
```

Ouvrir un nouveau terminal suffit souvent. Si le fichier existe mais pas la commande, ajoutez ceci à votre configuration de shell :

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## L'agent répond par une erreur de clé ou de modèle

```bash
hermes config show     # vérifier la configuration
hermes model           # reconfigurer fournisseur, clé et modèle
```

Vérifiez que la clé correspond bien au fournisseur choisi, et qu'aucune ligne en conflit ne traîne dans `~/.hermes/.env`. Pour une erreur « modèle introuvable », relancez `hermes model` et choisissez dans la liste. Sur une erreur de limite de débit (429), attendez ou prévoyez un fournisseur de secours (chapitre 2).

## L'agent ne répond plus sur Telegram

Dans l'ordre :

1. La passerelle (gateway) tourne-t-elle ? `hermes gateway status`. Sinon, `hermes gateway start`.
2. Que dit le journal ? `hermes logs gateway -n 100`.
3. Le jeton du bot est-il valide ? S'il a été révoqué, il faut en générer un nouveau auprès de BotFather et mettre à jour le fichier `.env`.
4. Le message « unauthorized » ? Votre identifiant n'est pas dans la liste des utilisateurs autorisés.
5. Un seul bot par jeton : deux profils ou deux machines qui utilisent le même jeton se disputent le bot, et la seconde passerelle n'arrive pas à se connecter.
6. Dans un groupe, le mode confidentialité du bot est probablement actif : il ignore les messages qui ne lui sont pas adressés.
7. Si le modèle ne répond pas, la passerelle renvoie un message court qui dit où chercher. « interrupted mid-request » : connexion coupée, tapez `/retry`. « not running or is unreachable » : le serveur du modèle est arrêté ou injoignable, vérifiez son adresse. « could not reach » : tapez `/retry`, puis `hermes doctor` si ça persiste.

Après avoir corrigé un réglage, `hermes gateway restart` force la passerelle à le relire.

## L'agent oublie mes consignes

Plusieurs causes, du plus fréquent au plus rare :

1. **Mauvais modèle.** Tapez `/model` ou `/status` pour voir le modèle réellement utilisé. Un changement fait depuis le tableau de bord ne vaut que pour les nouvelles sessions.
2. **Conversation trop longue.** `/usage` montre l'occupation du contexte, `/context` le détail. Remède : `/compress` (résume l'historique) ou `/new` (nouvelle session). Après une compression, les détails fins disparaissent du résumé ; l'agent peut les retrouver dans les sessions passées par une recherche (`session_search`).
3. **Longueur de contexte mal détectée.** Si les limites arrivent trop tôt, indiquez la bonne valeur dans `config.yaml` sous `model`, clé `context_length`.
4. **La mémoire mise à jour en cours de session n'apparaît qu'à la suivante.** C'est voulu : la mémoire est lue au début de la session. Ce que vous demandez de retenir sera disponible à la **prochaine** session.
5. **La mémoire est bornée.** Elle garde des faits choisis, pas la transcription de vos échanges. Pour retrouver une discussion ancienne, demandez à l'agent de chercher dans les sessions passées.
6. **Compétence ou outil absent.** `/skills` liste les compétences installées, `/tools list` les outils. `/reload-skills` relit le dossier des compétences.

Plus généralement : une consigne glissée dans une conversation peut se perdre. Ce qui doit tenir longtemps se met dans les fichiers de l'agent (son SOUL, ses compétences), pas dans la discussion.

## Après une mise à jour, quelque chose ne marche plus

```bash
hermes doctor
hermes config check      # options de configuration manquantes
hermes config migrate    # les ajouter
hermes gateway status
hermes pm status         # dépendances : cherchez une étape en échec
hermes gateway restart   # si la configuration ne semble pas prise en compte
```

Avant d'aller plus loin, relisez ce qui s'est passé : `hermes logs update` montre le journal de la mise à jour, et chaque mise à jour écrit un reçu dans `~/.hermes/logs/update_receipts/`. Si une extension (plugin) ne convient plus à la nouvelle version, la mise à jour la désactive et l'écrit dans ses avertissements. Quand elle est de nouveau compatible : `hermes plugins enable <nom>`.

Une mise à jour peut migrer des données d'une façon que l'ancienne version ne sait plus lire. Revenir en arrière n'est donc pas qu'un retour de code : il faut une sauvegarde d'avant la mise à jour.

> **Sur le terrain.** Dans notre installation, après une mise à jour, un paquet a disparu de l'environnement des outils et un outil s'est arrêté sans bruit. Et un plugin n'est chargé qu'au démarrage du processus : après une modification, il faut redémarrer la passerelle. Un garde-fou se teste dans la vraie surface (Telegram), pas seulement au terminal.

## Une tâche programmée ne se lance pas ou n'envoie rien

1. La tâche existe-t-elle et est-elle active ? `hermes cron list` (l'état doit être `[active]`).
2. **La passerelle tourne-t-elle ?** C'est la cause la plus fréquente : c'est elle qui déclenche les tâches. Une session de discussion dans un terminal ne le fait pas.
3. L'horloge de la machine et son fuseau horaire sont-ils corrects ? Comparez `date` et les heures de prochain passage dans `hermes cron list`.
4. La destination est-elle bien configurée (jeton du bot dans `.env`, orthographe exacte) ? Une destination mal réglée supprime l'envoi sans bruit, alors que la tâche s'exécute quand même.
5. Un résultat vide, ou contenant le marqueur `[SILENT]`, n'est volontairement pas envoyé.
6. Deux passerelles en parallèle peuvent retarder ou sauter des tâches : n'en gardez qu'une.

Pour tester, `hermes cron run <identifiant>` programme un passage au prochain cycle ; les messages d'erreur sont dans `hermes logs`.

## Le système doit s'arrêter tout de suite

`hermes pause` est l'arrêt d'urgence global : plus de nouvelle tâche programmée ni de nouveau tour de passerelle, sans tuer le travail en cours. `hermes resume` le lève.

## Comment sauvegarder avant d'intervenir ?

```bash
hermes backup            # archive complète (config, compétences, sessions)
hermes backup --quick    # photo rapide des fichiers d'état critiques
```

L'archive complète contient vos clés : rangez-la comme un secret.

> **Sur le terrain.** Dans notre installation, une sauvegarde des profils est faite chaque nuit.

## Quand demander de l'aide ?

Si rien de tout cela ne suffit : cherchez dans les tickets du projet sur GitHub, ou ouvrez-en un. Donnez votre système, la version (`hermes --version`), la version de Python et le message d'erreur complet.

## Sources

- https://hermes-agent.nousresearch.com/docs/reference/faq
- https://hermes-agent.nousresearch.com/docs/guides/troubleshooting-agent-quality
- https://hermes-agent.nousresearch.com/docs/guides/cron-troubleshooting
- https://hermes-agent.nousresearch.com/docs/getting-started/updating
- https://hermes-agent.nousresearch.com/docs/getting-started/quickstart
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram
