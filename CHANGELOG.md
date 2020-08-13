## 1.3.1 (Aug, 13, 2020)
* Fix an issue that'd prevent the `onAction` delegate method from being called #47
* Implement `.description` to `Action` class #46
* Make sure `onConsentReady` is called on all actions that closes the ConsentUI #41

## 1.3.0 (Jun, 12, 2020)
* Store the `IABUSPrivacy_String` as spec'ed by the [CCPA IAB](https://github.com/InteractiveAdvertisingBureau/USPrivacy/blob/master/CCPA/USP%20API.md#in-app-support).
* Store the "ccpa applies" boolean. This is not covered by the IAB CCPA In-app spec so we're using our own key. It can be retrieved by reading it from the `UserDefaults` with:
```swift
UserDefaults.standard.bool(forKey: CCPAConsentViewController.CCPA_APPLIES_KEY)
```
* Fixed an issue that'd prevent the consent message from showing again if the user dismissed it in the first place.

## 1.2.0 (April, 30, 2020)
* Added authenticated consent. For more details on how to use it check the README

## 1.1.3 (March, 18, 2020)
* Added a new consent status ConsentedAll.
* Fixed an issue that was causing consent from not being stored when clickin on a button of action type "Accept All"
* Fixed an issue that prevented the message from showing on every second app launch if no user interaction was taken.
* Fixed an issue that would cause the stored userConsents to always be RejectedNone

## 1.1.2 (March, 16, 2020)
* ConsentUIWillShow deprecated and substituted for ccpaConsentUIWillShow to enable integration with gdpr SDK.

## 1.1.1 (January, 27, 2020)
* expanded `PropertyName` to accept property names with dashes (-)

## 1.1.0 (January, 21, 2020)
* Changed init method to receive `campaignEnv` instead of `campaign`
* `campaignEnv` is now an enum (`CampaignEnv`) with two possible values `.Public` and `.Stage`
* added `@objcMembers` to `UserConsent` class.
* added `targetingParams: TargetingParams` to CCPAConsentViewController's init method. The `targetingParams` is a dictionary of arbitrary key/value strings that can be passed by the host app and used in the scenario builder on SourcePoint's dashboard.
* fixed an issue preventing the SDK from loading a CCPA message

## 1.0.0 (December, 19, 2019)

First release.
* Using the new and improved native message client.
* Using new wrapper api with CCPA endpoints
