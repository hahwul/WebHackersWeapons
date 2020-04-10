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
