# Exemples prêts à copier

Chaque fichier ici est testé dans un conteneur Hermes Agent neuf, à chaque modification du guide et chaque lundi ([`scripts/tester_exemples.sh`](../scripts/tester_exemples.sh)).

| Fichier | À quoi il sert | Où le mettre | Ce que le test vérifie | Chapitre |
|---|---|---|---|---|
| [`SOUL.md`](SOUL.md) | L'identité d'un assistant administratif : rôle, ton, ce qu'il ne fait pas | `~/.hermes/SOUL.md` | présent et court | 4 |
| [`config-securite.yaml`](config-securite.yaml) | Une base prudente : mode d'approbation, liste de refus, outils retirés | à fusionner dans `~/.hermes/config.yaml` | `git push --force`, `curl … \| sh`, `sendmail` refusés ; `rm -rf ./build` soumis à validation ; `ls` autorisé | 5 |
| [`plugins/garde-sorties/`](plugins/garde-sorties/) | Bloque l'envoi direct de mail depuis le terminal, soumet `git push` à validation | `~/.hermes/plugins/garde-sorties/`, puis `hermes plugins enable garde-sorties` | blocage, demande de validation, commande anodine laissée passer | 5 |
| [`skills/relance-devis/`](skills/relance-devis/SKILL.md) | Une compétence : préparer la relance d'un devis, en brouillon | `~/.hermes/skills/<catégorie>/relance-devis/` | reconnue par `hermes skills list` | 4, 12 |
| [`scripts/surveillance-disque.sh`](scripts/surveillance-disque.sh) | Tâche programmée sans modèle : alerte si le disque se remplit | `~/.hermes/scripts/` | muet sous le seuil, alerte au-dessus | 6, 12 |

Adaptez-les : ce sont des points de départ, pas des réglages universels. Relisez toujours un fichier avant de l'installer, comme tout ce qui donne des droits à un agent.
