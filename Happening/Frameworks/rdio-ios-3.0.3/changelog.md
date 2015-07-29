# Rdio iOS SDK changelog

## 3.0.3

* Fix skip limit enforcement for ad-supported stations
* Remove documentation that said OAuth 2.0 is for partners only

## 3.0.2

* Use services.rdio.com for API and token calls
* Fix issue where playback tokens weren't generated

## 3.0.1

* Client ID is now included in all API requests
* Fix for Facebook login flow

## 3.0.0

* Major updates to the audio streaming engine
* Introduced an `RDPlayerStateBuffering` state to the RDPlayer to indicate
  when the player is buffering.
* Integrate with Rdio's pub-sub servers to allow the iOS SDK to share player
  state across Rdio instances (meaning the iOS SDK can now be used in Rdio's
  'Remote Control' mode)
* Update the Queuing mechanism so that it's compatible with remote control mode.
  This means that the methods used to play and queue tracks have changed.  Please
  see the documentation for RDPlayer for more info.
* Update the codebase to use ARC
* Update the Login screen to fix some issues with landscape devices and Autolayout
* Support OAuth 2.0. The Rdio iOS SDK now requires AFOAuth2Manager as a dependency.
  We recommend using Cocoapods to bring it into your project.
* Remove `RDAPIRequestDelegate` and update the `callAPI` method signature.
  Results of API calls are now passed to `success` and `failure` block parameters,
  similar to how AFNetworking behaves.
* Addition of `RDStationManager` to support proper station playback.  Now when
  you queue up a station source, the RDStationManager will make sure that the
  station never ends until `stop` or `nextSource` is called.
* Special features for partners


## 2.1.4

* Fixed bug for login view while in landscape mode for some devices

## 2.1.3

* `logout` will no longer delete all cookies

## 2.1.2

* Further protection from crashing when handling rdioRequest errors

## 2.1.1

* Fix for crash when handling playback and access token retrival errors

## 2.1.0

* Improve the stability of seeking
* `seekToPosition:` now calls delegate when changing playback state
* Two new `RDPlayerDelegate` methods: `rdioPlayerSetAudioCategory` and `rdioPlayerSetAudioSessionActive:` for controlling the audio session
* Reduce log level from warning to info for "Got NSNull for result" message

## 2.0.1

* Rename `initPlayerWithDelegate:` to `preparePlayerWithDelegate:` to prevent issues with ARC

## 2.0.0

* Separate RDPlayer initialization from Rdio initialization so that API calls are not made on load.
* Add interval-based listeners on playback position and on audio signal level,
  introducing a dependency on `CoreMedia.framework`, and adding 4 new methods:
  *  `-(id)addPeriodicTimeObserverForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(CMTime time))block`
  *  `-(void)removeTimeObserver:(id)observer`
  *  `-(id)addPeriodicLevelObserverForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(Float32 left, Float32 right))block`
  *  `-(void)removeLevelObserver:(id)observer`
* Remove deprecated `authorizeUsingAccessToken:fromController:` method
* Update the following error-related delegates to expect NSError instead of
  NSString:
  * `-(void)rdioAuthorizationFailed:(NSError *)error`
  * `-(BOOL)rdioPlayerFailedDuringTrack:(NSString *)trackKey withError:(NSError *)error`
  * `-(void)rdioRequest:(RDAPIRequest *) didFailWithError:(NSError *)error`
* Use `RDErrorDomain` and error codes from a new `RDErrorCode` enum.
* Fix a bug that caused the Authorization View to be un-dismissable in
  situations without network connectivity.
* Make RDPlayer's `duration` KVO-compliant
* Internal bug fixes, and dependency simplification
* Fix a bug where seek requests made before the track was loaded would get lost

## version 1.3.7

* Fix a crash when canceling `RDAuthViewController` (https://github.com/rdio/api/issues/118)

## version 1.3.6

* Fix status bar using parent VC's preferred status bar settings. (https://github.com/rdio/api/issues/99)
* Handle unstreamable tracks correctly when pre-buffering. (https://github.com/rdio/api/issues/112)
* Calling `previous` while playing the first track now causes playback to stop.
  (Previously it was a NOP)
* Fix CPU spike issue (https://github.com/rdio/api/issues/113)

## version 1.3.5

* Fix logout so that the Auth view prompts the user to login again.
* Fix `skipToIndex:` issue.

## version 1.3.4

* Fix the Auth View Controller's landscape view.

## version 1.3.3

* Fix `-updateQueue:withCurrentTrackIndex:` race condition. All queue
  manipulation methods are now serialized properly so that the required
  network requests don't create undesirable states.
* Fix documentation on `-play`
* Better sanity checking in various places
* Handle iOS 7's status bar changes by pushing the Auth View down by
  the status bar's height if the SDK is running on iOS 7.

## version 1.3.2

* Patch for iPad login view glitch


## version 1.3.1

* Fix playSources extras bug introduced in 1.3.0


## version 1.3.0

* Renovated login view that supports Facebook auth


## version 1.2

* Add `-authorizeUsingAccessToken:`, which does not automatically pop up the
  login view on failure ([issue #30](https://github.com/rdio/api/issues/30)):w
* Mark `-authorizeUsingAccessToken:fromController:` as deprecated.  Projects
  should be updated to use `-authorizeUsingAccessToken:` instead, and handle
  the error case themselves
* Bug fixes for RDPlayer and the under-the-hood OAuth library
* Add `-skipToIndex:` and `-resetQueue` methods to RDPlayer
* Add `rdioPlayerCouldNotStreamTrack:` method to RDPlayerDelegate
* Tidy up NSLogs
* Documentation updates
