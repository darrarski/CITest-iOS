#!/bin/sh

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi

if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. No deployment will be done."
  exit 0
fi

# Thnaks @JagCesar https://gist.github.com/JagCesar/a6283bc2cb2f439b3a1d 
# Thanks @djacobs https://gist.github.com/djacobs/2411095
 
PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
OUTPUTDIR="/Users/travis/build"
 
echo "********************"
echo "*     Signing      *"
echo "********************"
xcrun -log -sdk iphoneos PackageApplication "$OUTPUTDIR/$APPNAME.app" -o "$OUTPUTDIR/$APPNAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"
 
RELEASE_NOTES="This version was uploaded automagically by Travis\nTravis Build number: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"
 
zip -r -9 "$OUTPUTDIR/$APPNAME.app.dSYM.zip" "$OUTPUTDIR/$APPNAME.app.dSYM"
 
echo "********************"
echo "*    Uploading     *"
echo "********************"

IPA_FILE="$OUTPUTDIR/$APPNAME.ipa"
DSYM_ZIP_FILE="$OUTPUTDIR/$APPNAME.app.dSYM.zip"
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
echo "NOTES: $RELEASE_NOTES"
echo "DISTRIBUTION_LISTS: $TF_DISTRIBUTION_LISTS"
echo "FILE: $OUTPUTDIR/$APPNAME.ipa [$IPA_FILE_TEST]"
echo "DSYM: $OUTPUTDIR/$APPNAME.app.dSYM.zip [$DSYM_ZIP_FILE_TEST]"
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
  -F distribution_lists="$TF_DISTRIBUTION_LISTS")

echo
echo "RESPONSE: $RESPONSE"
echo
