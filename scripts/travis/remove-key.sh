# Remove keychain
security delete-keychain ios-build.keychain

# Remove mobile provisioning profile files
rm -f ~/Library/MobileDevice/Provisioning\ Profiles/*
