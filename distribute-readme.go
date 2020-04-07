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

type mmm = map[string]interface{}

func mergeKeys(left, right mmm) mmm {
	for key, rightVal := range right {
		if leftVal, present := left[key]; present {
			//then we don't want to replace it - recurse
			left[key] = mergeKeys(leftVal.(mmm), rightVal.(mmm))
		} else {
			// key not in left so we can just shove it in
			left[key] = rightVal
		}
	}
	return left
}

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
		//m[string(line)] = ""
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
		mt := myMap["Method"].(string)
		_ = d
		_ = mt
		tool := make(map[string]interface{})
		tool[k] = d
		fmt.Println(m[t+"/"+mt])
		//fmt.Println(reflect.TypeOf(m[t+"/"+mt]).String())
		//if reflect.TypeOf(m[t+"/"+mt]).String() == "string" {
		if m[t+"/"+mt] == nil {
			m[t+"/"+mt] = tool
		} else {
			tool = mergeKeys(tool, m[t+"/"+mt].(map[string]interface{}))
			//fmt.Println(tool)
			m[t+"/"+mt] = tool
		}
	}
	readme := "| Type | Name | Description | Popularity | Language |\r\n| ---------- | :---------- | :----------: | :----------: | :----------: | \r\n"

	keys := []string{}
	for key := range m {
		keys = append(keys, key)
	}
	sort.Strings(keys)

	for _, dat := range keys {
		vv := m[dat]
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
				readme = readme + vd.(string) + "\r\n"
			}
		}
	}
	fmt.Println(readme)
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
	//fmt.Println(readme)

	file, err := os.OpenFile(
		"README.md",
		os.O_CREATE|os.O_RDWR|os.O_TRUNC,

		os.FileMode(0644))
	if err != nil {
		fmt.Println(err)
		return
	}
	defer file.Close()
	_, err = file.Write([]byte(readme))
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println("[+] Patched README.md file")
	fmt.Println("[+] Please check README file and git push")
	fmt.Println("[ copy/paste this ] git add data.json README.md ; git commit -m 'distribute readme'; git push -u origin master")
}
