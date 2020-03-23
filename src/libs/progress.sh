function ProgressBar {
  let _progress=(${1}*100/${2}*100)/100
  let _done=(${_progress}*4)/10
  let _left=40-$_done
  _color=$green
  _fill=$(printf "%${_done}s")
  _empty=$(printf "%${_left}s")
  if [ "$_progress" -gt 0 ]; then
    _color="${green}"
  fi
  if [ "$_progress" -gt 33 ]; then
    _color="${yellow}"
  fi
  if [ "$_progress" -gt 80 ]; then
    _color="${red}"
  fi
  printf "\rProgress : ${_color}[${_fill// /#}${_empty// /-}] ${_progress}%%\r${no_color}"
}