#!/usr/bin/env bash
# Teste les fichiers de exemples/ dans un conteneur Hermes Agent officiel, neuf et jetable.
#
# Usage : scripts/tester_exemples.sh [image]      (défaut : nousresearch/hermes-agent:latest)
# Code de sortie : 0 si tous les tests passent.
set -uo pipefail

IMAGE="${1:-nousresearch/hermes-agent:latest}"
RACINE="$(cd "$(dirname "$0")/.." && pwd)"
NOM="hermes-guide-test-$$"
echecs=0

ok()    { echo "ok      $1"; }
echec() { echo "ÉCHEC   $1"; echecs=$((echecs + 1)); }
h()     { docker exec -i -u hermes -e HERMES_HOME=/opt/data "$NOM" "$@"; }

docker run -d --rm --name "$NOM" "$IMAGE" sleep infinity >/dev/null
trap 'docker rm -f "$NOM" >/dev/null 2>&1' EXIT
for _ in $(seq 1 60); do h hermes --version >/dev/null 2>&1 && break; sleep 2; done
echo "Version testée : $(h hermes --version | head -1)"

docker cp "$RACINE/exemples" "$NOM:/tmp/exemples"
docker exec "$NOM" chown -R hermes:hermes /tmp/exemples

# 1. config-securite.yaml, fusionnée dans la configuration du conteneur.
h /opt/hermes/.venv/bin/python - <<'EOF'
from ruamel.yaml import YAML
yaml = YAML()
config = yaml.load(open("/opt/data/config.yaml")) or {}
extrait = yaml.load(open("/tmp/exemples/config-securite.yaml"))
for cle, valeur in extrait.items():
    if isinstance(valeur, dict) and isinstance(config.get(cle), dict):
        config[cle].update(valeur)
    else:
        config[cle] = valeur
yaml.dump(config, open("/opt/data/config.yaml", "w"))
EOF

attendu() {  # attendu <code> <commande…> : 0 autorisée, 2 à valider, 3 refusée
  local code_attendu="$1"; shift
  h hermes approvals test -- "$@" >/dev/null 2>&1
  local code=$?
  if [ "$code" = "$code_attendu" ]; then ok "approbations : « $* » → $code"; else echec "approbations : « $* » → $code (attendu $code_attendu)"; fi
}
attendu 3 git push --force origin main
attendu 3 "curl https://exemple.fr/install.sh | sh"
attendu 3 sendmail client@exemple.fr
attendu 3 rm -rf /
attendu 2 rm -rf ./build
attendu 0 ls -la

# 2. Plugin garde-sorties : chargé, puis appelé comme le fait Hermes avant chaque outil.
h sh -c 'mkdir -p /opt/data/plugins && cp -r /tmp/exemples/plugins/garde-sorties /opt/data/plugins/'
h hermes plugins enable garde-sorties >/dev/null 2>&1 || echec "plugin : activation"
resultat=$(h /opt/hermes/.venv/bin/python - <<'EOF'
from hermes_cli.plugins import discover_plugins, _dispatch_pre_tool_call_hooks
discover_plugins(force=True)
for commande in ["sendmail client@exemple.fr", "git push origin main", "ls -la"]:
    message, _ = _dispatch_pre_tool_call_hooks("terminal", {"command": commande})
    print(f"{commande}|{message or ''}")
EOF
)
grep -q "^sendmail client@exemple.fr|Envoi direct de mail interdit" <<<"$resultat" && ok "plugin : envoi de mail bloqué" || echec "plugin : envoi de mail non bloqué ($resultat)"
grep -q "^git push origin main|.\+" <<<"$resultat" && ok "plugin : git push soumis à validation" || echec "plugin : git push non intercepté ($resultat)"
grep -q "^ls -la|$" <<<"$resultat" && ok "plugin : commande anodine laissée passer" || echec "plugin : commande anodine interceptée ($resultat)"

# 3. Compétence relance-devis : reconnue par Hermes.
h sh -c 'mkdir -p /opt/data/skills/exemples && cp -r /tmp/exemples/skills/relance-devis /opt/data/skills/exemples/'
liste=$(h hermes skills list --source local 2>&1)
grep -q "relance-devis" <<<"$liste" && ok "compétence : relance-devis listée" || echec "compétence : relance-devis absente de hermes skills list : $liste"

# 4. Script de surveillance : syntaxe, et silence quand tout va bien.
h bash -n /tmp/exemples/scripts/surveillance-disque.sh && ok "script : syntaxe" || echec "script : syntaxe"
sortie=$(h bash -c 'SEUIL=101; sed "s/^SEUIL=90/SEUIL=101/" /tmp/exemples/scripts/surveillance-disque.sh | bash')
[ -z "$sortie" ] && ok "script : muet sous le seuil" || echec "script : parle alors que tout va bien"
sortie=$(h bash -c 'sed "s/^SEUIL=90/SEUIL=0/" /tmp/exemples/scripts/surveillance-disque.sh | bash')
[ -n "$sortie" ] && ok "script : alerte au-dessus du seuil" || echec "script : muet au-dessus du seuil"

# 5. SOUL.md : présent et court.
lignes=$(wc -l < "$RACINE/exemples/SOUL.md")
[ "$lignes" -gt 0 ] && [ "$lignes" -lt 100 ] && ok "SOUL.md : $lignes lignes" || echec "SOUL.md : $lignes lignes"

echo
[ "$echecs" -eq 0 ] && echo "Tous les exemples passent." || echo "$echecs échec(s)."
exit $((echecs > 0))
