#!/bin/sh

# https://gist.github.com/JagCesar/a6283bc2cb2f439b3a1d

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. No deployment will be done."
  exit 0
fi
 
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

echo "OUTPUTDIR:"
ls $OUTPUTDIR

echo "DISTRIBUTION_LISTS:"
echo $DISTRIBUTION_LISTS

curl http://testflightapp.com/api/builds.json \
  -F file="@$OUTPUTDIR/$APPNAME.ipa" \
  -F dsym="@$OUTPUTDIR/$APPNAME.app.dSYM.zip" \
  -F api_token="$API_TOKEN" \
  -F team_token="$TEAM_TOKEN" \
  -F distribution_lists=$DISTRIBUTION_LISTS \
  -F notes="$RELEASE_NOTES" -v \
  -F notify="FALSE"