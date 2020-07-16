package tests;

import static org.framework.logger.LoggingManager.logMessage;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import org.framework.allureReport.TestListener;
import org.framework.pageObjects.MobilePageWrapper;
import org.testng.Assert;
import org.testng.annotations.Listeners;
import org.testng.annotations.Test;
import org.testng.asserts.SoftAssert;

import io.qameta.allure.Description;

@Listeners({ TestListener.class })
public class CCPA_MetaAppTests extends BaseTest {

	String accountId = "808";
	String siteName = "ccpa.automation.testing.com";
	String staggingValue = "OFF";
	String key = "region";
	String value = "ca";
	String siteID = "7050";
	String pmID = "5ed09c33a785184c33f91f64";
	String authID;
	String expectedCAMessageTitle = "TEST CONSENT MESSAGE CALIFORNIA REGION KEY-VALUE PAIR";
	String expectedCAMessageText = "To offer the best experience of relevant content, information and advertising. By clicking to continue, you accept our use of cookies.";

	String expectedShowOnceTitle = "SHOW ONLY ONCE MESSAGE";
	String expectedShowOnceText = "THIS MESSAGE ONLY SHOW ONCE IF THE TARGETING CRITERIA MET";
	String expectedWrongCampaignMessage = "There is no message matching the scenario based on the property info and device local data. Consider reviewing the property info or clearing the cookies. If that was intended, just ignore this message.";

	String expectedAnotherCAMessageText = "Cookies and other technologies are used on this site to offer users the best experience of relevant content, information and advertising. As a California resident you have the right to adjust what data we and our partner collect to optimize your experience. You can view more information on the specific categories of third parties that are used and which data is accessed and stored by clicking on \"Settings\". For more information, please review our ";

	private static final DateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");

	ArrayList<String> expectedCAMsg = new ArrayList<String>();

	public ArrayList<String> setExpectedCAMsg() {
		expectedCAMsg.add(expectedCAMessageTitle);
		expectedCAMsg.add(expectedCAMessageText);
		return expectedCAMsg;
	}

	ArrayList<String> expectedShowOnceMsg = new ArrayList<String>();

	public ArrayList<String> setShowOnceExpectedMsg() {
		expectedShowOnceMsg.add(expectedShowOnceTitle);
		expectedShowOnceMsg.add(expectedShowOnceText);
		return expectedShowOnceMsg;
	}

	ArrayList<String> expectedAnotherCAMsg = new ArrayList<String>();

	public ArrayList<String> setAnotherExpectedCAMsg() {
		expectedAnotherCAMsg.add(expectedAnotherCAMessageText);
		return expectedAnotherCAMsg;
	}

	@Test(groups = { "CCPASDKTests" }, priority = 1)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent should display When user click on Privacy Settings button Then user\n"
			+ "	 will see Privacy Manager screen When user click on Cancel button Then user\n"
			+ "	 will navigate back to the consent message")
	public void CheckCancleFromPrivacyManager() throws InterruptedException {
		logMessage("CheckCancleFromPrivacyManager - \" + String.valueOf(Thread.currentThread().getId())");
		SoftAssert softAssert = new SoftAssert();
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details....");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			logMessage("Check for message and tap on Privacy Manager button");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));
			logMessage("Verify Privacy Manager displayed");
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			logMessage("Tap on Cancel and verify user navigate back to the message");
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			mobilePageWrapper.privacyManagerPage.ccpa_CancelButton.click();

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage1.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedCAMsg));

		} catch (Exception e) {
			logMessage("Exception: " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPASDKTests" }, priority = 2)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent message should display When user select Reject all Then user will\n"
			+ "	 navigate to Site Info screen showing ConsentUUID and no EUConsent and with no\n"
			+ "	 Vendors & Purpose Consents When user navigate back & tap on the site name and\n"
			+ "	 select MANAGE PREFERENCES button from consent message view Then he/she will\n"
			+ "	 see all vendors & purposes as selected")
	public void CheckConsentOnRejectAllFromMessage() throws InterruptedException {
		logMessage("CheckConsentOnRejectAllFromMessage - " + String.valueOf(Thread.currentThread().getId()));
		SoftAssert softAssert = new SoftAssert();
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			logMessage("Check for message and tap on Reject All");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg), "Expected consent message not displayed");

			mobilePageWrapper.consentViewPage.eleButton("Reject All").click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());

			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");
			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			logMessage("Tap on the property again and navigate to PM");

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName,
					"Property not present");
			mobilePageWrapper.siteListPage.tapOnSite_ccpa(siteName, mobilePageWrapper.siteListPage.CCPASiteList);

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			logMessage("Verify all toggle button displayed as false");
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Manager not displayed");
			// check PM data for all false

		} catch (Exception e) {
			logMessage("Exception: " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPASDKTests" }, priority = 3)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent message should display When user tap on Privacy Manager button And navigate to PM, all consent\n"
			+ "	 toggle should show as selected When user tap on Reject all Then should see\n"
			+ "	 same ConsentUUID data")
	public void CheckConsentOnRejectAllFromPM() throws InterruptedException {
		logMessage(" Test execution start : CheckConsentOnRejectAllFromPM");
		SoftAssert softAssert = new SoftAssert();
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details...");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			logMessage("Check for the message and tap on Privacy Settings");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg), "Expected consent message not displayed");

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Manager not displayed");
			// check for all purposes selected as true
			logMessage("Tap on Reject All and check updated consent informations");
			mobilePageWrapper.privacyManagerPage.ccpa_RejectAllButton.click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());

			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage
					.checkForNoPurposeConsentData(mobilePageWrapper.siteDebugInfoPage.CCPAConsentNotAvailable));
		} catch (Exception e) {
			logMessage("Exception: " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPASDKTests" }, priority = 4)
	@Description("Given user submit valid property details and tap on Save "
			+ "Then expected message should display When user tap on Privacy Settings "
			+ "Then all vendors/purposes should display as selected "
			+ "When user tap on Reject All and navigate back Then no consent information should get stored"
			+ "When user reset property cookies Then he/she should see message again"
			+ "When user tap on Privacy Settng button Then all consent information data should displayed as true")
	public void CheckPurposeConsentAfterResetCookies() throws InterruptedException {
		logMessage("CheckPurposeConsentAfterResetCookies - " + String.valueOf(Thread.currentThread().getId()));
		SoftAssert softAssert = new SoftAssert();
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details....");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			logMessage("Check for message and tap on Privacy Settings button");
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Manager not displayed");

			logMessage("Check for all vendors/purposes selected as true");
			mobilePageWrapper.privacyManagerPage.ccpa_RejectAllButton.click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);
			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);

			logMessage("Delete cookies for the property and check for message");
			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Reset");

			softAssert.assertTrue(mobilePageWrapper.consentViewPage.verifyDeleteCookiesMessage());

			mobilePageWrapper.consentViewPage.YESButton.click();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			logMessage("Tap on Privacy Setting button and check all consents are selected as true");
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
		} catch (Exception e) {
			logMessage("Exception: " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPASDKTests" }, priority = 5)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent message should display When user tap on Reject All from Then consent data\n"
			+ "	 should get stored When user navigate to PM directly by clicking on Show PM\n"
			+ "	 link Then all vendors/purposes should display as false")
	public void CheckConsentDataFromPrivacyManagerDirect() throws InterruptedException {
		logMessage("CheckConsentDataFromPrivacyManagerDirect - " + String.valueOf(Thread.currentThread().getId()));
		SoftAssert softAssert = new SoftAssert();
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details....");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			logMessage("Check for message and tap on Reject All button");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Reject All").click();

			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);

			logMessage("Tap on Show Pm link to display PM directly and check all consents are selected as false");
			mobilePageWrapper.siteDebugInfoPage.CCPAShowPMLink.click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy manager not displayed");
			logMessage("Tap on Reject All button and check no consent data available ");
			mobilePageWrapper.privacyManagerPage.ccpa_RejectAllButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(), consentData.get(0));
			softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage
					.checkForNoPurposeConsentData(mobilePageWrapper.siteDebugInfoPage.CCPAConsentNotAvailable));

		} catch (Exception e) {
			logMessage("Exception : " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPASDKTests" }, priority = 6)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent message should display When user tap on Reject All from Then no consent data\n"
			+ "	 should get stored When user navigate to PM directly by clicking on Show PM\n"
			+ "	 link And tap on Cancel Then he.she should navigate back to info screen with no consent data")
	public void CheckCancelFromDirectPrivacyManager() throws InterruptedException {
		logMessage("CheckCancelFromDirectPrivacyManager - " + String.valueOf(Thread.currentThread().getId()));
		SoftAssert softAssert = new SoftAssert();
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details....");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			logMessage("Check for message and tap on Reject All button");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Reject All").click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");
			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);

			logMessage("Tap on Show link to display PM direct and tap on Cancel button");
			mobilePageWrapper.siteDebugInfoPage.CCPAShowPMLink.click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			mobilePageWrapper.privacyManagerPage.ccpa_CancelButton.click();

			logMessage("Check for no consent information");
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(), consentData.get(0));
			softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage
					.checkForNoPurposeConsentData(mobilePageWrapper.siteDebugInfoPage.CCPAConsentNotAvailable));
		} catch (Exception e) {
			logMessage("Exception:" + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 7)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent message should display When user tap on Privacy Settings btton Then user should navigate to PM screen "
			+ "  When user tap on Save and Exit Then navigate back to inof screen "
			+ " When he/she agian tap on property Then he/she should not see message again")
	public void CheckNoConsentMessageDisplayAfterShowSiteInfo() throws InterruptedException {
		logMessage("CheckNoConsentMessageDisplayAfterShowSiteInfo - " + String.valueOf(Thread.currentThread().getId()));
		SoftAssert softAssert = new SoftAssert();
		setShowOnceExpectedMsg();
		String key = "displayMode";
		String value = "appLaunch";
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details....");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			logMessage("Check for message and tap on Privacy Settings button");
			ArrayList<String> actualConsentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(actualConsentMessage.containsAll(expectedShowOnceMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Manager not displayed");
			logMessage("Tap on Save and Exit button and check for consent information");
			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

//			softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage.isConsentViewDataPresent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentView));
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);
			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			mobilePageWrapper.siteListPage.tapOnSite_ccpa(siteName, mobilePageWrapper.siteListPage.CCPASiteList);
			logMessage("Tap on the site again from property list and check for the consent information");

			Assert.assertEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(), consentData.get(0));

		} catch (Exception e) {
			logMessage("Exception : " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 8)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent message should display When user tap on Privacy Settings button Then user should navigate to PM screen "
			+ "  When user tap on Save and Exit Then navigate back to inof screen "
			+ "  When he/she delete property cookies Then he/she should see message again")
	public void CheckConsentMessageDisplayAfterDeleteCookies() throws InterruptedException {
		logMessage("CheckConsentMessageDisplayAfterDeleteCookies - " + String.valueOf(Thread.currentThread().getId()));
		SoftAssert softAssert = new SoftAssert();
		setShowOnceExpectedMsg();
		String key = "displayMode";
		String value = "appLaunch";
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details....");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			logMessage("Check for message and tap on Privacy Settings button");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedShowOnceMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Manager not displayed");
			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);
			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			mobilePageWrapper.siteListPage.tapOnSite_ccpa(siteName, mobilePageWrapper.siteListPage.CCPASiteList);

			softAssert.assertEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(), consentData.get(0),
					"ConsentUUID not matching");

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			logMessage("reset cookies and check for the message");
			mobilePageWrapper.siteListPage.selectAction("Reset");
			softAssert.assertTrue(mobilePageWrapper.consentViewPage.verifyDeleteCookiesMessage());
			mobilePageWrapper.consentViewPage.YESButton.click();

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedShowOnceMsg));

		} catch (Exception e) {
			logMessage("Exception :" + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 9)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent message should display When user tap on Reject All button "
			+ "Then user should navigate to info screen with no consent information")
	public void CheckConsentForTargetingParameterAfterRejectAll() throws InterruptedException {
		SoftAssert softAssert = new SoftAssert();
		logMessage(
				"CheckConsentForTargetingParameterAfterRejectAll - " + String.valueOf(Thread.currentThread().getId()));
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details....");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();
			logMessage("Check for message and tap on Reject All button");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));
			mobilePageWrapper.consentViewPage.eleButton("Reject All").click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");
			softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage
					.checkForNoPurposeConsentData(mobilePageWrapper.siteDebugInfoPage.CCPAConsentNotAvailable));

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
		} catch (Exception e) {
			logMessage("Exception : " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 10)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent message should display When user navigate to PM and tap on Save and Exit button "
			+ "Then user should navigate to info screen with consent information")
	public void CheckConsentForTargetingParameterAfterAcceptAll() throws InterruptedException {
		SoftAssert softAssert = new SoftAssert();
		logMessage(
				"CheckConsentMessageDisplayForTargetingParameter - " + String.valueOf(Thread.currentThread().getId()));
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			logMessage("Enter property details....");
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();
			logMessage("Check for message and tap on Privacy Settings button");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			logMessage("Tap on Save and exit button");
			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
		} catch (Exception e) {
			logMessage("Exception :" + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 11)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent message should display When delete property then property should get removed from list")
	public void DeleteSite() throws InterruptedException {
		SoftAssert softAssert = new SoftAssert();
		logMessage("DeleteSite - " + String.valueOf(Thread.currentThread().getId()));
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details....");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			logMessage("Check for message and tap on Reject All button");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));
			mobilePageWrapper.consentViewPage.eleButton("Reject All").click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			logMessage("Delete property");
			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Delete");
			softAssert.assertTrue(mobilePageWrapper.siteListPage.verifyDeleteSiteMessage());

			mobilePageWrapper.siteListPage.NOButton.click();

			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Delete");
			softAssert.assertTrue(mobilePageWrapper.siteListPage.verifyDeleteSiteMessage());

			mobilePageWrapper.siteListPage.YESButton.click();
		} catch (Exception e) {
			logMessage("Exception : " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 12)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent message should display When user tap on Reject All "
			+ "Then user should navigate to info screen with no consent information "
			+ "When user edit the property details with new data and save "
			+ "Then he/she should see rescpective message configured for the new property")
	public void EditSiteWithNoConsentGivenBefore() throws InterruptedException {
		logMessage("EditSiteWithNoConsentGivenBefore - " + String.valueOf(Thread.currentThread().getId()));
		setExpectedCAMsg();
		setAnotherExpectedCAMsg();
		String key = "region";
		String value = "ca";
		SoftAssert softAssert = new SoftAssert();
		ArrayList<String> consentData;
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details....");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();
			logMessage("Check for message and tap on Reject all button");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Reject All").click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);
			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			logMessage("Edit with new property details having no given consent before");
			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Edit");
			mobilePageWrapper.newSitePage.CCPASiteId.clear();
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys("6168");
			mobilePageWrapper.newSitePage.CCPASiteName.clear();
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys("ccpa.cybage.testing.com");
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, "ON");
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			logMessage("Check message and tap on Privacy Setting button");
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Manager not displayed");

			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

		} catch (Exception e) {
			logMessage("Exception: " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}


	@Test(groups = { "CCPAMetaAppTests" }, priority = 13)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent message should display When user navigate to PM and tap on Save & Exit "
			+ " Then user should navigate to info screen with consent information When user reset the property cookies"
			+ "Then he/she should see expected message")
	public void ResetCookies() throws InterruptedException {
		logMessage("ResetCookies - " + String.valueOf(Thread.currentThread().getId()));
		SoftAssert softAssert = new SoftAssert();
		setShowOnceExpectedMsg();
		String key = "displayMode";
		String value = "appLaunch";
		ArrayList<String> consentData;
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details...");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			logMessage("Check for message and tap on Privacy Settings button");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedShowOnceMsg));
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Manager not displayed");

			logMessage("Tap on Save and Exit button");
			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);

			logMessage("Reset the cookie for the property");
			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Reset");

			softAssert.assertTrue(mobilePageWrapper.consentViewPage.verifyDeleteCookiesMessage());
			mobilePageWrapper.consentViewPage.YESButton.click();

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedShowOnceMsg));

		} catch (Exception e) {
			logMessage("Exception: " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 14)
	@Description("Given user submit valid property details with authentication and tap on Save Then expected\n"
			+ "	 consent message should display When user navigate to PM and tap on Save & exit "
			+ "Then user should navigate to info screen with consent information "
			+ "When user reset property cookies Then he/she shouldnot see message again")
	public void CheckNoMessageWithShowOnceCriteriaWhenConsentAlreadySaved() throws Exception {
		logMessage(" Test execution start ; CheckNoMessageWithShowOnceCriteriaWhenConsentAlreadySaved");
		SoftAssert softAssert = new SoftAssert();
		setShowOnceExpectedMsg();
		String key = "displayMode";
		String value = "appLaunch";
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details with unique authentication...");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			Date date = new Date();
			mobilePageWrapper.newSitePage.CCPAAuthID.sendKeys(sdf.format(date));
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();
			logMessage("Check for message and tap on Privacy Setting button");

			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedShowOnceMsg));
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Manager not displayed");

			logMessage("Tap on Save and Exit button");
			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available", "Consent UUID not generated.");

			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			logMessage("Reset the cookies for the property");
			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Reset");

			softAssert.assertTrue(mobilePageWrapper.consentViewPage.verifyDeleteCookiesMessage());
			mobilePageWrapper.consentViewPage.YESButton.click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertFalse(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			softAssert.assertEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(), consentData.get(0),
					"ConsentUUID not matching");

		} catch (Exception e) {
			logMessage("Exception: " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 15)
	@Description("Given user submit valid property details with authentication and tap on Save Then expected\n"
			+ "	 consent message should display When user navigate to PM and tap on Reject All button "
			+ "Then user should navigate to info screen with no consent information "
			+ "When user add same property with new unquie authentication details "
			+ "Then he/she should message and see consent data as selected on PM")
	public void CheckSavedConsentAlwaysWithSameAuthID() throws Exception {
		logMessage(" Test execution start :CheckSavedConsentAlwaysWithSameAuthID");
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		Date date = new Date();
		ArrayList<String> consentData;
		SoftAssert softAssert = new SoftAssert();
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details with unique authentication....");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);

			authID = sdf.format(date);
			mobilePageWrapper.newSitePage.CCPAAuthID.sendKeys(authID);
			logMessage("Unique AuthID : " + authID);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();
			logMessage("Check for message and tap on Reject All from PM");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Manager not displayed");
			mobilePageWrapper.privacyManagerPage.ccpa_RejectAllButton.click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");
			consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			logMessage("Create new property with same details but some other unique authentication");

			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			Date date2 = new Date();
			authID = sdf.format(date2);
			mobilePageWrapper.newSitePage.CCPAAuthID.sendKeys(authID);
			logMessage("Unique AuthID : " + authID);

			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();
			logMessage("Check for message and check all toggles displyed as false from PM");

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage1.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Managet not displayed");

			// Check all consent are saves as true
		} catch (Exception e) {
			logMessage("Exception: " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 18)
	@Description("Given user submit valid property details with authentication and tap on Save Then expected\n"
			+ "	 consent message should display When user navigate to PM and tap on Reject All button "
			+ "Then user should navigate to info screen with no consent information "
			+ "When user delete the property and recreate same Then he/she should see message And should see consent as false from PM")
	public void CheckConsentWithSameAuthIDAfterDeletingAndRecreate() throws Exception {
		logMessage("CheckConsentWithSameAuthIDAfterDeletingAndRecreate - "
				+ String.valueOf(Thread.currentThread().getId()));
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		SoftAssert softAssert = new SoftAssert();
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details with unique authentication...");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			Date date1 = new Date();
			authID = sdf.format(date1);
			mobilePageWrapper.newSitePage.CCPAAuthID.sendKeys(authID);
			logMessage("AuthID : " + authID);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			logMessage("Check message and tap on Privacy Settings button");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Manager not displayed");
			mobilePageWrapper.privacyManagerPage.ccpa_RejectAllButton.click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			logMessage("Delete the property");
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Delete");
			softAssert.assertTrue(mobilePageWrapper.siteListPage.verifyDeleteSiteMessage());

			mobilePageWrapper.siteListPage.YESButton.click();
			softAssert.assertFalse(mobilePageWrapper.siteListPage.isSitePressent_ccpa(siteName));

			logMessage("Create property again with same Authentication details");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.CCPAAuthID.sendKeys(authID);

			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();
			logMessage("Check for all toggels as false from PM");

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedCAMsg));
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Manager not displayed");

			// Check all consent are save as false
		} catch (Exception e) {
			logMessage("Exception: " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 19)
	@Description("Given user submit valid property details and tap on Save Then expected\n"
			+ "	 consent message should display When user navigate to PM and tap on Save & Exit"
			+ "Then user should navigate to info screen with consent information "
			+ "When user edit property with authentication Then he/she should not see message again")
	public void CheckNoMessageAfterLoggedInWithAuthID() throws Exception {
		logMessage("CheckNoMessageAfterLoggedInWithAuthID - " + String.valueOf(Thread.currentThread().getId()));
		setShowOnceExpectedMsg();
		String key = "displayMode";
		String value = "appLaunch";
		Date date = new Date();
		String authID = sdf.format(date);
		SoftAssert softAssert = new SoftAssert();
		try {
			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			logMessage("Enter property details...");
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			logMessage("Check for message and tap on Privacy Settings button");
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedShowOnceMsg));
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent(),
					"Privacy Manager not displayed");
			logMessage("Tap on Save and Exit and check for consent information");
			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			logMessage("Edit proeprty details with unique authid");
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);

			mobilePageWrapper.siteListPage.selectAction("Edit");
			mobilePageWrapper.newSitePage.CCPAAuthID.sendKeys(authID);
			mobilePageWrapper.newSitePage.CCPASaveButton.click();
			logMessage("Get consent information : ConsentUUID: "
					+ mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText());
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");
			softAssert.assertEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(), consentData.get(0),
					"ConsentUUID not matching");

		} catch (Exception e) {
			logMessage("Exception: " + e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}
}
