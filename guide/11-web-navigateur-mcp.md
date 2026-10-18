# 11. Donner accès au web, au navigateur et à d'autres logiciels (MCP)

Ce chapitre explique comment l'agent peut chercher sur le web, naviguer sur un site, se connecter avec vos identifiants, et se brancher à d'autres logiciels par MCP. Il dit aussi comment rendre tout cela fiable, et ce qu'il ne faut jamais lui confier. Chaque accès ajouté est un risque et un poids de plus dans le contexte : voir chapitres 5 et 9.

## Quels sont les trois niveaux d'accès ?

Du plus simple au plus puissant :

1. **Recherche et lecture web** : l'agent cherche, puis lit le texte d'une page. Outils `web_search` et `web_extract`.
2. **Navigateur** : l'agent ouvre une vraie page, clique, remplit un formulaire. Outils `browser_*`.
3. **MCP** : l'agent utilise un logiciel externe (base de données, outil de tickets, fichiers) par un serveur qui lui expose des outils.

Règle pratique : prenez le niveau le plus bas qui fait le travail. La recherche et la lecture suffisent pour la plupart des besoins de veille et de réponse à une question.

## Comment activer la recherche web ?

Un `hermes tools` interactif, choix « Web Search & Extract », puis le fournisseur. L'assistant demande la clé ou l'adresse nécessaire et l'écrit dans la configuration.

```bash
hermes tools
```

Deux outils, un fournisseur (ou deux : un pour chercher, un pour lire, via `web.search_backend` et `web.extract_backend`) :

- `web_search` : renvoie des résultats classés.
- `web_extract` : récupère le texte lisible d'une ou plusieurs adresses.

Clés citées par la page `web-search` (certaines sont facultatives) :

| Variable | Rôle |
|---|---|
| `FIRECRAWL_API_KEY` | fournisseur par défaut, recherche et lecture |
| `SEARXNG_URL` | moteur de métarecherche que vous hébergez vous-même, recherche seule, sans clé |
| `BRAVE_SEARCH_API_KEY` | recherche seule |
| `EXA_API_KEY`, `PARALLEL_API_KEY`, `TAVILY_API_KEY`, `PERPLEXITY_API_KEY`, `KEENABLE_API_KEY`, `XAI_API_KEY` | recherche et, selon le cas, lecture |

Bon à savoir :

- Une installation neuve a déjà une recherche web qui marche sans aucune clé, en tournant sur des offres gratuites publiques. C'est limité en débit : pour un usage régulier, choisissez un fournisseur et sa clé.
- Plusieurs fournisseurs sont « recherche seule » : il faut en associer un autre pour que `web_extract` fonctionne.
- Les clés vont dans `~/.hermes/.env`, jamais dans le SOUL (chapitre 5).

## Comment rendre la recherche web fiable ?

Question fréquente : l'agent invente, tourne en rond, ou rate des pages. Ce que la doc permet de régler :

1. **Cherchez, puis lisez, plutôt que de naviguer.** `web_search` puis `web_extract` est plus stable et moins cher que le navigateur. Réservez le navigateur aux pages qui exigent du JavaScript ou une action (la doc le dit : si l'extraction rend peu de contenu, passez par `browser_navigate` puis `browser_snapshot`).
2. **Les pages longues sont coupées.** `web_extract` garde le début et la fin d'une page au-delà d'un budget de caractères (clé `web.extract_char_limit`), met un marqueur `[TRUNCATED]`, et range le texte complet dans un fichier que l'agent peut relire par morceaux. Si l'agent conclut sur une page tronquée sans lire le milieu, demandez-lui explicitement de lire la suite.
3. **Le cache peut servir une réponse ancienne.** Les mêmes requêtes sont servies depuis un cache pendant une durée réglable (`web.cache_ttl_minutes`, coupure complète avec `web.cache_enabled: false`). Pour des données qui changent vite (cours, actualité), baissez la durée ou coupez le cache.
4. **Exigez les sources.** Dans le SOUL ou la consigne : « cite l'adresse de chaque page utilisée, dis quand une page n'a pas pu être lue ». C'est une consigne, donc contrôlable à la lecture, pas une garantie.
5. **Limitez les sites, en connaissant la limite.** La clé `security.website_blocklist` (avec `enabled`, désactivée par défaut, et `domains`) bloque des sites pour la lecture de pages, la navigation par les outils intégrés (`browser_navigate`) et l'analyse d'images. Vérifié dans le code de v0.21.5 : elle ne s'applique ni aux résultats de recherche, ni à `browser_exec` (le navigateur par code). La doc officielle dit le contraire. Si la liste compte pour vous, revenez aux outils intégrés (`browser.backend: "off"`).
6. **Un modèle trop faible choisit mal ses outils.** Voir chapitre 2 et la page `troubleshooting-agent-quality`.

## Que sait faire le navigateur ?

Hermes lit une page comme un arbre de texte (accessibilité), pas comme une image : chaque élément cliquable reçoit un repère, et l'agent clique ou saisit par ce repère. Par défaut, l'agent reçoit un seul outil, `browser_exec`, qui écrit et exécute du code Python dans le navigateur ; il n'est proposé qu'aux sessions qui ont aussi accès au terminal. `/browser use off` (ou `browser.backend: "off"`) revient aux outils intégrés, plus simples : `browser_navigate`, `browser_snapshot`, `browser_click`, `browser_type`, `browser_scroll`, `browser_press`, `browser_back`, `browser_vision` (capture d'écran analysée par le modèle).

Plusieurs moteurs sont documentés :

- **Navigateur local** livré avec Hermes (installé par `hermes tools`, entrée « Browser Automation »). Sans fournisseur ni connexion configurés, c'est celui que Hermes lance.
- **Navigateur dans le nuage**, chez un fournisseur, choisi aussi dans `hermes tools`. Le fournisseur actif est celui de la clé `browser.cloud_provider` que l'assistant écrit.
- **Votre propre navigateur** : `/browser connect` (commande de la ligne de commande interactive uniquement, pas dans Telegram) attache Hermes à un Chrome, Brave, Chromium ou Edge lancé avec le débogage à distance. Utile pour voir ce que fait l'agent.

Réglages utiles :

```yaml
browser:
  headed: true            # fenêtre visible, reste ouverte entre les tours
  use_real_profile: true  # navigue avec vos connexions existantes (voir risques)
  record_sessions: true   # enregistre la session en vidéo
```

Limites annoncées par la doc :

- **Pas de téléchargement de fichiers** depuis le navigateur.
- Les grandes pages sont tronquées (`browser.snapshot_threshold`), l'instantané complet est rangé dans un fichier.
- Les sessions inactives sont fermées après un délai (`browser.inactivity_timeout`).
- Les navigateurs dans le nuage consomment les crédits du fournisseur ; `/browser connect` est présenté comme la solution locale gratuite.
- Les sites protégés contre les robots (CAPTCHA, double authentification) bloquent souvent. Le mode fenêtre visible (`browser.headed`) permet d'intervenir à la main pour passer l'obstacle.

Sous WSL2 avec un Chrome côté Windows, la doc déconseille `/browser connect` et recommande de passer par MCP (page `browser`, section « WSL2 + Windows Chrome »).

## Comment l'agent se connecte-t-il à un site ?

Avec `hermes vault`. Vous enregistrez un identifiant et un mot de passe, chiffrés sur la machine. L'agent ne voit que l'identifiant : le mot de passe est injecté directement dans la page, et seulement sur le site exact où il a été enregistré. Il n'y a rien à installer.

```bash
hermes vault add
hermes vault list
hermes vault rm <handle>
hermes vault sources
```

`hermes vault list` ne montre que les métadonnées, jamais les valeurs. Si l'agent atteint une page de connexion pour laquelle il n'a rien, il vous le demande sur place, dans une saisie masquée. Les codes à usage unique (double authentification) sont gérés : clé d'authentificateur enregistrée avec l'identifiant, ou saisie par vous du code reçu. Si vous utilisez déjà un gestionnaire de mots de passe en ligne de commande (`op` ou `bw`), Hermes le détecte ; `hermes vault sources --disable bitwarden` le coupe.

À savoir :

- Les tâches programmées et webhooks n'ont personne pour répondre : les identifiants déjà enregistrés y fonctionnent, sinon l'outil répond qu'il n'y a pas de saisie possible. Enregistrez avant, depuis une session interactive.
- Le coffre protège le mot de passe de la conversation, pas contre la page : une fois saisi sur un site, ce site l'a.

## Qu'est-ce que MCP, et comment en ajouter un ?

MCP (Model Context Protocol) est un standard qui permet de brancher à l'agent des outils qui vivent hors de Hermes : un dossier de fichiers, un outil de tickets, une base de données.

Commandes documentées :

```bash
hermes mcp                   # sélecteur interactif du catalogue (par défaut)
hermes mcp catalog           # liste simple des serveurs approuvés
hermes mcp install deepwiki  # installer un serveur du catalogue par son nom
hermes mcp list              # serveurs configurés
hermes mcp test <nom>        # tester la connexion
hermes mcp add <nom> --url <adresse>                          # serveur distant
hermes mcp add <nom> --command npx --args <arguments>         # serveur local
hermes mcp remove <nom>
```

(`--args` doit être la dernière option de `hermes mcp add`. Vérifiez avec `hermes mcp add --help`.) Autre méthode : écrire le serveur dans `~/.hermes/config.yaml`, sous `mcp_servers`.

```yaml
mcp_servers:
  filesystem:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-filesystem", "/chemin/du/dossier/autorisé"]
```

Après une modification de la configuration, tapez `/reload-mcp` pour que l'agent prenne la nouvelle liste d'outils.

Marche à suivre conseillée par la doc : ajoutez **un seul** serveur, vérifiez qu'il se charge, et filtrez ses outils tout de suite.

```yaml
mcp_servers:
  github:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-github"]
    tools:
      include: [create_issue, list_issues]
```

`tools.include` ne garde que les outils listés ; `tools.exclude` retire des outils précis ; `enabled: false` désactive le serveur sans le supprimer.

Coût : chaque outil MCP est décrit au modèle à chaque tour. Beaucoup de serveurs alourdissent la consommation (chapitre 9). La recherche d'outils (`tools.tool_search`) ne charge que ceux qui servent.

## Quels sont les risques, et comment les réduire ?

- **Injection d'instructions.** Une page web, un résultat de recherche ou la réponse d'un serveur MCP peut contenir des ordres cachés. Aucun réglage ne rend le modèle immunisé : voir chapitre 5. La parade est d'architecture.

- **Moindre accès.** Donnez à chaque agent seulement ce dont il a besoin : outils web retirés aux agents qui n'en ont pas l'usage (`hermes tools disable <nom>`, ou `agent.disabled_toolsets`), liste d'outils MCP limitée par `tools.include`, dossier le plus étroit possible pour un serveur de fichiers.
- **Profil réel du navigateur.** `browser.use_real_profile: true` donne à l'agent vos connexions, donc vos comptes. À réserver à une machine et un profil dédiés, jamais au navigateur où vous êtes connecté à vos comptes importants.
- **Un jeton MCP est un accès.** Donnez-lui les droits minimaux (lecture seule si possible). Les secrets des serveurs locaux passent par `env`, rien d'autre de votre environnement n'est transmis.
- **Ne jamais confier un paiement.** Le coffre sait enregistrer des cartes, avec une confirmation à chaque usage. Ne le faites pas : n'y mettez aucune carte, et pour un serveur MCP lié à un service de paiement, retirez les actions sensibles avec `tools.exclude` (la doc donne l'exemple de remboursement et de suppression de client). Les opérations d'argent restent humaines.

## Sources

- https://hermes-agent.nousresearch.com/docs/user-guide/features/web-search
- https://hermes-agent.nousresearch.com/docs/user-guide/features/browser
- https://hermes-agent.nousresearch.com/docs/user-guide/features/credential-vault
- https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp
- https://hermes-agent.nousresearch.com/docs/guides/use-mcp-with-hermes
- https://hermes-agent.nousresearch.com/docs/user-guide/security
- https://hermes-agent.nousresearch.com/docs/guides/troubleshooting-agent-quality
