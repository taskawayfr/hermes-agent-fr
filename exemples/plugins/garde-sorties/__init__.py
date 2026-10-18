"""Plugin d'exemple « garde-sorties » pour Hermes Agent.

Deux règles qui ne dépendent pas du modèle :
  1. l'envoi direct d'un mail depuis le terminal est bloqué ;
  2. un « git push » attend la validation d'une personne.

Installation : copier ce dossier dans ~/.hermes/plugins/garde-sorties/, puis
  hermes plugins enable garde-sorties
et redémarrer la passerelle (un plugin n'est chargé qu'au démarrage).
Testé sur Hermes Agent v0.22.2 : voir scripts/tester_exemples.sh.
"""
import re

# Commandes qui envoient un mail sans passer par une validation.
ENVOI_MAIL = re.compile(r"\b(sendmail|mailx?|mutt|swaks|msmtp)\b|smtps?://", re.IGNORECASE)
PUBLICATION_GIT = re.compile(r"\bgit\s+push\b")


def verifier(tool_name, args, **kwargs):
    """Appelé juste avant chaque outil. Ne rien renvoyer laisse passer l'appel."""
    if tool_name != "terminal":
        return None
    commande = str((args or {}).get("command", ""))
    if ENVOI_MAIL.search(commande):
        return {
            "action": "block",
            "message": "Envoi direct de mail interdit : préparez un brouillon, une personne l'enverra.",
        }
    if PUBLICATION_GIT.search(commande):
        return {"action": "approve", "message": "Publication de code : validation humaine requise."}
    return None


def register(ctx):
    ctx.register_hook("pre_tool_call", verifier)
