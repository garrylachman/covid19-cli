#!/usr/bin/env bash
#
# Corona Virus (Covid-19) statistics cli,
#
# MIT License
# Copyright (c) 2020 Garry Lachman
# https://github.com/garrylachman/covid19-cli

basedir=$( cd `dirname $0`; pwd )

source ${basedir}/defines.sh

. ${basedir}/libs/tables.sh
. ${basedir}/libs/progress.sh
. ${basedir}/libs/sparkline.sh

# Detect whether output is piped or not.
[[ -t 1 ]] && piped=0 || piped=1

# Defaults
args=()

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

err() {
  if [[ "$rawoutput" == true ]]; then
    out "$@"
  else
    out " \033[1;31m✖\033[0m  $@";
  fi
} >&2

success() { 
  if [[ "$rawoutput" == true ]]; then
    out "$@"
  else
    out " \033[1;32m✔\033[0m  $@";
  fi
}

bold=$(tput bold)
normal=$(tput sgr0)

# colours
green=$(tput setaf 2)
no_color='\033[0m'
red=$(tput setaf 1)
yellow=$(tput setaf 3)

# Notify on function success
notify() { [[ $? == 0 ]] && success "$@" || err "$@"; }

# Escape a string
escape() { echo $@ | sed 's/\//\\\//g'; }

version="v${VERSION}"

check_dependencies() {
  if ! [ -x "$(command -v jq)" ]; then
    err 'Error: jq is not installed.\nhttps://stedolan.github.io/jq/' >&2
    die
  fi
  if ! [ -x "$(command -v curl)" ]; then
    err 'Error: curl is not installed.\nhttps://github.com/curl/curl' >&2
    die
  fi
}

# Print usage
usage() {
  banner
  echo "$(basename $0) [OPTION]...

 Corona Virus (Covid-19) statistics cli.

 MIT License
 Copyright (c) 2020 Garry Lachman
 https://github.com/garrylachman/covid19-cli

 Options:
  -c, --country     Specific Country (actual data + historical)
  -l, --list-all    List all countries
  -s, --sort        Sort countries list by key (country|cases|active|critical|deaths|recovered|todayCases|todayDeaths|casesPerOneMillion)
  -i, --historical  List all countries historical trend chart 
  -h, --help        Display this help and exit
  -n, --no-banner   Hides \"Covid19-CLI\" banner
  -r, --raw-output  Remove text formatting (colors, bold)
      --version     Output version information and exit
"
}

banner() {
    if [[ "$nobanner" != true ]]; then
    echo "
${green}_________             .__    ._______ ________          _________ .____    .___ 
\_   ___ \  _______  _|__| __| _/_   /   __   \         \_   ___ \|    |   |   |
${yellow}/    \  \/ /  _ \  \/ /  |/ __ | |   \____    /  ______ /    \  \/|    |   |   |
\     \___(  <_> )   /|  / /_/ | |   |  /    /  /_____/ \     \___|    |___|   |
 ${red}\______  /\____/ \_/ |__\____ | |___| /____/            \______  /_______ \___|
        \/                    \/                                \/        \/        
"
printf "${no_color}"
    fi
}


function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

set_raw_output() {
  bold=""
  normal=""

  # colours
  green=""
  no_color=""
  red=""
  yellow=""
}

main() {
  if [[ "$rawoutput" == true ]]; then
    set_raw_output
  fi
  check_dependencies
  banner
  if [[ -n "$country"  && "$list_all" == 1 ]]; then
    err "--country (-c) and --list-all (-l) cannot be mixed together"
    die
  fi;

  if [ "$list_all" == 1 ]; then
    # The part can be re-factored in better way...
    success "List all Countries"
    if [ -n "$sort_by" ]; then
      success "Sory by key: $sort_by"
    fi
    success "Please wait while we: "
    success "- Retrieve & preparing the data..."
    result=$(curl -s "$API_ALL_COUNTRIES_ENDPOINT/?sort=$sort_by")
    cols=(country cases active critical deaths recovered todayCases todayDeaths casesPerOneMillion)
    titles=(Country Cases Active Critical Deaths Recovered Today-Cases Today-Deaths Cases-Per-One-Million)
    lines=()
    lines+=($(join_by , "${titles[@]}"))
    cnt=0
    _start=1
    _end=$(echo "${result}" | jq -r 'length')
    ((_end=_end-1))
    for row in $(echo "${result}" | jq -r '.[] | @base64'); do
      ProgressBar ${cnt} ${_end}
      plainRow=$(echo "${row}" | base64 --decode)
      line=()
      for k in "${cols[@]}"; do
        val=$(echo $plainRow | jq -r ".${k}")
        line+=("$val")
      done
      line=$(join_by , "${line[@]}")
      lines+=("$line")
      ((cnt=cnt+1))
    done
    resultStr=$(join_by "\n" "${lines[@]}")
    echo ""
    success "- Bulding data tables"
    printTable "," "$resultStr"

  elif [ -n "$historical_all" ]; then
    echo "historical_all"
    success "Historical"
    result=$(curl -s $API_HISTORICAL_COUNTRIES_ENDPOINT)

    for row in $(echo "${result}" | jq -r '.[] | @base64'); do
      plainRow=$(echo "${row}" | base64 --decode)
      #echo $plainRow | jq '. | "\(.country)-\(.province)"'
      country=$(echo $plainRow | jq -r ".country")
      province=$(echo $plainRow | jq -r ".province")
      
      printf "${bold}${country}"
      if [ "$province" != "null" ]; then
        printf " (${province})"
      fi 
      printf "${no_color}\n"

      casesHistorical=$(echo $plainRow | jq -r '.timeline .cases | map(.|tostring) | join(",")')
      deathsHistorical=$(echo $plainRow | jq -r '.timeline .deaths | map(.|tostring) | join(",")')

      printf "${bold}Cases:\t\t${yellow}$(spark ${casesHistorical})${no_color}\n"
      printf "${bold}Deaths:\t\t${red}$(spark ${deathsHistorical})${no_color}\n"

      printf "\n"
    done



  elif [[ -n "$country" &&  !"$historical_all" ]]; then
    success "Country: $country"
    result=$(curl -s $API_ALL_COUNTRIES_ENDPOINT/$country)
    historicalResult=$(curl -s $API_HISTORICAL_COUNTRIES_ENDPOINT/$country)

    cases=$(echo $result | jq ".cases")
    deaths=$(echo $result | jq ".deaths")
    recovered=$(echo $result | jq ".recovered")

    casesHistorical=$(echo $historicalResult | jq -r '.timeline .cases | map(.|tostring) | join(",")')
    deathsHistorical=$(echo $historicalResult | jq -r '.timeline .deaths | map(.|tostring) | join(",")')

    printf "\n"
    printf "${bold}Cases:\t\t${normal}${yellow}${cases}\t$(spark ${casesHistorical})${no_color}\n"
    printf "${bold}Deaths:\t\t${normal}${red}${deaths}\t$(spark ${deathsHistorical})${no_color}\n"
    printf "${bold}Recovered:\t${normal}${green}${recovered}${no_color}\n"

  else
    success "Global Statistics"
    result=$(curl -s $API_TOTAL_ENDPOINT)
    cases=$(echo $result | jq ".cases")
    deaths=$(echo $result | jq ".deaths")
    recovered=$(echo $result | jq ".recovered")

    printf "\n"
    printf "${bold}Cases:\t\t${normal}${yellow}${cases}${no_color}\n"
    printf "${bold}Deaths:\t\t${normal}${red}${deaths}${no_color}\n"
    printf "${bold}Recovered:\t${normal}${green}${recovered}${no_color}\n"
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
    -n|--no-banner) nobanner=true;;
    -r|--raw-output) rawoutput=true;;
    -h|--help) usage >&2; safe_exit ;;
    --version) out "$(basename $0) $version"; safe_exit ;;
    -c|--country) country=$2; shift ;;
    -l|--list-all) list_all=1 ;;
    -s|--sort) sort_by=$2 ;;
    -i|--historical) historical_all=1 ;;
    --endopts) shift; break ;;
    *) die "invalid option: $1" ;;
  esac
  shift
done

args+=("$@")

main

safe_exit
