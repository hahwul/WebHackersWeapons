package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"reflect"
	"sort"
	"strings"
)

func main() {
	typeFile, err := os.Open("type.lst")
	// if we os.Open returns an error then handle it
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println("Successfully Opened type.lst")
	// defer the closing of our jsonFile so that we can parse it later on
	defer typeFile.Close()
	index := 0i
	m := make(map[string]interface{})
	readerF := bufio.NewReader(typeFile)
	for {
		line, isPrefix, err := readerF.ReadLine()
		if isPrefix || err != nil {
			break
		}
		strings.TrimRight(string(line), "\r\n")
		m[string(line)] = ""
		index = index + 1
	}
	fmt.Println(m)
	dataJson, err := os.Open("data.json")
	// if we os.Open returns an error then handle it
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println("Successfully Opened data.json")
	// defer the closing of our dataJson so that we can parse it later on
	defer dataJson.Close()
	byteValue, _ := ioutil.ReadAll(dataJson)
	var result map[string]interface{}
	json.Unmarshal([]byte(byteValue), &result)
	//result[name] = tool
	for k, v := range result {
		myMap := v.(map[string]interface{})
		t := myMap["Type"].(string)
		d := myMap["Data"].(string)
		_ = d
		tool := make(map[string]interface{})
		tool[k] = d
		m[t] = tool
	}
	readme := ""
	for k, vv := range m {
		readme = readme + "\r\n## " + k + "\r\n\r\n| Name | Description | Popularity | Language | Metadata |\r\n| ---------- | :---------- | :----------: | :----------: | :----------: |\r\n"
		keys := []string{}
		_ = keys
		if vv != nil && reflect.TypeOf(vv).String() != "string" {
			v := vv.(map[string]interface{})
			for key := range v {
				keys = append(keys, key)
			}
			sort.Strings(keys)
		}
		for _, val := range keys {
			if reflect.TypeOf(val).String() != "string" {
			} else {
				vd := vv.(map[string]interface{})[val]
				readme = readme + vd.(string) + "<br>"
			}
		}
	}
	top, err := os.Open("template/head.md")
	if err != nil {
		fmt.Println(err)
	}
	defer dataJson.Close()
	head_data, _ := ioutil.ReadAll(top)
	foot, err := os.Open("template/foot.md")
	if err != nil {
		fmt.Println(err)
	}
	defer dataJson.Close()
	foot_data, _ := ioutil.ReadAll(foot)
	readme = string(head_data) + readme + string(foot_data)
	fmt.Println("======================result====================")
	fmt.Println(readme)
}
