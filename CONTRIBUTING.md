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
type:          # Army-knife / Proxy / Recon / Fuzzer / Scanner / Exploit / Env / Utils / Etc
platform:
- linux        # linux 
- macos        # macos application
- windows      # windows application
- firefox      # firefox addon
- safari       # safari addon
- chrome       # chrome addon
- zap          # anything to do with zap (addons, scripts, etc..)
- burpsuite    # anything to do with burpsuite (extensions, payloads, etc..)
# If supported crossplatform (OS), you write out all three (linux/macos/windows)
# If supported zap and burpsuite addon, you write both (zap/burpsuite)
lang:          # go / python / ruby / rust / etc...
tags: []       # xss / sqli / ssrf / oast / http / subdomains / etc...
```

*Sample*
```yaml
---
name: HUNT
description: Identifies common parameters vulnerable to certain vulnerability classes
url: https://github.com/bugcrowd/HUNT
category: tool-addon
type: Recon
platform:
- linux
- macos
- windows
- zap
- burpsuite
lang: Kotlin
tags: 
- param
```

![1415](https://user-images.githubusercontent.com/13212227/98445635-00db1e00-215c-11eb-8a59-d7d21dd98db0.png)

### Third, There's no third.
