# Only major and minor version should be specified here
REQUIRED_APOLLO_CLI_VERSION=1.8
# Only major version should be specified here
REQUIRED_NODE_VERSION=8

# Using npx to execute 'apollo' looks for a local install in node_modules before checking $PATH (for a global install)
APOLLO_CLI="npx --no-install apollo"

# Part of this code has been adapted from
# https://github.com/facebook/react-native/blob/master/scripts/react-native-xcode.sh

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

parse_version() {
  if [[ $1 =~ ([0-9\.]+) ]]; then
    echo ${BASH_REMATCH[1]}
  fi
}

get_installed_node_version() {
  version=$(node -v)
  if [[ $? -eq 0 ]]; then
    echo "$version"
  fi
}

is_mimimum_major_version() {
  [[ "$(parse_version $1 | cut -d. -f1)" -ge $2 ]]
}

# Check the installed version of Node, if available
INSTALLED_NODE_VERSION="$(get_installed_node_version)"
if [[ -z "$INSTALLED_NODE_VERSION" ]]; then
  echo "error: Apollo CLI requires Node $REQUIRED_NODE_VERSION or higher to be installed."
  exit 1
elif ! is_mimimum_major_version "$INSTALLED_NODE_VERSION" $REQUIRED_NODE_VERSION; then
  echo "error: Apollo CLI requires Node $REQUIRED_NODE_VERSION or higher, \
but $INSTALLED_NODE_VERSION seems to be installed."
  exit 1
fi

get_installed_cli_version() {
  version=$($APOLLO_CLI -v)
  if [[ $? -eq 0 ]]; then
    echo "$version"
  fi
}

# We consider versions to be compatible if the major and minor versions match
are_versions_compatible() {
  [[ "$(parse_version $1 | cut -d. -f1-2)" == $2 ]]
}

install_apollo_cli() {
  echo "note: Installing apollo@$REQUIRED_APOLLO_CLI_VERSION in your project directory to avoid version conflicts..."
  # Exit immediately if the command fails
  set -e
  npm install --prefix $PROJECT_DIR --no-package-lock apollo@$REQUIRED_APOLLO_CLI_VERSION
  set +e
}

# Check the installed version of the Apollo CLI, if available
INSTALLED_APOLLO_CLI_VERSION="$(get_installed_cli_version)"

if [[ -z "$INSTALLED_APOLLO_CLI_VERSION" ]]; then
  echo "warning: Apollo iOS requires version $REQUIRED_APOLLO_CLI_VERSION.x of the Apollo CLI to be installed \
either globally or in a local node_modules directory."
  install_apollo_cli
elif ! are_versions_compatible "$INSTALLED_APOLLO_CLI_VERSION" $REQUIRED_APOLLO_CLI_VERSION; then
  echo "warning: The version of Apollo.framework in your project requires Apollo CLI $REQUIRED_APOLLO_CLI_VERSION.x, \
but $INSTALLED_APOLLO_CLI_VERSION seems to be installed."
  install_apollo_cli
fi

# Print commands before executing them (useful for troubleshooting)
set -x
$APOLLO_CLI "$@"
