# Only major and minor version should be specified here
REQUIRED_APOLLO_CLI_VERSION=1.2.0

# Part of this code has been adapted from
# https://github.com/facebook/react-native/blob/master/scripts/react-native-xcode.sh

# This script is supposed to be invoked as part of the Xcode build process
# and relies on environment variables set by Xcode

install_apollo_cli() {
  # Exit immediately if the command fails
  set -e
  npm install --prefix $SRCROOT apollo@$REQUIRED_APOLLO_CLI_VERSION
  set +e
}

# We consider versions to be compatible if the major and minor versions match
are_versions_compatible() {
  [[ "$(cut -d/ -f2 <<< $1 | cut -d. -f1-2)" == "$(cut -d/ -f2 <<< $2 | cut -d. -f1-2)" ]]
}

get_installed_version() {
  version=$($SRCROOT/node_modules/.bin/apollo -v)
  if [[ $? -eq 0 ]]; then
    echo "$version"
  else
    echo "an unknown older version"
  fi
}

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

if [[ -s "$SRCROOT/node_modules/.bin/apollo" ]]; then
  # If it's installed locally, use version build instead
  set -x

  INSTALLED_APOLLO_CLI_VERSION="$(get_installed_version)"

  if ! are_versions_compatible $INSTALLED_APOLLO_CLI_VERSION $REQUIRED_APOLLO_CLI_VERSION; then
    echo "The version of Apollo.framework in your project requires Apollo CLI $REQUIRED_APOLLO_CLI_VERSION, \
  but $INSTALLED_APOLLO_CLI_VERSION seems to be installed. Installing..."
    install_apollo_cli
  fi

  exec "$SRCROOT/node_modules/.bin/apollo" "$@"
else
  # Otherwise install locally
  echo "Can't find Apollo CLI. Installing..."
  install_apollo_cli

  # Print commands before executing them (useful for troubleshooting)
  set -x

  exec "$SRCROOT/node_modules/.bin/apollo" "$@"
fi
