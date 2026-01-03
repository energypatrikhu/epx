_rnd_number() {
  local num=$(tr -cd 0-9 < /dev/urandom | head -c 15 | sed 's/^0*//')
  [[ -z "$num" ]] && num=0
  echo "$num"
}
