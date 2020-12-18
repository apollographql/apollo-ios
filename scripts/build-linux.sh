set -eu

target="Apollo"

echo "preparing docker build image"
docker build . -t builder
echo "docker build done"

echo "building target"
docker run --rm -v "$(pwd)":/workspace -w /workspace builder bash -cl "swift build --target $target"
echo "target build done"

# now what?