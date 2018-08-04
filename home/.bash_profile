alias devkill="tmux kill-session -t dev"

alias sgrep='egrep --exclude-dir .git --exclude-dir log --exclude-dir tmp -r'

# AWS aliases
alias aws-cfn='aws cloudformation'

# Source .envrc files as we move around
eval "$(direnv hook bash)"
