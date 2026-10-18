# 2. Choisir un modèle et un fournisseur

Ce chapitre explique ce qu'est un fournisseur de modèle, comment choisir entre clé d'API et abonnement, comment régler le modèle d'Hermes, et comment prévoir une solution de secours.

## Qu'est-ce qu'un fournisseur et un modèle ?

Hermes est l'agent : il organise le travail, utilise des outils, garde la mémoire. Le **modèle** est le cerveau de langage qui lui répond. Le **fournisseur** est le service qui héberge ce modèle et que vous payez (ou votre propre machine, si le modèle est local).

La doc distingue deux emplacements :

- le **modèle principal** : celui avec lequel l'agent réfléchit, pour chaque message ;
- les **modèles auxiliaires** : des petites tâches annexes (résumer une longue conversation, analyser une image, résumer une page web…). Par défaut, ils réutilisent le modèle principal (`auto`). Vous n'avez rien à régler au départ.

## Clé d'API ou abonnement ?

Deux façons de s'identifier auprès d'un fournisseur.

- **La clé d'API** : une longue chaîne de caractères que le fournisseur vous donne. Hermes l'utilise pour chaque appel. Les clés sont rangées dans `~/.hermes/.env`, les réglages ordinaires dans `~/.hermes/config.yaml`. Vous n'avez pas à ouvrir ces fichiers : `hermes model` et `hermes config set` écrivent au bon endroit.
- **La connexion par abonnement (OAuth)** : vous vous connectez avec un compte, dans le navigateur, sans clé à gérer. Plusieurs fournisseurs le permettent.

Piège documenté : un abonnement grand public ne couvre pas toujours ce que l'on croit. C'est, selon la doc, la première source de mauvaises surprises sur la facture. Ce qu'elle dit au 4 octobre 2026 :

| Abonnement | Utilisable par Hermes ? | À savoir |
|---|---|---|
| Claude Max (connexion OAuth) | oui | l'usage est décompté des crédits supplémentaires achetés en plus, pas de l'allocation incluse dans Max |
| Claude Pro (connexion OAuth) | non | utiliser une clé d'API Anthropic, ou le plugin officiel ci-dessous |
| Claude Pro ou Max, par le plugin officiel « Claude Subscription DirectSDK » | oui (expérimental) | il passe par le logiciel Claude Code, installé et connecté sur la machine |
| ChatGPT (connexion OAuth, modèles Codex) | oui | ce qui est décompté de l'abonnement n'est pas encore documenté |
| SuperGrok / X Premium+ (connexion OAuth) | oui | certaines formules refusent l'accès malgré un abonnement actif |
| Google AI Pro / Ultra (Gemini) | pas de voie documentée | le fournisseur Gemini fonctionne par clé d'API seulement |

Avant de choisir, relisez la section « Subscription plans » de la page des fournisseurs : ces règles changent.

Une clé est aussi spécifique à son fournisseur : une clé d'un fournisseur ne marche pas chez un autre.

## Quels fournisseurs sont pris en charge ?

La liste est longue et évolue ; `hermes model` affiche celle de votre version. Les plus courants :

- **Nous Portal**, le service de l'éditeur d'Hermes, proposé en configuration rapide au premier lancement ;
- **Anthropic** (modèles Claude), **OpenAI** (par l'abonnement ChatGPT et les modèles Codex), **Google** (Gemini), **xAI** (Grok) ;
- **OpenRouter**, qui donne accès à de nombreux modèles avec une seule clé ;
- en local : **Ollama**, **LM Studio**, **llama.cpp**, **vLLM**, et tout serveur compatible avec l'API OpenAI.

## Comment configurer le modèle ?

Dans un terminal, hors d'une conversation :

```bash
hermes model
```

L'assistant vous fait choisir le fournisseur, vous identifier (navigateur pour l'abonnement, saisie pour la clé), puis choisir le modèle dans une liste recommandée. Le résultat est écrit dans `config.yaml` (clés `model.provider` et `model.default`).

Pour voir ce qu'Hermes utilisera vraiment :

```bash
hermes config get model --json
hermes status
```

Pour changer de modèle pendant une conversation, tapez `/model` (sans argument, il affiche le modèle courant). Avec un nom, le changement ne vaut que pour la session en cours. Ajoutez `--global` pour l'enregistrer :

```
/model <nom-du-modèle> --provider <fournisseur> --global
```

Deux pièges :

- `/model` ne bascule qu'entre fournisseurs **déjà configurés**. Pour en ajouter un, quittez la conversation et lancez `hermes model`.
- Un changement fait depuis le terminal ne s'applique qu'aux **nouvelles** sessions. Sur une passerelle, les conversations en cours gardent leur modèle ; `hermes gateway restart` force la prise en compte.

Changer de modèle au milieu d'une longue conversation a un coût : le fournisseur doit relire tout l'historique sans bénéficier de son cache. Sur une session très longue, mieux vaut en ouvrir une nouvelle avec `/new`.

La doc fixe une contrainte : le modèle doit offrir au moins 64 000 jetons de contexte (la « mémoire de travail » d'une conversation). Les modèles hébergés courants la dépassent largement ; c'est surtout à surveiller en local.

## Modèle dans le nuage ou en local ?

**Dans le nuage** : le modèle tourne chez le fournisseur. C'est le plus simple et c'est le chemin par défaut. Vos messages sont envoyés au fournisseur que vous avez choisi, et à lui seul : la doc précise qu'Hermes ne collecte pas de télémétrie.

**En local** : le modèle tourne sur votre machine ou sur un serveur à vous. Dans `hermes model`, on choisit « Custom endpoint » et on indique l'adresse du serveur (n'importe quel serveur compatible avec l'API OpenAI convient). Aucune clé de fournisseur, aucune donnée ne quitte la machine. Contreparties que la doc signale : il faut une machine assez puissante (la mémoire vive compte avant tout), les réponses sont plus lentes sans carte graphique, et il faut régler la taille du contexte à au moins 64 000 jetons sur le serveur. La page « Run Hermes Locally with Ollama » détaille un exemple pas à pas ; un coup d'œil suffit pour juger si c'est pour vous.

Pour une première installation en entreprise, commencez par le nuage : une seule chose à régler, et un modèle puissant sans matériel à acheter. Le local se réfléchit ensuite, si la confidentialité ou le fonctionnement hors ligne l'exigent.

Chaque profil a sa propre configuration : le modèle se règle donc profil par profil (chapitre 4).

> **Sur le terrain.** Dans notre installation, l'agent qui coordonne les autres tourne sur le modèle le plus puissant de son fournisseur, et les agents spécialisés sur un modèle plus léger. Les tâches annexes de l'orchestrateur (relecture de sa mémoire après un échange) passent aussi sur le modèle léger.

## Que faire quand le fournisseur est en panne ? Les fournisseurs de secours

Un fournisseur peut refuser un appel : limite de débit atteinte, service surchargé, erreur d'authentification, connexion coupée. Hermes sait alors basculer en cours de conversation vers un fournisseur de secours (fallback), sans perdre l'échange.

```bash
hermes fallback          # affiche la chaîne actuelle
hermes fallback add      # ajoute un fournisseur et un modèle (même assistant que hermes model)
hermes fallback remove   # retire une entrée
hermes fallback clear    # vide la chaîne
```

Les secours sont essayés dans l'ordre. Ils sont enregistrés sous la clé `fallback_providers` de `config.yaml`, avec pour chaque entrée un `provider` et un `model`.

À savoir :

- Le secours vaut **pour le tour en cours** : au message suivant, Hermes retente d'abord le modèle principal.
- La bascule fait perdre le cache du fournisseur : le message suivant coûte plus cher en lecture de l'historique.
- Un secours doit être authentifié à l'avance, comme un fournisseur principal.
- Mettez en place le secours **après** qu'une conversation normale marche. La doc le conseille : gardez le routage simple tant que le fournisseur principal n'est pas stable.

## Sources

- https://hermes-agent.nousresearch.com/docs/user-guide/configuring-models
- https://hermes-agent.nousresearch.com/docs/integrations/providers
- https://hermes-agent.nousresearch.com/docs/user-guide/features/fallback-providers
- https://hermes-agent.nousresearch.com/docs/guides/local-ollama-setup
- https://hermes-agent.nousresearch.com/docs/getting-started/quickstart
- https://hermes-agent.nousresearch.com/docs/reference/faq
- https://hermes-agent.nousresearch.com/docs/plugins/claude-subscription-directsdk
