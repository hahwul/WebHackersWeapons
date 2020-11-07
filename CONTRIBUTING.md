# Contribute
## Fork and Build Contribute tools
First, fork this repository 
![1414](https://user-images.githubusercontent.com/13212227/98445633-fd479700-215b-11eb-876f-fcc82a010bb6.png)

Second, Clone forked repo and compile `add-tool` and `distribute-readme` using `make` command:
```
$ git clone https://github.com/{your-id}/WebHackersWeaponse
$ cd WebHackersWeaponse
```

```bash
$ make contribute
```

## Add new tool
### First, your tool append `data.json` using `add-tool
Usage
```
./add-tool
Usage of ./add-tool:
  -isFirst
    	if you add new type, it use
  -url string
    	any url
```

E.g
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

And if you want to add an install / update script for whw-tools, please open data.json and fill out the additional parts.
![1416](https://user-images.githubusercontent.com/13212227/98445636-0173b480-215c-11eb-8390-5dca78e0f79b.png)

### Second, Give me PR or Add issue with data.json<br>
![1415](https://user-images.githubusercontent.com/13212227/98445635-00db1e00-215c-11eb-8a59-d7d21dd98db0.png)

### Third, There's no third.

### Asciinema video
[![asciicast](https://asciinema.org/a/318456.svg)](https://asciinema.org/a/318456)

## Add Other type tools 
(`Burp Suite or ZAP Extensions`, `Bookmarklets`, `Browser Extensions`)

### First, add-tool in 
```
$ cd {Other directory}
```
e.g : `./WebHackersWeapons/Burp and ZAP Extensions`, `./Bookmarklets`, `./Browser Extensions`

```
$ ../add-tool -url https://github.com/nccgroup/BurpSuiteLoggerPlusPlus
```

### Second, PR data.json

## Distruibute (only for me)
### Distribute to common tools
```
$ ./distribute-readme
=> show new README file
```

### Distribute to Another directory
```
$ ../distribute-readme
=> show new README file in Burp Suite or ZAP Extensions
```
