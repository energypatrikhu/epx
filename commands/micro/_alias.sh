if command -v micro &> /dev/null; then
  alias edit='micro'
  alias editor='micro'
  alias nano='micro'
  alias neovim='micro'
  alias vi='micro'
  alias vim='micro'

  export EDITOR='micro'
fi
