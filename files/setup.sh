#/bin/bash

APT_CGY_URL="https://raw.github.com/transcode-open/apt-cyg/master/apt-cyg"
PYTHON_EZ_SETUP_URL="https://bootstrap.pypa.io/ez_setup.py"
CENTOS_EPEL_URL="http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm"
HOMEBREW_URL="https://raw.github.com/Homebrew/homebrew/go/install"

function check_linux_distro() {
	distro=$1; shift
	grep $distro /etc/issue &> /dev/null; echo $?
}

sudo_cmd=
os_type="$(uname -o)"
test "$os_type" == "" && os_type="$(uname)"
echo "Found os type $os_type"
if [ "$os_type" == "Cygwin" ]; then
	test -f /bin/wget
    if [ "$?" == "1" ]; then
    	echo "Please install wget from cygwin" && exit 1
	fi

	echo "Installing apt-cyg"
	tmp_dir=$(mktemp -d) || exit 1
	wget $APT_CGY_URL -O $tmp_dir/apt-cyg || exit 1
	dos2unix $tmp_dir/apt-cyg || exit 1
	cp -f $tmp_dir/apt-cyg /bin  || exit 1
	chmod +x /bin/apt-cyg  || exit 1
	rm -rf $tmp_dir

	echo "Installing cygwin packages for ansible dependencies"
	echo /bin/apt-cyg install python gcc-core git openssh unzip zip tar curl | bash
	if [ "$?" == "1" ]; then
		echo "Check that mirror site is correct."
		echo "Use apt-cyg -m <url> show to set a new mirror"
		exit 1
	fi

	echo "Installing setuptools"
	(cd $tmpdir; curl https://bootstrap.pypa.io/ez_setup.py -o - | python)

	echo "Installing pip"
	easy_install pip || exit 1
elif [ "$os_type" == "GNU/Linux" ]; then
	echo "Found Linux distro"
	if [ "$(check_linux_distro Ubuntu)" == "0" ]; then
		sudo_cmd=sudo
		echo "Found Ubuntu distro"
		echo "Installing pip"
		$sudo_cmd apt-get update --fix-missing -y || exit 1
		$sudo_cmd apt-get install python-dev python-pip -y || exit 1
	elif [ "$(check_linux_distro CentOS)" == "0" ]; then
		sudo_cmd=sudo
		echo "Found CentOS distro"
		$sudo_cmd rpm -Uvh $CENTOS_EPEL_URL
		$sudo_cmd yum install ansible -y || exit 1
	else
		echo "Unknown Linux distro: $(cat /etc/issue)" && exit 1
	fi
elif [ "$os_type" == "Darwin" ]; then
#	echo -n "Installing home brew... "
#	ruby -e "$(curl -fsSL $HOMEBREW_URL)" &> /dev/null && echo "OK" || {echo "FAILED"; exit 1 }

#	echo -n "Test if home brew is installed... "
#	brew --version &> /dev/null && echo "OK"
#    if [ "$?" == "1"]; then
#		echo "FAILED" && exit 1
#	fi

	echo "Installing pip"
	pip --version &> /dev/null || sudo easy_install pip || exit 1
else
	echo "Not a supported platform" && exit 1
fi

echo "Sudo command is '$sudo_cmd'"

echo -n "Test if pip is installed..."
pip --version &> /dev/null && echo "OK" 
if [ "$?" == "1" ]; then 
	echo "FAILED"; exit 1
fi

echo -n "Installing passlib..."
$sudo_cmd pip install passlib paramiko PyYAML jinja2 httplib2 docker-py virtualenv pycrypto --upgrade && echo "OK"
if [ "$?" == "1" ]; then
	echo "FAILED"; exit 1
fi

echo -n "Installing ansible..."
$sudo_cmd pip install ansible --upgrade && echo "OK"
if [ "$?" == "1" ]; then
	echo "FAILED"; exit 1
fi

echo -n "Test ansible is installed... "
ansible --version &> /dev/null && echo "OK"
if [ "$?" == "1" ]; then
    echo "FAILED"; exit 1
fi

exit 0
