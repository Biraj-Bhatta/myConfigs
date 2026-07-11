set -o vi

shopt -s autocd
shopt -s cdspell
shopt -s dirspell
shopt -s checkwinsize

if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

eval "$(fzf --bash)"

lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ] && [ "$dir" != "$(pwd)" ]; then
            cd "$dir" || echo "Failed to cd to $dir"
        fi
    fi
}
bind '"\C-o":"lfcd\n"'

ex () {
  if [ -f "$1" ] ; then
      case $1 in
         *.tar.bz2)   tar xjf $1   ;;
         *.tar.gz)    tar xzf $1   ;;
         *.bz2)       bunzip2 $1   ;;
         *.rar)       unrar x $1   ;;
         *.gz)        gunzip $1    ;;
         *.tar)       tar xf $1    ;;
         *.tbz2)      tar xjf $1   ;;
         *.tgz)       tar xzf $1   ;;
         *.zip)       unzip $1     ;;
         *.Z)         uncompress $1;;
         *.7z)        7z x $1      ;;
         *.deb)       ar x $1      ;;
         *.tar.xz)    tar xf $1    ;;
         *.tar.zst)   unzstd $1    ;;
         *)           echo "'$1' cannot be extracted via ex()" ;;
      esac
  else
      echo "'$1' is not a valid file"
  fi
}

# pcc() {
#     if [ -z "$1" ]; then
#         echo "Usage: pcc filename"
#         return 1
#     elif [ ! -f "$1" ]; then
#         echo "File not found: $1"
#         return 1
#     fi
#     base="${1%.*}"
#     pandoc "$1" -o "$base.pdf" --pdf-engine=typst
# }

# Aliases
alias ls='ls --color=always --group-directories-first'
alias ll='eza --icons=always -lah --colour=always --classify=always --group-directories-first --show-symlinks'
alias grep='grep --color=auto'
alias ..='cd ..'
alias mkins="sudo make clean install"
alias v="nvim "
alias vim="nvim "
alias sv="sudoedit "
alias ka='killall '
alias pac='sudo pacman '
alias rm='rm -i'
# alias sphone='ssh -p 8022 u0_a169@192.168.1.33'
# alias mphone='sshfs u0_a169@192.168.1.33:storage /home/krishna/mnt/ -o follow_symlinks -p 8022'

parse_git_branch() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    status=$(git status --porcelain=v2 --branch 2>/dev/null) || return
    branch=$(echo "$status" | grep '^# branch.head' | cut -d' ' -f3)
    staged=$(echo "$status" | grep -E '^(1|2) [A-Z].' | wc -l)
    unstaged=$(echo "$status" | grep -E '^(1|2) .[A-Z]' | wc -l)
    untracked=$(echo "$status" | grep '^?' | wc -l)

    markers=""
    [ "$staged" -gt 0 ] && markers="${markers}+"
    [ "$unstaged" -gt 0 ] && markers="${markers}*"
    [ "$untracked" -gt 0 ] && markers="${markers}?"

    echo " [$branch$markers]"
}


export PS1='\[\e[1;33m\] 󰥳 \[\e[1;37m\] \w\[\e[0;32m\] $(parse_git_branch) \[\e[1;36m\]$\[\e[0;37m\] '
