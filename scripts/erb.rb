require 'erb'
require 'yaml'

def generate_badge array
    badge = ""
    array.each { |t|
        case t
        when 'linux'
            badge = badge + "![linux](./images/linux.png)"
        when 'windows'
            badge = badge + "![windows](./images/windows.png)"
        when 'macos'
            badge = badge + "![macos](./images/apple.png)"
        when 'firefox'
            badge = badge + "![firefox](./images/firefox.png)"
        when 'safari'
            badge = badge + "![safari](./images/safari.png)"
        when 'chrome'
            badge = badge + "![chrome](./images/chrome.png)"
        when 'burpsuite'
            badge = badge + "![burp](./images/burp.png)"
        when 'zap'
            badge = badge + "![zap](./images/zap.png)"
        end
    }
    
    return badge
end

template = %q{
<h1 align="center">
<br>
<a href=""><img src="https://user-images.githubusercontent.com/13212227/104400969-9f3d9280-5596-11eb-80f4-864effae95fc.png" alt="" width="500px;"></a>
<br>
<img src="https://img.shields.io/github/last-commit/hahwul/WebHackersWeapons?style=flat"> 
<img src="https://img.shields.io/badge/PRs-welcome-cyan">
<img src="https://github.com/hahwul/WebHackersWeapons/workflows/Build/badge.svg">
<a href="https://twitter.com/intent/follow?screen_name=hahwul"><img src="https://img.shields.io/twitter/follow/hahwul?style=flat&logo=twitter"></a>
</h1>
A collection of awesome tools used by Web hackers. Happy hacking , Happy bug-hunting

## Family project
[![WebHackersWeapons](https://img.shields.io/github/stars/hahwul/WebHackersWeapons?label=WebHackersWeapons)](https://github.com/hahwul/WebHackersWeapons)
[![MobileHackersWeapons](https://img.shields.io/github/stars/hahwul/MobileHackersWeapons?label=MobileHackersWeapons)](https://github.com/hahwul/MobileHackersWeapons)

## Table of Contents
- [Weapons](#weapons)
    - [Tools](#tools)
    - [Bookmarklets](#bookmarklets)
    - [Browser Addons](#browser-addons)
    - [Burp and ZAP Addons](#burpsuite-and-zap-addons)
- [Contribute](CONTRIBUTING.md) 
- [Thanks to contributor](#thanks-to-contributor)

## Weapons
- OS: Linux(![](./images/linux.png)) macOS(![](./images/apple.png)) Windows(![](./images/windows.png)) 
- Browser-Addon: Firefox(![](./images/firefox.png)) Safari(![](./images/safari.png)) Chrome(![](./images/chrome.png)) 
- Tool-Addon: ZAP(![](./images/zap.png)) BurpSuite(![](./images/burp.png))   

### Tools
<%= tools %>

### Bookmarklets
<%= bookmarklets %>

### Browser Addons
<%= browser_addons %>

### Burpsuite and ZAP Addons
<%= tool_addons %>

## Thanks to (Contributor)
I would like to thank everyone who helped with this project 👍😎 
![](/images/CONTRIBUTORS.svg)

}.gsub(/^  /, '')

head = "| Type | Name | Description | Badges | Popularity |\n"
head = head + "| --- | --- | --- | --- | --- |"
tools = head + "\n"
bookmarklets = head + "\n"
browser_addons = head + "\n"
tool_addons = head + "\n"

Dir.entries("./weapons/").each do | name |
    if name != '.' && name != '..'
        begin
            data = YAML.load(File.open("./weapons/#{name}"))
            name = data['name']
            popularity = "x"

            if data['url'].length > 0 
                name = "[#{name}](#{data['url']})"
            end

            if data['url'].include? "github.com"
                split_result = data['url'].split "//github.com/"
                popularity = "![](https://img.shields.io/github/stars/#{split_result[1]})"
            end
            badge = generate_badge(data['platform'])
            line = "|#{data['type']}|#{name}|#{data['description']}|#{badge}|#{popularity}|"
            case data['category'] 
            when 'tool'
                tools = tools + line + "\n"
            when 'tool-addon'
                tool_addons = tool_addons + line + "\n"
            when 'browser-addon'
                browser_addons = browser_addons + line + "\n"
            when 'bookmarklet'
                bookmarklets = bookmarklets + line + "\n"
            else
                puts name
            end
        rescue => e 
            puts e
        end
    end
end

markdown = ERB.new(template, trim_mode: "%<>")
#puts markdown.result
File.write './README.md', markdown.result