if command -v micro &> /dev/null; then
  alias edit="$(which micro)"
  alias editor="$(which micro)"
  alias nano="$(which micro)"
  alias neovim="$(which micro)"
  alias vi="$(which micro)"
  alias vim="$(which micro)"

  export EDITOR="$(which micro)"
fi
