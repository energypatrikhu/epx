_cci python3

# check if directory is provided
if [[ -z "${1-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Python - Create")] $(_c LIGHT_YELLOW "Usage: py.create <directory>")"
  exit 1
fi

# check if directory already exists
if [[ -d "${1-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Python - Create")] $(_c LIGHT_RED "Directory") "${1-}" $(_c LIGHT_RED "already exists")"
  exit 1
fi

# create directory
echo -e "[$(_c LIGHT_BLUE "Python - Create")] Creating directory $(_c LIGHT_YELLOW "${1-}")"
mkdir -p "${1-}"

# change directory
echo -e "[$(_c LIGHT_BLUE "Python - Create")] Changing directory to $(_c LIGHT_YELLOW "${1-}")"
cd "${1-}" || exit 1

# create requirements.txt and main.py
echo -e "[$(_c LIGHT_BLUE "Python - Create")] Creating $(_c LIGHT_YELLOW "requirements.txt") and $(_c LIGHT_YELLOW "main.py")"
touch requirements.txt
touch main.py

# create virtual environment
echo -e "[$(_c LIGHT_BLUE "Python - Create")] Creating virtual environment"
python3 -m venv .venv

# check if virtual environment is created
if [[ ! -d .venv ]]; then
  echo -e "[$(_c LIGHT_BLUE "Python - Create")] $(_c LIGHT_RED "Failed to create virtual environment")"
  exit 1
fi

# activate virtual environment
echo -e "[$(_c LIGHT_BLUE "Python - Create")] To activate virtual environment"
echo -e "[$(_c LIGHT_BLUE "Python - Create")] Run $(_c LIGHT_YELLOW "source .venv/bin/activate")"

# inform user how to deactivate virtual environment
echo -e "[$(_c LIGHT_BLUE "Python - Create")] To deactivate virtual environment"
echo -e "[$(_c LIGHT_BLUE "Python - Create")] Run $(_c LIGHT_YELLOW "deactivate")"
