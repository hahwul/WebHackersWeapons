+++
title = "Proxy Tools"
description = "Intercepting proxies used to inspect, modify, and replay HTTP(S) traffic during web application testing."
weight = 1
+++

Intercepting proxies sit between your browser (or client) and the target server so you can **pause, inspect, edit, and replay** every request. They are the single most important class of tool for hands-on web application testing — every other technique (auth bypass, IDOR, SSRF, injection) is delivered through one of these.

## The heavyweights

**Burp Suite** and **ZAP** are the industry defaults. Burp has the deeper ecosystem (BApp Store, Turbo Intruder, Collaborator) and a free Community edition with throttled scanning. ZAP is fully open-source and ships with an automation API that integrates cleanly into CI.

{{ weapons("burpsuite", "zap") }}

## Modern alternatives

These challengers focus on developer ergonomics, scriptability, and speed. Caido and Hetty lean into a Go/Rust implementation with HTTP/2-first design; mitmproxy gives you a Python scripting surface that is unmatched for automation.

{{ weapons("caido", "hetty", "mitmproxy", "proxify") }}

## Specialized proxies

Lower-level or single-purpose tools that complement the mainline proxies — typically pulled in when you need a specific behavior (custom rendering, browser-integrated workflows, or a stripped-down REPL proxy).

{{ weapons("glorp", "rep") }}

## When to reach for which

- **Bug bounty / engagement with a heavy extension workflow** — Burp Suite Pro.
- **OSS-only, CI/CD automation, broad license compatibility** — ZAP.
- **Teams / collaborative sessions / modern UI** — Caido.
- **Scripted traffic rewriting, programmatic MITM** — mitmproxy.
- **Fast CLI pipeline processing (probe, rewrite, persist)** — proxify.
