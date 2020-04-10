package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"golang.org/x/net/html"
	"io"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"
)

/*
template
| [WebHackersWeapons](https://github.com/hahwul/WebHackersWeapons) | template | ![](https://img.shields.io/github/stars/hahwul/WebHackersWeapons) | ![](https://img.shields.io/github/languages/top/hahwul/WebHackersWeapons) | ![](https://img.shields.io/github/repo-size/hahwul/WebHackersWeapons)<br>![](https://img.shields.io/github/license/hahwul/WebHackersWeapons) <br> ![](https://img.shields.io/github/forks/hahwul/WebHackersWeapons) <br> ![](https://img.shields.io/github/watchers/hahwul/WebHackersWeapons) |
*/

type Tools struct {
	Type, Data, Method string
}

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

func writeJSON(category string, name string, method string, data string) {
	jsonFile, err := os.Open("data.json")
	// if we os.Open returns an error then handle it
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println("Successfully Opened data.json")
	// defer the closing of our jsonFile so that we can parse it later on
	defer jsonFile.Close()
	byteValue, _ := ioutil.ReadAll(jsonFile)
	var result map[string]interface{}
	json.Unmarshal([]byte(byteValue), &result)
	tool := Tools{
		Type:   category,
		Data:   data,
		Method: method,
	}
	result[name] = tool
	file, _ := json.MarshalIndent(result, "", " ")
	_ = ioutil.WriteFile("data.json", file, 0644)
}

func main() {
	repourl := flag.String("url", "", "any url")
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

	if u.Host == "github.com" {
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

		typeFile, err := os.Open("type.lst")
		// if we os.Open returns an error then handle it
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println("Successfully Opened type.lst")
		// defer the closing of our jsonFile so that we can parse it later on
		defer typeFile.Close()
		index := 0
		m := make(map[int]string)
		reader := bufio.NewReader(typeFile)
		for {
			line, isPrefix, err := reader.ReadLine()
			if isPrefix || err != nil {
				break
			}
			m[index] = string(line)
			fmt.Println("[" + strconv.Itoa(index) + "] " + string(line))
			index = index + 1
		}
		var choicetype int
		fmt.Println("[+] What is type?")
		_, err = fmt.Scan(&choicetype)
		fmt.Println(m[choicetype])
		reader1 := bufio.NewReader(os.Stdin)
		fmt.Println("[+] What is method(e.g XSS, WVS, SSL, ETC..)?")
		method, _ := reader1.ReadString('\n')
		method = strings.TrimRight(method, "\r\n")
		writeJSON(m[choicetype], name, method, "| "+m[choicetype]+"/"+method+" | ["+name+"]("+*repourl+") | "+desc+" | ![](https://img.shields.io/github/stars"+u.Path+") | ![](https://img.shields.io/github/languages/top"+u.Path+") |")
	} else {
		reader := bufio.NewReader(os.Stdin)
		fmt.Println("[+] What is name?")
		name, _ := reader.ReadString('\n')
		name = strings.TrimRight(name, "\r\n")
		fmt.Println("[+] Input Description?")
		udesc, _ := reader.ReadString('\n')
		udesc = strings.TrimRight(udesc, "\r\n")

		typeFile, err := os.Open("type.lst")
		// if we os.Open returns an error then handle it
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println("Successfully Opened type.lst")
		// defer the closing of our jsonFile so that we can parse it later on
		defer typeFile.Close()
		index := 0
		m := make(map[int]string)
		readerF := bufio.NewReader(typeFile)
		for {
			line, isPrefix, err := readerF.ReadLine()
			if isPrefix || err != nil {
				break
			}
			m[index] = string(line)
			fmt.Println("[" + strconv.Itoa(index) + "] " + string(line))
			index = index + 1
		}
		var choicetype int
		fmt.Println("What is type?")
		_, err = fmt.Scan(&choicetype)
		fmt.Println(m[choicetype])
		reader1 := bufio.NewReader(os.Stdin)
		fmt.Println("[+] What is method(e.g XSS, WVS, SSL, ETC..)?")
		method, _ := reader1.ReadString('\n')
		method = strings.TrimRight(method, "\r\n")
		writeJSON(m[choicetype], name, method, "| "+m[choicetype]+"/"+method+"  | ["+name+"]("+*repourl+") |  "+udesc+"|![](https://img.shields.io/static/v1?label=&message=it's not github&color=gray)|![](https://img.shields.io/static/v1?label=&message=it's not github&color=gray)")
	}

	if *first {
		fmt.Println("| Type | Name | Description | Popularity | Language |")
		fmt.Println("| ---------- | :---------- | :----------: | :----------: | :----------: |")
	}
	//fmt.Println("| [" + name + "](" + *repourl + ") | " + desc + " | ![](https://img.shields.io/github/stars" + u.Path + ") | ![](https://img.shields.io/github/languages/top" + u.Path + ") | ![](https://img.shields.io/github/repo-size" + u.Path + ")<br>![](https://img.shields.io/github/license" + u.Path + ") <br> ![](https://img.shields.io/github/forks" + u.Path + ") <br> ![](https://img.shields.io/github/watchers" + u.Path + ") |")
}
