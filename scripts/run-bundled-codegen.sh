# Get the path to the script directory
SCRIPT_DIR="$(eval dirname $0)"

# Use the bundled executable of the Apollo CLI to generate code
APOLLO_CLI="${SCRIPT_DIR}/apollo/bin/run"

# Print version
echo "Apollo CLI Information: $(eval ${APOLLO_CLI} --version)"

# Print commands before executing them (useful for troubleshooting)
set -x
$APOLLO_CLI "$@"
