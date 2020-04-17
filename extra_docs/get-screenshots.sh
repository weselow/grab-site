#!/bin/bash
# source: http://www.manhunter.ru/webmaster/1442_sozdanie_skrinshotov_saytov_s_pomoschyu_headless_chrome.html
#
# /opt/google/chrome/chrome --no-sandbox --headless --disable-gpu \
#	--proxy-server=socks5://ip:port@login:password --proxy-bypass-list=* \
#	--window-size=1024,768 --screenshot=/images/my_screenshot_1024.png \
#	https://www.yandex.ru
#
#	Install Chrome
#	wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
#	sudo dpkg -i google-chrome-stable_current_amd64.deb



# -----------------------------
# -- Install Chromium Browser --
# -----------------------------
#
if [[ -z "$(dpkg -s chromium-browser | grep Description)" ]]; then
	sudo apt install -y chromium-browser
fi

# Create Dirs

# Make screenshots
# 800 × 600, 1024 × 768, 1280 × 1024
# source: https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D1%88%D0%B5%D0%BD%D0%B8%D0%B5_%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0_%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B0

 usr/bin/chromium-browser --no-sandbox --headless --disable-gpu \
	--window-size=1024,768 --screenshot=/images/my_screenshot_1024.png \
	https://www.yandex.ru

/usr/bin/chromium-browser --no-sandbox --headless --disable-gpu \
	--window-size=1280,1024 --screenshot=/images/my_screenshot_1280.png \
	https://www.yandex.ru
