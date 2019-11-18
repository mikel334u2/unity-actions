#!/usr/bin/env bash

set -e

echo "$UNITY_LICENSE" > /root/.local/share/unity3d/Unity/Unity_lic.ulf
echo "$UNITY_LICENSE" > /root/.local/share/unity3d/Unity/Unity_v2019.2.11f1.ulf
echo "$UNITY_LICENSE" > Unity_v2019.2.11f1.ulf

cat /root/.local/share/unity3d/Unity/Unity_lic.ulf

set -x

# Activate container
# See: https://docs.unity3d.com/Manual/CommandLineArguments.html
echo "Activating container"
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' \
  /opt/Unity/Editor/Unity \
    -batchmode \
    -manualLicenseFile Unity_v2019.2.11f1.ulf \
    -nographics \
    -logFile /dev/stdout \
    -quit || true

echo "Activation attempt 2"

xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' \
  /opt/Unity/Editor/Unity \
    -batchmode \
    -manualLicenseFile Unity_v2019.2.11f1.ulf \
    -nographics \
    -logFile /dev/stdout \
    -quit \
    -username "$UNITY_EMAIL" \
    -password "$UNITY_PASSWORD" || true

echo "Testing for $TEST_PLATFORM"

xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' \
  /opt/Unity/Editor/Unity \
    -batchmode \
    -manualLicenseFile Unity_v2019.2.11f1.ulf \
    -nographics \
    -logFile /dev/stdout \
    -quit \
    -projectPath "$GITHUB_WORKSPACE" \
    -testPlatform $TEST_PLATFORM \
    -testResults "$GITHUB_WORKSPACE/$TEST_PLATFORM-results.xml" \
    -runTests

# For if needed
#    -username "$UNITY_EMAIL" \
#    -password "$UNITY_PASSWORD" \

UNITY_EXIT_CODE=$?

if [ $UNITY_EXIT_CODE -eq 0 ]; then
  echo "Run succeeded, no failures occurred";
elif [ $UNITY_EXIT_CODE -eq 2 ]; then
  echo "Run succeeded, some tests failed";
elif [ $UNITY_EXIT_CODE -eq 3 ]; then
  echo "Run failure (other failure)";
else
  echo "Unexpected exit code $UNITY_EXIT_CODE";
fi

echo "Results: "
cat $GITHUB_WORKSPACE/$TEST_PLATFORM-results.xml
cat $GITHUB_WORKSPACE/$TEST_PLATFORM-results.xml | grep test-run | grep Passed
exit $UNITY_TEST_EXIT_CODE
