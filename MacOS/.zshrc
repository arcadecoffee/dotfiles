export CLICOLOR=1

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias sosume='sudo -i'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
else
	color_prompt=
fi

# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '!'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats '(%b)%c%u '

# Set up the prompt (with git branch name)
setopt PROMPT_SUBST

# Prompt = '[time] user@host:path (git branch, if exists) $ '
PROMPT='%B%F{green}%n@%m%f:%F{blue}%(4~|%-1~/.../%2~|%~)%f %F{172}${vcs_info_msg_0_}%f%b$ '

# some helper functions for working with Docker
function docker-log () { docker logs -f $(docker ps -qf name=$1); }
function docker-shell () { docker exec -it $(docker ps -qf name=$1) /bin/bash; }
function docker-kill () { docker kill $(docker ps -qf name=$1) /bin/bash; }
function docker-nuke () { docker kill $(docker ps -q); docker rm $(docker ps -aq); docker rmi -f $(docker images -aq); }

# AWS stuff
function set-aws-profile () { export AWS_PROFILE=$1; }
function ecr-login () { aws ecr get-login-password | docker login --username AWS --password-stdin 850077434821.dkr.ecr.us-east-1.amazonaws.com; }

# Git stuff
alias git-reset='git checkout master && git fetch && git pull'

function update-remote() {
  repoName=$(git config --get remote.origin.url | sed 's:.*/::')
  git remote set-url origin "ssh://git@gitlab.com/storable/analytics/$repoName"
}

