_rnd_number() {
  echo $(tr -cd 0-9 < /dev/urandom | head -c 5)
}
