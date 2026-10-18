#!/usr/bin/env python3
"""Vérifie que chaque commande `hermes …` citée dans le guide existe encore.

Pour chaque commande trouvée dans les fichiers Markdown (blocs de code et code en ligne),
le script lance `hermes <sous-commande> --help` et contrôle :
  - que la sous-commande existe (code de sortie 0) ;
  - que chaque option longue citée (--quelque-chose) figure dans l'aide de cette sous-commande.

Usage :
  python3 scripts/verifier_commandes.py                 # avec le hermes installé
  HERMES_CMD="docker run --rm nousresearch/hermes-agent" python3 scripts/verifier_commandes.py

Code de sortie : 0 si tout est trouvé, 1 sinon.
"""
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path

RACINE = Path(__file__).resolve().parent.parent
HERMES = shlex.split(os.environ.get("HERMES_CMD", "hermes"))

# Une commande commence par « hermes » et s'arrête au premier caractère de fin de ligne,
# de commentaire, de redirection ou de fin de code en ligne.
MOTIF = re.compile(r"(?<![\w/.-])hermes((?:[ \t]+[^\s#`|;&<>]+)*)")
# Mots qui ne sont pas des sous-commandes (arguments à remplacer, valeurs).
ARGUMENT = re.compile(r"^(<.*>|\".*|'.*|[A-Z_]+=.*|\d.*)$")


def commandes(texte):
    """Rend les commandes `hermes …` du texte, sous forme de listes de mots."""
    for bloc in re.findall(r"```[^\n]*\n(.*?)```", texte, flags=re.S) + re.findall(r"`([^`\n]+)`", texte):
        bloc = bloc.replace("\\\n", " ")
        for ligne in bloc.splitlines():
            # Dans une commande Docker, « hermes » est aussi le nom du conteneur : ces lignes
            # relèvent de la doc Docker, pas de l'aide de hermes.
            if re.match(r"\s*(sudo\s+)?(docker|podman)\b", ligne):
                continue
            for m in MOTIF.finditer(ligne):
                yield m.group(1).split()


def chemin_et_options(mots):
    """Sépare la sous-commande (mots avant le premier argument ou option) et les options longues."""
    chemin, options = [], set()
    for mot in mots:
        if mot.startswith("--"):
            options.add(mot.split("=")[0])
        elif mot.startswith("-") or ARGUMENT.match(mot) or options:
            continue
        elif len(chemin) < 2 and re.fullmatch(r"[a-z][a-z0-9-]*", mot):
            chemin.append(mot)
    # « -p <profil> » précède la sous-commande : on l'ignore.
    return tuple(chemin), options


def aide(chemin, cache={}):
    if chemin not in cache:
        r = subprocess.run(HERMES + list(chemin) + ["--help"], capture_output=True, text=True, timeout=120)
        cache[chemin] = (r.returncode, r.stdout + r.stderr)
    return cache[chemin]


def main():
    trouves = {}
    for fichier in sorted(list(RACINE.glob("*.md")) + list((RACINE / "guide").glob("*.md"))):
        for mots in commandes(fichier.read_text(encoding="utf-8")):
            if mots[:1] == ["-p"]:
                mots = mots[2:]
            chemin, options = chemin_et_options(mots)
            cle = trouves.setdefault(chemin, {"options": set(), "fichiers": set()})
            cle["options"] |= options
            cle["fichiers"].add(fichier.relative_to(RACINE).as_posix())

    erreurs = 0
    for chemin in sorted(trouves):
        code, texte = aide(chemin)
        nom = " ".join(("hermes",) + chemin)
        ou = ", ".join(sorted(trouves[chemin]["fichiers"]))
        # Une option globale (--version, --continue…) se lit dans l'aide de « hermes » seul.
        texte_global = aide(())[1]
        if code != 0:
            print(f"INTROUVABLE  {nom}  ({ou})")
            erreurs += 1
            continue
        manquantes = sorted(o for o in trouves[chemin]["options"]
                            if o not in texte and o not in texte_global and o != "--help")
        if manquantes:
            print(f"OPTION ABSENTE  {nom} {' '.join(manquantes)}  ({ou})")
            erreurs += 1
        else:
            print(f"ok  {nom}")
    print(f"\n{len(trouves)} commandes vérifiées, {erreurs} problème(s).")
    sys.exit(1 if erreurs else 0)


if __name__ == "__main__":
    main()
