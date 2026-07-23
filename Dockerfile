# Custom LaTeX image for this project (default 'abnt' flavor).
#
# texlive/texlive:latest uses the FULL TeX Live scheme, so abntex2, abntex2cite
# and the Portuguese hyphenation / babel-portuges patterns are ALREADY present
# (verified with kpsewhich). No 'tlmgr install' is needed -- and running it here
# actually fails when the image's TeX Live year is older than the remote tlnet
# repository ("tlmgr is older than the repository"). If you ever DO need an
# extra package, prefer pinning the base image to a matching -historic tag.
FROM texlive/texlive:latest
