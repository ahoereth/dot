# props @Faedrivin

PROMPT='%(?.%F{green}.%F{red})%#%{%F{249}%} '
RPS1='$(basename `git rev-parse --show-toplevel`) $(git_prompt_info)%{%F{220}%}%2~%{%f%}'

ZSH_THEME_GIT_PROMPT_PREFIX='%{%F{60}%}'
ZSH_THEME_GIT_PROMPT_SUFFIX='%f '
ZSH_THEME_GIT_PROMPT_DIRTY=' %F{red}!'
ZSH_THEME_GIT_PROMPT_CLEAN=''