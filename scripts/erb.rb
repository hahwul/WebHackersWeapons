require 'erb'

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
    - Tools
    - [Bookmarklets](https://github.com/hahwul/WebHackersWeapons/tree/master/Bookmarklets)
    - [Browser Extensions](https://github.com/hahwul/WebHackersWeapons/tree/master/Browser%20Extensions)
    - [Burp and ZAP Extensions](https://github.com/hahwul/WebHackersWeapons/tree/master/Burp%20and%20ZAP%20Extensions)
- [Contribute](https://github.com/hahwul/WebHackersWeapons/blob/master/CONTRIBUTING.md) 
- [Thanks to contributor](#thanks-to-contributor)

## Weapons
### Tools
<%= tools %>

### Bookmarklets
<%= bookmarklets %>

### Browser Addons
<%= browser_addons %>

### Burpsuite and ZAP Addons
<%= burpzap_addons %>

## Thanks to (Contributor)
I would like to thank everyone who helped with this project 👍😎 
![](/CONTRIBUTORS.svg)

}.gsub(/^  /, '')
tools = 4414
bookmarklets = 111
browser_addons = 111
burpzap_addons = 111

markdown = ERB.new(template, trim_mode: "%<>")
puts markdown.result