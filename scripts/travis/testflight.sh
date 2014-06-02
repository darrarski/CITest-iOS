#!/bin/sh

# Thnaks @JagCesar https://gist.github.com/JagCesar/a6283bc2cb2f439b3a1d 
# Thanks @djacobs https://gist.github.com/djacobs/2411095

################################################################################
# Configuration

# TestFlight API Token
# TF_API_TOKEN=... (stored securely in .travis.yml)

# TestFlight Team Token
# TF_TEAM_TOKEN=... (stored securely in .travis.yml)

# TestFlight distribution lists (coma separated)
TF_DISTRIBUTION_LISTS="CITest"

# Notify permitted teammates to install the build
TF_NOTIFY=True

# Replace binary for an existing build if one is found with the same name/bundle version
TF_REPLACE=True

# Deploy only if testing on this branch
TF_BRANCH="master"

# Build directory
BUILD_DIR="/Users/travis/build/release"

# Release date
RELEASE_DATE=`date -u '+%Y-%m-%d %H:%M:%S %Z'`

# Release notes
RELEASE_NOTES="This version was uploaded automagically by Travis\nTravis Build number: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"

# Application name
APPNAME="CITest"

# Developer name used to sign the app
DEVELOPER_NAME="iPhone Distribution: EL Passion Next Sp. z o.o."

# Mobile provisioning profile name used to sign the app
PROFILE_NAME=Wildcard_App_InHouse_Dist

# Path to provisioning profile file
PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"

################################################################################

# Don't deploy on pull requests (Travis secure variables are not available in that case)
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  echo
  exit 0
fi

# Don't deploy on branches other than configured
if [[ "$TRAVIS_BRANCH" != "$TF_BRANCH" ]]; then
  echo "Testing on a branch other than $TF_BRANCH. No deployment will be done."
  echo
  exit 0
fi

################################################################################
echo
echo "***** Signing *****"
echo

rm -f "$BUILD_DIR/$APPNAME.ipa"
rm -f "$BUILD_DIR/$APPNAME.app.dSYM"
xcrun -log -sdk iphoneos PackageApplication "$BUILD_DIR/$APPNAME.app" -o "$BUILD_DIR/$APPNAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

rm -f "$BUILD_DIR/$APPNAME.app.dSYM.zip"
zip -r -9 "$BUILD_DIR/$APPNAME.app.dSYM.zip" "$BUILD_DIR/$APPNAME.app.dSYM"

################################################################################
echo
echo "***** Uploading *****"
echo

IPA_FILE="$BUILD_DIR/$APPNAME.ipa"
DSYM_ZIP_FILE="$BUILD_DIR/$APPNAME.app.dSYM.zip"
TF_READY_TO_UPLOAD=true

if [[ ! -f $IPA_FILE ]]; then
    IPA_FILE_TEST="NOT FOUND"
    TF_READY_TO_UPLOAD=false
else
  IPA_FILE_TEST="OK"
fi

if [[ ! -f $DSYM_ZIP_FILE ]]; then
    DSYM_ZIP_FILE_TEST="NOT FOUND"
    TF_READY_TO_UPLOAD=false
else
  DSYM_ZIP_FILE_TEST="OK"
fi

echo
echo "RELEASE NOTES:\n$RELEASE_NOTES"
echo
echo "DISTRIBUTION_LISTS: $TF_DISTRIBUTION_LISTS"
echo
echo "IPA FILE: $IPA_FILE [$IPA_FILE_TEST]"
echo
echo "DSYM ZIP FILE: $DSYM_ZIP_FILE [$DSYM_ZIP_FILE_TEST]"
echo

if ! $TF_READY_TO_UPLOAD ; then
  echo "ERROR"
  echo
  exit 1
fi

RESPONSE=$(curl http://testflightapp.com/api/builds.json \
  -F file="@$IPA_FILE" \
  -F dsym="@$DSYM_ZIP_FILE" \
  -F api_token="$TF_API_TOKEN" \
  -F team_token="$TF_TEAM_TOKEN" \
  -F notes="$RELEASE_NOTES" \
  -F notify=$TF_NOTIFY \
  -F replace=$TF_REPLACE \
  -F distribution_lists="$TF_DISTRIBUTION_LISTS")

echo
echo "RESPONSE: $RESPONSE"
echo
