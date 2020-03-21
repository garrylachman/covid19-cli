#!/usr/bin/env sh
#
# Corona Virus (Covid-19) statistics cli,
#
# MIT License
# Copyright (c) 2020 Garry Lachman
# https://github.com/garrylachman/covid19-cli

BASE_API="https://coronavirus-19-api.herokuapp.com"
API_TOTAL_ENDPOINT="$BASE_API/all"
API_ALL_COUNTRIES_ENDPOINT="$BASE_API/countries"

#set -e

# Detect whether output is piped or not.
[[ -t 1 ]] && piped=0 || piped=1

# Defaults
args=()

# }}}
# Helpers {{{

out() {
  ((quiet)) && return

  local message="$@"
  if ((piped)); then
    message=$(echo $message | sed '
      s/\\[0-9]\{3\}\[[0-9]\(;[0-9]\{2\}\)\?m//g;
      s/✖/Error:/g;
      s/✔/Success:/g;
    ')
  fi
  printf '%b\n' "$message";
}
die() { out "$@"; exit 1; } >&2
err() { out " \033[1;31m✖\033[0m  $@"; } >&2
success() { out " \033[1;32m✔\033[0m  $@"; }

bold=$(tput bold)
normal=$(tput sgr0)

# colours
green=$(tput setaf 2)
red=$(tput setaf 1)
white=$(tput setaf 7)
yellow=$(tput setaf 3)

# Notify on function success
notify() { [[ $? == 0 ]] && success "$@" || err "$@"; }

# Escape a string
escape() { echo $@ | sed 's/\//\\\//g'; }

version="v0.1"

# Print usage
usage() {
  echo -n "$(basename $0) [OPTION]...

 Corona Virus (Covid-19) statistics cli.

 MIT License
 Copyright (c) 2020 Garry Lachman
 https://github.com/garrylachman/covid19-cli

 Options:
  -c, --country     Specific Country
  -l, --list-all         List all countries
                    this through the interactive option
  -h, --help        Display this help and exit
      --version     Output version information and exit
"
}


# Set a trap for cleaning up in case of errors or when script exits.

# Put your script here
output() {
    echo "${bold}Cases: ${normal}${yellow}$1${white}, ${bold}Deaths: ${normal}${red}$2${white}, ${bold}Recovered: ${normal}${green}$3";
}

main() {
  if [[ -n "$country"  && "$list_all" == 1 ]]; then
    err "--country (-c) and --list-all (-l) cannot be mixed together"
    die
  fi;
  
  if [ "$list_all" == 1 ]; then
    success "List all Countries"
    curl -s $API_ALL_COUNTRIES_ENDPOINT | jq -c '.[]' | column -t -s'[],"'
  elif [ -n "$country" ]; then
    success "Country: $country"
    result=$(curl -s $API_ALL_COUNTRIES_ENDPOINT/$country)
    cases=$(echo $result | jq ".cases")
    deaths=$(echo $result | jq ".deaths")
    recovered=$(echo $result | jq ".recovered")

    output $cases $deaths $recovered
  else
    success "Global Statistics"
    result=$(curl -s $API_TOTAL_ENDPOINT)
    cases=$(echo $result | jq ".cases")
    deaths=$(echo $result | jq ".deaths")
    recovered=$(echo $result | jq ".recovered")

    output $cases $deaths $recovered
  fi;

}

optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;
    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options


# A non-destructive exit for when the script exits naturally.
safe_exit() {
  trap - INT TERM EXIT
  exit
}

while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; safe_exit ;;
    --version) out "$(basename $0) $version"; safe_exit ;;
    -c|--country) country=$2; shift ;;
    -l|--list-all) list_all=1 ;;
    --endopts) shift; break ;;
    *) die "invalid option: $1" ;;
  esac
  shift
done

args+=("$@")

main

safe_exit
