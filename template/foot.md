## Contribute and Contributor
### Usage of add-tool
```
./add-tool
Usage of ./add-tool:
  -isFirst
    	if you add new type, it use
  -url string
    	github / gitlab / bitbucket url
```

### Three Procedures for the Contribute
- First, your tool append `data.json` using `add-tool
```
$ ./add-tool -url https://github.com/hahwul/s3reverse

$ cat data.json | grep s3reverse
 "s3reverse": {
  "Data": "| [s3reverse](https://github.com/hahwul/s3reverse) | The format of various s3 buckets is convert in one format. for bugbounty and security testing. | ![](https://img.shields.io/github/stars/hahwul/s3reverse) | ![](https://img.shields.io/github/languages/top/hahwul/s3reverse) | ![](https://img.shields.io/github/repo-size/hahwul/s3reverse)\u003cbr\u003e![](https://img.shields.io/github/license/hahwul/s3reverse) \u003cbr\u003e ![](https://img.shields.io/github/forks/hahwul/s3reverse) \u003cbr\u003e ![](https://img.shields.io/github/watchers/hahwul/s3reverse) |",
```
- Second, Give me PR or Add issue with data.json<br>
- Third, There's no third.

### Distribute
```
$ ./distribute-readme
=> show new README file
```
