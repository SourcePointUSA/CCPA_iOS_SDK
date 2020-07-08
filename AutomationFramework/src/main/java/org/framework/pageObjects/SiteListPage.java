package org.framework.pageObjects;

import static org.framework.logger.LoggingManager.logMessage;

import java.time.Duration;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.concurrent.TimeUnit;

import org.framework.enums.PlatformName;
import org.framework.helpers.Page;
import org.openqa.selenium.By;
import org.openqa.selenium.Dimension;
import org.openqa.selenium.Point;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.PageFactory;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.Assert;

import io.appium.java_client.AppiumDriver;
import io.appium.java_client.MobileDriver;
import io.appium.java_client.PerformsTouchActions;
import io.appium.java_client.TouchAction;
import io.appium.java_client.touch.WaitOptions;
import io.appium.java_client.touch.offset.PointOption;
import io.appium.java_client.pagefactory.AndroidFindBy;
import io.appium.java_client.pagefactory.AppiumFieldDecorator;
import io.appium.java_client.pagefactory.WithTimeout;
import io.appium.java_client.pagefactory.iOSFindBy;
import io.appium.java_client.pagefactory.iOSXCUITFindBy;

public class SiteListPage extends Page {

	WebDriver driver;

	public SiteListPage(WebDriver driver) throws InterruptedException {
		this.driver = driver;
		PageFactory.initElements(driver, this);
		logMessage("Initializing the " + this.getClass().getSimpleName() + " elements");
		PageFactory.initElements(new AppiumFieldDecorator(driver), this);
		Thread.sleep(1000);
	}

	@iOSXCUITFindBy(accessibility = "Add")
	public WebElement CCPAAddButton;

	@iOSXCUITFindBy(xpath = "//XCUIElementTypeOther[contains(@name, 'Property List')]")
	public WebElement CCPASiteListPageHeader;

	@iOSXCUITFindBy(xpath = "//XCUIElementTypeStaticText[@name=\'Site List\']")
	public WebElement CCPASiteListView;

	@iOSXCUITFindBy(xpath = "//XCUIElementTypeButton[@name='Edit']")
	public WebElement CCPAEditButton;

	@iOSXCUITFindBy(xpath = "//XCUIElementTypeButton[@name='Reset']")
	public WebElement CCPAResetButton;

	@WithTimeout(time = 30, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(xpath = "//XCUIElementTypeButton[@name='Trash']")
	public WebElement CCPADeleteButton;

	@WithTimeout(time = 30, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(xpath = "(//XCUIElementTypeStaticText[@name=\'propertyCell\'])")
	public List<WebElement> CCPASiteList;

	@WithTimeout(time = 30, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(accessibility = "propertyName")
	public WebElement CCPASiteName;

	@WithTimeout(time = 50, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(xpath = "(//XCUIElementTypeButton)")
	public List<WebElement> ActionButtons;

	@WithTimeout(time = 50, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(xpath = "(//XCUIElementTypeStaticText)")
	public List<WebElement> ErrorMessage;

	@iOSXCUITFindBy(accessibility = "YES")
	public WebElement YESButton;

	@iOSXCUITFindBy(accessibility = "NO")
	public WebElement NOButton;

	boolean siteFound = false;

	public boolean isSitePressent_ccpa(String siteName) throws InterruptedException {
		siteFound = false;
		if (driver.findElements(By.xpath("//XCUIElementTypeStaticText[@name='propertyCell']")).size() > 0) {
			if (driver.findElement(By.xpath("//XCUIElementTypeStaticText[@name='propertyCell']")).getText()
					.equals(siteName)) {
				siteFound = true;
			}
		}
		return siteFound;
	}

	public void selectAction(String action) throws InterruptedException {
		if (action.equalsIgnoreCase("Reset")) {
			ActionButtons.get(1).click();
		} else if (action.equalsIgnoreCase("Edit")) {
			ActionButtons.get(2).click();
		} else if (action.equalsIgnoreCase("Delete")) {
			ActionButtons.get(3).click();
		}

	}

	public boolean isSitePressent(String siteName) throws InterruptedException {
		return siteFound;

	}

	public void tapOnSite_ccpa(String siteName, List<WebElement> siteList) throws InterruptedException {
		driver.findElement(By.xpath("//XCUIElementTypeStaticText[@name='propertyCell']")).click();
	}

	public void swipeHorizontaly_ccpa(String siteName) throws InterruptedException {
		WebElement ele = driver.findElement(By.xpath("//XCUIElementTypeStaticText[@name='propertyCell']"));

		waitForElement(ele, timeOutInSeconds);

		Point point = ele.getLocation();
		TouchAction action = new TouchAction((PerformsTouchActions) driver);

		int[] rightTopCoordinates = { ele.getLocation().getX() + ele.getSize().getWidth(), ele.getLocation().getY() };
		int[] leftTopCoordinates = { ele.getLocation().getX(), ele.getLocation().getY() };
		action.press(PointOption.point(rightTopCoordinates[0] - 1, rightTopCoordinates[1] + 1))
				.waitAction(WaitOptions.waitOptions(Duration.ofMillis(3000)))
				.moveTo(PointOption.point(leftTopCoordinates[0] + 1, leftTopCoordinates[1] + 1)).release().perform();
	}

	public void waitForElement(WebElement ele, int timeOutInSeconds) {
		WebDriverWait wait = new WebDriverWait(driver, timeOutInSeconds);
		wait.until(ExpectedConditions.visibilityOf(ele));
	}

	public boolean verifyDeleteSiteMessage() {
		return ErrorMessage.get(ErrorMessage.size() - 1).getText().contains("Are you sure you want to");

	}

}
