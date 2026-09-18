#!/usr/bin/env python3
"""tex_to_jats.py — convert one article's main.tex (+ references.bib) into
JATS XML (Journal Publishing Tag Set 1.3), e.g.:

    python3 tex_to_jats.py artigo_modelo_revista_infor \
        --doi 10.12345/xxxx --volume 12 --issue 1 --fpage 5 --lpage 20

This is the Phase-2 script the tutorial describes but says "ainda não
existe" (JATS_XML_MAPEAMENTO_TUTORIAL.org, Seção 7). It implements exactly
the field-by-field mapping documented there:

  Seção 2 -- front-matter: \\titulo, \\tituloestrangeiroRevInfor,
             \\nomeAutorRevInfor/\\sobrenomeAutorRevInfor/\\anoRevInfor,
             \\autorRevInfor{nome}{afiliação}{email}{orcid}, the two
             \\resumo environments (+ \\palavraschaveRevInfor).
  Seção 3 -- body: \\section/\\subsection, paragraphs (blank-line
             separated), \\textit/\\textbf/\\underline, \\cite/
             \\citeonline, and bare \\includegraphics figures.
  Seção 4 -- \\back/<ref-list>: only the BibTeX entries actually cited in
             the body (article's own references.bib +
             common-shared/bib/references.bib), read with bibtexparser.

NOT implemented (the tutorial itself flags these as needing manual,
per-article work rather than being mechanical): LaTeX tables (Seção 3.4),
and any macro not listed above -- a real article that leans on other
abntex2/memoir commands in its body will need those handled by hand after
this script's first pass.

DOI, volume/issue/pages are not derivable from main.tex (Seção 2.5/2.6 of
the tutorial) -- they only exist once OJS assigns them, so they are CLI
flags, not something this script goes looking for in the .tex.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from xml.sax.saxutils import escape as xml_escape

sys.path.insert(0, str(Path(__file__).resolve().parent))
import revinfor_common as common  # noqa: E402

try:
    import bibtexparser
except ImportError:  # pragma: no cover - guidance path, not a code path
    raise SystemExit(
        "error: the 'bibtexparser' package is required (see Seção 4 of "
        "JATS_XML_MAPEAMENTO_TUTORIAL.org).\nInstall it with:\n"
        "    pip install bibtexparser"
    )

# Hard-coded journal-meta (Seção 2.1 of the tutorial) -- same for every
# article published in this journal, so it does not come from any main.tex.
JOURNAL_ID = "cdep3"
JOURNAL_TITLE = "InFor, Inov. Form., Rev. NEaD-Unesp"
PUBLISHER_NAME = "Universidade Estadual Paulista (UNESP) - NEaD"
CLS_PATH = common.PROJECT_ROOT / "common-shared" / "cls" / "Article_Class_RevInfor.cls"


def issn_from_cls() -> str:
    """Extract the ISSN from Article_Class_RevInfor.cls (Seção 2.1) instead
    of duplicating it as a second hard-coded constant here.
    """
    text = CLS_PATH.read_text(encoding="utf-8")
    match = re.search(r"ISSN\s+([\d]{4}-[\dXx]{4})", text)
    if not match:
        raise SystemExit(f"error: could not find an ISSN in {CLS_PATH}")
    return match.group(1)


# ---------------------------------------------------------------------------
# Low-level LaTeX parsing helpers (balanced braces -- \titulo{...} can nest
# \textit{...} inside it, so a plain "[^}]*" regex is not enough; see
# Seção 2.2's "Atenção" note in the tutorial).
# ---------------------------------------------------------------------------


def find_matching_brace(text: str, open_pos: int) -> int:
    """text[open_pos] must be '{'. Returns the index of its matching '}'."""
    assert text[open_pos] == "{"
    depth = 0
    for i in range(open_pos, len(text)):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                return i
    raise ValueError(f"unbalanced braces starting at {open_pos!r}")


def find_command(text: str, name: str, start: int = 0):
    """Find the next \\name occurrence at/after `start`. Returns
    (cmd_start, args_start) where args_start is the index right after the
    command name (where an optional [...] or required {...} may follow), or
    None if not found.
    """
    pattern = re.compile(r"\\" + re.escape(name) + r"(?![A-Za-z])")
    match = pattern.search(text, start)
    if not match:
        return None
    return match.start(), match.end()


def read_args(text: str, pos: int, nargs: int, optional: bool = False):
    """Starting at `pos` (right after a command name), skip whitespace and
    read `nargs` consecutive required {...} groups, honoring one leading
    optional [...] group when `optional` is True. Returns
    (list_of_required_args, optional_arg_or_None, end_pos).
    """
    opt_arg = None
    i = pos
    while i < len(text) and text[i] in " \t\n":
        i += 1
    if optional and i < len(text) and text[i] == "[":
        close = text.index("]", i)
        opt_arg = text[i + 1 : close]
        i = close + 1
        while i < len(text) and text[i] in " \t\n":
            i += 1
    args = []
    for _ in range(nargs):
        while i < len(text) and text[i] in " \t\n":
            i += 1
        if i >= len(text) or text[i] != "{":
            raise ValueError(f"expected '{{' at position {i} while reading args")
        close = find_matching_brace(text, i)
        args.append(text[i + 1 : close])
        i = close + 1
    return args, opt_arg, i


def extract_command(text: str, name: str, optional: bool = False, required: bool = True):
    """Convenience wrapper for a single \\name{...} (or \\name[...]{...}).
    Returns (required_arg_or_None, optional_arg_or_None). If the command
    isn't found: (None, None).
    """
    found = find_command(text, name)
    if not found:
        if required:
            return None, None
        return None, None
    _, args_start = found
    args, opt_arg, _ = read_args(text, args_start, 1, optional=optional)
    return args[0], opt_arg


def iter_command_args(text: str, name: str, nargs: int):
    """Yield the args list for every \\name{...}...{...} (nargs groups)
    occurrence in `text`, in document order.
    """
    pos = 0
    while True:
        found = find_command(text, name, pos)
        if not found:
            return
        _, args_start = found
        args, _opt, end = read_args(text, args_start, nargs)
        yield args
        pos = end


def strip_command(text: str, name: str, nargs: int = 1, optional: bool = False) -> str:
    """Remove every \\name{...} (nargs required groups, optionally one
    leading [...]) occurrence from `text`. Used to drop non-semantic
    commands (\\label, \\index) and to peel a nested command's own args out
    of a block once they've been extracted separately (e.g. removing
    \\palavraschaveRevInfor{...} from a resumo body after pulling its text).
    """
    out = []
    pos = 0
    while True:
        found = find_command(text, name, pos)
        if not found:
            out.append(text[pos:])
            break
        cmd_start, args_start = found
        out.append(text[pos:cmd_start])
        _args, _opt, end = read_args(text, args_start, nargs, optional=optional)
        pos = end
    return "".join(out)


def strip_latex_comments(text: str) -> str:
    """Drop '% ...' to end-of-line, but not the escaped '\\%'."""
    return re.sub(r"(?<!\\)%[^\n]*", "", text)


# ---------------------------------------------------------------------------
# Inline text: LaTeX -> JATS. Handles the three formatting commands and the
# two citation commands from Seção 3.2/3.3, recursively (so \\textbf{\\textit{x}}
# works), and escapes everything else for safe XML embedding.
# ---------------------------------------------------------------------------

LATEX_SPECIALS = {
    r"\&": "&", r"\%": "%", r"\_": "_", r"\#": "#", r"\$": "$",
    r"\{": "{", r"\}": "}", "``": "\u201c", "''": "\u201d",
    "---": "\u2014", "--": "\u2013", "~": " ",
}

INLINE_COMMANDS = {"textit": "italic", "textbf": "bold", "underline": "underline"}


def unescape_latex_specials(text: str) -> str:
    for latex, plain in LATEX_SPECIALS.items():
        text = text.replace(latex, plain)
    return text


def latex_inline_to_xml(text: str, cite_index: dict) -> str:
    """Convert a run of LaTeX body text (no blank lines) into an XML-safe
    string with real <italic>/<bold>/<underline>/<xref> tags mixed in with
    escaped literal text, ready to be wrapped as "<p>...</p>" and parsed.
    """
    out = []
    pos = 0
    cmd_re = re.compile(
        r"\\(textit|textbf|underline|cite|citeonline)(?![A-Za-z])"
    )
    while True:
        match = cmd_re.search(text, pos)
        if not match:
            out.append(xml_escape(unescape_latex_specials(text[pos:])))
            break
        out.append(xml_escape(unescape_latex_specials(text[pos : match.start()])))
        name = match.group(1)
        args, _opt, end = read_args(text, match.end(), 1)
        inner = args[0]
        if name in INLINE_COMMANDS:
            tag = INLINE_COMMANDS[name]
            out.append(f"<{tag}>{latex_inline_to_xml(inner, cite_index)}</{tag}>")
        else:
            out.append(render_citation(name, inner, cite_index))
        pos = end
    return "".join(out)


def render_citation(command: str, keys_arg: str, cite_index: dict) -> str:
    """\\cite{k1,k2} -> "(Silva, 2020; Souza, 2019)" with one <xref> per key.
    \\citeonline{k1,k2} -> "Silva (2020); Souza (2019)" (author-prominent,
    per Seção 3.3 of the tutorial -- extended here to accept several keys
    the same way \\cite does, since abntex2cite allows it).
    """
    keys = [k.strip() for k in keys_arg.split(",") if k.strip()]
    pieces = []
    for key in keys:
        entry = cite_index.get(key)
        label = entry["author_year"] if entry else f"?{key}?"
        rid = f"ref-{key}"
        if command == "cite":
            pieces.append(f'<xref ref-type="bibr" rid="{xml_escape(rid)}">{xml_escape(label)}</xref>')
        else:
            surname, year = (label.rsplit(", ", 1) + [""])[:2] if ", " in label else (label, "")
            text = f"{surname} ({year})" if year else label
            pieces.append(f'<xref ref-type="bibr" rid="{xml_escape(rid)}">{xml_escape(text)}</xref>')
    if command == "cite":
        return "(" + "; ".join(pieces) + ")"
    return "; ".join(pieces)


# ---------------------------------------------------------------------------
# BibTeX -> JATS <ref-list> (Seção 4)
# ---------------------------------------------------------------------------

LATEX_ACCENT_MACROS = [
    (r"\{\\'([aeiouAEIOU])\}", "acute"), (r"\\'([aeiouAEIOU])", "acute"),
    (r"\{\\`([aeiouAEIOU])\}", "grave"), (r"\\`([aeiouAEIOU])", "grave"),
    (r"\{\\\^([aeiouAEIOU])\}", "circ"), (r"\\\^([aeiouAEIOU])", "circ"),
    (r'\{\\"([aeiouAEIOU])\}', "uml"), (r'\\"([aeiouAEIOU])', "uml"),
    (r"\{\\~([anoANO])\}", "tilde"), (r"\\~([anoANO])", "tilde"),
    (r"\{\\c\s*([cC])\}", "cedil"), (r"\\c\s*([cC])", "cedil"),
]

ACCENT_TABLE = {
    "acute": {"a": "á", "e": "é", "i": "í", "o": "ó", "u": "ú",
              "A": "Á", "E": "É", "I": "Í", "O": "Ó", "U": "Ú"},
    "grave": {"a": "à", "e": "è", "i": "ì", "o": "ò", "u": "ù",
              "A": "À", "E": "È", "I": "Ì", "O": "Ò", "U": "Ù"},
    "circ": {"a": "â", "e": "ê", "i": "î", "o": "ô", "u": "û",
             "A": "Â", "E": "Ê", "I": "Î", "O": "Ô", "U": "Û"},
    "uml": {"a": "ä", "e": "ë", "i": "ï", "o": "ö", "u": "ü",
            "A": "Ä", "E": "Ë", "I": "Ï", "O": "Ö", "U": "Ü"},
    "tilde": {"a": "ã", "n": "ñ", "o": "õ", "A": "Ã", "N": "Ñ", "O": "Õ"},
    "cedil": {"c": "ç", "C": "Ç"},
}


def latex_to_unicode(text: str) -> str:
    """Best-effort cleanup for BibTeX field values: resolves the common
    LaTeX accent macros (needed for common-shared/bib/references.bib, which
    stores accents as \\c{c}/\\~a/... rather than raw UTF-8 -- see Seção 4
    of the tutorial), then drops leftover bare braces (pure LaTeX grouping
    with no visual effect once the accent macros are gone).
    """
    for pattern, kind in LATEX_ACCENT_MACROS:
        text = re.sub(pattern, lambda m: ACCENT_TABLE[kind].get(m.group(1), m.group(1)), text)
    text = unescape_latex_specials(text)
    text = text.replace("{", "").replace("}", "")
    return text


def bib_author_year(entry_fields: dict) -> str:
    author_field = latex_to_unicode(entry_fields.get("author", entry_fields.get("Author", "")))
    first_author = author_field.split(" and ")[0].strip()
    if "," in first_author:
        surname = first_author.split(",")[0].strip()
    else:
        words = first_author.split()
        surname = words[-1] if words else "?"
    year = latex_to_unicode(entry_fields.get("year", entry_fields.get("Year", "")))
    return f"{surname}, {year}" if year else surname


ENTRY_TYPE_TO_PUBLICATION_TYPE = {
    "article": "journal", "book": "book", "incollection": "book",
    "inproceedings": "confproc", "conference": "confproc",
    "phdthesis": "thesis", "mastersthesis": "thesis",
    "techreport": "report", "online": "webpage", "misc": "other",
}


def load_bib_fields(*bib_paths: Path) -> dict:
    """Read one or more .bib files with bibtexparser and return
    {key: {field_name_lowercase: cleaned_value, "_entry_type": type}}.
    """
    fields_by_key = {}
    for bib_path in bib_paths:
        if not bib_path.is_file():
            continue
        library = bibtexparser.parse_file(str(bib_path))
        for entry in library.entries:
            fields = {k.lower(): latex_to_unicode(v.value) for k, v in entry.fields_dict.items()}
            fields["_entry_type"] = entry.entry_type
            fields_by_key[entry.key] = fields
    return fields_by_key


def build_cite_index(bib_fields: dict) -> dict:
    return {key: {"author_year": bib_author_year(fields)} for key, fields in bib_fields.items()}


def bib_entry_to_ref_xml(key: str, fields: dict) -> str:
    entry_type = fields.get("_entry_type", "misc")
    pub_type = ENTRY_TYPE_TO_PUBLICATION_TYPE.get(entry_type, "other")

    persons = []
    author_field = fields.get("author", "")
    for person in author_field.split(" and "):
        person = person.strip()
        if not person:
            continue
        if "," in person:
            surname, given = (p.strip() for p in person.split(",", 1))
        else:
            parts = person.split()
            surname, given = (parts[-1], " ".join(parts[:-1])) if len(parts) > 1 else (person, "")
        persons.append(
            f"<name><surname>{xml_escape(surname)}</surname>"
            f"<given-names>{xml_escape(given)}</given-names></name>"
        )
    person_group = (
        f'<person-group person-group-type="author">{"".join(persons)}</person-group>'
        if persons else ""
    )

    title = fields.get("title", "")
    title_tag = "article-title" if entry_type == "article" else "source"
    title_xml = f"<{title_tag}>{xml_escape(title)}</{title_tag}>"

    source_xml = ""
    journal = fields.get("journal", "")
    if journal and entry_type == "article":
        source_xml = f"<source>{xml_escape(journal)}</source>"

    extras = []
    if fields.get("year"):
        extras.append(f"<year>{xml_escape(fields['year'])}</year>")
    if fields.get("volume"):
        extras.append(f"<volume>{xml_escape(fields['volume'])}</volume>")
    if fields.get("number"):
        extras.append(f"<issue>{xml_escape(fields['number'])}</issue>")
    if fields.get("pages"):
        parts = re.split(r"-+", fields["pages"])
        fpage = parts[0].strip()
        lpage = parts[-1].strip() if len(parts) > 1 else ""
        extras.append(f"<fpage>{xml_escape(fpage)}</fpage>")
        if lpage:
            extras.append(f"<lpage>{xml_escape(lpage)}</lpage>")
    if fields.get("publisher"):
        extras.append(f"<publisher-name>{xml_escape(fields['publisher'])}</publisher-name>")
    if fields.get("doi"):
        extras.append(f'<pub-id pub-id-type="doi">{xml_escape(fields["doi"])}</pub-id>')

    body = person_group + title_xml + source_xml + "".join(extras)
    return f'<ref id="ref-{xml_escape(key)}"><element-citation publication-type="{pub_type}">{body}</element-citation></ref>'


# ---------------------------------------------------------------------------
# Front matter (Seção 2)
# ---------------------------------------------------------------------------


def build_front_matter(tex: str, cite_index: dict, args: argparse.Namespace) -> str:
    issn = issn_from_cls()
    journal_meta = (
        "<journal-meta>"
        f'<journal-id journal-id-type="publisher-id">{xml_escape(JOURNAL_ID)}</journal-id>'
        f"<journal-title-group><journal-title>{xml_escape(JOURNAL_TITLE)}</journal-title></journal-title-group>"
        f'<issn pub-type="epub">{xml_escape(issn)}</issn>'
        f"<publisher><publisher-name>{xml_escape(PUBLISHER_NAME)}</publisher-name></publisher>"
        "</journal-meta>"
    )

    titulo, _ = extract_command(tex, "titulo")
    if titulo is None:
        raise SystemExit(r"error: no \titulo{...} found in main.tex")
    trans_titulo, _ = extract_command(tex, "tituloestrangeiroRevInfor")

    title_group = f"<title-group><article-title>{latex_inline_to_xml(titulo, cite_index)}</article-title>"
    if trans_titulo:
        title_group += (
            '<trans-title-group xml:lang="en">'
            f"<trans-title>{latex_inline_to_xml(trans_titulo, cite_index)}</trans-title>"
            "</trans-title-group>"
        )
    title_group += "</title-group>"

    nome, _ = extract_command(tex, "nomeAutorRevInfor")
    sobrenome, _ = extract_command(tex, "sobrenomeAutorRevInfor")
    ano, _ = extract_command(tex, "anoRevInfor")

    contribs = []
    for nome_arg, afiliacao, email, orcid in iter_command_args(tex, "autorRevInfor", 4):
        if nome_arg.strip() == r"\nomeCompletoAutorRevInfor":
            surname, given = sobrenome or "", nome or ""
        else:
            # Extra \autorRevInfor calls beyond the first author don't have
            # their own \nomeAutorRevInfor/\sobrenomeAutorRevInfor pair (the
            # class only stores one), so a literal "Given Surname" here is
            # split heuristically: last word is the surname (Seção 2.3 note).
            parts = latex_inline_to_xml(nome_arg, cite_index).split()
            surname, given = (parts[-1], " ".join(parts[:-1])) if len(parts) > 1 else (nome_arg.strip(), "")
        contribs.append(
            "<contrib contrib-type=\"author\">"
            f'<contrib-id contrib-id-type="orcid">https://orcid.org/{xml_escape(orcid.strip())}</contrib-id>'
            f"<name><surname>{xml_escape(surname)}</surname><given-names>{xml_escape(given)}</given-names></name>"
            f"<email>{xml_escape(email.strip())}</email>"
            f"<aff>{latex_inline_to_xml(afiliacao, cite_index)}</aff>"
            "</contrib>"
        )
    contrib_group = f"<contrib-group>{''.join(contribs)}</contrib-group>" if contribs else ""

    abstracts = []
    resumo_re = re.compile(r"\\begin\{resumo\}(?:\[(?P<opt>[^\]]*)\])?(?P<body>.*?)\\end\{resumo\}", re.DOTALL)
    for match in resumo_re.finditer(tex):
        is_english = (match.group("opt") or "").strip().lower() == "abstract"
        body = match.group("body")
        keywords_raw, kwd_opt = extract_command(body, "palavraschaveRevInfor", optional=True)
        body = strip_command(body, "palavraschaveRevInfor", optional=True)
        body = re.sub(r"\\begin\{otherlanguage\*?\}\{[^}]*\}", "", body)
        body = re.sub(r"\\end\{otherlanguage\*?\}", "", body)
        paragraphs = [p.strip() for p in re.split(r"\n\s*\n", body) if p.strip()]
        lang = "en" if is_english else "pt"
        tag = "trans-abstract" if is_english else "abstract"
        paras_xml = "".join(f"<p>{latex_inline_to_xml(p, cite_index)}</p>" for p in paragraphs)
        abstracts.append(f'<{tag} xml:lang="{lang}">{paras_xml}</{tag}>')
        if keywords_raw:
            terms = [t.strip().rstrip(".").strip() for t in keywords_raw.strip().rstrip(".").split(". ")]
            kwds = "".join(f"<kwd>{xml_escape(unescape_latex_specials(t))}</kwd>" for t in terms if t)
            abstracts.append(f'<kwd-group xml:lang="{lang}">{kwds}</kwd-group>')

    article_id = f'<article-id pub-id-type="doi">{xml_escape(args.doi)}</article-id>' if args.doi else ""
    pub_date = f"<pub-date publication-format=\"electronic\"><year>{xml_escape(ano or '')}</year></pub-date>"

    article_meta = (
        "<article-meta>"
        + article_id
        + title_group
        + contrib_group
        + pub_date
        + "".join(abstracts)
        + "</article-meta>"
    )
    return f"<front>{journal_meta}{article_meta}</front>"


# ---------------------------------------------------------------------------
# Body (Seção 3)
# ---------------------------------------------------------------------------

FIGURE_RE = re.compile(r"^\\includegraphics(?:\[[^\]]*\])?\{([^}]*)\}$")


def blocks_to_xml(content: str, cite_index: dict) -> str:
    """Split a section/subsection's raw text into <p>/<fig> blocks on blank
    lines (Seção 3.1's "regra prática"), skipping \\lipsum placeholders
    (they have no extractable text -- generated at LaTeX compile time) and
    turning a standalone \\includegraphics into a <fig> (Seção 3.5).
    """
    out = []
    for raw in re.split(r"\n\s*\n", content):
        block = raw.strip()
        if not block:
            continue
        if re.fullmatch(r"\\lipsum(?:\[[^\]]*\])?", block):
            print(f"warning: skipping \\lipsum placeholder (no extractable text): {block}", file=sys.stderr)
            continue
        fig_match = FIGURE_RE.match(block)
        if fig_match:
            out.append(f'<fig><graphic xlink:href="{xml_escape(fig_match.group(1))}"/></fig>')
            continue
        out.append(f"<p>{latex_inline_to_xml(block, cite_index)}</p>")
    return "".join(out)


def build_body(tex: str, cite_index: dict) -> str:
    textual_match = re.search(r"\\textual\b", tex)
    postextual_match = re.search(r"\\postextual\b", tex)
    if not textual_match or not postextual_match:
        raise SystemExit(r"error: could not find \textual ... \postextual in main.tex")
    body_tex = tex[textual_match.end() : postextual_match.start()]
    body_tex = strip_command(body_tex, "label")

    sections = []
    pos = 0
    section_positions = []
    while True:
        found = find_command(body_tex, "section", pos)
        if not found:
            break
        section_positions.append(found)
        pos = found[1]

    for idx, (cmd_start, args_start) in enumerate(section_positions):
        (title,), _opt, content_start = read_args(body_tex, args_start, 1)
        content_end = section_positions[idx + 1][0] if idx + 1 < len(section_positions) else len(body_tex)
        raw_content = body_tex[content_start:content_end]
        sections.append(build_section(title, raw_content, cite_index))
    return f"<body>{''.join(sections)}</body>"


def build_section(title: str, raw_content: str, cite_index: dict) -> str:
    sub_positions = []
    pos = 0
    while True:
        found = find_command(raw_content, "subsection", pos)
        if not found:
            break
        sub_positions.append(found)
        pos = found[1]

    intro_end = sub_positions[0][0] if sub_positions else len(raw_content)
    intro_xml = blocks_to_xml(raw_content[:intro_end], cite_index)

    subsections_xml = []
    for idx, (cmd_start, args_start) in enumerate(sub_positions):
        (sub_title,), _opt, content_start = read_args(raw_content, args_start, 1)
        content_end = sub_positions[idx + 1][0] if idx + 1 < len(sub_positions) else len(raw_content)
        sub_body_xml = blocks_to_xml(raw_content[content_start:content_end], cite_index)
        subsections_xml.append(f"<sec><title>{xml_escape(sub_title)}</title>{sub_body_xml}</sec>")

    return f"<sec><title>{xml_escape(unescape_latex_specials(title))}</title>{intro_xml}{''.join(subsections_xml)}</sec>"


# ---------------------------------------------------------------------------
# References actually cited in the body (Seção 4) -- not the whole
# bibliography file, which typically holds entries unrelated to this article.
# ---------------------------------------------------------------------------


def find_cited_keys(tex: str) -> list:
    keys = []
    seen = set()
    for match in re.finditer(r"\\(?:cite|citeonline)\{([^}]*)\}", tex):
        for key in match.group(1).split(","):
            key = key.strip()
            if key and key not in seen:
                seen.add(key)
                keys.append(key)
    return keys


def build_back(tex: str, bib_fields: dict) -> str:
    cited_keys = find_cited_keys(tex)
    refs = []
    for key in cited_keys:
        fields = bib_fields.get(key)
        if fields is None:
            print(f"warning: \\cite{{{key}}} used but '{key}' not found in any references.bib", file=sys.stderr)
            continue
        refs.append(bib_entry_to_ref_xml(key, fields))
    if not refs:
        return ""
    return f"<back><ref-list>{''.join(refs)}</ref-list></back>"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def find_bibliography_paths(tex: str, article_dir: Path) -> list:
    match = re.search(r"\\bibliography\{([^}]*)\}", tex)
    if not match:
        return [article_dir / "references.bib"]
    paths = []
    for stem in match.group(1).split(","):
        stem = stem.strip()
        path = (article_dir / stem).resolve()
        paths.append(path if path.suffix == ".bib" else path.with_suffix(".bib"))
    return paths


def convert(article_dir: Path, args: argparse.Namespace) -> str:
    tex = strip_latex_comments((article_dir / "main.tex").read_text(encoding="utf-8"))

    bib_paths = find_bibliography_paths(tex, article_dir)
    bib_fields = load_bib_fields(*bib_paths)
    cite_index = build_cite_index(bib_fields)

    front = build_front_matter(tex, cite_index, args)
    body = build_body(tex, cite_index)
    back = build_back(tex, bib_fields)

    article = (
        '<article xmlns:xlink="http://www.w3.org/1999/xlink" '
        'article-type="research-article" xml:lang="pt">'
        f"{front}{body}{back}</article>"
    )
    return article


def prettify(article_xml: str) -> str:
    """Round-trip through ElementTree to indent the output; ET.indent needs
    Python 3.9+ (already required by this project's Docker images/tutorials).
    """
    root = ET.fromstring(article_xml)
    ET.indent(root, space="  ")
    pretty = ET.tostring(root, encoding="unicode")
    # ElementTree only re-emits a namespace declaration if some element in
    # the tree actually uses it -- an article with no <fig>/xlink:href (e.g.
    # the model article) would silently lose xmlns:xlink from <article>
    # otherwise, even though Seção 1 of the tutorial requires it on every
    # article root regardless of whether this particular one has figures.
    if "xmlns:xlink=" not in pretty.split(">", 1)[0]:
        pretty = pretty.replace(
            "<article ", '<article xmlns:xlink="http://www.w3.org/1999/xlink" ', 1
        )
    return pretty


DOCTYPE = (
    '<!DOCTYPE article PUBLIC '
    '"-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.3 20210610//EN" '
    '"JATS-journalpublishing1.dtd">'
)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        "art", help="Article folder, e.g. artigo_modelo_revista_infor "
        "or artigos/artigo_modelo_revista_infor"
    )
    parser.add_argument("--doi", default="", help="DOI assigned by OJS (Seção 2.5); omitted if not given")
    parser.add_argument("--output", help="Output path (default: <article_dir>/main.jats.xml)")
    parser.add_argument("--xsd", help="Path to JATS-journalpublishing1.xsd to validate against with xmllint")
    args = parser.parse_args()

    article_dir = common.resolve_article_dir(args.art)
    article_xml = convert(article_dir, args)

    try:
        pretty = prettify(article_xml)
    except ET.ParseError as exc:
        raise SystemExit(f"error: generated XML is not well-formed ({exc}); this is a bug in tex_to_jats.py")

    output_path = Path(args.output) if args.output else article_dir / "main.jats.xml"
    output_path.write_text(f'<?xml version="1.0" encoding="UTF-8"?>\n{DOCTYPE}\n{pretty}\n', encoding="utf-8")
    print(f"Revinfor: generated {output_path}")

    if args.xsd:
        result = subprocess.run(["xmllint", "--noout", "--schema", args.xsd, str(output_path)])
        if result.returncode != 0:
            return result.returncode
        print("Revinfor: XML validated OK against", args.xsd)
    return 0


if __name__ == "__main__":
    sys.exit(main())
