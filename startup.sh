aptlist=" "
condalist=" "

echo "Install Conda 3? (latest)?"
select conda in "Yes" "No"; do
	case $conda in
		Yes ) break;;
		No )  break;;
	esac
done

echo "Install Cyclus Dependencies? (conda)"
select condacyclus in "Yes" "No"; do
	case $condacyclus in
		Yes ) break;;
		No ) break;;
	esac
done

echo "Install Cyclus Dependencies? (apt)"
select cyclus in "Yes" "No"; do
	case $cyclus in
		Yes ) break;;
		No )  break;;
	esac
done

echo "Install Pyne Dependencies? (conda)"
select condapyne in "Yes" "No"; do
	case $condapyne in
		Yes ) break;;
		No ) break;;
	esac
done

echo "Install Pyne Dependencies? (apt)"
select pyne in "Yes" "No"; do
	case $pyne in
		Yes ) break;;
		No )  break;;
	esac
done

echo "Install Jupyter Extensions?"
select nbextension in "Yes" "No"; do
	case $nbextension in
		Yes ) break;;
		No ) break;;
	esac
done

echo "Install Sublime Text?"
select sublime in "Yes" "No"; do
	case $sublime in
		Yes ) 
			echo "Copy my sublime text settings?"
			select sublsettings in "Yes" "No"; do
				case $sublsettings in
					Yes )
						mkdir -p $HOME/.config/sublime-text-3/Packages/User
						cp -r sublime_text_settings $HOME/.config/sublime-text-3/Packages/User
						break;;
					No )  break;;
				esac
			done
			break;;
		No )  break;;
	esac
done

echo "Install Other Software?"
select other in "Yes" "No"; do
	case $other in
		Yes )
			echo "List all apt to get (separated by single space only)"
			read aptget;
			break;;
		No )  break;;
	esac
done

echo "Setup Git?"
select github in "Yes" "No"; do
	case $github in
		Yes )
			sudo apt install -y git
			echo "Enter Git User Email";
			read email;
			git config --global user.email $email;
			echo "Enter Git User Name";
			read name;
			git config --global user.name $name;
			echo "Enter Default editor";
			read editor;
			git config --global core.editor $editor;
			ssh-keygen -t rsa -b 4096 -C $email;
			echo "Copy and Paste this to: https://github.com/settings/ssh/new"
			echo "$(cat $HOME/.ssh/id_rsa.pub)"
			break;;
		No )  break;;
	esac
done

echo "Display git branch name in shell?"
select parsegit in "Yes" "No"; do
	case $parsegit in
		Yes )
			echo "Obtained from: https://coderwall.com/p/fasnya/add-git-branch-name-to-bash-prompt"
			cat parse_git_branch.txt >> $HOME/.bashrc;
			break;;
		No )  break;;
	esac
done

echo "Running wsl with xserver?"
select wsl in "Yes" "No"; do
	case $wsl in
		Yes )
			echo "export DISPLAY=:0" >> $HOME/.bashrc
			echo -e '\n\neval `dbus-launch --auto-syntax`\ngnome-terminal' | sudo tee -a /etc/profile 1> /dev/null
			break;;
		No )  break;;
	esac
done

echo "Add alias to .bashrc?"
select alias in "Yes" "No"; do
	case $alias in
		Yes )
			cat alias.txt >> $HOME/.bashrc
			break;;
		No )  break;;
	esac
done

if [[ $cyclus == "Yes" ]]; then
	aptlist+="cmake make libboost-all-dev libxml2-dev libxml++2.6-dev \
		libsqlite3-dev libhdf5-serial-dev libbz2-dev coinor-libcbc-dev coinor-libcoinutils-dev \
		coinor-libosi-dev coinor-libclp-dev coinor-libcgl-dev libblas-dev liblapack-dev g++ \
		libgoogle-perftools-dev python3-dev python3-tables python3-pandas python3-numpy python3-nose \
		python3-jinja2 cython3 "
fi

if [[ $pyne == "Yes" ]]; then
	aptlist+="build-essential gfortran libblas-dev liblapack-dev libhdf5-dev autoconf libtool "
fi

if [[ $sublime == "Yes" ]]; then
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	aptlist+="sublime-text "
fi

if [[ $other == "Yes" ]]; then
	aptlsit+="$aptget "
fi

sudo apt update;
sudo apt install -y $aptlist;

if [[ $conda == "Yes" ]]; then
	wget -O - https://www.anaconda.com/distribution/ 2>/dev/null \
	| sed -ne 's@.*\(https:\/\/repo\.anaconda\.com\/archive\/Anaconda3-.*-Linux-x86_64\.sh\)\">64-Bit (x86) Installer.*@\1@p' \
	| xargs wget -O Anaconda3.sh
	bash Anaconda3.sh -b -p $HOME/anaconda3
	rm Anaconda3.sh
	cat path.txt >> $HOME/.bashrc
	export PATH="$HOME/anaconda3/bin:$PATH"
	conda config --add channels conda-forge
fi

if [[ $condacyclus == "Yes" ]]; then
	condalist+="cyclus-build-deps "
fi

if [[ $condapyne == "Yes" ]]; then
	condalist+="conda-build jinja2 nose setuptools pytables hdf5 scipy "
fi

if [[ $nbextension == "Yes" ]]; then
	condalist+="jupyter_contrib_nbextensions autopep8 "
fi

conda install -c conda-forge -y $condalist;

echo -e $"Done.\nDon't forget to run 'source $HOME/.bashrc'"
