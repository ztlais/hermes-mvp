import json
from playwright.sync_api import sync_playwright

TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidXNlcm5hbWUiOiJ6ZWluIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzg0NzQwODIwfQ.omQRPztGcOdcIUbrED_-w0DlCVGhdDY5KLlZn6pjGEw"
USER = json.dumps({"username": "zein", "full_name": "Zein Tlais", "role": "admin"})

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto("http://localhost:3000")
    page.evaluate(f"""() => {{
        localStorage.setItem('hermes_token', {json.dumps(TOKEN)});
        localStorage.setItem('hermes_user', {json.dumps(USER)});
    }}""")
    page.goto("http://localhost:3000/projects")
    page.wait_for_timeout(1500)

    console_msgs = []
    page.on("console", lambda msg: console_msgs.append(f"{msg.type}: {msg.text}"))
    page.on("pageerror", lambda exc: console_msgs.append(f"pageerror: {exc}"))

    # Switch to Afrique zone
    try:
        page.click("text=Afrique", timeout=3000)
    except Exception as e:
        print("could not click Afrique tab:", e)

    page.wait_for_timeout(1000)
    page.screenshot(path="/root/hermes-mvp/screenshot_afrique.png", full_page=True)

    # Open export dropdown
    page.click("text=Export")
    page.wait_for_timeout(500)
    page.screenshot(path="/root/hermes-mvp/screenshot_export_menu.png", full_page=True)

    with page.expect_download(timeout=10000) as dl_info:
        page.click("text=PDF")
    download = dl_info.value
    path = "/root/hermes-mvp/exported_afrique.pdf"
    download.save_as(path)
    print("Saved PDF to", path)

    print("---console---")
    for m in console_msgs:
        print(m)

    browser.close()
