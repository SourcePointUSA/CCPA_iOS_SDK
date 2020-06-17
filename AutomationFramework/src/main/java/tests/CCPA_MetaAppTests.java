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

	/**
	 * Given the account id 808 and site name ccpa.automation.testing.com When user
	 * add targeting parameter as region/ca Then the message with expected title
	 * will displayed with Reject all and Privacy Settings buttons When user click
	 * on Privacy Settings button Then user will see Privacy Manager screen When
	 * user click on Cancel button Then user will navigate back to the consent
	 * message
	 */

	@Test(groups = { "CCPASDKTests" }, priority = 1)
	public void CheckCancleFromPrivacyManager() throws InterruptedException {

		SoftAssert softAssert = new SoftAssert();
		setExpectedCAMsg();

		String key = "region";
		String value = "ca";
		try {
			System.out.println("***************** Test execution start *****************");
			System.out.println("CheckCancleFromPrivacyManager - " + String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			mobilePageWrapper.privacyManagerPage.ccpa_CancelButton.click();

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage1.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedCAMsg));

		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPASDKTests" }, priority = 2)
	public void CheckConsentOnRejectAllFromConsentView() throws InterruptedException {

		SoftAssert softAssert = new SoftAssert();
		setExpectedCAMsg();

		String key = "region";
		String value = "ca";
		try {
			System.out.println("***************** Test execution start *****************");
			System.out.println(
					"CheckConsentOnRejectAllFromConsentView - " + String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Reject All").click();

			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");
//				softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage
//						.checkForNoPurposeConsentData(mobilePageWrapper.siteDebugInfoPage.CCPAConsentNotAvailable));
			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			mobilePageWrapper.siteListPage.tapOnSite_ccpa(siteName, mobilePageWrapper.siteListPage.CCPASiteList);

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());

			// check PM data for all false

		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPASDKTests" }, priority = 3)
	public void CheckConsentOnRejectAllFromPM() throws InterruptedException {

		SoftAssert softAssert = new SoftAssert();
		setExpectedCAMsg();

		String key = "region";
		String value = "ca";
		try {
			System.out.println("***************** Test execution start *****************");
			System.out.println("CheckConsentOnRejectAllFromPM - " + String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			// check for all purposes selected as true

			mobilePageWrapper.privacyManagerPage.ccpa_RejectAllButton.click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage
					.checkForNoPurposeConsentData(mobilePageWrapper.siteDebugInfoPage.CCPAConsentNotAvailable));
		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPASDKTests" }, priority = 4)
	public void CheckPurposeConsentAfterResetCookies() throws InterruptedException {

		SoftAssert softAssert = new SoftAssert();
		setExpectedCAMsg();

		try {
			String key = "region";
			String value = "ca";
			System.out.println("***************** Test execution start *****************");
			System.out.println(
					"CheckPurposeConsentAfterResetCookies - " + String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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

			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			// check for all purposes selected as false
			// driver.hideKeyboard();
			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

//				softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage
//						.isConsentViewDataPresent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentView));
			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);
			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);

			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Reset");

			softAssert.assertTrue(mobilePageWrapper.consentViewPage.verifyDeleteCookiesMessage());

			mobilePageWrapper.consentViewPage.YESButton.click();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			System.out.println("passed");
			// check for all purposes selected as true

		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPASDKTests" }, priority = 5)
	public void CheckConsentDataFromPrivacyManagerDirect() throws InterruptedException {

		SoftAssert softAssert = new SoftAssert();
		setExpectedCAMsg();

		String key = "region";
		String value = "ca";

		try {
			System.out.println("***************** Test execution start *****************");
			System.out.println(
					"CheckConsentDataFromPrivacyManagerDirect - " + String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Reject All").click();

			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);

			mobilePageWrapper.siteDebugInfoPage.CCPAShowPMLink.click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());

			// check for all purposes selected as false
			mobilePageWrapper.privacyManagerPage.ccpa_RejectAllButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(), consentData.get(0));
			softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage
					.checkForNoPurposeConsentData(mobilePageWrapper.siteDebugInfoPage.CCPAConsentNotAvailable));

		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPASDKTests" }, priority = 6)
	public void CheckCancelFromDirectPrivacyManager() throws InterruptedException {

		SoftAssert softAssert = new SoftAssert();
		setExpectedCAMsg();

		String key = "region";
		String value = "ca";
		try {
			System.out.println("***************** Test execution start *****************");
			System.out
					.println("CheckCancelFromDirectPrivacyManager - " + String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Reject All").click();

			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");
			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);

			mobilePageWrapper.siteDebugInfoPage.CCPAShowPMLink.click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			// driver.hideKeyboard();
			mobilePageWrapper.privacyManagerPage.ccpa_CancelButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(), consentData.get(0));
			softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage
					.checkForNoPurposeConsentData(mobilePageWrapper.siteDebugInfoPage.CCPAConsentNotAvailable));

			// check for all purposes selected as false

		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 7)
	public void CheckNoConsentMessageDisplayAfterShowSiteInfo() throws InterruptedException {
		SoftAssert softAssert = new SoftAssert();

		setShowOnceExpectedMsg();
		try {
			String key = "displayMode";
			String value = "appLaunch";
			System.out.println("***************** Test execution start *****************");
			System.out.println("CheckNoConsentMessageDisplayAfterShowSiteInfo - "
					+ String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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

			ArrayList<String> actualConsentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(actualConsentMessage.containsAll(expectedShowOnceMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			// driver.hideKeyboard();
			logMessage("check details");
			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

//			softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage.isConsentViewDataPresent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentView));

			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);
			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			mobilePageWrapper.siteListPage.tapOnSite_ccpa(siteName, mobilePageWrapper.siteListPage.CCPASiteList);
			logMessage("check details");

			Assert.assertEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(), consentData.get(0));

		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 8)
	public void CheckConsentMessageDisplayAfterDeleteCookies() throws InterruptedException {
		SoftAssert softAssert = new SoftAssert();
		setShowOnceExpectedMsg();
		try {
			String key = "displayMode";
			String value = "appLaunch";
			System.out.println("***************** Test execution start *****************");
			System.out.println(
					"CheckConsentMessageDisplayAfterDeleteCookies - " + String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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
			softAssert.assertTrue(consentMessage.containsAll(expectedShowOnceMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			// driver.hideKeyboard();
			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);
			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			mobilePageWrapper.siteListPage.tapOnSite_ccpa(siteName, mobilePageWrapper.siteListPage.CCPASiteList);

			softAssert.assertEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(), consentData.get(0));

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);

			mobilePageWrapper.siteListPage.selectAction("Reset");
			softAssert.assertTrue(mobilePageWrapper.consentViewPage.verifyDeleteCookiesMessage());
			mobilePageWrapper.consentViewPage.YESButton.click();

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedShowOnceMsg));

		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 9)
	public void CheckConsentForTargetingParameterAfterRejectAll() throws InterruptedException {
		SoftAssert softAssert = new SoftAssert();

		setExpectedCAMsg();
		try {
			String key = "region";
			String value = "ca";
			System.out.println("***************** Test execution start *****************");
			System.out.println("CheckConsentForTargetingParameterAfterRejectAll - "
					+ String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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

			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Reject All").click();
//				softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
//						"ConsentUUID not available");
//				softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage
//						.checkForNoPurposeConsentData(mobilePageWrapper.siteDebugInfoPage.CCPAConsentNotAvailable));

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 10)
	public void CheckConsentForTargetingParameterAfterAcceptAll() throws InterruptedException {
		SoftAssert softAssert = new SoftAssert();

		setExpectedCAMsg();
		try {
			String key = "region";
			String value = "ca";
			System.out.println("***************** Test execution start *****************");
			System.out.println("CheckConsentMessageDisplayForTargetingParameter - "
					+ String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			// driver.hideKeyboard();

			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			// softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage.isConsentViewDataPresent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentView));

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();
			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 11)
	public void DeleteSite() throws InterruptedException {
		SoftAssert softAssert = new SoftAssert();

		setExpectedCAMsg();
		try {
			String key = "region";
			String value = "ca";
			System.out.println("***************** Test execution start *****************");
			System.out.println("DeleteSite - " + String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Reject All").click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);

			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Delete");
			// softAssert.assertTrue(mobilePageWrapper.siteListPage.verifyDeleteSiteMessage());

			mobilePageWrapper.siteListPage.NOButton.click();

			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Delete");
			// softAssert.assertTrue(mobilePageWrapper.siteListPage.verifyDeleteSiteMessage(udid));

			mobilePageWrapper.siteListPage.YESButton.click();
		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 12)
	public void EditSiteWithNoConsentGivenBefore() throws InterruptedException {

		setExpectedCAMsg();
		setAnotherExpectedCAMsg();
		String key = "region";
		String value = "ca";
		SoftAssert softAssert = new SoftAssert();
		ArrayList<String> consentData;
		try {
			System.out.println("***************** Test execution start *****************");
			System.out.println("EditSiteWithNoConsentGivenBefore - " + String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Reject All").click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);
			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);

			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Edit");
			mobilePageWrapper.newSitePage.CCPASiteId.clear();
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys("6168");
			mobilePageWrapper.newSitePage.CCPASiteName.clear();
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys("ccpa.cybage.testing.com");
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, "ON");

			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage1.getConsentMessageDetails();

			// softAssert.assertTrue(consentMessage1.containsAll(expectedAnotherCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			// driver.hideKeyboard();

			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 13)
	public void ResetCookies() throws InterruptedException {
		SoftAssert softAssert = new SoftAssert();
		setShowOnceExpectedMsg();

		ArrayList<String> consentData;
		try {
			String key = "displayMode";
			String value = "appLaunch";
			System.out.println("***************** Test execution start *****************");
			System.out.println("ResetCookies - " + String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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
			softAssert.assertTrue(consentMessage.containsAll(expectedShowOnceMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			// driver.hideKeyboard();

			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			// softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage.isConsentViewDataPresent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentView));
			consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);

			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Reset");

			softAssert.assertTrue(mobilePageWrapper.consentViewPage.verifyDeleteCookiesMessage());
			mobilePageWrapper.consentViewPage.YESButton.click();

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedShowOnceMsg));

		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 14)
	public void CheckNoMessageWithShowOnceCriteriaWhenConsentAlreadySaved() throws Exception {
		SoftAssert softAssert = new SoftAssert();
		setShowOnceExpectedMsg();

		try {
			String key = "displayMode";
			String value = "appLaunch";
			System.out.println("***************** Test execution start *****************");
			System.out.println("CheckNoMessageWithShowOnceCriteriaWhenConsentAlreadySaved - "
					+ String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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
			ArrayList<String> consentData;

			// mobilePageWrapper.consentViewPage.loadTime();
			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedShowOnceMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			// driver.hideKeyboard();

			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			Thread.sleep(3000);
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available", "Consent UUID not generated.");

//			softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage.isConsentViewDataPresent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentView));
			consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);

			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Reset");

			// softAssert.assertTrue(mobilePageWrapper.consentViewPage.verifyDeleteCookiesMessage());
			mobilePageWrapper.consentViewPage.YESButton.click();
			Thread.sleep(8000);
			softAssert.assertEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(), consentData.get(0),
					"ConsentUUID not matching");

		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 15)
	public void CheckSavedConsentAlwaysWithSameAuthID() throws Exception {
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		Date date = new Date();
		ArrayList<String> consentData;

		SoftAssert softAssert = new SoftAssert();

		try {
			System.out.println("***************** Test execution start *****************");
			System.out.println(
					"CheckSavedConsentAlwaysWithSameAuthID - " + String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);

			authID = sdf.format(date);
			mobilePageWrapper.newSitePage.CCPAAuthID.sendKeys(authID);
			System.out.println("AuthID : " + authID);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();

			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			// mobilePageWrapper.consentViewPage.PrivacySettingsButton);
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
//				driver.hideKeyboard();

			mobilePageWrapper.privacyManagerPage.ccpa_RejectAllButton.click();
			// mobilePageWrapper.privacyManagerPage.eleButton(udid, "Reject
			// All"));

			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");
			consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);

			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);

//			mobilePageWrapper.newSitePage.CCPAAuthID.sendKeys(authID);
//			System.out.println("AuthID : " + authID);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage1.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();
			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());

			// Check all consent are saves as true
		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

//	@Test(groups = { "CCPAMetaAppTests" }, priority = 16)
	public void CheckConsentWithSameAuthIDWithNewInstallation() throws Exception {
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";

		SoftAssert softAssert = new SoftAssert();

		try {
			System.out.println("***************** Test execution start *****************");
			System.out.println("CheckConsentWithSameAuthIDWithNewInstallation - "
					+ String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);

			Date date1 = new Date();
			authID = sdf.format(date1);
			mobilePageWrapper.newSitePage.CCPAAuthID.sendKeys(authID);
			System.out.println("AuthID : " + authID);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();

			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			// driver.hideKeyboard();

			mobilePageWrapper.privacyManagerPage.ccpa_RejectAllButton.click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);

			System.out.println("Uninstall app");
			// mobilePageWrapper.siteListPage.removeCCPAApp();

			System.out.println("Install app");
			// mobilePageWrapper.siteListPage.installApp();

			MobilePageWrapper mobilePageWrapper1 = new MobilePageWrapper(driver);
			mobilePageWrapper1.siteListPage.CCPAAddButton.click();
			mobilePageWrapper1.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper1.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper1.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper1.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper1.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton,
					staggingValue);
			mobilePageWrapper1.newSitePage.CCPAAuthID.sendKeys(authID);

			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper1.newSitePage.CCPAParameterKey,
					mobilePageWrapper1.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper1.newSitePage.CCPASaveButton.click();

			ArrayList<String> consentMessage1 = mobilePageWrapper1.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper1.privacyManagerPage.isPrivacyManagerViewPresent());

			// Check all consent are save as false
		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

//	@Test(groups = { "CCPAMetaAppTests" }, priority = 17)
	public void CheckSavedConsentAlwaysWithSameAuthIDCrossPlatform() throws Exception {

		setExpectedCAMsg();
		String key = "region";
		String value = "ca";
		SoftAssert softAssert = new SoftAssert();

		try {
			System.out.println("***************** Test execution start *****************");
			System.out.println("CheckSavedConsentAlwaysWithSameAuthIDCrossPlatform - "
					+ String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);

			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);

			Date date1 = new Date();
			authID = sdf.format(date1);
			mobilePageWrapper.newSitePage.CCPAAuthID.sendKeys(authID);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			// driver.hideKeyboard();

			mobilePageWrapper.privacyManagerPage.ccpa_RejectAllButton.click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);

//				String baseDir = DirectoryOperations.getProjectRootPath();
//				System.setProperty("webdriver.chrome.driver", baseDir + "/setupfiles/Fusion/chromedriver_MAC");
//
//				WebDriver driver1 = new ChromeDriver(); // init chrome driver
//
//				driver1.get("https://in-app-messaging.pm.sourcepoint.mgr.consensu.org/v2.0.html?\r\n" + "\r\n"
//						+ "_sp_accountId=" + accountId + "&_sp_writeFirstPartyCookies=true&_sp_msg_domain=mms.sp-\r\n"
//						+ "\r\n" + "prod.net&_sp_debug_level=OFF&_sp_pmOrigin=production&_sp_siteHref=https%3A%2F%2F"
//						+ siteName + "\r\n" + "\r\n" + "%2F&_sp_msg_targetingParams=\r\n" + "\r\n" + "%7B\"" + key
//						+ "\"%3A\"" + value + "\"%7D&_sp_authId=" + authID
//						+ "&_sp_cmp_inApp=true&_sp_msg_stageCampaign=" + staggingValue + "&_sp_cmp_origin=%2F\r\n"
//						+ "\r\n" + "%2Fsourcepoint.mgr.consensu.org");
//
//				Thread.sleep(5000);
//				driver1.findElement(By.id("Show Purposes")).click();
//				Thread.sleep(3000);
//			WebDriverWait wait = new WebDriverWait(webDriver, 30);
//			wait.until(ExpectedConditions.presenceOfElementLocated(By.className("priv_main_parent")));
// Check all consent are save as true

//			driver1.quit();
		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 18)
	public void CheckConsentWithSameAuthIDAfterDeletingAndRecreate() throws Exception {
		setExpectedCAMsg();
		String key = "region";
		String value = "ca";

		SoftAssert softAssert = new SoftAssert();

		try {
			System.out.println("***************** Test execution start *****************");
			System.out.println("CheckConsentWithSameAuthIDAfterDeletingAndRecreate - "
					+ String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
			mobilePageWrapper.siteListPage.CCPAAddButton.click();
			mobilePageWrapper.newSitePage.CCPAAccountID.sendKeys(accountId);
			mobilePageWrapper.newSitePage.CCPASiteId.sendKeys(siteID);
			mobilePageWrapper.newSitePage.CCPASiteName.sendKeys(siteName);
			mobilePageWrapper.newSitePage.CCPAPMId.sendKeys(pmID);
			mobilePageWrapper.newSitePage.selectCampaign(mobilePageWrapper.newSitePage.CCPAToggleButton, staggingValue);

			Date date1 = new Date();
			authID = sdf.format(date1);
			mobilePageWrapper.newSitePage.CCPAAuthID.sendKeys(authID);
			System.out.println("AuthID : " + authID);
			mobilePageWrapper.newSitePage.addTargetingParameter(mobilePageWrapper.newSitePage.CCPAParameterKey,
					mobilePageWrapper.newSitePage.CCPAParameterValue, key, value);
			mobilePageWrapper.newSitePage.CCPAParameterAddButton.click();
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			ArrayList<String> consentMessage = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
//				driver.hideKeyboard();

			mobilePageWrapper.privacyManagerPage.ccpa_RejectAllButton.click();
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);

			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);
			mobilePageWrapper.siteListPage.selectAction("Delete");
			// softAssert.assertTrue(mobilePageWrapper.siteListPage.verifyDeleteSiteMessage(udid));

			mobilePageWrapper.siteListPage.YESButton.click();
			// softAssert.assertFalse(mobilePageWrapper.siteListPage.isSitePressent_ccpa(siteName));

			// MobilePageWrapper mobilePageWrapper1 = new MobilePageWrapper(driver);
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

			ArrayList<String> consentMessage1 = mobilePageWrapper.consentViewPage.getConsentMessageDetails();
			softAssert.assertTrue(consentMessage1.containsAll(expectedCAMsg));

			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());

			// Check all consent are save as false
		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}

	@Test(groups = { "CCPAMetaAppTests" }, priority = 19)
	public void CheckNoMessageAfterLoggedInWithAuthID() throws Exception {
		setShowOnceExpectedMsg();
		String key = "displayMode";
		String value = "appLaunch";
		Date date = new Date();
		String authID = sdf.format(date);

		SoftAssert softAssert = new SoftAssert();

		try {
			System.out.println(" Test execution start ");
			System.out.println(
					"CheckNoMessageAfterLoggedInWithAuthID - " + String.valueOf(Thread.currentThread().getId()));

			MobilePageWrapper mobilePageWrapper = new MobilePageWrapper(driver);
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

			softAssert.assertTrue(consentMessage.containsAll(expectedShowOnceMsg));
			mobilePageWrapper.consentViewPage.eleButton("Privacy Settings").click();

			softAssert.assertTrue(mobilePageWrapper.privacyManagerPage.isPrivacyManagerViewPresent());
			// driver.hideKeyboard();

			mobilePageWrapper.privacyManagerPage.ccpa_SaveAndExitButton.click();
			Thread.sleep(5000);
			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");

//			softAssert.assertTrue(mobilePageWrapper.siteDebugInfoPage.isConsentViewDataPresent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentView));
			ArrayList<String> consentData = mobilePageWrapper.siteDebugInfoPage
					.storeConsent(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID);

			mobilePageWrapper.siteDebugInfoPage.BackButton.click();

			softAssert.assertEquals(mobilePageWrapper.siteListPage.CCPASiteName.getText(), siteName);
			mobilePageWrapper.siteListPage.swipeHorizontaly_ccpa(siteName);

			mobilePageWrapper.siteListPage.selectAction("Edit");
			mobilePageWrapper.newSitePage.CCPAAuthID.sendKeys(authID);
			mobilePageWrapper.newSitePage.CCPASaveButton.click();

			softAssert.assertNotEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(),
					"ConsentUUID not available");
			softAssert.assertEquals(mobilePageWrapper.siteDebugInfoPage.CCPAConsentUUID.getText(), consentData.get(0));

		} catch (Exception e) {
			System.out.println(e);
			throw e;
		} finally {
			softAssert.assertAll();
		}
	}
}
