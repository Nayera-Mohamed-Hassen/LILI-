import unittest
from appium import webdriver
from appium.options.android import UiAutomator2Options
import time
import re

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
        if not username_field.text:
            username_field.set_value('ganna')
        password_field.click()
        password_field.send_keys('1234')

        if not password_field.text:
            password_field.set_value('1234')

        self.driver.save_screenshot('logout_fields_after_input.png')
    
        login_button.click()
        time.sleep(3)
        # --- Wait for home screen ---
        try:
            self.driver.find_element('accessibility id', 'home_greeting')
        except Exception:
            self.driver.save_screenshot('logout_home_not_found.png')
            raise Exception('Home screen not loaded after login')
        # --- NAVIGATE TO PROFILE VIA NAVBAR ---
        views = self.driver.find_elements('class name', 'android.view.View')
        # Find clickable views at the bottom of the screen (y >= 2000)
        navbar_buttons = []
        for v in views:
            try:
                bounds = v.get_attribute('bounds')
                clickable = v.get_attribute('clickable') == 'true'
                if clickable and bounds:
                    m = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', bounds)
                    if m:
                        left, top, right, bottom = map(int, m.groups())
                        # Heuristic: bottom of screen is >= 2200 (adjust if needed)
                        if top >= 2000 or bottom >= 2000:
                            navbar_buttons.append((left, v))
            except Exception:
                pass
        if not navbar_buttons:
            self.driver.save_screenshot('logout_navbar_buttons_not_found.png')
            raise Exception('No navbar buttons found at bottom of screen')
        # Tap the rightmost one (largest left)
        navbar_buttons.sort()
        profile_button = navbar_buttons[-1][1]
        profile_button.click()
        time.sleep(2)
        self.driver.save_screenshot('logout_profile_screen.png')
        # --- SCROLL TO LOGOUT AND TAP ---
        found = False
        logout_tile = None
        for attempt in range(3):  # Try up to 3 times (initial + 2 scrolls)
            views = self.driver.find_elements('class name', 'android.view.View')
            candidates = []
            for v in views:
                try:
                    desc = v.get_attribute('content-desc') or ''
                    if 'Logout' in desc:
                        bounds = v.get_attribute('bounds')
                        m = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', bounds) if bounds else None
                        top = int(m.group(2)) if m else 0
                        candidates.append((top, v))
                except Exception:
                    pass
            if candidates:
                candidates.sort()
                logout_tile = candidates[0][1]
                found = True
                break
            if attempt < 2:
                self.driver.swipe(500, 1500, 500, 500, 800)
                time.sleep(1)
        if not found or logout_tile is None:
            print('No clickable view with Logout in content-desc found after three attempts.')
            self.driver.save_screenshot('logout_tile_not_found.png')
            raise Exception('Logout ListTile not found after three attempts and debug printed')
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