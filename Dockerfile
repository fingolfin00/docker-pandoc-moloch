FROM pandoc/latex:3.8.3

# Use apk since image is Alpine-based
RUN apk add --no-cache python3 py3-pip bash wget ca-certificates xz curl jq build-base font-liberation font-dejavu

# Install python + tools, create venv
ENV VENV_DIR=/opt/venv
RUN python3 -m venv "${VENV_DIR}" \
 && "${VENV_DIR}/bin/python" -m pip install --upgrade pip setuptools wheel \
 && "${VENV_DIR}/bin/pip" install --no-cache-dir pandoc-latex-environment \
 && ln -s "${VENV_DIR}/bin/pandoc-latex-environment" /usr/local/bin/pandoc-latex-environment

ENV PATH="${VENV_DIR}/bin:${PATH}"

# Install LaTeX packages we saw missing (ignore failures to keep build resilient)
# Pin tlmgr to the TeX Live 2025 repository to avoid cross-release errors
RUN tlmgr option repository https://ftp.tu-chemnitz.de/pub/tug/historic/systems/texlive/2025/tlnet-final
RUN tlmgr update --self || true
RUN tlmgr install siunitx xkeyval footnotebackref varwidth pdflscape pagecolor mdframed zref needspace
RUN tlmgr install titling sourcesanspro sourcecodepro footmisc xcolor inconsolata oberdiek moloch pdfcol
RUN tlmgr install changepage cancel koma-script
RUN tlmgr install etoolbox l3kernel l3packages
RUN tlmgr install amsmath
# Very long install
RUN tlmgr install collection-latexrecommended collection-latexextra collection-fontsrecommended collection-fontsextra latexmk
RUN tlmgr install collection-xetex
RUN tlmgr update --all

# Copy custom templates (keep it here to take advantage of caching)
COPY eisvogel-thesis.tex /usr/local/share/pandoc/templates/eisvogel-thesis.tex
COPY eisvogel.tex /usr/local/share/pandoc/templates/eisvogel.tex

# Add pandoc filters
RUN mkdir -p /usr/local/share/pandoc/filters \
 && wget -q https://raw.githubusercontent.com/pandoc-ext/fonts-and-alignment/main/fonts-and-alignment.lua -P /usr/local/share/pandoc/filters/ \
 && wget -q https://raw.githubusercontent.com/pandoc-ext/abstract-section/main/_extensions/abstract-section/abstract-section.lua -P /usr/local/share/pandoc/filters/

WORKDIR /data
ENTRYPOINT ["pandoc"]
