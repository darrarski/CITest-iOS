#!/bin/sh
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. No deployment will be done."
  exit 0
fi
 
PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_UUID.mobileprovision"
RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
OUTPUTDIR="$PWD/build/Release-iphoneos"
 
mkdir -p $OUTPUTDIR
 
LATEST_ARCHIVE_PATH=`find ~/Library/Developer/Xcode/Archives -type d -Btime -60m -name '*.xcarchive' | head -1`
echo $LATEST_ARCHIVE_PATH
 
PRODUCT_PATH="$LATEST_ARCHIVE_PATH/Products/Applications/$APPNAME.app"
DSYM_PATH="$LATEST_ARCHIVE_PATH/dSYMs/$APPNAME.app.dSYM"
echo $PRODUCT_PATH
echo $DSYM_PATH
 
 
echo "********************"
echo "*     Signing      *"
echo "********************"
xcrun -log -sdk iphoneos PackageApplication -v "$PRODUCT_PATH" -o "$OUTPUTDIR/$APPNAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"
 
RELEASE_NOTES="Build: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"
 
zip -r -9 "$OUTPUTDIR/$APPNAME.app.dSYM.zip" "$DSYM_PATH"
 
IPA_SIZE=$(stat -c%s "$OUTPUTDIR/$APPNAME.ipa")
echo "IPA SIZE: $IPA_SIZE"
DSYM_SIZE=$(stat -c%s "$OUTPUTDIR/$APPNAME.app.dSYM.zip")
echo "DSYM SIZE: $DSYM_SIZE"
 
echo "********************"
echo "*    Uploading     *"
echo "********************"
curl http://testflightapp.com/api/builds.json \
  -F file="@$OUTPUTDIR/$APPNAME.ipa" \
  -F dsym="@$OUTPUTDIR/$APPNAME.app.dSYM.zip" \
  -F api_token="$API_TOKEN" \
  -F team_token="$TEAM_TOKEN" \
  -F distribution_lists='Internal' \
  -F notes="$RELEASE_NOTES" -vs
