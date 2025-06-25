import unittest
from appium import webdriver
from appium.options.android import UiAutomator2Options
import time

class RegisterTest(unittest.TestCase):
    def setUp(self):
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'first_android',  # Emulator name
            'app': 'C:/Users/ganna/Documents/GitHub/LILI/build/app/outputs/flutter-apk/app-debug.apk',
            'automationName': 'UiAutomator2',
        }
        options = UiAutomator2Options().load_capabilities(desired_caps)
        self.driver = webdriver.Remote('http://localhost:4723', options=options)

    def test_register_and_init_setup(self):
        time.sleep(2)  # Wait for the UI to load
        # Navigate to the register/signup page using the new accessibility id
        signup_button = self.driver.find_element('accessibility id', 'register_now')
        signup_button.click()
        time.sleep(2)

        # Debug: Take a screenshot after navigating to signup
        self.driver.save_screenshot('after_signup_nav.png')

        # Try to find fields by accessibility id (labelText), fallback to field order for debug only
        try:
            name_field = self.driver.find_element('accessibility id', 'Full Name')
            username_field = self.driver.find_element('accessibility id', 'Username')
            email_field = self.driver.find_element('accessibility id', 'Email')
            phone_field = self.driver.find_element('accessibility id', 'Phone Number')
            password_field = self.driver.find_element('accessibility id', 'Password')
            confirm_password_field = self.driver.find_element('accessibility id', 'Confirm Password')
        except Exception as e:
            print('Could not find one or more registration fields by accessibility id:', e)
            fields = self.driver.find_elements('class name', 'android.widget.EditText')
            print(f"Found {len(fields)} EditText fields on signup page")
            for i, field in enumerate(fields):
                print(f"Field {i}: content-desc={field.get_attribute('content-desc')}, text={field.text}")
            self.driver.save_screenshot('signup_fields_debug.png')
            # Fallback for debug only
            if len(fields) >= 6:
                name_field = fields[0]
                username_field = fields[1]
                email_field = fields[2]
                phone_field = fields[3]
                password_field = fields[4]
                confirm_password_field = fields[5]
            else:
                raise

        # Fill all fields
        name_field.click()
        time.sleep(0.5)
        name_field.send_keys('Ganna Test')
        time.sleep(0.5)

        username_field.click()
        time.sleep(0.5)
        username_field.send_keys('ganna_test')
        time.sleep(0.5)

        email_field.click()
        time.sleep(0.5)
        email_field.send_keys('ganna@example.com')
        time.sleep(0.5)

        phone_field.click()
        time.sleep(0.5)
        phone_field.send_keys('1234567890')
        time.sleep(0.5)

        password_field.click()
        time.sleep(0.5)
        password_field.send_keys('Testpass1')
        time.sleep(0.5)

        confirm_password_field.click()
        time.sleep(0.5)
        confirm_password_field.send_keys('Testpass1')
        time.sleep(0.5)

        # Debug: print field values and take screenshot
        fields = self.driver.find_elements('class name', 'android.widget.EditText')
        for i, field in enumerate(fields):
            print(f"After all input - Field {i}: text={field.text}")
        self.driver.save_screenshot('fields_after_input.png')
        # Now continue with the rest of the registration flow

        # Scroll to bottom before searching for the button
        try:
            self.driver.swipe(100, 1200, 100, 100, 800)  # Adjust coordinates as needed for your device
            time.sleep(1)
        except Exception:
            pass

        # Find the register button by accessibility id (Semantics label)
        try:
            register_button = self.driver.find_element('accessibility id', 'register_button')
        except Exception as e:
            print('Could not find register button by accessibility id:', e)
            buttons = self.driver.find_elements('class name', 'android.widget.Button')
            print(f"Found {len(buttons)} Button fields")
            for i, button in enumerate(buttons):
                print(f"Button {i}: text={button.text}")
            self.driver.save_screenshot('register_button_debug.png')
            raise
        register_button.click()
        time.sleep(3)

        # Now on Init Setup page, fill all required fields
        birthdate_field = self.driver.find_element('accessibility id', 'initsetup_birthdate')
        birthdate_field.click()
        time.sleep(1)
        # Robust date picker interaction: select year 2000 and day 1, then OK
        try:
            year_button = self.driver.find_element('xpath', "//android.widget.Button[contains(@content-desc, 'Select year')]")
            year_button.click()
            time.sleep(1)
            # Find all year buttons by content-desc
            year_buttons = self.driver.find_elements('class name', 'android.widget.Button')
            years = []
            for yb in year_buttons:
                desc = yb.get_attribute('content-desc')
                if desc and desc.isdigit():
                    years.append((int(desc), yb))
            if years:
                years.sort()
                print(f'Clicking oldest year: {years[0][0]}')
                years[0][1].click()
                time.sleep(1)
            else:
                print('No year buttons with numeric content-desc found!')
                self.driver.save_screenshot('year_buttons_not_found.png')
        except Exception as e:
            print('Could not select year:', e)
        # Select day 1 (should now be in the selected year)
        try:
            day_1 = self.driver.find_element('xpath', "//android.widget.Button[contains(@content-desc, '1,')]")
            day_1.click()
            time.sleep(1)
        except Exception as e:
            print('Could not select day:', e)
        # Click OK
        try:
            ok_button = self.driver.find_element('xpath', "//android.widget.Button[@content-desc='OK']")
            ok_button.click()
            time.sleep(1)
        except Exception as e:
            print('Could not click OK:', e)
            self.driver.back()
            time.sleep(1)
        time.sleep(1)
        # Gender dropdown (combo box)
        gender_field = None
        buttons = self.driver.find_elements('class name', 'android.widget.Button')
        for button in buttons:
            desc = button.get_attribute('content-desc') or ''
            if desc.startswith('initsetup_gender'):
                gender_field = button
                break
        if not gender_field:
            print('Could not find gender field by partial content-desc')
            self.driver.save_screenshot('initsetup_gender_debug.png')
            raise Exception('Gender field not found')
        gender_field.click()
        time.sleep(0.5)
        # Select 'Female' (button with content-desc=Female)
        try:
            female_option = self.driver.find_element('xpath', "//android.widget.Button[@content-desc='Female']")
            female_option.click()
            time.sleep(0.5)
        except Exception as e:
            print('Could not find Female button:', e)
            options = self.driver.find_elements('xpath', '//*')
            for i, opt in enumerate(options):
                try:
                    print(f'Option {i}: class={opt.get_attribute("className")}, content-desc={opt.get_attribute("content-desc")}, text={opt.text}')
                except Exception:
                    continue
            self.driver.save_screenshot('gender_options_debug.png')
            raise
        # Diet dropdown (combo box)
        diet_field = None
        for button in buttons:
            desc = button.get_attribute('content-desc') or ''
            if desc.startswith('initsetup_diet'):
                diet_field = button
                break
        if not diet_field:
            print('Could not find diet field by partial content-desc')
            self.driver.save_screenshot('initsetup_diet_debug.png')
            raise Exception('Diet field not found')
        diet_field.click()
        time.sleep(0.5)
        # Print all buttons after opening diet dropdown
        diet_buttons = self.driver.find_elements('class name', 'android.widget.Button')
        vegan_found = False
        for i, btn in enumerate(diet_buttons):
            desc = btn.get_attribute("content-desc")
            print(f'Diet option {i}: content-desc={desc}, text={btn.text}')
            if desc == 'Vegan':
                btn.click()
                vegan_found = True
                time.sleep(0.5)
                print('Clicked Vegan diet option')
                break
        if not vegan_found:
            print('Could not find Vegan button!')
            self.driver.save_screenshot('diet_options_debug.png')
            raise Exception('Vegan diet option not found')
        # Scroll down to reveal more fields (if needed)
        try:
            self.driver.swipe(100, 1200, 100, 100, 800)
            time.sleep(1)
        except Exception:
            pass
        # Print all EditText fields and their content-desc/text for debug
        edit_fields = self.driver.find_elements('class name', 'android.widget.EditText')
        print(f'Found {len(edit_fields)} EditText fields on init setup page')
        for i, field in enumerate(edit_fields):
            try:
                print(f'EditText {i}: content-desc={field.get_attribute("content-desc")}, text={field.text}')
            except Exception:
                continue
        self.driver.save_screenshot('initsetup_edittexts_debug.png')
        # Now try to find the height field
        try:
            height_field = self.driver.find_element('accessibility id', 'initsetup_height')
            height_field.click()
            height_field.send_keys('170')
            time.sleep(0.5)
            weight_field = self.driver.find_element('accessibility id', 'initsetup_weight')
            weight_field.click()
            weight_field.send_keys('65.2')
            time.sleep(0.5)
            # Allergies field is intentionally left empty
        except Exception:
            # Fallback: Use field order for height, weight
            edit_fields = self.driver.find_elements('class name', 'android.widget.EditText')
            if len(edit_fields) >= 2:
                height_field = edit_fields[0]
                weight_field = edit_fields[1]
                height_field.click()
                height_field.send_keys('170')
                time.sleep(0.5)
                weight_field.click()
                weight_field.send_keys('65.2')
                time.sleep(0.5)
                # Allergies field is intentionally left empty
            else:
                raise Exception('Not enough EditText fields for height/weight')
        finish_button = self.driver.find_element('accessibility id', 'initsetup_finish')
        finish_button.click()
        time.sleep(3)
        self.driver.save_screenshot('register_result_debug.png')

    def tearDown(self):
        self.driver.quit()

if __name__ == '__main__':
    unittest.main() 