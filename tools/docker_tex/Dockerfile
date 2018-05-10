FROM ubuntu:16.04

COPY texlive.profile /

RUN apt-get -qq -y update --fix-missing \
 && apt-get -qq -y install --no-install-recommends \
      wget libswitch-perl haskell-platform make \
      python3 python3-dev python3-pip python3-setuptools \
 && wget -qO- http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | tar xz \
 && cd install-tl-* \
 && ./install-tl -profile /texlive.profile \
 && rm -rf install-tl-* \
 && apt-get remove --purge -qq $PACKAGES \
 && apt-get autoremove --purge -qq \
 && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/jgm/pandoc/releases/download/2.0.4/pandoc-2.0.4-1-amd64.deb \
 && dpkg -i pandoc-*.deb \
 && rm pandoc-*.deb

RUN wget -qO- https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.0.0-beta3/linux-ghc8-pandoc-2-0.tar.gz | tar xz \
 && mv pandoc-crossref /bin/pandoc-crossref

# RUN cabal install https://github.com/lierdakil/pandoc-crossref/archive/v0.3.0.0-beta.tar.gz
# RUN cabal update \
#  && cabal install pandoc-crossref

# pandoc pandoc-citeproc

ENV PATH="/root/.cabal/bin:${PATH}"
ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"
ENV MANPATH="/usr/local/texlive/texmf-dist/doc/man:${MANPATH}"
ENV INFOPATH="/usr/local/texlive/texmf-dist/doc/info:${INFOPATH}"

RUN pip3 --no-cache-dir --disable-pip-version-check -q install \
      pandocfilters jinja2

RUN mkdir /wd
WORKDIR /wd