#!/usr/bin/env python3
"""view_article.py — open one article's already-built PDF with the OS's
default viewer, e.g.:

    python3 view_article.py artigo_curso_defectologia_vigostky --flavor abnt

Portable (Linux/macOS/Windows) standalone counterpart to build_article.py, for
terminal use or any future GUI. The Emacs "Revinfor" menu does NOT call this
script for its own "View PDF" -- it keeps opening the PDF in-editor via
pdf-tools (SyncTeX support), which this script has no equivalent for.
"""

from __future__ import annotations

import argparse
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
    args = parser.parse_args()

    article_dir = common.resolve_article_dir(args.art)
    pdf_path = article_dir / common.pdf_name(args.flavor, args.engine)
    if not pdf_path.is_file():
        raise SystemExit(
            f"error: {pdf_path} not found yet — build it first "
            f"(build_article.py {args.art} --flavor {args.flavor} --engine {args.engine})"
        )

    common.open_file(pdf_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
