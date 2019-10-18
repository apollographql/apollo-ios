xcrun simctl list runtimes
if [[ -n "${DEVICE_TYPE}" ]]; then
  echo "Making sure simulator is installed"
  xcrun simctl create "${DEVICE_TYPE}_${RUNTIME}" "${DEVICE_TYPE}" "${RUNTIME}"
else
  echo "Not installing simulator as DEVICE_TYPE has no content"
fi
