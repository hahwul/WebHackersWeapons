<h1 align="center">
  <br>
  <a href=""><img src="https://user-images.githubusercontent.com/13212227/79006553-5fbfc100-7b94-11ea-8b42-3fa154d098fd.png" alt="" width="600px;"></a>
  <br>
  Web Hacker's Weapons<br>
  &lt; Burp and ZAP Extensions &gt;
  <br>
  <a href="https://twitter.com/intent/follow?screen_name=hahwul"><img src="https://img.shields.io/twitter/follow/hahwul?style=flat-square"></a> <img src="https://img.shields.io/github/languages/top/hahwul/WebHackersWeapons?style=flat-square"> <img src="https://img.shields.io/github/last-commit/hahwul/WebHackersWeapons?style=flat-square"> 
</h1>
A collection of cool tools used by Web hackers. Happy hacking , Happy bug-hunting<br>
This is Cool Extensions collection of Burp suite and ZAP

## Table of Contents
- [Web Hacker's Weapons Main](https://github.com/hahwul/WebHackersWeapons)
- [Cool Extensions](#cool-extensions)
- [Contribute](#contribute-and-contributor) 

## Cool Extensions
| Type | Name | Description | Popularity | Language |
| ---------- | :---------- | :----------: | :----------: | :----------: | 
| All/ANALYSIS | [HUNT](https://github.com/bugcrowd/HUNT) | Data Driven web hacking Manual testing | ![](https://img.shields.io/github/stars/bugcrowd/HUNT) | ![](https://img.shields.io/github/languages/top/bugcrowd/HUNT) |
| All/ANALYSIS | [burp-retire-js](https://github.com/h3xstream/burp-retire-js) | Burp/ZAP/Maven extension that integrate Retire.js repository to find vulnerable Javascript libraries. | ![](https://img.shields.io/github/stars/h3xstream/burp-retire-js) | ![](https://img.shields.io/github/languages/top/h3xstream/burp-retire-js) |
| All/ANALYSIS | [csp-auditor](https://github.com/GoSecure/csp-auditor) | Burp and ZAP plugin to analyse Content-Security-Policy headers or generate template CSP configuration from crawling a Website | ![](https://img.shields.io/github/stars/GoSecure/csp-auditor) | ![](https://img.shields.io/github/languages/top/GoSecure/csp-auditor) |
| All/POC | [http-script-generator](https://github.com/h3xstream/http-script-generator) | ZAP/Burp plugin that generate script to reproduce a specific HTTP request (Intended for fuzzing or scripted attacks) | ![](https://img.shields.io/github/stars/h3xstream/http-script-generator) | ![](https://img.shields.io/github/languages/top/h3xstream/http-script-generator) |
| Burp/CODE | [burp-exporter](https://github.com/artssec/burp-exporter) | Exporter is a Burp Suite extension to copy a request to the clipboard as multiple programming languages functions. | ![](https://img.shields.io/github/stars/artssec/burp-exporter) | ![](https://img.shields.io/github/languages/top/artssec/burp-exporter) |
| Burp/HISTORY | [BurpSuiteLoggerPlusPlus](https://github.com/nccgroup/BurpSuiteLoggerPlusPlus) | Burp Suite Logger++ | ![](https://img.shields.io/github/stars/nccgroup/BurpSuiteLoggerPlusPlus) | ![](https://img.shields.io/github/languages/top/nccgroup/BurpSuiteLoggerPlusPlus) |
| ZAP/INTERFACE | [zap-hud](https://github.com/zaproxy/zap-hud) | The OWASP ZAP Heads Up Display (HUD) | ![](https://img.shields.io/github/stars/zaproxy/zap-hud) | ![](https://img.shields.io/github/languages/top/zaproxy/zap-hud) |
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
