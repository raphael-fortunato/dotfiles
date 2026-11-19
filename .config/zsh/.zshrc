
# Enable keybindings
bindkey -e

# History setup
HISTFILE=$HOME/.config/zsh/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# Colors
autoload -U colors && colors

# Starship Prompt
eval "$(starship init zsh)"

# Source FZF integration
# Based on installation paths found earlier
# Case-insensitive search for fzf-cd-widget (Ctrl+T and Alt+C)
export FZF_ALT_C_OPTS="-i"
if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi

# Enable FZF keybindings (Ctrl+T, Ctrl+R, Alt+C)
# These are usually enabled by the scripts above, but just in case
bindkey '^T' fzf-cd-widget
bindkey '^R' fzf-history-widget

# Custom widget: fuzzy find directories from ~ and cd into them
fzf-home-cd-widget() {
  local dir
  dir=$(find ~ -type d 2>/dev/null | fzf -i +m) && cd "$dir"
  zle reset-prompt
}
zle -N fzf-home-cd-widget
bindkey '^G' fzf-home-cd-widget  # Ctrl+G

# Source Autosuggestions
if [ -f $HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source $HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Autosuggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=200
bindkey '^f' autosuggest-accept

# Zoxide (smarter cd)
eval "$(zoxide init zsh)"

# Syntax Highlighting
ZSH_HIGHLIGHT_MAXLENGTH=200
# Drop Windows dirs from PATH (slow /mnt/c lookups on every keystroke)
path=(${path:#/mnt/c/*})
# Must be sourced at the end
if [ -f $HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
   source $HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Aliases
alias ll='ls -l'
alias la='ls -la'
alias grep='grep --color=auto'
alias ..='cd ..'
alias perf='/usr/lib/linux-tools/6.8.0-110-generic/perf'
alias fix-mtu='sudo ip link set dev eth0 mtu 1350'

export FASTDDS_DEFAULT_PROFILES_FILE=~/projects/tops_dds_modules/external/tops_dds_lib/DEFAULT_FASTDDS_PROFILES.xml
#export FASTDDS_DEFAULT_PROFILES_FILE=~/projects/dds_tester/DEFAULT_FASTDDS_PROFILES.xml

export PYTHONPATH=/usr/local/lib/python3.12/dist-packages:/usr/local/lib/python3.12/site-packages:/usr/local/lib/python3/dist-packages:/usr/local/lib/python3/site-packages
export PATH="$HOME/.local/nvim-linux-x86_64/bin:$PATH"
#export ANDROID_HOME=$HOME/android-sdk
#export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
#export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH="$PATH:$HOME/flutter/bin"

# Point WSL2 to the Windows ADB server
#export WINDOWS_IP=$(ip route show default | awk '{print $3}')
#export ADB_SERVER_SOCKET=tcp:$WINDOWS_IP:5037

export PATH="$PATH:$HOME/.local/bin"

#export PUB_HOSTED_URL=https://ias-cloud.tno.nl/pub/
# export PUB_HOSTED_URL=https://ias-cloud.tno.nl/nexus/repository/pub-dev

