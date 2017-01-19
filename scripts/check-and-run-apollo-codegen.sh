REQUIRED_APOLLO_CODEGEN_VERSION=0.10

# Part of this code has been adapted from https://github.com/facebook/react-native/blob/master/packager/react-native-xcode.sh

# This script is supposed to be invoked as part of the Xcode build process
# and relies on environment variables set by Xcode

if [[ -z "$CONFIGURATION" ]]; then
    echo "$0 must be invoked as part of an Xcode script phase"
    exit 1
fi

# Define NVM_DIR and source the nvm.sh setup script
[[ -z "$NVM_DIR" ]] && export NVM_DIR="$HOME/.nvm"

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  . "$HOME/.nvm/nvm.sh"
elif [[ -x "$(command -v brew)" && -s "$(brew --prefix nvm)/nvm.sh" ]]; then
  . "$(brew --prefix nvm)/nvm.sh"
fi

# Set up the nodenv node version manager if present
if [[ -x "$HOME/.nodenv/bin/nodenv" ]]; then
  eval "$("$HOME/.nodenv/bin/nodenv" init -)"
fi

if ! type "apollo-codegen" >/dev/null 2>&1; then
  echo "error: Can't find apollo-codegen command; make sure to run 'npm install -g apollo-codegen' first."
  exit 1
fi

# We consider versions to be compatible if the major and minor versions match
are_versions_compatible() {
  [[ "$(cut -d. -f1-2 <<< $1)" == "$(cut -d. -f1-2 <<< $2)" ]]
}

get_installed_version() {
  version=$(apollo-codegen --version)
  if [[ $? -eq 0 ]]; then
    echo "$version"
  else
    echo "an unknown older version"
  fi
}
INSTALLED_APOLLO_CODEGEN_VERSION="$(get_installed_version)"

if ! are_versions_compatible $INSTALLED_APOLLO_CODEGEN_VERSION $REQUIRED_APOLLO_CODEGEN_VERSION; then
  echo "error: The version of Apollo.framework in your project requires the use of version $REQUIRED_APOLLO_CODEGEN_VERSION of apollo-codegen, \
but $INSTALLED_APOLLO_CODEGEN_VERSION seems to be installed."
  exit 1
fi

# Print commands before executing them (useful for troubleshooting)
set -x

exec apollo-codegen "$@"
