# Contribuer

Merci de vouloir améliorer ce guide. Toute aide compte : une coquille, une commande qui a changé, un piège que vous avez rencontré.

## Signaler une erreur

Ouvrez un ticket (issue) avec le modèle « Erreur dans le guide » : le chapitre, la phrase, ce qui est faux, et votre version de Hermes (`hermes --version`).

## Proposer une modification

1. Créez une branche, modifiez le Markdown.
2. **Chaque commande, option, clé de configuration ou chemin cité doit exister** dans la [documentation officielle](https://hermes-agent.nousresearch.com/docs/) ou dans l'aide de `hermes` (`hermes <commande> --help`). Ajoutez la page de doc utilisée à la section « Sources » du chapitre.
3. Vérifiez en local, si vous avez Docker :
   ```bash
   python3 scripts/verifier_commandes.py          # avec votre hermes installé
   scripts/tester_exemples.sh                     # teste exemples/ dans un conteneur neuf
   ```
   La même vérification tourne sur GitHub à chaque proposition, et chaque lundi contre la dernière version de Hermes.
4. Ouvrez une pull request : dites ce qui change et pourquoi.

## Règles d'écriture

- Français simple, phrases courtes, vouvoiement. Un texte qui se lit à voix haute sans buter.
- Un parcours pratique, pas une traduction de la doc : ce qu'on fait, dans l'ordre, puis les pièges.
- Aucun prix, aucun chiffre de gain : ils changent et dépendent de chacun.
- Pas de publicité, pas de lien d'affiliation.
- Un retour d'expérience (« Sur le terrain ») dit ce qui s'est passé, la cause et le remède. Il est daté.

## Les schémas

Ils sont décrits en HTML dans `sources-images/` et rendus en PNG (`node sources-images/rendre.cjs`, avec Playwright). Modifiez le HTML, pas l'image.

## Code de conduite

Ce projet suit le [code de conduite Contributor Covenant](CODE_OF_CONDUCT.md).
