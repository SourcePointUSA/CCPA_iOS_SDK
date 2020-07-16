package org.framework.pageObjects;

import static org.framework.logger.LoggingManager.logMessage;

import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.TimeUnit;

import org.framework.enums.PlatformName;
import org.framework.helpers.Page;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Point;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.PageFactory;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import io.appium.java_client.AppiumDriver;
import io.appium.java_client.MobileDriver;
//import io.appium.java_client.WebElement;
import io.appium.java_client.PerformsTouchActions;
import io.appium.java_client.TouchAction;
import io.appium.java_client.pagefactory.AndroidFindBy;
import io.appium.java_client.pagefactory.AppiumFieldDecorator;
import io.appium.java_client.pagefactory.WithTimeout;
import io.appium.java_client.pagefactory.iOSFindBy;
import io.appium.java_client.pagefactory.iOSXCUITFindBy;
import io.appium.java_client.touch.offset.PointOption;
import io.qameta.allure.Step;

public class NewSitePage extends Page {
	WebDriver driver;

	public NewSitePage(WebDriver driver) throws InterruptedException {
		this.driver = driver;
		PageFactory.initElements(driver, this);
		logMessage("Initializing the " + this.getClass().getSimpleName() + " elements");
		PageFactory.initElements(new AppiumFieldDecorator(driver), this);
		Thread.sleep(1000);
	}

	@WithTimeout(time = 30, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(xpath = "//XCUIElementTypeTextField[@name='accountIDTextFieldOutlet']")
	public WebElement CCPANewSitePageHeader;

	@iOSXCUITFindBy(xpath = "//XCUIElementTypeTextField[@name='accountIDTextFieldOutlet']")
	public WebElement AccountIDLabel;

	@WithTimeout(time = 30, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(accessibility = "Save")
	public WebElement CCPASaveButton;

	@WithTimeout(time = 30, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(xpath = "//XCUIElementTypeTextField[@name='accountIDTextFieldOutlet']")
	public WebElement CCPAAccountID;

	@iOSXCUITFindBy(accessibility = "propertyTextFieldOutlet")
	public WebElement CCPASiteName;

	@iOSXCUITFindBy(accessibility = "isStagingSwitchOutlet")
	public WebElement CCPAToggleButton;

	@iOSXCUITFindBy(accessibility = "authIdTextFieldOutlet")
	public WebElement CCPAAuthID;

	@iOSXCUITFindBy(accessibility = "targetingParamKeyTextFieldOutlet")
	public WebElement CCPAParameterKey;

	@iOSXCUITFindBy(accessibility = "targetingParamValueTextFieldOutlet")
	public WebElement CCPAParameterValue;

	@iOSXCUITFindBy(accessibility = "addButton")
	public WebElement CCPAParameterAddButton;

	@WithTimeout(time = 50, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(xpath = "(//XCUIElementTypeStaticText)")
	public List<WebElement> ErrorMessage;

	@WithTimeout(time = 50, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(accessibility = "OK")
	public WebElement OKButton;

	@WithTimeout(time = 30, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(accessibility = "propertyIdTextFieldOutlet")
	public WebElement CCPASiteId;

	@iOSXCUITFindBy(accessibility = "pmTextFieldOutlet")
	public WebElement CCPAPMId;

	@iOSXCUITFindBy(accessibility = "showPMSwitchOutlet")
	public WebElement CCPAShowPrivacyManager;

	boolean paramFound = false;

	public void selectCampaign(WebElement ele, String staggingValue) throws InterruptedException {
		if (staggingValue.equals("ON")) {
			Point point = ele.getLocation();
			TouchAction touchAction = new TouchAction((PerformsTouchActions) driver);

			touchAction.tap(PointOption.point(point.x + 20, point.y + 20)).perform();
		}
	}

	public void addTargetingParameter(WebElement paramKey, WebElement paramValue, String key, String value)
			throws InterruptedException {

		JavascriptExecutor js = (JavascriptExecutor) driver;
		HashMap<String, String> scrollObject = new HashMap<String, String>();
		scrollObject.put("direction", "up");
		js.executeScript("mobile: scroll", scrollObject);

		paramKey.sendKeys(key);

		scrollObject.put("direction", "up");
		js.executeScript("mobile: scroll", scrollObject);

		paramValue.sendKeys(value);

		scrollObject.put("direction", "up");
		js.executeScript("mobile: scroll", scrollObject);

	}

	public void waitForElement(WebElement ele, int timeOutInSeconds) {
		WebDriverWait wait = new WebDriverWait(driver, timeOutInSeconds);
		wait.until(ExpectedConditions.visibilityOf(ele));
	}

}
