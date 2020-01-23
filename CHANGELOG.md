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
