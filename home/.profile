export TERM=xterm-256color
export VISUAL=vim
export EDITOR=vim
export PATH="bin:${HOME}/bin:${PATH}"
export PS1='$(smart_loc)'
export DIRENV_LOG_FORMAT=

# .local_profile should contain local modifications not wanted for every install
source ~/.local_profile
