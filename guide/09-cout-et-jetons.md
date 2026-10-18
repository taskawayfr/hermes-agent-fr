# 9. Maîtriser la consommation (jetons)

Ce chapitre explique ce qui fait grossir la consommation de votre agent, comment la mesurer, quels réglages la réduisent, et que faire quand une seule réponse consomme énormément. Il ne donne aucun prix : les tarifs changent et dépendent de votre fournisseur (voir chapitre 2).

## Qu'est-ce qu'un jeton, et pourquoi tout le monde en parle ?

Un jeton (token) est un morceau de texte, à peu près un demi-mot à un mot. Le fournisseur compte ce que vous lui envoyez (entrée) et ce qu'il renvoie (sortie). Le point qui surprend les débutants : **à chaque tour, Hermes renvoie au modèle toute la conversation depuis le début**, plus ses instructions fixes. Une réponse de trois lignes peut donc coûter très cher si le contexte est gros.

Avec un abonnement, la même mécanique use votre quota plus vite. Avec une clé d'API, elle alourdit la facture.

## Qu'est-ce qui est relu à chaque tour ?

Dans l'ordre où la doc les décrit (voir `/context` plus bas pour les voir chiffrés) :

- **Le prompt système** : `SOUL.md`, les fichiers de contexte (`AGENTS.md`, `.hermes.md`, etc.), la mémoire, l'index des compétences. Chapitre 4 pour les ranger.
- **Les définitions d'outils** : chaque outil activé est décrit au modèle. Les outils connectés par MCP (chapitre 11) pèsent vite lourd.
- **L'historique** de la conversation, y compris les gros résultats d'outils (une page web lue, un fichier ouvert, une sortie de terminal).

Et ce qui s'ajoute en coulisse :

- **Les tâches annexes** : titre de la session, résumé lors de la compression, analyse d'images, relecture de la mémoire. Par défaut, elles tournent sur votre modèle principal.
- **Les boucles d'outils** : l'agent enchaîne appels d'outils et relectures. Chaque aller-retour est un tour complet.
- **Les tâches programmées** (chapitre 6) : chaque exécution est une session neuve qui recharge le prompt système (sans les fichiers de contexte, sauf ceux de son dossier de travail), à chaque déclenchement.

## Comment mesurer ?

Commandes qui lisent sans rien modifier :

| Commande | Ce qu'elle montre |
|---|---|
| `/usage` | Jetons consommés par la session, remplissage du contexte, et, selon le fournisseur, le quota restant |
| `/context` | Répartition du contexte : prompt système, outils, règles, compétences, MCP, mémoire, conversation, plus la liste des fichiers de contexte chargés avec leur poids |
| `/context all` | Ajoute le poids de chaque compétence et de chaque jeu d'outils |
| `hermes prompt-size` | Le poids fixe d'une session neuve (prompt système, index des compétences, mémoire, outils), sans appel au modèle. `--platform telegram` simule la messagerie |
| `hermes insights` | Usage des jetons, outils utilisés, tendances. `--days N` pour la période, `--source telegram` pour une plateforme |
| `/insights` | La même chose depuis une conversation |
| `hermes status` | État des composants (clés, plateformes) ; ce n'est pas un compteur de jetons |

Marche à suivre : lancez `hermes prompt-size`. Si le poids fixe est déjà gros, le problème vient de ce que vous chargez (SOUL, fichiers de contexte, outils). S'il est petit mais que `/usage` grimpe, c'est l'historique ou les boucles d'outils.

## Comment réduire la consommation ?

### 1. Garder le poids fixe léger

- Un `SOUL.md` court et des fichiers de contexte ciblés : la doc rappelle que chaque caractère est injecté à chaque message (page `guides/tips`). Au-delà d'un plafond, Hermes tronque (clé `context_file_max_chars`).
- Retirer les outils inutiles : `hermes tools list`, puis `hermes tools disable <nom>`. Pour couper un jeu d'outils partout d'un coup, la clé est `agent.disabled_toolsets` dans `config.yaml` (voir chapitre 5).
- Beaucoup de serveurs MCP ou de plugins : la recherche d'outils (`tools.tool_search`) remplace leurs descriptions par trois outils de recherche, et le modèle ne charge que ce dont il a besoin. Elle est active par défaut (réglage `tools.tool_search.enabled` à `auto`, qui vaut `on`, vérifié dans le code ; la page de la doc la dit « opt-in », à tort). Ne la coupez (`off`) que si vous avez une raison.

### 2. Mettre un modèle léger sur les tâches annexes

Par défaut (`provider: "auto"`), toutes les tâches annexes utilisent votre modèle principal. Sur un modèle puissant, c'est du gaspillage. Le plus simple : `hermes model`, puis « Configure auxiliary models ». À la main, dans `config.yaml` :

```yaml
auxiliary:
  compression:
    provider: openrouter          # exemple : votre fournisseur
    model: <un modèle léger>
  title_generation:
    provider: openrouter
    model: <un modèle léger>
  background_review:
    provider: openrouter
    model: <un modèle léger>
```

Clés citées par la doc : `auxiliary.compression`, `auxiliary.title_generation`, `auxiliary.vision`, `auxiliary.background_review` (relecture de la mémoire et des compétences). Chacune accepte `provider`, `model`, `base_url`, et `reasoning_effort` (sauf `background_review` quand il tourne sur le même modèle que la conversation). Pour la relecture, vous pouvez aussi la couper : `auxiliary.background_review.enabled: false`, ou espacer avec `memory.nudge_interval`. La génération de titre se coupe avec `auxiliary.title_generation.enabled: false`.

> **Sur le terrain (octobre 2026).** Notre orchestrateur tourne sur le modèle le plus puissant du fournisseur, les spécialistes sur un modèle plus léger, et les tâches annexes de l'orchestrateur (relecture de sa mémoire) aussi sur le modèle léger.

### 3. Compresser ou repartir à zéro

- `/compress` résume l'historique. `/compress here` garde les derniers échanges tels quels. Après une compression, les détails fins disparaissent du résumé (chapitre 8).
- `/new` ouvre une session neuve : le moyen le plus radical. Sur une messagerie, la session dure jusqu'à un `/new` ou `/reset` explicite : pensez-y quand vous changez de sujet.
- La compression automatique se règle sous `compression:` (`enabled`, `threshold`). Détails dans la page de configuration.

### 4. Ne pas casser le cache

Les fournisseurs gardent en cache le début de la conversation, ce qui rend les tours suivants moins chers. Le cache est lié au modèle et au compte. Changer de modèle avec `/model`, une bascule automatique vers un fournisseur de secours (chapitre 2), ou une rotation de comptes, oblige à relire toute la conversation au tarif plein. Sur une longue session, mieux vaut ouvrir une session neuve que d'alterner. Hermes demande d'ailleurs confirmation avant un changement de modèle en pleine session volumineuse (clé `model.switch_context_confirm_tokens`).

De même, modifier les fichiers de contexte en cours de route change le prompt. La mémoire, elle, ne le change pas : elle est figée au début de la session, et ce que l'agent y écrit n'apparaît qu'à la session suivante.

### 5. Ne pas payer un modèle pour ce qu'un script fait

Une tâche programmée qui ne demande aucun raisonnement (surveiller un disque, un site, envoyer un rappel fixe) peut tourner sans modèle : `hermes cron create ... --no-agent --script <fichier>`. Aucun jeton, aucun fournisseur. Voir chapitre 6. Pour les tâches qui raisonnent, `--reasoning-effort` fixe le niveau de réflexion par tâche, et un déclenchement moins fréquent coûte moins cher : une tâche toutes les cinq minutes, c'est autant de sessions neuves.

### 6. Limiter les boucles

Par défaut, `agent.max_turns` est illimité (doc `user-guide/configuration`, section Iteration Budget). Vous pouvez poser un plafond entier positif. Attention : un plafond coupe la tâche en cours, parfois à moitié faite. Pour les objectifs à long cours (`/goal`), le plafond est `goals.max_turns`, 20 par défaut, avant mise en pause.

Pour du travail en parallèle, la délégation (`delegate_task`) confie chaque sous-tâche à un agent au contexte séparé : seuls les résumés reviennent dans la conversation principale. Le modèle des sous-agents se règle sous `delegation.provider` et `delegation.model`.

## « Mon agent consomme énormément pour une seule réponse »

Question fréquente. Marche à suivre, dans l'ordre :

1. **`/context all`.** Qui pèse : outils ? compétences ? un fichier de contexte énorme ? la mémoire ?
2. **`/usage`.** Le contexte est-il presque plein ? Si oui, `/compress`, ou `/new`.
3. **Un gros résultat d'outil traîne-t-il dans l'historique ?** Une page web ou un fichier lu une fois est ensuite relu à chaque tour. La compression le résume ; `compression.proactive_prune_tokens` élague en plus les vieux résultats d'outils sans appel au modèle.
4. **Beaucoup d'outils MCP ?** Vérifiez que la recherche d'outils n'a pas été coupée (`tools.tool_search.enabled`), et retirez les serveurs inutiles.
5. **Une seule réponse, plusieurs appels.** Si l'agent a enchaîné vingt outils pour répondre, c'est autant de tours complets. Le journal de la session le montre ; précisez la demande, ou cadrez dans le SOUL.
6. **Modèle en boucle.** Sur la passerelle et dans les tâches programmées, Hermes bloque les appels d'outils identiques répétés ; au terminal, il avertit seulement. Un modèle faible peut quand même tourner en rond : `hermes pause` en cas d'urgence (chapitre 8).
7. **Modèle local lent.** Sur machine locale, c'est le temps de calcul qui explose, pas la facture : voir chapitre 10.

À retenir : le coût d'une réponse dépend moins de la question que de la taille du contexte et du nombre de tours d'outils derrière.

## Sources

- https://hermes-agent.nousresearch.com/docs/user-guide/configuration
- https://hermes-agent.nousresearch.com/docs/user-guide/features/tool-search
- https://hermes-agent.nousresearch.com/docs/user-guide/features/context-files
- https://hermes-agent.nousresearch.com/docs/user-guide/features/memory
- https://hermes-agent.nousresearch.com/docs/user-guide/features/cron
- https://hermes-agent.nousresearch.com/docs/user-guide/configuring-models
- https://hermes-agent.nousresearch.com/docs/reference/slash-commands
- https://hermes-agent.nousresearch.com/docs/reference/cli-commands
- https://hermes-agent.nousresearch.com/docs/guides/tips
