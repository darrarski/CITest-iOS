CITest-iOS
==========

This repository contains iOS project used for testing Travis CI service.

Last build status: 
[![Build Status](https://travis-ci.org/darrarski/CITest-iOS.svg?branch=master)](https://travis-ci.org/darrarski/CITest-iOS)

## Continuous Integration

This project is using Travis CI. The repository is configured for following continuous integration flow:

- Commit and push changes to master branch
- Travis CI will fetch changes and update dependencies defined in Podfile using Cocoapods
- Build project for iPhone Simulator and run unit tests
- Build project for iPhone (distribution)
- Sign app with distribution certificate contained in the repository
- Upload signed IPA file and dSYM to TestFlight API
- If build version changed, notify teammates via TestFlight

Whole process is triggered by pushing changes to the repository and is fully automatic. Distribution certificate, TestFlight API keys and other valuable data are encrypted and stored securely in the repository, so it could be publically available without any risk.

## Credits

- [EL Passion](http://www.elpassion.pl) mobile development team

- [JagCesar](https://gist.github.com/JagCesar/a6283bc2cb2f439b3a1d)

- [johanneswuerbach](https://gist.github.com/johanneswuerbach/5559514)
