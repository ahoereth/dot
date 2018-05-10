# ahoereth/tex

Docker image providing everything to build whatever your tex and pandoc heart desires. If something is missing, feel free to send a PR -- this image is not intendet to be small, but instead the *one-stop-tex-shop*.

## Usage

```Shell
docker run -it -v $(pwd):/wd ahoereth/tex pdflatex
```

Shorter multi use:

```Shell
alias d="docker run -it -v $(pwd):/wd -w /wd"
d ahoereth/tex pdflatex
```