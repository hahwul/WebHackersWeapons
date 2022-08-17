## Contribute
### First, Fork Repository
Fork this repository :D

### Second, Write `./weapons/<appname>.yaml` and Commit/PR
Write YAML Code. 
```yaml
---
name: App Name
description: App Description
url: App URL   # https://github.com/hahwul/dalfox
category: tool # tool / tool-addon / browser-addon / bookmarklet
type:       # fuzzer / scanner / enum / etc...
platform:
- linux     # linux 
- macos     # macos application
- windows   # windows application
- firefox   # firefox addon
- safari    # safari addon
- chrome    # chrome addon
- zap       # zap addon
- burpsuite # burpsuite addon
# If supported crossplatform, you write out all three (linux/macos/windows)
lang: []
tags: []
```

![1415](https://user-images.githubusercontent.com/13212227/98445635-00db1e00-215c-11eb-8a59-d7d21dd98db0.png)

### Third, There's no third.