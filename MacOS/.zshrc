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

autoload -U colors && colors # Enable colors in prompt

# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '+'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' 
zstyle ':vcs_info:*' formats '(%b%c%u) '


# Echoes information about Git repository status when inside a Git repository
git_info() {

  # Exit if not inside a Git repository
  ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return

  # Git branch/tag, or name-rev if on detached head
  local GIT_LOCATION=${$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD)#(refs/heads/|tags/)}

  local AHEAD="%{$fg[red]%}⇡NUM%{$reset_color%}"
  local BEHIND="%{$fg[cyan]%}⇣NUM%{$reset_color%}"
  local MERGING="%{$fg[magenta]%}⚡︎%{$reset_color%}"
  local UNTRACKED="%{$fg[red]%}●%{$reset_color%}"
  local MODIFIED="%{$fg[yellow]%}●%{$reset_color%}"
  local STAGED="%{$fg[green]%}●%{$reset_color%}"

  local -a DIVERGENCES
  local -a FLAGS

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    DIVERGENCES+=( "${AHEAD//NUM/$NUM_AHEAD}" )
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    DIVERGENCES+=( "${BEHIND//NUM/$NUM_BEHIND}" )
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    FLAGS+=( "$MERGING" )
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    FLAGS+=( "$UNTRACKED" )
  fi

  if ! git diff --quiet 2> /dev/null; then
    FLAGS+=( "$MODIFIED" )
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    FLAGS+=( "$STAGED" )
  fi

  local -a GIT_INFO
  GIT_INFO+=( "\033[38;5;15m±" )
  [ -n "$GIT_STATUS" ] && GIT_INFO+=( "$GIT_STATUS" )
  [[ ${#DIVERGENCES[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)DIVERGENCES}" )
  [[ ${#FLAGS[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)FLAGS}" )
  GIT_INFO+=( "\033[38;5;15m$GIT_LOCATION%{$reset_color%}" )
  echo "${(j: :)GIT_INFO}"

}

# Set up the prompt (with git branch name)
setopt PROMPT_SUBST

# Prompt = '[time] user@host:path (git branch, if exists) $ '
PROMPT='%B%F{green}%n@%m%f:%F{blue}%(4~|%-1~/.../%2~|%~)%f %F{172}${vcs_info_msg_0_}%f%b $(git_info)%f $ '

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

