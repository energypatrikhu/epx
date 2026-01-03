if command -v micro &>/dev/null
  alias edit='micro'
  alias editor='micro'
  alias nano='micro'
  alias neovim='micro'
  alias vi='micro'
  alias vim='micro'

  set -x EDITOR 'micro'
end
