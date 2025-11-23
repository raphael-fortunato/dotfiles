# install starship
if [ ! $(command -v starship) ]; then
    echo "Installing starship"
    sh -c "$(curl -fsSL https://starship.rs/install.sh)"
fi
eval "$(starship init zsh)"

unsetopt flowcontrol
unsetopt menu_complete
setopt appendhistory
setopt autocd extendedglob histignorealldups
setopt interactive_comments
setopt auto_menu
setopt complete_in_word
setopt always_to_end
stty stop undef		# Disable ctrl-s to freeze terminal.
zle_highlight=('paste:none')

# beeping is annoying
unsetopt BEEP


# completions
# autoload -Uz compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
autoload -U compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}' menu select
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion::complete:lsof:*' menu yes select
zmodload zsh/complist
# compinit
_comp_options+=(globdots)		# Include hidden files.

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Colors
autoload -Uz colors && colors

HIST_STAMPS="dd/mm/yyyy"
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$XDG_CACHE_HOME/zsh/history"

source $XDG_CONFIG_HOME/shell/aliasrc
source $XDG_CONFIG_HOME/shell/shortcutrc
source $ZDOTDIR/zsh_functions
source $ZDOTDIR/zsh-completions.plugin.zsh

#source zsh functions
zsh_add_file "zsh_vim_mode"
# zsh_add_file "zsh_prompt"

#Plugins
zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"
zsh_add_plugin "hlissner/zsh-autopair"
zsh_add_plugin "zsh-fzf"

# Key-bindings
bindkey -v
export KEYTIMEOUT=0

bindkey -s '^o' 'lf^M'
bindkey -s '^s' 'ncdu^M'
bindkey -s '^e' '$EDITOR "$(find -maxdepth 4 -type f| fzf)"^M'
bindkey -s '^z' 'zi^M'
bindkey '^f' autosuggest-accept
bindkey '^[[P' delete-char
bindkey "^n" up-line-or-beginning-search # Up
bindkey "^p" down-line-or-beginning-search # Down
bindkey '^n' expand-or-complete
bindkey '^p' reverse-menu-complete
bindkey '^u' backward-kill-line
# bindkey -r "^u"
# bindkey -r "^d"

eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"
eval "$(pyenv init -)"

#install zoxide
if [ ! $(command -v zoxide) ]; then
    echo "installing zoxide"
    curl -sS https://webinstall.dev/zoxide | bash
fi
eval "$(zoxide init zsh)"

#fzf bindings
# source /usr/share/fzf/key-bindings.zsh
# source /usr/share/fzf/completion.zsh
#zsh auto suggest
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }
source ~/.config/shell/shortcutrc

if [[ $TTY == /dev/tty1 ]] && [[ -z $DISPLAY ]]; then
  exec startx
fi
