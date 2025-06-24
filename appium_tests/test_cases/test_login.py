import unittest
from appium import webdriver
from appium.options.android import UiAutomator2Options

class LoginTest(unittest.TestCase):
    def setUp(self):
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'first',  # Updated emulator name
            'app': '/path/to/your/app.apk',  # Update with your app path
            'automationName': 'UiAutomator2',
        }
        options = UiAutomator2Options().load_capabilities(desired_caps)
        self.driver = webdriver.Remote('http://localhost:4723/wd/hub', options=options)

    def test_login_valid_credentials(self):
        # Example: Find username and password fields and login button
        username_field = self.driver.find_element_by_accessibility_id('username')
        password_field = self.driver.find_element_by_accessibility_id('password')
        login_button = self.driver.find_element_by_accessibility_id('login_button')

        username_field.send_keys('testuser')
        password_field.send_keys('password123')
        login_button.click()

        # Assert successful login (update with your app's logic)
        home_screen = self.driver.find_element_by_accessibility_id('home_screen')
        self.assertIsNotNone(home_screen)

    def tearDown(self):
        self.driver.quit()

if __name__ == '__main__':
    unittest.main() 