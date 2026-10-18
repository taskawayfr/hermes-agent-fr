# Hermes Agent en français

Un guide pratique, en français, pour installer et faire tourner [Hermes Agent](https://github.com/NousResearch/hermes-agent), l'agent IA libre de Nous Research.

La documentation officielle est complète, mais en anglais et organisée par fonction. Ce guide suit l'ordre dans lequel on fait les choses la première fois, et signale les pièges rencontrés en production.

**Pour qui ?** Un dirigeant de petite entreprise ou un technicien qui installe Hermes pour la première fois et veut savoir quoi faire, dans l'ordre.

> Guide non officiel, indépendant de Nous Research. Vérifié sur Hermes Agent v0.21.5 (documentation du 4 octobre 2026). En cas de doute, la [documentation officielle](https://hermes-agent.nousresearch.com/docs/) fait foi.

## Sommaire

1. [Installer Hermes Agent](guide/01-installer.md)
2. [Choisir un modèle et un fournisseur](guide/02-choisir-un-modele.md)
3. [Parler à l'agent depuis Telegram](guide/03-brancher-telegram.md)
4. [Donner un rôle à l'agent : SOUL, compétences, mémoire, profils](guide/04-profils-soul-competences.md)
5. [Sécurité : ce que l'agent a le droit de faire](guide/05-securite-et-approbations.md)
6. [Faire travailler l'agent tout seul (tâches programmées)](guide/06-taches-programmees.md)
7. [Migrer depuis OpenClaw](guide/07-migrer-depuis-openclaw.md)
8. [Dépannage](guide/08-depannage.md)

[Glossaire](guide/glossaire.md)

## Les encadrés « Sur le terrain »

Chaque chapitre contient un ou deux encadrés tirés de notre propre installation : une équipe de cinq agents Hermes qui tourne tous les jours sur une machine allumée en permanence. Ils disent ce qui a marché, ce qui a cassé, et ce qu'on fait depuis.

## Contribuer

Une commande a changé, une explication est fausse, un chapitre manque ? Ouvrez un ticket (issue) ou proposez une modification (pull request). Chaque commande citée doit exister dans la documentation officielle ou dans l'aide de `hermes`.

## Licence

Texte sous licence [Creative Commons Attribution 4.0](LICENSE) : vous pouvez le copier, l'adapter et le republier, y compris pour un usage commercial, en citant la source. Les commandes et extraits de configuration viennent de Hermes Agent, sous licence MIT.

---

Maintenu par [Taskaway](https://www.taskaway.fr), qui installe des agents Hermes dans les PME.
