FROM pandoc/extra
RUN apk update && \
    apk upgrade && \
    apk add pipx
RUN pipx install pandoc-latex-environment
RUN tlmgr install moloch
RUN tlmgr install oberdiek 
RUN tlmgr install pdfcol 
RUN tlmgr install changepage 
RUN tlmgr install cancel 
RUN tlmgr install xcolor 
RUN wget https://raw.githubusercontent.com/pandoc-ext/fonts-and-alignment/main/fonts-and-alignment.lua -P /usr/local/share/pandoc/filters/
