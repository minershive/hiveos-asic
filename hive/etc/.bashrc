function set_prompt () {
  local GRAY="\[\033[1;30m\]"
  local LIGHT_GRAY="\[\033[0;37m\]"
  local CYAN="\[\033[0;36m\]"
  local LIGHT_CYAN="\[\033[1;36m\]"
  local NO_COLOUR="\[\033[0m\]"
  local BLUE="\[\033[0;34m\]"
  local LIGHT_BLUE="\[\033[1;34m\]"
  local RED="\[\033[0;31m\]"
  local LIGHT_RED="\[\033[1;31m\]"
  local GREEN="\[\033[0;32m\]"
  local LIGHT_GREEN="\[\033[1;32m\]"
  local PURPLE="\[\033[0;35m\]"
  local LIGHT_PURPLE="\[\033[1;35m\]"
  local BROWN="\[\033[0;33m\]"
  local YELLOW="\[\033[1;33m\]"
  local BLACK="\[\033[0;30m\]"
  local WHITE="\[\033[1;37m\]"
  # PS1="$LIGHT_GREEN\u $YELLOW[$RED\w$YELLOW] $LIGHT_BLUE(\$(date +%H:%M:%S))$NO_COLOUR: "
  # PS1="$LIGHT_GREEN\u $YELLOW[$RED\w$YELLOW]$NO_COLOUR "
  # PS1="\u@\h "
}
set_prompt

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

#motd
[[ -e /hive/etc/motd ]] && . /hive/etc/motd
