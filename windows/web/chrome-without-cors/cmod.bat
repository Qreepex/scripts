start /min "Chrome" "C:\Program Files\Google\Chrome\Application\chrome.exe" ^
  --user-data-dir="C:\tmp\chrome_dev_session" ^
  --lang=en-US ^
  --no-first-run ^
  --no-default-browser-check ^
  --disable-default-apps ^
  --disable-extensions ^
  --disable-sync ^
  --disable-features=Translate,TranslateUI,TranslationsPlatform ^
  --disable-popup-blocking ^
  --disable-web-security ^
  --disable-site-isolation-trials ^
  --disable-gpu ^
  --incognito ^
  "http://localhost:3000" %*