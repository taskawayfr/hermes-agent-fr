# Glossaire

Les mots qui reviennent dans ce guide, avec le terme anglais de la documentation officielle quand il diffère.

| Terme | Anglais | Ce que c'est |
|---|---|---|
| Agent | agent | Le logiciel Hermes : il reçoit une demande, utilise des outils, garde une mémoire et répond. |
| Modèle | model | Le modèle de langage qui « réfléchit » pour l'agent. Hermes en change sans changer de nature. |
| Fournisseur | provider | Le service qui fait tourner le modèle (ou votre propre machine, en local). |
| Clé d'API | API key | Identifiant secret donné par un fournisseur, rangé dans `~/.hermes/.env`. |
| Connexion par abonnement | OAuth | Connexion à un fournisseur avec votre compte, dans le navigateur, sans clé à gérer. |
| Contexte | context | Tout ce que le modèle a sous les yeux pendant une conversation. Il se mesure en jetons (tokens) et sa taille est limitée. |
| Compression | compression | Résumé automatique d'une longue conversation pour libérer du contexte. |
| Passerelle | gateway | Le processus qui relie Hermes aux messageries et déclenche les tâches programmées. |
| Canal d'accueil | home channel | La conversation où arrivent les résultats des tâches programmées (`/sethome`). |
| Profil | profile | Un agent complet et séparé sur la même machine : configuration, clés, SOUL, mémoire, compétences. |
| SOUL | SOUL.md | Le fichier qui dit qui est l'agent et comment il parle. |
| Fichier de contexte | context file | Les consignes d'un projet (`AGENTS.md`, `.hermes.md`), chargées depuis le dossier de travail. |
| Compétence | skill | Une procédure écrite que l'agent charge seulement quand il en a besoin. |
| Mémoire | memory | Deux petits fichiers de notes relus au début de chaque session. |
| Jeu d'outils | toolset | Un groupe d'outils qu'on active ou retire d'un bloc (terminal, web, délégation…). |
| Approbation | approval | La validation demandée avant une commande jugée risquée. |
| Plugin | plugin | Une extension en Python, chargée au démarrage, qui peut ajouter des outils ou bloquer des actions. |
| Crochet | hook | Un point d'accroche où un plugin ou un script s'exécute (par exemple juste avant chaque outil). |
| Tâche programmée | cron job | Une consigne rattachée à un horaire, exécutée par la passerelle. |
| Délégation | delegation | L'agent lance des sous-agents pour une partie du travail et récupère leur résumé. |
| Injection d'instructions | prompt injection | Un texte extérieur (mail, page web) qui tente de donner des ordres à l'agent. |
