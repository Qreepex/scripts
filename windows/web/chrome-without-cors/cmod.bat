start /min "Chrome" "C:\Program Files\Google\Chrome\Application\chrome.exe" ^
  --lang=en-US ^
  --no-first-run ^
  --no-default-browser-check ^
  --disable-default-apps ^
  --disable-extensions ^
  --disable-sync ^
  --disable-features=Translate,TranslateUI,TranslationsPlatform ^
  --disable-popup-blocking ^
  --disable-web-security ^
  --disable-gpu ^
  --incognito ^
  "http://localhost:3000" %*