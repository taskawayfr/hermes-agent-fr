# Hermes Agent en français

[![Vérification du guide](https://github.com/taskawayfr/hermes-agent-fr/actions/workflows/verification.yml/badge.svg)](https://github.com/taskawayfr/hermes-agent-fr/actions/workflows/verification.yml)
[![Testé sur Hermes Agent v0.22.2](https://img.shields.io/badge/test%C3%A9%20sur-Hermes%20Agent%20v0.22.2-0A0E1A)](CHANGELOG.md)
[![Licence CC BY 4.0](https://img.shields.io/badge/licence-CC%20BY%204.0-D4FF4F)](LICENSE)

Le guide pratique, en français, pour installer [Hermes Agent](https://github.com/NousResearch/hermes-agent) (l'agent IA libre de Nous Research), le brancher sur Telegram, le sécuriser et le laisser travailler seul.

![Comment Hermes s'organise : vous parlez à l'agent par le terminal ou une messagerie ; l'agent (un profil : SOUL, compétences, mémoire, configuration) réfléchit avec un modèle et agit avec des outils ; la passerelle relie les messageries et déclenche les tâches programmées.](images/architecture.png)

## Pourquoi ce guide, à côté de la documentation officielle ?

La [documentation officielle](https://hermes-agent.nousresearch.com/docs/) est complète, en anglais, et rangée par fonction. Ce guide ne la remplace pas : il la complète.

- **Il suit l'ordre de la première fois.** Ce qu'on fait, dans l'ordre, puis les pièges.
- **Il dit ce qui casse en production.** Les encadrés « Sur le terrain » viennent d'une équipe de cinq agents Hermes qui tourne tous les jours : ce qui a cassé, pourquoi, ce qu'on fait depuis.
- **Il donne des fichiers prêts à copier, et testés.** Un `SOUL.md` en français, une configuration de sécurité, un plugin garde-fou, une compétence, un script de surveillance : [`exemples/`](exemples/).
- **Il couvre ce que les débutants demandent vraiment.** Consommation de jetons, choix de la machine, abonnements utilisables, Docker et NAS, navigation web.
- **Il est vérifié automatiquement.** Voir plus bas.

## Par où commencer ?

**Vous dirigez une petite entreprise et voulez comprendre avant de décider (20 minutes).** Le schéma ci-dessus, puis le chapitre 12 (cas d'usage), le chapitre 5 (sécurité) et la [FAQ](guide/faq.md).

**Vous installez.** Chapitres 1 à 6 dans l'ordre, puis la liste de contrôle du chapitre 13 avant de laisser l'agent seul.

**Ça ne marche pas.** Chapitre 8 (dépannage), puis la [FAQ](guide/faq.md).

## Sommaire

1. [Installer Hermes Agent](guide/01-installer.md)
2. [Choisir un modèle et un fournisseur](guide/02-choisir-un-modele.md) (quels abonnements sont utilisables)
3. [Parler à l'agent depuis Telegram](guide/03-brancher-telegram.md)
4. [Donner un rôle à l'agent : SOUL, compétences, mémoire, profils](guide/04-profils-soul-competences.md)
5. [Sécurité : ce que l'agent a le droit de faire](guide/05-securite-et-approbations.md)
6. [Faire travailler l'agent tout seul (tâches programmées)](guide/06-taches-programmees.md)
7. [Migrer depuis OpenClaw](guide/07-migrer-depuis-openclaw.md)
8. [Dépannage](guide/08-depannage.md)
9. [Maîtriser la consommation (jetons)](guide/09-cout-et-jetons.md)
10. [Quelle machine, et où l'héberger ?](guide/10-materiel-et-hebergement.md) (Docker, NAS, Windows, serveur)
11. [Donner accès au web, au navigateur et à d'autres logiciels (MCP)](guide/11-web-navigateur-mcp.md)
12. [Six cas d'usage pour une petite entreprise](guide/12-cas-usage.md)
13. [Liste de contrôle : avant de laisser l'agent travailler seul](guide/13-avant-de-laisser-l-agent-seul.md)

[Questions fréquentes](guide/faq.md) · [Glossaire](guide/glossaire.md) · [Exemples prêts à copier](exemples/)

## Comment ce guide est-il vérifié ?

- **Le contenu** est écrit à partir de la documentation officielle (v0.21.5, 4 octobre 2026) et de son code source quand la documentation se contredit. Chaque chapitre cite ses sources.
- **Les commandes** : un script extrait chaque commande `hermes …` du guide et contrôle, dans la dernière image Docker officielle de Hermes, que la commande et ses options existent ([`scripts/verifier_commandes.py`](scripts/verifier_commandes.py)).
- **Les exemples** sont installés dans un conteneur Hermes neuf et testés : la configuration de sécurité refuse ce qu'elle doit refuser, le plugin bloque ce qu'il doit bloquer, la compétence est reconnue, le script reste muet quand tout va bien ([`scripts/tester_exemples.sh`](scripts/tester_exemples.sh)).
- **Les liens** sont contrôlés.
- Tout cela tourne sur GitHub à chaque modification **et chaque lundi**, pour repérer ce qu'une nouvelle version de Hermes a changé.

Guide non officiel, indépendant de Nous Research. En cas de doute, la documentation officielle fait foi.

## Contribuer

Une commande a changé, une explication est fausse, un sujet manque ? [Ouvrez un ticket](https://github.com/taskawayfr/hermes-agent-fr/issues/new/choose) ou proposez une modification : voir [CONTRIBUTING.md](CONTRIBUTING.md).

## Licence

Texte et schémas sous licence [Creative Commons Attribution 4.0](LICENSE) : vous pouvez les copier, les adapter et les republier, y compris pour un usage commercial, en citant la source. Les commandes et extraits de configuration viennent de Hermes Agent, sous licence MIT.

Maintenu par [Taskaway](https://www.taskaway.fr).
