# 4. Donner un rôle à l'agent : SOUL, compétences, mémoire, profils

Ce chapitre explique où ranger quoi pour qu'un agent ait une voix, un rôle et des savoir-faire stables, et comment faire cohabiter plusieurs agents sur une même machine.

La règle qui guide tout le chapitre : chaque type d'information a sa place. Mal rangée, elle est soit oubliée, soit relue à chaque message pour rien.

![Où ranger quoi : qui est l'agent et comment il parle va dans SOUL.md ; les règles d'un projet dans AGENTS.md ; une procédure dans une compétence ; une préférence dans la mémoire ; un fait qui doit rester exact (tarif, adresse, règle) dans un fichier de référence que l'agent relit, jamais la mémoire ; un deuxième agent dans un profil.](../images/ranger.png)

La doc officielle a une page qui détaille chaque fichier : [« Which file does what »](https://hermes-agent.nousresearch.com/docs/user-guide/which-file-does-what).

## Que mettre dans SOUL.md ?

`SOUL.md` est l'identité de l'agent. C'est le premier texte de son prompt système (ses instructions de fond). Il vit ici :

```text
~/.hermes/SOUL.md
```

Hermes en crée un par défaut s'il n'existe pas, et ne l'écrase jamais. Ouvrez-le et gardez peu de lignes, qui disent vraiment quelque chose : le ton, le degré de franchise, ce que l'agent évite, comment il réagit quand une demande est floue.

À mettre :

- le rôle (« vous êtes l'assistant qui prépare les devis »),
- le ton et le style,
- la façon de traiter l'incertitude et le désaccord.

Un exemple complet en français, prêt à adapter : [`exemples/SOUL.md`](../exemples/SOUL.md).

À ne pas mettre (la doc est claire là-dessus) : chemins de fichiers, commandes, ports, architecture, procédures de travail. Tout cela relève de `AGENTS.md` ou d'une compétence. Un SOUL rempli de détails de projet devient contradictoire, et la doc signale qu'un fichier trop long est tronqué.

Après une modification, relancez Hermes ou ouvrez une nouvelle session. Pour un changement temporaire de ton, la commande `/personality` superpose un style le temps d'une session sans toucher au SOUL.

> **Sur le terrain (octobre 2026).** Notre équipe compte cinq profils : un orchestrateur et quatre spécialistes, chacun avec son SOUL et ses compétences. Les SOUL font moins de 100 lignes ; les règles communes à tous les agents sont dans un fichier à part.

## Et les fichiers de contexte (AGENTS.md) ?

Un fichier de contexte décrit un projet : conventions, dossiers, consignes. Hermes le charge depuis le dossier de travail. Un seul type de fichier est retenu par session, le premier trouvé dans cet ordre :

1. `.hermes.md` (ou `HERMES.md`)
2. `AGENTS.override.md`
3. `AGENTS.md`
4. `CLAUDE.md`
5. `.cursorrules`

`SOUL.md` est chargé à part, toujours, et seulement depuis le dossier personnel de Hermes (jamais depuis un projet).

Pièges à connaître :

- **Taille limitée.** Un fichier trop gros est coupé (début et fin gardés, milieu remplacé par un marqueur). La limite se règle avec `context_file_max_chars` dans `config.yaml`. Sans cette clé, elle s'adapte à la fenêtre du modèle. Gardez vos fichiers courts : ils sont relus à chaque tour.
- **Analyse de sécurité.** Un `AGENTS.md` qui contient des formules ressemblant à une injection d'instructions est bloqué et ne se charge pas. C'est voulu : relisez tout fichier venant d'un dépôt que vous n'avez pas écrit.

## Que sont les compétences (skills) ?

Une compétence est un document de procédure que l'agent charge seulement quand il en a besoin. Elle ne coûte rien tant qu'elle n'est pas utilisée. Toutes vivent dans `~/.hermes/skills/` (pour le profil par défaut).

Pour en écrire une à la main :

```bash
mkdir -p ~/.hermes/skills/ma-categorie/ma-competence
```

Puis créez `SKILL.md` dans ce dossier :

```markdown
---
name: ma-competence
description: Une phrase qui dit à quoi elle sert
version: 1.0.0
---

# Ma compétence

## When to Use
Quand l'utiliser.

## Procedure
1. Première étape
2. Deuxième étape

## Pitfalls
- Ce qui rate d'habitude, et le remède

## Verification
Comment vérifier que c'est réussi.
```

Un exemple complet en français, testé à chaque modification de ce guide : [`exemples/skills/relance-devis/`](../exemples/skills/relance-devis/SKILL.md). Gardez les intertitres anglais (`When to Use`, `Procedure`…) : c'est le format de la doc.

La compétence est disponible tout de suite, sans enregistrement : tapez `/ma-competence` dans une conversation. Des fichiers d'appui (`references/`, `templates/`, `scripts/`) peuvent l'accompagner.

Pour en installer une existante :

```bash
hermes skills search <mot>
hermes skills inspect <identifiant>
hermes skills install <identifiant>
hermes skills list
```

Chaque installation passe par une analyse de sécurité. Cette analyse aide, mais ne remplace pas votre relecture : la politique de sécurité de Hermes demande de lire aussi le code et les scripts d'une compétence tierce, pas seulement sa description.

L'agent peut aussi créer ou corriger ses propres compétences (outil `skill_manage`). Si vous préférez valider chaque écriture, mettez `skills.write_approval: true` : les écritures sont alors mises en attente, et `/skills pending`, `/skills approve <id>` ou `/skills reject <id>` permettent de trancher.

## Que garde la mémoire, et à quoi ne pas l'employer ?

La mémoire tient dans deux petits fichiers du dossier `~/.hermes/memories/` : `MEMORY.md` (notes de l'agent) et `USER.md` (votre profil). Ils sont limités en taille (2 200 caractères pour le premier, 1 375 pour le second) et recopiés dans le prompt au début de chaque session.

Ce qui y va bien : une préférence, un fait d'environnement, une correction. Ce qui n'y va pas : un long texte, des données brutes, tout ce qui figure déjà dans `SOUL.md` ou `AGENTS.md`.

**Un fait qui doit rester exact va dans un fichier, pas en mémoire.** Un tarif, une règle commerciale, une adresse : la mémoire est écrite par le modèle, résumée, fusionnée, parfois mal. Mettez le fait dans un fichier que l'agent lit à la demande (ou dans une compétence), et laissez à la mémoire ce qui tolère l'approximation. Pour une procédure, la doc le dit simplement : si c'est une page de référence, c'est une compétence ; si c'est un pense-bête, c'est la mémoire.

Autres points :

- Si vous demandez « souviens-toi de ça » et qu'une nouvelle session l'ignore, regardez `~/.hermes/memories/MEMORY.md` : l'agent a peut-être dit l'avoir noté sans appeler l'outil.
- La mémoire est propre à chaque profil.
- Les sessions de messagerie durent longtemps. Lancez `/new` aux moments naturels (fin d'une tâche, début de journée) pour que la mémoire à jour soit relue.

## Comment faire tourner plusieurs agents sur une machine ?

Un profil est un dossier Hermes séparé : sa configuration, ses clés, son SOUL, sa mémoire, ses compétences, ses sessions. Ne faites jamais tourner deux agents sur le même profil : leurs écritures en mémoire se mélangent.

```bash
hermes profile create redacteur          # crée le profil et la commande « redacteur »
hermes profile list
hermes profile show redacteur
hermes -p redacteur chat                 # lance une commande sur ce profil
hermes -p redacteur gateway start
hermes profile describe redacteur --text "Rédige les textes."
```

Autres commandes utiles : `hermes profile use <nom>` (profil par défaut), `rename`, `export`, `import`, `delete`. `--clone` copie la configuration, le `.env` (donc les clés des fournisseurs), le SOUL, les compétences et la mémoire d'un profil existant ; `--no-skills` crée un profil sans compétences fournies.

Un profil ne démarre pas dans un dossier de projet. Réglez `terminal.cwd` dans son `config.yaml` si besoin.

> **Sur le terrain (octobre 2026).** Nos profils sont générés depuis un dépôt git par un script, jamais modifiés à la main ; un contrôle quotidien compare les profils réels au dépôt et alerte sur Telegram en cas d'écart.

Piège important : un clonage normal ne copie plus les jetons de messagerie (la doc le précise), et l'option `--clone-channels` les copie quand même. Dans ce cas, le jeton est partagé et les deux profils se disputent le même bot.

> **Sur le terrain (octobre 2026).** Nous ne clonons jamais un profil qui porte un jeton Telegram : le jeton est copié et les deux profils se disputent le même bot.

Pour chaque nouveau profil, configurez son propre bot avec `hermes -p <nom> setup`.

## Comment les agents se passent-ils le travail ?

La doc propose l'outil intégré `delegate_task` : l'agent lance des sous-agents, chacun avec une conversation neuve, et seul leur résumé final revient. C'est adapté aux recherches en parallèle ou aux tâches qui noieraient la conversation de détails. Un sous-agent n'est pas un profil : il n'a ni son SOUL ni sa mémoire propres.

Pour faire collaborer de vrais profils, la doc décrit aussi un tableau de tâches (`hermes kanban`).

Si vous voulez désactiver la délégation intégrée, ajoutez `delegation` à la liste `agent.disabled_toolsets` du profil (voir le chapitre 5).

> **Sur le terrain (octobre 2026).** Chez nous, la délégation intégrée (`delegate_task`) est désactivée sur l'orchestrateur : il confie le travail aux autres profils par un petit script, ce qui laisse une trace de chaque passage de main.

## Sources

- https://hermes-agent.nousresearch.com/docs/guides/use-soul-with-hermes
- https://hermes-agent.nousresearch.com/docs/user-guide/features/personality
- https://hermes-agent.nousresearch.com/docs/user-guide/features/context-files
- https://hermes-agent.nousresearch.com/docs/user-guide/features/skills
- https://hermes-agent.nousresearch.com/docs/guides/work-with-skills
- https://hermes-agent.nousresearch.com/docs/user-guide/features/memory
- https://hermes-agent.nousresearch.com/docs/user-guide/profiles
- https://hermes-agent.nousresearch.com/docs/reference/profile-commands
- https://hermes-agent.nousresearch.com/docs/user-guide/features/delegation
- https://hermes-agent.nousresearch.com/docs/guides/delegation-patterns
