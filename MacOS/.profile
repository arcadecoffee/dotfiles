if [ -x /opt/homebrew/bin/brew ]; then
	eval $(/opt/homebrew/bin/brew shellenv)
elif [ -x /usr/local/bin/brew ]; then
	eval $(/usr/local/bin/brew shellenv)
fi

if [[ $0 == *bash* ]] && [ -f ~/.bashrc ]; then source ~/.bashrc; fi

eval "$(pyenv init --path)"
