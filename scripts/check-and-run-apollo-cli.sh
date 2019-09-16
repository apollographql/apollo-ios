# Only major and minor version should be specified here
REQUIRED_APOLLO_CLI_VERSION=2.17
# Specify fully qualified version here. Ideally this should be a LTS version.
REQUIRED_NODE_VERSION=10.16.0

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

# Add MacPorts default bin path if the user has `port` command.
if [[ -x /opt/local/bin/port ]]; then
    PATH="$PATH:/opt/local/bin"
fi

use_correct_node_via_nvm() {
  nvm version $REQUIRED_NODE_VERSION > /dev/null
  if [[ $? -eq 0 ]]; then
    # The version of node that we want is installed.
    nvm use $REQUIRED_NODE_VERSION
  else
    nvm install $REQUIRED_NODE_VERSION
  fi
}

use_correct_node_via_nodenv() {
  nodenv install -s $REQUIRED_NODE_VERSION
  nodenv shell $REQUIRED_NODE_VERSION
}

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  . "$HOME/.nvm/nvm.sh"
  use_correct_node_via_nvm
elif [[ -x "$(command -v brew)" && -s "$(brew --prefix nvm)/nvm.sh" ]]; then
  . "$(brew --prefix nvm)/nvm.sh"
  use_correct_node_via_nvm
fi

# Set up the nodenv node version manager if present
if [[ -x "$HOME/.nodenv/bin/nodenv" ]]; then
  eval "$("$HOME/.nodenv/bin/nodenv" init -)"
  use_correct_node_via_nodenv
fi

parse_version() {
  if [[ $1 =~ ([0-9\.]+) ]]; then
    echo ${BASH_REMATCH[1]}
  fi
}

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
  echo "warning: Installing apollo@$REQUIRED_APOLLO_CLI_VERSION in your project directory to avoid version conflicts..."
  # Exit immediately if the command fails
  set -e
  npm install --prefix "$PROJECT_DIR" --no-package-lock apollo@$REQUIRED_APOLLO_CLI_VERSION
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
