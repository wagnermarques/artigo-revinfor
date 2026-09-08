"""revinfor_common.py — shared helpers for the build/view scripts in this
directory.

These mirror the root Makefile's FLAVOR/ENGINE/PDF-naming conventions
(see ../Makefile) so the two conventions never drift apart, while being
pure Python (stdlib only) so they run unchanged on Linux, macOS and
Windows -- no `make`, no bash.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

# This file lives in <repo-root>/common-commands/, so its grandparent is the
# repo root. Deriving this from the file's own path (rather than shelling out
# to `git rev-parse --show-toplevel`, as the Emacs bash wrappers do) keeps
# this module dependency-free and working even without a .git directory.
PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Container flavor -> (image tag, Dockerfile). Mirrors the Makefile's
# DOCKER_IMAGE_LATEX / DOCKERFILE computation for FLAVOR=abnt|overleaf.
FLAVORS = {
    "abnt": {
        "image": "artigo-revinfor-latex:latest",
        "dockerfile": "Dockerfile",
    },
    "overleaf": {
        "image": "artigo-revinfor-overleaf:latest",
        "dockerfile": "Dockerfile.overleaf",
    },
}

# LaTeX engine -> latexmk flag. Mirrors the Makefile's LATEXMK_FLAG.
ENGINE_FLAGS = {
    "pdf": "-pdf",
    "xe": "-pdfxe",
    "lua": "-pdflua",
}


def resolve_article_dir(art: str) -> Path:
    """Resolve ART (a bare folder name or an artigos/<folder> path) to the
    article's directory, requiring a main.tex inside it. Mirrors how `make
    build ART=...` is invoked, but also accepts the bare folder name for
    convenience.
    """
    # `make build ART=...` trains a habit: tolerate a leading "art="/"ART="
    # typed onto this script's positional argument by the same reflex,
    # rather than erroring on it.
    prefix, sep, rest = art.partition("=")
    if sep and prefix.strip().lower() == "art":
        art = rest
    art = art.rstrip("/\\")

    candidates = [PROJECT_ROOT / art, PROJECT_ROOT / "artigos" / art]
    for candidate in candidates:
        if (candidate / "main.tex").is_file():
            return candidate
    tried = ", ".join(str(c) for c in candidates)
    raise SystemExit(f"error: no main.tex found for article '{art}' (tried: {tried})")


def pdf_name(flavor: str, engine: str) -> str:
    """Matches the Makefile's PDF_NAME = main-$(FLAVOR)-$(ENGINE)."""
    return f"main-{flavor}-{engine}.pdf"


def ensure_image(flavor: str) -> None:
    """Build FLAVOR's Docker image if it isn't present locally yet, mirroring
    `make docker-build FLAVOR=...`. Streams build output live.
    """
    info = FLAVORS[flavor]
    check = subprocess.run(
        ["docker", "image", "inspect", info["image"]],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if check.returncode == 0:
        return
    print(
        f"Revinfor: image {info['image']} not found — building it now "
        "(first run, a few minutes)...",
        flush=True,
    )
    subprocess.run(
        ["docker", "build", "-t", info["image"], "-f", info["dockerfile"], "."],
        cwd=PROJECT_ROOT,
        check=True,
    )


def open_file(path: Path) -> None:
    """Open PATH with the OS's default handler (Linux/macOS/Windows)."""
    if sys.platform.startswith("win"):
        import os

        os.startfile(path)  # type: ignore[attr-defined]  # Windows-only API
    elif sys.platform == "darwin":
        subprocess.run(["open", str(path)], check=True)
    else:
        subprocess.run(["xdg-open", str(path)], check=True)
