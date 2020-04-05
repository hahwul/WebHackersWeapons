package main

import (
	"flag"
	"fmt"
	"golang.org/x/net/html"
	"io"
	"net/http"
	"net/url"
	"strings"
)

/*
template
| [WebHackersWeapons](https://github.com/hahwul/WebHackersWeapons) | template | ![](https://img.shields.io/github/stars/hahwul/WebHackersWeapons) | ![](https://img.shields.io/github/languages/top/hahwul/WebHackersWeapons) | ![](https://img.shields.io/github/repo-size/hahwul/WebHackersWeapons)<br>![](https://img.shields.io/github/license/hahwul/WebHackersWeapons) <br> ![](https://img.shields.io/github/forks/hahwul/WebHackersWeapons) <br> ![](https://img.shields.io/github/watchers/hahwul/WebHackersWeapons) |
*/

func isTitleElement(n *html.Node) bool {
	return n.Type == html.ElementNode && n.Data == "title"
}

func traverse(n *html.Node) (string, bool) {
	if isTitleElement(n) {
		return n.FirstChild.Data, true
	}

	for c := n.FirstChild; c != nil; c = c.NextSibling {
		result, ok := traverse(c)
		if ok {
			return result, ok
		}
	}

	return "", false
}

func GetHtmlTitle(r io.Reader) (string, bool) {
	doc, err := html.Parse(r)
	if err != nil {
		panic("Fail to parse html")
	}

	return traverse(doc)
}

func main() {
	repourl := flag.String("url", "", "github / gitlab / bitbucket url")
	first := flag.Bool("isFirst", false, "if you add new type, it use")
	flag.Parse()
	if flag.NFlag() == 0 {
		flag.Usage()
		return
	}
	u, err := url.Parse(*repourl)
	if err != nil {
		panic(err)
	}

	//fmt.Println(u.Path)
	name := strings.Split(u.Path, "/")[2]
	//fmt.Println(name)
	desc := "asdf"
	resp, err := http.Get(*repourl)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	if title, ok := GetHtmlTitle(resp.Body); ok {
		desc = strings.Split(string(title), ": ")[1]
	} else {
		println("Fail to get HTML title")
	}
	if *first {
		fmt.Println("| Name | Description | Popularity | Language | Metadata |")
		fmt.Println("| ---------- | :---------- | :----------: | :----------: | :----------: |")
	}
	fmt.Println("| [" + name + "](" + *repourl + ") | " + desc + " | ![](https://img.shields.io/github/stars" + u.Path + ") | ![](https://img.shields.io/github/languages/top" + u.Path + ") | ![](https://img.shields.io/github/repo-size" + u.Path + ")<br>![](https://img.shields.io/github/license" + u.Path + ") <br> ![](https://img.shields.io/github/forks" + u.Path + ") <br> ![](https://img.shields.io/github/watchers" + u.Path + ") |")
}
