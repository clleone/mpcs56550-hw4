import os
import pytest
from playwright.sync_api import Page, expect

BASE_URL = os.getenv("APP_URL", "http://flask-app:5000")


def test_user_journey_login(page: Page):
    # go to login page
    page.goto(f"{BASE_URL}/login")

    # fill form
    page.fill("#username", "libby")
    page.fill("#password", "journalist1")

    # submit form
    page.click("button[type='submit']")

    print(f"Current URL: {page.url}")
    print(f"Page content: {page.content()}")

    # Take a screenshot for debugging
    page.screenshot(path="debug_screenshot.png")

    # confirm we've been logged in
    expect(page.get_by_text("Welcome,")).to_be_visible()
    print("User journey successful: Logged in and verified welcome message.")
