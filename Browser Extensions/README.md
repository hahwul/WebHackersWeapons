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
