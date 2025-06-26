import unittest
from appium import webdriver
from appium.options.android import UiAutomator2Options
import time

class LoginTest(unittest.TestCase):
    def setUp(self):
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'first_android',  # Emulator name
            'app': 'C:/Users/ganna/Documents/GitHub/LILI/build/app/outputs/flutter-apk/app-debug.apk',
            'automationName': 'UiAutomator2',
        }
        options = UiAutomator2Options().load_capabilities(desired_caps)
        self.driver = webdriver.Remote('http://localhost:4723', options=options)

    def test_login_valid_credentials(self):
        time.sleep(2)  # Wait for the UI to load
        # Try to find by accessibility id first
        try:
            username_field = self.driver.find_element('accessibility id', 'username')
        except Exception as e:
            # If not found, print all EditText fields and their content-desc
            fields = self.driver.find_elements('class name', 'android.widget.EditText')
            print(f"Found {len(fields)} EditText fields")
            for i, field in enumerate(fields):
                print(f"Field {i}: content-desc={field.get_attribute('content-desc')}, text={field.text}")
            # Try to use the first EditText as username, second as password
            if len(fields) >= 2:
                username_field = fields[0]
                password_field = fields[1]
            else:
                self.driver.save_screenshot('login_screen_debug.png')
                raise e
        else:
            password_field = self.driver.find_element('accessibility id', 'password')
        # Find the login button by accessibility id (Semantics label)
        try:
            login_button = self.driver.find_element('accessibility id', 'login_button')
        except Exception as e:
            print('Login button not found by accessibility id. Trying fallback...')
            # Fallback: print all Button fields and their text
            buttons = self.driver.find_elements('class name', 'android.widget.Button')
            print(f"Found {len(buttons)} Button fields")
            for i, button in enumerate(buttons):
                print(f"Button {i}: text={button.text}")
            self.driver.save_screenshot('login_button_debug.png')
            raise Exception("Login button not found")

        # Tap and fill username
        username_field.click()
        time.sleep(0.5)
        username_field.send_keys('ganna')
        time.sleep(0.5)
        # Check if username was filled, fallback to set_value if not
        if not username_field.text:
            print('send_keys did not work for username, trying set_value')
            username_field.set_value('ganna')
            time.sleep(0.5)
        # Tap and fill password
        password_field.click()
        time.sleep(0.5)
        password_field.send_keys('1234')
        time.sleep(0.5)
        # Check if password was filled, fallback to set_value if not
        if not password_field.text:
            print('send_keys did not work for password, trying set_value')
            password_field.set_value('1234')
            time.sleep(0.5)
        # Debug: print field values and take screenshot
        print(f"Username field after input: '{username_field.text}'")
        print(f"Password field after input: '{password_field.text}'")
        self.driver.save_screenshot('fields_after_input.png')
        time.sleep(1)
        login_button.click()
        time.sleep(3)
        # Check for the home greeting by accessibility id
        try:
            self.driver.find_element('accessibility id', 'home_greeting')
        except Exception:
            self.driver.save_screenshot('login_result_debug.png')
            raise Exception("Home screen greeting not found - login may have failed or UI not loaded.")

    def tearDown(self):
        self.driver.quit()

if __name__ == '__main__':
    unittest.main() 