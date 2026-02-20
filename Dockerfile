FROM pandoc/latex:3.8.3

# Use apk since image is Alpine-based
RUN apk add --no-cache python3 py3-pip bash wget ca-certificates xz curl jq build-base || true

# Install python + tools, create venv
ENV VENV_DIR=/opt/venv
RUN python3 -m venv "${VENV_DIR}" \
 && "${VENV_DIR}/bin/python" -m pip install --upgrade pip setuptools wheel \
 && "${VENV_DIR}/bin/pip" install --no-cache-dir pandoc-latex-environment \
 && ln -s "${VENV_DIR}/bin/pandoc-latex-environment" /usr/local/bin/pandoc-latex-environment || true

ENV PATH="${VENV_DIR}/bin:${PATH}"

# Install LaTeX packages we saw missing (ignore failures to keep build resilient)
RUN tlmgr update --self || true \
 && tlmgr install siunitx xkeyval footnotebackref varwidth pdflscape pagecolor mdframed zref needspace || true \
 && tlmgr install titling sourcesanspro sourcecodepro footmisc xcolor inconsolata oberdiek moloch pdfcol changepage cancel koma-script || true \
 && tlmgr install array xparse xcolor xkeyval etoolbox l3kernel l3packages || true \
 && tlmgr update --all

# Add pandoc filters
RUN mkdir -p /usr/local/share/pandoc/filters \
 && wget -q https://raw.githubusercontent.com/pandoc-ext/fonts-and-alignment/main/fonts-and-alignment.lua -P /usr/local/share/pandoc/filters/ \
 && wget -q https://raw.githubusercontent.com/pandoc-ext/abstract-section/main/_extensions/abstract-section/abstract-section.lua -P /usr/local/share/pandoc/filters/

WORKDIR /data
ENTRYPOINT ["pandoc"]
