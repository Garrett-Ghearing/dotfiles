#!/bin/bash
USERDIR=/home/$SUDO_USER

cd "$(dirname "$0")"
SCRIPTDIR="$(pwd)" 


if [[ "$(id -u)" -eq 0 ]]; then #checking if script is running with root permission
	echo "Script is running as root"
	if [[ -n "$(which apt)" ]]; then #checking if apt is installed
		echo "apt is installed"
	else
		echo "apt is not installed - exiting" 1>&2
		exit 1
	fi
else
	echo "Script is not running as root - exiting" 1>&2
	exit 1
fi

#installs necessary packages
apt_install() {
	echo "installing required packages"
	apt install -y \
		ninvaders \
		nmap \
		dnsutils \
		libgl1-mesa-glx \
		libegl1-mesa \
		libxrandr2 \
		libxss1 \
		libxcursor1 \
		libxcomposite1 \
		libasound2 \
		libxi6 \
		unzip \
		libxtst6
	}

# check if anaconda is installed, if not installs it
anaconda_install() {
	if [[ -d $USERDIR/anaconda3 ]]; then
		echo "Anaconda3 is already installed"
		return
	fi
	if [[ $(ls Anaconda3*.sh 2> /dev/null == head -1) ]]; then
		echo "installer found, running it..."
		bash Anaconda3-2024.02-1-Linux-x86_64.sh -b -p $USERDIR/anaconda3
		echo "PATH=$PATH:$USERDIR/anaconda3/bin" >> $USERDIR/.profile
	else
		echo "downloading anaconda installer..."
		curl -O https://repo.anaconda.com/archive/Anaconda3-2024.02-1-Linux-x86_64.sh
		anaconda_install
	fi
}
awscli_install() {
	if command -v aws &> /dev/null; then
        echo "[INFO] AWS CLI is already installed."
        return
    fi
	if [[ -e $(ls awsdl/awscliv2.zip 2> /dev/null | head -1) ]]; then
		echo "AWS CLI V2 installer found, running it"
		unzip ./awsdl/awscliv2.zip -d awsdl/
		./awsdl/aws/install 
	else
		mkdir awsdl
		curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awsdl/awscliv2.zip"
		unzip ./awsdl/awscliv2.zip -d awsdl/
		./awsdl/aws/install
	fi 
}
# Update .vimrc with Vim configurations
# Update .vimrc with Vim configurations

apt_install
anaconda_install
awscli_install

su $SUDO_USER
mkdir -p ~/.vim/bundle

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
if [ -f ~/.vimrc ]; then
    mv ~/.vimrc ~/.vimrc.backup
fi
echo "Vundle has been successfully installed"
echo "Removed Vundle default vimrc"
echo '
set background=dark
colorscheme jellybeans

" Vundle plugins
Plugin "VundleVim/Vundle.vim"
Plugin "Valloric/YouCompleteMe"
Plugin "tpope/vim-fugitive"
' >> ~/.vimrc

ln -sf $USERDIR/dotfiles/.gitconfig ~/.gitconfig
ln -sf $USERDIR/dotfiles/.bashrc ~/.bashrc
# bash $USERDIR/dotfiles/bashrc.sh
