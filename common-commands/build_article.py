#!/usr/bin/env python3
"""build_article.py — build one article's PDF inside the project's Docker
image, e.g.:

    python3 build_article.py artigo_curso_defectologia_vigostky --flavor abnt

Portable Python port of the root Makefile's `build:` target (see ../Makefile),
so both stay in sync on naming (main-<flavor>-<engine>.pdf) and only one place
(revinfor_common.py) knows about Docker image/Dockerfile choices. Meant to be
called from a terminal, from the Emacs "Revinfor" menu, or from any future
GUI -- it takes plain arguments and streams its own output, no editor-specific
assumptions.

On success, opens the generated PDF with the OS's default viewer (see
revinfor_common.open_file) unless --no-open is given -- the Emacs "Revinfor"
menu passes --no-open, since it opens the PDF itself in-editor via pdf-tools.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import revinfor_common as common  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "art", help="Article folder, e.g. artigo_modelo_revista_infor "
        "or artigos/artigo_modelo_revista_infor"
    )
    parser.add_argument(
        "--flavor", choices=sorted(common.FLAVORS), default="abnt",
        help="Container flavor (default: abnt)",
    )
    parser.add_argument(
        "--engine", choices=sorted(common.ENGINE_FLAGS), default="pdf",
        help="LaTeX engine (default: pdf)",
    )
    parser.add_argument(
        "--no-open", action="store_true",
        help="Don't open the generated PDF with the OS default viewer afterwards",
    )
    args = parser.parse_args()

    article_dir = common.resolve_article_dir(args.art)
    common.ensure_image(args.flavor)

    image = common.FLAVORS[args.flavor]["image"]
    engine_flag = common.ENGINE_FLAGS[args.engine]
    pdf_filename = common.pdf_name(args.flavor, args.engine)
    jobname = pdf_filename[: -len(".pdf")]
    workdir = "/workdir/" + article_dir.relative_to(common.PROJECT_ROOT).as_posix()

    result = subprocess.run([
        "docker", "run", "--rm",
        "-v", f"{common.PROJECT_ROOT}:/workdir",
        "-w", workdir,
        image,
        "latexmk", engine_flag, f"-jobname={jobname}",
        "-interaction=nonstopmode", "main.tex",
    ])
    if result.returncode != 0:
        return result.returncode

    pdf_path = article_dir / pdf_filename
    print(f"Revinfor: generated {pdf_path}")
    if not args.no_open:
        common.open_file(pdf_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
