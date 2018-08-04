export TERM=xterm-256color
export VISUAL=vim
export EDITOR=vim
export PATH="bin:${HOME}/bin:${PATH}"
export PS1='$(smart_loc)'

# .local_profile should contain local modifications not wanted for every install
source ~/.local_profile
