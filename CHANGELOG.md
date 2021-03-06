## 1.6.0 (Dec, 16, 2020)
* Added support to Swift Package Manager (SPM) [#56](https://github.com/SourcePointUSA/CCPA_iOS_SDK/pull/56)

## 1.5.0 (Dec, 15, 2020)
* Added a feature to attach an arbitrary payload(publisher data) to action data. Check how to use it in this [section of the README](https://github.com/SourcePointUSA/CCPA_iOS_SDK#pubdata). [#55](https://github.com/SourcePointUSA/CCPA_iOS_SDK/pull/55)

## 1.4.0 (Nov, 07, 2020)
* Prefixed error classes with `CCPA` to avoid class naming clashes with the GDPR SDK [#50](https://github.com/SourcePointUSA/CCPA_iOS_SDK/pull/50)
* Fixed an issue with authenticated consent not clearing user data when authId changed [#54](https://github.com/SourcePointUSA/CCPA_iOS_SDK/pull/54)
* Significantly improved end-to-end testing

## 1.3.3 (Oct, 09, 2020)
*  Fixed an issue that was causing clash between GeneralRequestError class in GDPR and CCPA SDKs [#50](https://github.com/SourcePointUSA/CCPA_iOS_SDK/pull/50).
## 1.3.2 (Sept, 29, 2020)
* Fixed an issue that was causing clash between onError methods in GDPR and CCPA SDKs [#48](https://github.com/SourcePointUSA/CCPA_iOS_SDK/pull/48).
## 1.3.1 (Aug, 13, 2020)
* Fix an issue that'd prevent the onAction delegate method from being called [#47](https://github.com/SourcePointUSA/CCPA_iOS_SDK/pull/47).
* Implement .description to Action class [#46](https://github.com/SourcePointUSA/CCPA_iOS_SDK/pull/46).
* Make sure onConsentReady is called on all actions that closes the ConsentUI [#41](https://github.com/SourcePointUSA/CCPA_iOS_SDK/pull/41).
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
