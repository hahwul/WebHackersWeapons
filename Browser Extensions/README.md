<h1 align="center">
  <br>
  <a href=""><img src="https://user-images.githubusercontent.com/13212227/79006553-5fbfc100-7b94-11ea-8b42-3fa154d098fd.png" alt="" width="600px;"></a>
  <br>
  Web Hacker's Weapons<br>
  &lt; Browser Extensions &gt;
  <br>
  <a href="https://twitter.com/intent/follow?screen_name=hahwul"><img src="https://img.shields.io/twitter/follow/hahwul?style=flat-square"></a> <img src="https://img.shields.io/github/languages/top/hahwul/WebHackersWeapons?style=flat-square"> <img src="https://img.shields.io/github/last-commit/hahwul/WebHackersWeapons?style=flat-square"> 
</h1>
A collection of cool tools used by Web hackers. Happy hacking , Happy bug-hunting<br>
This is Cool Extensions collection of Browser Extensions

## Table of Contents
- [Web Hacker's Weapons Main](https://github.com/hahwul/WebHackersWeapons)
- [Browser Extensions](#extensions)
- [Contribute](#contribute-and-contributor) 

## Extensions
| Type | Name | Description | Popularity | Language |
| ---------- | :---------- | :----------: | :----------: | :----------: | 
| Chrome/Cookie | [Edit-This-Cookie](https://github.com/ETCExtensions/Edit-This-Cookie) | EditThisCookie is the famous Google Chrome/Chromium extension for editing cookies | ![](https://img.shields.io/github/stars/ETCExtensions/Edit-This-Cookie) | ![](https://img.shields.io/github/languages/top/ETCExtensions/Edit-This-Cookie) |
| Chrome/UA  | [User-Agent Switcher](https://chrome.google.com/webstore/detail/user-agent-switcher/clddifkhlkcojbojppdojfeeikdkgiae) |  quick and easy way to switch between user-agents.|![](https://img.shields.io/static/v1?label=&message=it's%20not%20github&color=gray)|![](https://img.shields.io/static/v1?label=&message=it's%20not%20github&color=gray)
| Chrome/postMessage | [postMessage-tracker](https://github.com/fransr/postMessage-tracker) | A Chrome Extension to track postMessage usage (url, domain and stack) both by logging using CORS and also visually as an extension-icon | ![](https://img.shields.io/github/stars/fransr/postMessage-tracker) | ![](https://img.shields.io/github/languages/top/fransr/postMessage-tracker) |
| Firefox and Chrome/DarkMode  | [Dark Reader](https://chrome.google.com/webstore/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh) |  Dark mode to any site|![](https://img.shields.io/static/v1?label=&message=it's%20not%20github&color=gray)|![](https://img.shields.io/static/v1?label=&message=it's%20not%20github&color=gray)
| Firefox and Chrome/Proxy  | [MM3 ProxySwitch](https://proxy-offline-browser.com/ProxySwitch/) |  Proxy Switch in Firefox and Chrome|![](https://img.shields.io/static/v1?label=&message=it's%20not%20github&color=gray)|![](https://img.shields.io/static/v1?label=&message=it's%20not%20github&color=gray)
| Safari/DarkMode  | [Dark Reader for Safari](https://apps.apple.com/us/app/dark-reader-for-safari/id1438243180) |  Dark mode to any site|![](https://img.shields.io/static/v1?label=&message=it's%20not%20github&color=gray)|![](https://img.shields.io/static/v1?label=&message=it's%20not%20github&color=gray)
| Safari/HISTORY  | [Wayback Machine](https://apps.apple.com/us/app/wayback-machine/id1472432422) |  History of website|![](https://img.shields.io/static/v1?label=&message=it's%20not%20github&color=gray)|![](https://img.shields.io/static/v1?label=&message=it's%20not%20github&color=gray)
## Contribute and Contributor
### Usage of add-tool
```
./add-tool
Usage of ./add-tool:
  -isFirst
    	if you add new type, it use
  -url string
    	any url
```

### Three Procedures for the Contribute
- First, your tool append `data.json` using `add-tool
```
$ ./add-tool -url https://github.com/sqlmapproject/sqlmap
Successfully Opened type.lst
[0] Army-Knife
[1] Discovery
[2] Fetch
[3] Scanner
[4] Utility
[+] What is type?
3
Scanner
[+] What is method(e.g XSS, WVS, SSL, ETC..)?
SQL
Successfully Opened data.json

```
- Second, Give me PR or Add issue with data.json<br>
- Third, There's no third.

### Add Burp Suite or ZAP Extensions
in `WebHackersWeapons/Burp and ZAP Extensions` directory
```
$ ../add-tool -url https://github.com/nccgroup/BurpSuiteLoggerPlusPlus
```

### Distribute to Burp Suite or ZAP Extensions
```
$ ../distribute-readme
=> show new README file in Burp Suite or ZAP Extensions
```

### Add/Distribute common tools
https://github.com/hahwul/WebHackersWeapons#contribute-and-contributor
