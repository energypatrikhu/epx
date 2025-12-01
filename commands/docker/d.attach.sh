_cci docker

if [[ -z $* ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] $(_c LIGHT_YELLOW "Usage: d.attach <container>")"
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] $(_c LIGHT_YELLOW "Warning: Attaching to container") ${@}"
echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] $(_c LIGHT_YELLOW "To detach: Press") Ctrl+P $(_c LIGHT_YELLOW "followed by") Ctrl+Q"
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] $(_c LIGHT_RED "Aborted")"
  exit 0
fi

docker container attach "${@}"
