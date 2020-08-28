
# iOS Setup guide

## How to install

### CocoaPods
We strongly recommend the use of [CocoaPods](https://cocoapods.org) in order to install our SDK.
In your `Podfile` add the following line to your app target:

```
pod 'CCPAConsentViewController', '1.3.0'
```
### Carthage
We also support [Carthage](https://github.com/Carthage/Carthage). It requires a couple more steps to install so we dedicated a whole [wiki page](https://github.com/SourcePointUSA/CCPA_iOS_SDK/wiki/Carthage-SDK-integration-guide) for it.
Let us know if we missed any step.

### Manual
We also support Manual integration of SDK. It requires a couple more steps to install so we dedicated a whole [wiki page](https://github.com/SourcePointUSA/CCPA_iOS_SDK/wiki/Manual-SDK-integration-guide) for it.
Let us know if we missed any step.

## How to use it

It's pretty simple, here are 5 easy steps for you:

1. implement the `ConsentDelegate` protocol
2. instantiate the `CCPAConsentViewController` with your Account ID, property id, property name, privacy manager id, campaign environment and the consent delegate
3. call `.loadMessage()` when your app starts or `.loadPrivacyManager()` when you wish to show the PrivacyManager.
4. present the controller when the message/PM is ready to be displayed
5. profit!

### Swift
```swift
import CCPAConsentViewController

class ViewController: UIViewController {
    let logger = Logger()

    lazy var consentViewController: CCPAConsentViewController = { return CCPAConsentViewController(
        accountId: 22,
        propertyId: 6099,
        propertyName: try! PropertyName("ccpa.mobile.demo"),
        PMId: "5df9105bcf42027ce707bb43",
        campaignEnv: .Public,
        consentDelegate: self
    )}()

    @IBAction func onPrivacySettingsTap(_ sender: Any) {
        consentViewController.loadPrivacyManager()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        consentViewController.loadMessage()
    }
}

extension ViewController: ConsentDelegate {
    func ccpaConsentUIWillShow() {
        present(consentViewController, animated: true, completion: nil)
    }

    func consentUIDidDisappear() {
        dismiss(animated: true, completion: nil)
    }

    func onConsentReady(consentUUID: ConsentUUID, userConsent: UserConsent) {
        print("consentUUID: \(consentUUID)")
        print("userConsents: \(userConsent)")
        print("CCPA applies:", UserDefaults.standard.bool(forKey: CCPAConsentViewController.CCPA_APPLIES_KEY))
        print("US Privacy String:", UserDefaults.standard.string(forKey: CCPAConsentViewController.IAB_PRIVACY_STRING_KEY)!)
    }

    func onError(ccpaError: CCPAConsentViewControllerError?) {
        logger.log("Error: %{public}@", [ccpaError?.description ?? "Something Went Wrong"])
    }
}
```

### Objective-C
```obj-c
#import "ViewController.h"
@import CCPAConsentViewController;

@interface ViewController ()<ConsentDelegate> {
    CCPAConsentViewController *ccpa;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PropertyName *propertyName = [[PropertyName alloc] init:@"ccpa.mobile.demo" error:NULL];
    ccpa = [[CCPAConsentViewController alloc]
           initWithAccountId:22
           propertyId:6099
           propertyName:propertyName
           PMId:@"5df9105bcf42027ce707bb43"
           campaignEnv:CampaignEnvPublic
           consentDelegate:self];
    [ccpa loadMessage];
}

- (void)consentUIWillShow {
    [self presentViewController:ccpa animated:true completion:NULL];
}

- (void)consentUIDidDisappear {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)onConsentReadyWithConsentUUID:(NSString *)consentUUID userConsent:(UserConsent *)userConsent {
    NSLog(@"ConsentUUID: %@", consentUUID);
    NSLog(@"US Privacy String: %@", userConsent.uspstring);
    NSLog(@"Consent status: %ld", (long)userConsent.status);
    for (id vendorId in userConsent.rejectedVendors) {
        NSLog(@"Rejected to Vendor(id: %@)", vendorId);
    }
    for (id purposeId in userConsent.rejectedCategories) {
        NSLog(@"Rejected to Purpose(id: %@)", purposeId);
    }
}

- (void)onErrorWithCcpaError:(CCPAConsentViewControllerError *)ccpaError {
    NSLog(@"Something went wrong: %@", ccpaError);
}
@end
```

### Authenticated Consent

#### How does it work?
You need to give us a `authId`, that can be anything, user name, email, uuid, as long as you can uniquely identifies an user in your user base.

We'll check our database for a consent profile associated with that `authId`. If we find one, we'll bring it to the user's device and not show a consent message again (technically this will depend on the scenario setup in our dashboard). If we haven't found any consent profile for that `authId` we'll create one and associate with the current user.

#### How to use it?

The workflow to use authenticated consent is exactly the same as the one above but instead of calling:
```swift
consentViewController.loadMessage()
```
you should use:
```swift
consentViewController.loadMessage(forAuthId: String?)
```
