#/bin/bash

function check_linux_distro() {
	distro=$1; shift
	grep Ubuntu /etc/issue &> /dev/null; echo $?
}

if [ "$(pip &> /dev/null; echo $!)" != "0" ]; then
	echo "Pip is not installed"
fi

os_type="$(uname -o)"
echo "Found os type $os_type"
if [ "$os_type" == "Cygwin" ]; then
	test -f /bin/git
        if [ "$?" == "1" ]; then
        	echo "Please install git from cygwin" && exit 1
	fi

	echo "Installing apt-cyg"
	tmp_dir=$(mktmp -d)
	git clone https://github.com/grlee/ansible-init $tmp_dir
	cp -f $tmp_dir/apt-cyg /bin
	chmod +x /bin/apt-cyg
	rm -rf $tmp_dir

	echo "Installing cygwin packages for ansible dependencies"
	apt-cyg install python gcc-core wget openssh

	echo "Installing setuptools"
	wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python

	echo "Installing pip"
	easy_install pip

elif [ "$os_type" == "GNU/Linux" ]; then
	echo "Found Linux distro"
	if [ "$(check_linux_distro Ubuntu)" == "0" ]; then
		echo "Found Ubuntu distro"
		echo "Installing pip"
		sudo apt-get install python-pip -y || exit 1
	else
		echo "Unknown Linux distro: $(cat /etc/issue)" && exit 1
	fi
elif [ "$(uname)" == "Darwin" ]; then
	echo -n "Installing home brew... "
	ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)" &> /dev/null && echo "OK" || {echo "FAILED"; exit 1 }

	echo -n "Test if home brew is installed... "
	brew --version &> /dev/null && echo "OK"
        if [ "$?" == "1"]; then
		echo "FAILED" && exit 1
	fi

	echo "Installing pip"
	sudo easy_install pip || exit 1
else
	echo "Not a supported platform" && exit 1
fi

echo -n "Test if pip is installed..."
pip --version &> /dev/null && echo "OK" 
if [ "$?" == "1" ]; then 
	echo "FAILED"; exit 1
fi

echo -n "Installing ansible..."
pip install ansible --upgrade && echo "OK"
if [ "$?" == "1" ]; then
        echo "FAILED"; exit 1
fi

echo -n "Test ansible is installed... "
ansible --version &> /dev/null && echo "OK"
if [ "$?" == "1" ]; then
        echo "FAILED"; exit 1
fi

exit 0
