# https://github.com/holman/spark
_echoSP()
{
  if [ "X$1" = "X-n" ]; then
    shift
    printf "%s" "$*"
  else
    printf "%s\n" "$*"
  fi
}

spark()
{
  local n numbers=

  # find min/max values
  local min=0xffffffff max=0

  for n in ${@//,/ }
  do
    # on Linux (or with bash4) we could use `printf %.0f $n` here to
    # round the number but that doesn't work on OS X (bash3) nor does
    # `awk '{printf "%.0f",$1}' <<< $n` work, so just cut it off
    n=${n%.*}
    (( n < min )) && min=$n
    (( n > max )) && max=$n
    numbers=$numbers${numbers:+ }$n
  done

  # print ticks
  local ticks=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

  # use a high tick if data is constant
  (( min == max )) && ticks=(▅ ▆)

  local f=$(( (($max-$min)<<8)/(${#ticks[@]}-1) ))
  (( f < 1 )) && f=1

  for n in $numbers
  do
    _echoSP -n ${ticks[$(( ((($n-$min)<<8)/$f) ))]}
  done
  _echoSP
}