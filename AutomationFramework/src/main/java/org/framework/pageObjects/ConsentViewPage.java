package org.framework.pageObjects;

import static org.framework.logger.LoggingManager.logMessage;

import java.time.Duration;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import org.framework.helpers.Page;
import org.openqa.selenium.By;
import org.openqa.selenium.Dimension;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Point;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.PageFactory;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import io.appium.java_client.AppiumDriver;
import io.appium.java_client.MobileDriver;
import io.appium.java_client.PerformsTouchActions;
import io.appium.java_client.TouchAction;
import io.appium.java_client.pagefactory.AndroidFindBy;
import io.appium.java_client.pagefactory.AppiumFieldDecorator;
import io.appium.java_client.pagefactory.WithTimeout;
import io.appium.java_client.pagefactory.iOSXCUITFindBy;
import io.appium.java_client.touch.WaitOptions;
import io.appium.java_client.touch.offset.PointOption;

public class ConsentViewPage extends Page {

	WebDriver driver;

	 public ConsentViewPage(WebDriver driver) throws InterruptedException {
	        this.driver = driver;
	        PageFactory.initElements(driver, this);
	        logMessage("Initializing the "+this.getClass().getSimpleName()+" elements");
	        PageFactory.initElements(new AppiumFieldDecorator(driver), this);
	        Thread.sleep(1000);
	    }
//	protected Report reporter = null;

	@WithTimeout(time = 30, chronoUnit = ChronoUnit.SECONDS)
	public WebElement ConsentMessageView;

	@WithTimeout(time = 30, chronoUnit = ChronoUnit.SECONDS)
	public WebElement ConsentMessageTitleText;

	@WithTimeout(time = 30, chronoUnit = ChronoUnit.SECONDS)
	public WebElement ConsentMessageBodyText;

	@iOSXCUITFindBy(accessibility = "Close")
	public WebElement CloseButton;

	@iOSXCUITFindBy(accessibility = "Continue")
	public WebElement ContinueButton;

	@iOSXCUITFindBy(accessibility = "Accept all cookies")
	public WebElement AcceptallCookiesButton;

	@iOSXCUITFindBy(accessibility = "Accept All cookies")
	public WebElement AcceptAllCookiesButton;

	@iOSXCUITFindBy(accessibility = "Reject all cookies")
	public WebElement RejectAllCookiesButton;

	@iOSXCUITFindBy(accessibility = "Show Purposes")
	public WebElement ShowPurposesButton;

	@WithTimeout(time = 80, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(xpath = "(//XCUIElementTypeStaticText)")
	public List<WebElement> ConsentMessage;

	@WithTimeout(time = 50, chronoUnit = ChronoUnit.SECONDS)
	public WebElement ErrorMessageView;

	@WithTimeout(time = 50, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(xpath = "(//XCUIElementTypeStaticText)")
	public List<WebElement> WrongCampaignErrorText;

	@iOSXCUITFindBy(accessibility = "SHOW SITE INFO")
	public WebElement ShowSiteInfoButton;

	@iOSXCUITFindBy(accessibility = "CLEAR COOKIES")
	public WebElement ClearCookiesButton;

	@WithTimeout(time = 50, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(xpath = "(//XCUIElementTypeStaticText)")
	public List<WebElement> DeleteCookiesMessage;

	@iOSXCUITFindBy(accessibility = "YES")
	public WebElement YESButton;

	@iOSXCUITFindBy(accessibility = "NO")
	public WebElement NOButton;

	@WithTimeout(time = 30, chronoUnit = ChronoUnit.SECONDS)
	@iOSXCUITFindBy(accessibility = "NO")
	public List<WebElement> ConsentButtons;

	public WebElement eleButton;

	boolean errorFound = false;

	public WebElement eleButton(String buttonText) throws InterruptedException {
		Thread.sleep(3000);	
		eleButton = (WebElement) driver
					.findElement(By.xpath("//XCUIElementTypeButton[@name='" + buttonText + "']"));
			Thread.sleep(3000);
			// eleButton = (WebElement) driver.findElement(By.("+buttonText+"));

		return eleButton;

	}

	public void loadTime() {
		try {

			long startTime = System.currentTimeMillis();
			new WebDriverWait(driver, 120).until(ExpectedConditions.presenceOfElementLocated(
					By.xpath("//android.webkit.WebView[contains(@text,'Notice Message App')]")));
			// new WebDriverWait(driver,
			// 60).until(ExpectedConditions.presenceOfElementLocated(By.xpath("//android.widget.Button[contains(@text,'Privacy
			// Setting')]")));
			long endTime = System.currentTimeMillis();
			long totalTime = endTime - startTime;
			System.out.println("**** Total Message Load Time: " + totalTime + " milliseconds");
		} catch (Exception ex) {
			System.out.println(ex);
			throw ex;
		}

	}

	public void scrollAndClick(String text) throws InterruptedException {
		JavascriptExecutor js = (JavascriptExecutor) driver;
		HashMap<String, String> scrollObject = new HashMap<String, String>();

		scrollObject.put("direction", "down");
		js.executeScript("mobile: scroll", scrollObject);
		js.executeScript("mobile: scroll", scrollObject);
		Thread.sleep(2000);
		
		//driver.findElement(By.xpath("//XCUIElementTypeButton[@name='" + text + "']")).click();
		try {
		//	long startTime = System.currentTimeMillis();
//			new WebDriverWait(driver, 120).until(ExpectedConditions.presenceOfElementLocated(
//					By.xpath("//XCUIElementTypeButton[@name='" + text + "']")));
//			
			driver.findElement(By.xpath("//XCUIElementTypeButton[@name='" + text + "']")).click();
		}catch(Exception ex){
			throw ex;
		}
	}

	public void scrollDown() {
		Dimension dimension = driver.manage().window().getSize();

		Double scrollHeightStart = dimension.getHeight() * 0.5;
		int scrollStart = scrollHeightStart.intValue();

		Double scrollHeightEnd = dimension.getHeight() * 0.8;
		int scrollEnd = scrollHeightEnd.intValue();

		new TouchAction((PerformsTouchActions) driver).press(PointOption.point(0, scrollStart))
				.waitAction(WaitOptions.waitOptions(Duration.ofSeconds(2))).moveTo(PointOption.point(0, scrollEnd))
				.release().perform();
	}

	ArrayList<String> consentMsg = new ArrayList<String>();

	ArrayList<String> expectedList = new ArrayList<String>();

	public void expectedList() {
		expectedList.add("");
		expectedList.add("");
	}

	public ArrayList<String> getConsentMessageDetails() throws InterruptedException {
		Thread.sleep(8000);
		for (WebElement msg : ConsentMessage) {
			consentMsg.add(msg.getText());
			// consentMsg.add(msg.getAttribute("value"));
		}
		return consentMsg;
	}

	public void getLocation() {
		for (WebElement msg : ConsentMessage) {
			Point point = msg.getLocation();
			TouchAction touchAction = new TouchAction((PerformsTouchActions) driver);
			System.out.println("******************");
			System.out.println((point.x) + (msg.getSize().getWidth()));
			System.out.println((point.y) + (msg.getSize().getWidth()));
			System.out.println("******************");
		}
	}

	public String verifyWrongCampaignError() throws InterruptedException {
		Thread.sleep(3000);
		try {
			return WrongCampaignErrorText.get(WrongCampaignErrorText.size() - 1).getText();
		} catch (Exception e) {
			throw e;
		}
	}

	public void waitForElement(WebElement ele, int timeOutInSeconds) {
		WebDriverWait wait = new WebDriverWait(driver, timeOutInSeconds);
		wait.until(ExpectedConditions.visibilityOf(ele));
	}

	public void clickOnButton(String buttonName) {
		for (WebElement button : ConsentButtons) {
			if (button.getText().equals(buttonName)) {
				button.click();
				break;
			}
		}
	}

	public boolean verifyDeleteCookiesMessage() {
		return DeleteCookiesMessage.get(DeleteCookiesMessage.size() - 1).getText()
				.contains("Cookies for all properties will be");
	}

}
