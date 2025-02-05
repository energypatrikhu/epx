d.list() {
  # Fetch container data dynamically using docker command
  data=$(docker container ls -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}")

  # Initialize column widths
  id_width=12    # Minimum width for CONTAINER ID
  names_width=5  # Minimum width for NAMES
  image_width=5  # Minimum width for IMAGE
  status_width=7 # Minimum width for STATUS

  # Calculate maximum column widths
  while IFS=$'\t' read -r id names image status; do
    id_width=$((${#id} > id_width ? ${#id} : id_width))
    names_width=$((${#names} > names_width ? ${#names} : names_width))
    image_width=$((${#image} > image_width ? ${#image} : image_width))
    status_width=$((${#status} > status_width ? ${#status} : status_width))
  done <<EOF
$data
EOF

  # Add padding to column widths (2 spaces for padding on each side)
  names_width=$((names_width + 2)) # +2 for the ● symbol and its space

  # Define the table header separator
  separator=$(printf "+%-${id_width}s--+%-${names_width}s--+%-${image_width}s--+%-${status_width}s--+\n" | tr ' ' '-')

  # Print the table header
  echo "$separator"
  printf "| %-${id_width}s | %-${names_width}s | %-${image_width}s | %-${status_width}s |\n" "CONTAINER ID" "NAMES" "IMAGE" "STATUS"
  echo "$separator"

  # Print each row of the table
  while IFS=$'\t' read -r id names image status; do
    # Determine the color for the ● symbol
    if echo "$status" | grep -q "Exited" || echo "$status" | grep -q "Dead"; then
      bullet="$(printf '\033[31m●\033[0m')" # Red for dead/exited containers
    else
      bullet="$(printf '\033[32m●\033[0m')" # Green for running/online containers
    fi

    # Add the colored ● before the container name
    names="$bullet $names"

    # Calculate the visible length of the names (excluding color codes)
    visible_names_length=$(printf "%s" "$names" | sed 's/\x1b\[[0-9;]*m//g' | wc -m)

    # Calculate the padding needed for the NAMES column
    padding=$((names_width - visible_names_length))

    # Print the row
    printf "| %-${id_width}s | %s%-${padding}s | %-${image_width}s | %-${status_width}s |\n" "$id" "$names" "" "$image" "$status"
  done <<EOF
$data
EOF

  # Print the table footer
  echo "$separator"
}
