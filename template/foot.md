## Contribute
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

### Build contribute tools
```
$ go build add-tool.go
$ go build distribute-readme.go
```

### Add common tools
in `WebHackersWeapons` directory
```
$ ./add-tool -url https://github.com/hahwul/s3reverse
```
### Add Burp Suite or ZAP Extensions
in `WebHackersWeapons/Burp and ZAP Extensions` directory
```
$ ../add-tool -url https://github.com/nccgroup/BurpSuiteLoggerPlusPlus
```

### Asciinema video
[![asciicast](https://asciinema.org/a/318456.svg)](https://asciinema.org/a/318456)

## Distribute (for me)
### Distribute to common tools
```
$ ./distribute-readme
=> show new README file
```

### Distribute to Burp Suite or ZAP Extensions
```
$ ../distribute-readme
=> show new README file in Burp Suite or ZAP Extensions
```

## Thanks to (Contributor)
[six2dez](https://github.com/six2dez) , [si9int](https://github.com/si9int) , [dwisiswant0](https://twitter.com/dwisiswant0) , [riza](https://github.com/riza)
