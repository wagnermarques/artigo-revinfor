FROM texlive/texlive:latest

# Install abntex2 and the Portuguese hyphenation patterns (babel-portuges),
# which are not included in the base texlive image scheme.
RUN tlmgr install abntex2 babel-portuges \
    && fmtutil-sys --quiet --all > /dev/null
