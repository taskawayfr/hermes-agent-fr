# 6. Faire travailler l'agent tout seul (tâches programmées)

Ce chapitre montre comment demander à Hermes d'exécuter un travail à heure fixe ou à intervalle régulier, et de vous en envoyer le résultat, sans que vous ayez à lui parler.

## Comment ça marche ?

Une tâche programmée (cron) est une consigne rattachée à un horaire. À chaque échéance, Hermes ouvre une session neuve, exécute la consigne et livre la réponse à l'endroit choisi.

C'est la passerelle (chapitre 3) qui fait avancer l'horloge : elle vérifie les échéances toutes les 60 secondes. Une simple session de discussion dans le terminal ne déclenche pas les tâches. Sans passerelle active, rien ne part.

Deux points à retenir :

- Chaque exécution part d'une page blanche, sans souvenir de vos conversations. La consigne doit donc contenir tout ce qu'il faut savoir.
- Une tâche ne peut pas en créer d'autres : Hermes désactive la gestion des tâches pendant leur exécution.

## Comment créer une tâche ?

Trois façons, au choix.

En langage naturel, dans une conversation :

```text
Chaque matin à 9h, cherche les actualités de mon secteur et envoie-moi un résumé sur Telegram.
```

Avec la commande `/cron`, dans le chat :

```text
/cron add "every 2h" "Vérifier l'état du serveur"
```

Avec le terminal :

```bash
hermes cron create "every 2h" "Vérifier l'état du serveur"
hermes cron create "0 9 * * *" "Résumer les nouveautés du jour" --name "resume-matin" --deliver telegram
```

L'horaire accepte plusieurs formes :

| Forme | Exemple | Effet |
|---|---|---|
| Délai unique | `in 30m` | Une fois, dans 30 minutes |
| Intervalle | `every 2h` | Toutes les 2 heures |
| Jour et heure | `weekdays at 9am` | Du lundi au vendredi, à l'heure indiquée |
| Expression cron | `0 9 * * *` | Tous les jours à 9h |

Une tâche à délai unique ou à date précise ne tourne qu'une fois. Les autres tournent jusqu'à suppression.

> **Sur le terrain.** Dans notre installation, les tâches programmées sont déclarées dans le dépôt et installées par script. Les agents ne peuvent pas en créer seuls : le jeu d'outils cron est désactivé dans leurs profils.

### Comment écrire une bonne consigne ?

Mauvaise consigne : « Fais mon point habituel du matin. » L'agent ne sait pas ce que c'est.

Bonne consigne : elle dit quoi chercher, combien d'éléments garder, quel format et quel ton. Tout est dans le texte.

## Où va le résultat ?

L'option `--deliver` choisit la destination :

| Valeur | Destination |
|---|---|
| `origin` | La conversation où la tâche a été créée (par défaut depuis une messagerie) |
| `local` | Fichiers sur la machine, dans `~/.hermes/cron/output/` (par défaut depuis le terminal) |
| `telegram` | Le canal d'accueil Telegram (`/sethome`, voir chapitre 3) |
| `telegram:<identifiant>` | Une conversation Telegram précise |
| `telegram,discord` | Plusieurs destinations à la fois |

La réponse finale de l'agent est livrée automatiquement : inutile de lui demander d'envoyer un message.

Pour ne rien recevoir quand tout va bien, demandez à l'agent de répondre seulement `[SILENT]` s'il n'y a rien à signaler. Le résultat reste archivé sur la machine, mais rien n'est envoyé. Les échecs, eux, sont toujours livrés.

## Comment gérer les tâches existantes ?

```bash
hermes cron list
hermes cron pause <tâche>
hermes cron resume <tâche>
hermes cron run <tâche>
hermes cron edit <tâche> --schedule "every 4h"
hermes cron remove <tâche>
hermes cron status
```

`<tâche>` peut être l'identifiant ou le nom de la tâche. `hermes cron run` déclenche la tâche au prochain passage de l'horloge, pratique pour tester. `hermes cron status` dit si le planificateur est vivant.

## Et une tâche sans modèle (script seul) ?

Parfois, vous savez déjà quel message envoyer : une alerte si le disque est plein, un signe de vie. Inutile de faire appel à un modèle pour cela. Le mode « script seul » (no-agent) lance un script à l'heure dite et livre tel quel ce qu'il affiche.

```bash
hermes cron create "every 5m" \
  --no-agent \
  --script memory-watchdog.sh \
  --deliver telegram \
  --name "memory-watchdog"
```

Règles de fonctionnement :

- Le script doit se trouver dans `~/.hermes/scripts/`.
- Un fichier `.sh` ou `.bash` s'exécute avec bash, tout autre fichier avec Python.
- Ce que le script affiche est envoyé tel quel. S'il n'affiche rien, rien n'est envoyé : c'est le principe du « je ne parle que s'il y a un problème ».
- Un code de sortie en erreur ou un dépassement de délai envoie une alerte, pour qu'un script cassé ne reste pas silencieux.
- Aucun modèle n'est appelé.

## Quelles sont les limites ?

- La passerelle doit tourner. Pour une alerte qui doit partir même passerelle arrêtée, la documentation recommande plutôt le cron du système avec un appel à un webhook Hermes.
- Les scripts ne reçoivent pas les clés de fournisseurs d'Hermes. Pour un accès à un service externe, il faut déclarer la variable dans `terminal.env_passthrough` de `config.yaml`.
- Un script d'avant-exécution a un délai maximal documenté de 3600 secondes par défaut (`cron.script_timeout_seconds`).
- Une tâche qui tourne reste soumise à un délai d'inactivité documenté de 600 secondes par défaut.
- Si plusieurs tâches tombent à la même minute, elles passent l'une après l'autre. Décalez-les.

## Que faire si une tâche ne part pas ?

Vérifiez dans l'ordre :

1. `hermes cron list` : la tâche est-elle active (et non en pause ou terminée) ?
2. L'horaire : une forme invalide ou un délai unique explique qu'elle disparaisse après un passage.
3. `hermes cron status` : le planificateur tourne-t-il ? Sinon, `hermes gateway status`, puis `hermes gateway restart`.
4. L'heure de la machine et son fuseau horaire : les horaires suivent l'heure locale.
5. La destination : le jeton de la messagerie est-il en place, le canal d'accueil est-il défini ? Une tâche peut s'exécuter et échouer à livrer.
6. `[SILENT]` ou sortie vide : un résultat peut être volontairement supprimé.
7. Les journaux : `hermes logs`, ou `~/.hermes/logs/agent.log` et `~/.hermes/logs/errors.log`.
8. `hermes cron doctor` : contrôle de santé des tâches.

> **Sur le terrain.** Dans notre installation, une tâche programmée n'attend jamais la réponse d'un autre agent : elle serait coupée par le délai d'inactivité. Elle dépose sa demande et s'arrête ; la réponse est traitée au passage suivant.

## Sources

- https://hermes-agent.nousresearch.com/docs/user-guide/features/cron
- https://hermes-agent.nousresearch.com/docs/guides/automate-with-cron
- https://hermes-agent.nousresearch.com/docs/guides/cron-script-only
- https://hermes-agent.nousresearch.com/docs/guides/cron-troubleshooting
- https://hermes-agent.nousresearch.com/docs/guides/daily-briefing-bot
