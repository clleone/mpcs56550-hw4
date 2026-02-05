import os
import pytest
from playwright.sync_api import Page, expect

BASE_URL = os.getenv("APP_URL", "http://flask-app:5000")


def test_user_journey_login(page: Page):
    # go to login page
    page.goto(f"{BASE_URL}/login")

    # fill form
    page.fill("#username", "test_admin")
    page.fill("#password", "secretpassword")

    # submit form
    page.click("button[type='submit']")

    # confirm we've been logged in
    expect(page.get_by_text("Welcome,")).to_be_visible()
    print("User journey successful: Logged in and verified welcome message.")
