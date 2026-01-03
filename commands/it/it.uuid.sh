_cci uuidgen

version="${1:-4}"

if [[ -z "$version" ]] || ! [[ "$version" =~ ^[1-5]$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - UUID")] Usage: $(_c LIGHT_YELLOW "it.uuid [version]")"
  echo -e "[$(_c LIGHT_BLUE "IT - UUID")] Supported versions: $(_c LIGHT_YELLOW "1, 3, 4, 5")"
  echo -e "[$(_c LIGHT_BLUE "IT - UUID")] Default version: $(_c LIGHT_YELLOW "4")"
  echo -e "[$(_c LIGHT_BLUE "IT - UUID")] Note: Versions 3 and 5 require namespace and name arguments"
  echo -e "[$(_c LIGHT_BLUE "IT - UUID")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - UUID")]   it.uuid"
  echo -e "[$(_c LIGHT_BLUE "IT - UUID")]   it.uuid 4"
  echo -e "[$(_c LIGHT_BLUE "IT - UUID")]   it.uuid 1"
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "IT - UUID")] Generating UUID v$version..." >&2

case "$version" in
  1)
    uuid=$(uuidgen -t 2>/dev/null || python3 -c "import uuid; print(uuid.uuid1())" 2>/dev/null)
    ;;
  3)
    uuid=$(python3 -c "import uuid; print(uuid.uuid3(uuid.NAMESPACE_DNS, 'example.com'))" 2>/dev/null)
    ;;
  4)
    uuid=$(uuidgen 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())" 2>/dev/null)
    ;;
  5)
    uuid=$(python3 -c "import uuid; print(uuid.uuid5(uuid.NAMESPACE_DNS, 'example.com'))" 2>/dev/null)
    ;;
  *)
    echo -e "[$(_c LIGHT_BLUE "IT - UUID")] $(_c LIGHT_RED "Error"): Invalid UUID version '$version'"
    exit 1
    ;;
esac

if [[ -z "$uuid" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - UUID")] $(_c LIGHT_RED "Error"): Failed to generate UUID"
  exit 1
fi

echo "$uuid"
echo -e "[$(_c LIGHT_BLUE "IT - UUID")] $(_c LIGHT_GREEN "UUID generated successfully")" >&2
