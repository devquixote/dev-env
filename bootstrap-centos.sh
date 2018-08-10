#!/usr/bin/bash
set -o nounset
set -o errexit
set -o xtrace

function setup() {
  yum update -y
}

function install_desktop() {
  local default_target="/etc/systemd/system/default.target"

  yum groups install -y "GNOME Desktop" "Graphical Administration Tools"

  if [ -f "${default_target}" ]; then
    mv "${default_target}" "${default_target}.bak"
  fi

  ln -sf /lib/systemd/system/runlevel5.target "${default_target}"

  # install the arc, arc-dark and arc-darker gnome3 themes;
  # will need to be manually activated later in gnome3
  yum -y install gnome-shell-extension-user-theme arc-theme
}

function pre_packages() {
  yum localinstall -y https://centos7.iuscommunity.org/ius-release.rpm
  yum install epel-release
}

function install_essentials() {
  yum install -y unzip
}

function install_openssl() {
  yum install -y openssl
}

function install_vim() {
  yum install -y vim
}

function install_tmux() {
  yum install -y tmux
}

function install_git() {
  yum install -y git2u

  git config --global diff.tool vimdiff
  git config --global difftool.prompt false
}

function install_aws_cli() {
  curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/tmp/awscli-bundle.zip"
  unzip -o "/tmp/awscli-bundle.zip"
  ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws 
}

function install_jq() {
  yum install -y jq
}

function install_docker() {
  local user="${1}"

  yum install -y yum-utils device-mapper-persistent-data lvm2
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce
  usermod -aG docker "${user}"

  systemctl start docker
}

function install pip() {
  curl https://bootstrap.pypa.io/get-pip.py | python
}

function install_direnv() {
  wget https://github.com/direnv/direnv/releases/download/v2.17.0/direnv.linux-amd64 -O direnv
  chmod +x direnv
  mv direnv /usr/local/bin/direnv
}

function install_desktop_apps() {
  yum install -y chromium evolution gimp

  if ! hash rambox 2>/dev/null; then
    yum localinstall -y https://github.com/saenzramiro/rambox/releases/download/0.5.17/Rambox-0.5.17-x64.rpm
  fi
}

function store_initial_home_state() {
  local user="${1}"
  local workdir=$(pwd)
  local target="/home/${user}"

  cd "${target}"

  if [ ! -d .git ]; then
    git init .
    cat > .gitignore << EOF
.bash_history
.viminfo
.cache
.config
.local
.mozilla
.dbus
Pictures
EOF
    sleep 1
    git add .
    git commit -m 'original home state'
  elif [ ! -z "$(git status --porcelain)" ]; then
    set +o xtrace

    cat << EOF
There are uncommitted modifications to the ${target} directory.  You will need to review and commit these
manually before re-running this script.  This is to prevent accidentally overwriting files that you do not
want to overwrite.
EOF

    exit 1
  fi

  cd "${workdir}"
}

function generate_ssh_key() {
  local user="${1}"
  local email="${2}"

  # TODO only do this is the .ssh directory does not exist and does not have a key
  mkdir -p "/home/${user}/.ssh"
  ssh-keygen -t rsa -b 4096 -C "${email}" -f .id_rsa
  mv --no-clobber .id_rsa "/home/${user}/.ssh/id_rsa"
  mv --no-clobber .id_rsa.pub "/home/${user}/.ssh/id_rsa.pub"
  chmod 700 "/home/${user}/.ssh"
  chmod 644 "/home/${user}/.ssh/id_rsa.pub"
  chmod 600 "/home/${user}/.ssh/id_rsa"
}

function setup_home() {
  local user="${1}"
  local target="/home/${user}"
  local workdir=$(pwd)

  cd "${target}"

  cp -R ${workdir}/home/. .
  chown -R "${user}:${user}" .
  git add .

  cd "${workdir}"
}

function finish_vim_setup() {
  local user="${1}"
  local vim_bundle_dir="/home/${user}/.vim/bundle"
  local vundle_dir="${vim_bundle_dir}/Vundle.vim"

  if [ ! -d "${vundle_dir}" ]; then
    mkdir -p ${vim_bundle_dir}
    git clone https://github.com/VundleVim/Vundle.vim.git ${vundle_dir}
    chown -R "${user}:${user}" "/home/${user}"
  fi

  su -c 'vim +PluginInstall +qall' lwoodson
}

function review_changes() {
  local user="${1}"
  local workdir=$(pwd)
  local target="/home/${user}"

  cd "${target}"
  set +o xtrace
  cat << EOF
We're now going to use vimdiff to review the changes to ${user}'s home directory.  If this is the first
run, you may need to modify some values in files, like AWS credentials and the like.  If this is a later
run, you will need to ensure that you are not overwriting anything you want to keep.  When you are ready
to proceed, hit <enter>.
EOF

  read _

  git difftool --cached

  cat << EOF
If you are happy with the changes you've made and the state of ${user}'s home directory, hit 'Y' below.
If you want to manually commit the changes later, enter 'n' or any other value.

Commit changes to "/home/${user}" (Y/n)?
EOF

  read resp
  set -o xtrace

  if [ $resp == "Y" ]; then
    git commit
  fi

  cd "${workdir}"
}

function parting_instructions() {
  local user="${1}"

  cat << EOF
Your development environment for ${user} has been bootstrapped.  If you did not commit the changes to
the '/home/${user}' directory after reviewing, you will need to do so (or revert them) before you can
run this command again.
EOF
}

function reboot_if_desired() {
  cat << EOF

The computer needs to be rebooted for all changes to take effect.  Would you like to reboot now? (Y/n)
EOF

  read resp

  if [ $resp == "Y" ]; then
    shutdown -r
  fi
}

function main() {
  local user=$(logname)
  local email="shvakian@gmail.com"
  local workdir=$(pwd)

  # TODO read user, email from cli flags

  setup
  install_desktop
  pre_packages
  install_essentials
  install_vim
  install_openssl
  install_git
  install_tmux
  install_aws_cli
  install_docker "${user}"
  install_direnv
  install_pip
  install_desktop_apps
  store_initial_home_state "${user}"
  generate_ssh_key "${user}" "${email}"
  setup_home "${user}"
  finish_vim_setup "${user}"
  review_changes "${user}"
  set +o xtrace
  parting_instructions "${user}"
  reboot_if_desired
}

main "$@"
