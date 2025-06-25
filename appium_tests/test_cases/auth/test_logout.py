import unittest
from appium import webdriver
from appium.options.android import UiAutomator2Options
import time

class LogoutTest(unittest.TestCase):
    def setUp(self):
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'first_android',
            'app': 'C:/Users/ganna/Documents/GitHub/LILI/build/app/outputs/flutter-apk/app-debug.apk',
            'automationName': 'UiAutomator2',
        }
        options = UiAutomator2Options().load_capabilities(desired_caps)
        self.driver = webdriver.Remote('http://localhost:4723', options=options)

    def test_logout(self):
        time.sleep(2)  # Wait for the UI to load
        # --- LOGIN (reuse logic from login test) ---
        try:
            username_field = self.driver.find_element('accessibility id', 'username')
        except Exception as e:
            fields = self.driver.find_elements('class name', 'android.widget.EditText')
            if len(fields) >= 2:
                username_field = fields[0]
                password_field = fields[1]
            else:
                self.driver.save_screenshot('logout_login_screen_debug.png')
                raise e
        else:
            password_field = self.driver.find_element('accessibility id', 'password')
        login_button = self.driver.find_element('accessibility id', 'login_button')
        username_field.click()
        time.sleep(0.5)
        username_field.send_keys('ganna')
        time.sleep(0.5)
        if not username_field.text:
            username_field.set_value('ganna')
            time.sleep(0.5)
        password_field.click()
        time.sleep(0.5)
        password_field.send_keys('1234')
        time.sleep(0.5)
        if not password_field.text:
            password_field.set_value('1234')
            time.sleep(0.5)
        self.driver.save_screenshot('logout_fields_after_input.png')
        time.sleep(1)
        login_button.click()
        time.sleep(3)
        # --- Wait for home screen ---
        try:
            self.driver.find_element('accessibility id', 'home_greeting')
        except Exception:
            self.driver.save_screenshot('logout_home_not_found.png')
            raise Exception('Home screen not loaded after login')
        # --- NAVIGATE TO PROFILE VIA NAVBAR ---
        time.sleep(1)
        # Debug: print all clickable elements and all ImageView/Button elements
        clickable = self.driver.find_elements('class name', 'android.view.View')
        print(f"Found {len(clickable)} android.view.View elements")
        for i, el in enumerate(clickable):
            try:
                print(f"View {i}: content-desc={el.get_attribute('content-desc')}, text={el.text}, clickable={el.get_attribute('clickable')}")
            except Exception:
                pass
        imageviews = self.driver.find_elements('class name', 'android.widget.ImageView')
        print(f"Found {len(imageviews)} ImageView elements")
        for i, el in enumerate(imageviews):
            try:
                print(f"ImageView {i}: content-desc={el.get_attribute('content-desc')}, text={el.text}, clickable={el.get_attribute('clickable')}")
            except Exception:
                pass
        buttons = self.driver.find_elements('class name', 'android.widget.Button')
        print(f"Found {len(buttons)} Button elements")
        for i, el in enumerate(buttons):
            try:
                print(f"Button {i}: content-desc={el.get_attribute('content-desc')}, text={el.text}, clickable={el.get_attribute('clickable')}")
            except Exception:
                pass
        self.driver.save_screenshot('logout_navbar_debug.png')
        # The profile button is the last icon in the navbar (index 4)
        if len(imageviews) < 5:
            raise Exception('Not enough navbar icons found')
        profile_button = imageviews[4]
        profile_button.click()
        time.sleep(2)
        self.driver.save_screenshot('logout_profile_screen.png')
        # --- SCROLL TO LOGOUT AND TAP ---
        # Try to find the Logout ListTile by text
        try:
            logout_tile = self.driver.find_element('xpath', "//android.widget.TextView[@text='Logout']")
        except Exception:
            # Try scrolling and searching again
            self.driver.swipe(500, 1500, 500, 500, 800)
            time.sleep(1)
            try:
                logout_tile = self.driver.find_element('xpath', "//android.widget.TextView[@text='Logout']")
            except Exception:
                self.driver.save_screenshot('logout_tile_not_found.png')
                raise Exception('Logout ListTile not found')
        logout_tile.click()
        time.sleep(1)
        self.driver.save_screenshot('logout_dialog.png')
        # --- CONFIRM LOGOUT IN DIALOG ---
        try:
            confirm_button = self.driver.find_element('xpath', "//android.widget.Button[@text='Logout']")
        except Exception:
            self.driver.save_screenshot('logout_confirm_not_found.png')
            raise Exception('Logout confirm button not found')
        confirm_button.click()
        time.sleep(2)
        self.driver.save_screenshot('logout_result.png')
        # --- VERIFY LOGIN SCREEN IS SHOWN ---
        try:
            self.driver.find_element('accessibility id', 'login_button')
        except Exception:
            self.driver.save_screenshot('logout_login_screen_not_found.png')
            raise Exception('Login screen not shown after logout')

    def tearDown(self):
        self.driver.quit()

if __name__ == '__main__':
    unittest.main() 