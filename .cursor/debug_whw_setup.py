#!/usr/bin/env python3
"""Probe: why WHW deploy / AGENTS.md workflow fails in this environment."""
import json
import os
import shutil
import time
from pathlib import Path

LOG = Path("/home/suaveseb/WebHackersWeapons/.cursor/debug-6fc605.log")
REPO = Path("/home/suaveseb/WebHackersWeapons")


def dbg(hypothesis_id, location, message, data):
    # #region agent log
    payload = {
        "sessionId": "6fc605",
        "runId": "run1",
        "hypothesisId": hypothesis_id,
        "location": location,
        "message": message,
        "data": data,
        "timestamp": int(time.time() * 1000),
    }
    LOG.parent.mkdir(parents=True, exist_ok=True)
    with LOG.open("a", encoding="utf-8") as f:
        f.write(json.dumps(payload) + "\n")
    # #endregion


def main():
    agents = (REPO / "AGENTS.md").read_text(encoding="utf-8") if (REPO / "AGENTS.md").exists() else ""
    deploy_verbs = ["deploy --core", "whw_deploy", "nuclei", "ffuf", "install tools"]
    dbg(
        "A",
        "debug_whw_setup.py:agents_md",
        "Repo AGENTS.md purpose check",
        {
            "exists": (REPO / "AGENTS.md").exists(),
            "mentions_erb": "erb.rb" in agents,
            "mentions_deploy_core": any(v in agents.lower() for v in [x.lower() for x in deploy_verbs]),
            "first_heading": agents.splitlines()[0] if agents else None,
            "snippet": agents[:240],
        },
    )

    workdir = Path("/home/workdir")
    dbg(
        "B",
        "debug_whw_setup.py:workdir",
        "Grok workdir path check",
        {
            "home_workdir_exists": workdir.exists(),
            "cwd": os.getcwd(),
            "home": str(Path.home()),
        },
    )

    script = Path("/home/workdir/.grok/skills/whw-deploy/scripts/whw_deploy.py")
    user_skill = Path.home() / ".grok/skills/whw-deploy/scripts/whw_deploy.py"
    win_skill = Path("/mnt/c/Users/sebas/.grok/skills/whw-deploy/scripts/whw_deploy.py")
    dbg(
        "C",
        "debug_whw_setup.py:skill",
        "whw-deploy skill presence",
        {
            "grok_workdir_script": str(script),
            "grok_workdir_exists": script.exists(),
            "linux_user_skill_exists": user_skill.exists(),
            "windows_user_skill_exists": win_skill.exists(),
        },
    )

    agents_cursor = Path("/home/workdir/.grok/whw/AGENTS.cursor.md")
    dbg(
        "D",
        "debug_whw_setup.py:agents_cursor",
        "Generated Cursor AGENTS.md source check",
        {
            "agents_cursor_exists": agents_cursor.exists(),
            "repo_agents_is_upstream_catalog": "erb.rb" in agents and "409+" in agents,
        },
    )

    go = shutil.which("go")
    git = shutil.which("git")
    tools = {name: shutil.which(name) for name in ("nuclei", "httpx", "ffuf", "gobuster", "dalfox", "subfinder")}
    dbg(
        "E",
        "debug_whw_setup.py:toolchain",
        "git/go/core CLI PATH check",
        {
            "git": git,
            "go": go,
            "go_bin_home": str(Path.home() / "go/bin"),
            "go_bin_home_exists": (Path.home() / "go/bin").exists(),
            "tools": tools,
        },
    )


if __name__ == "__main__":
    main()
    print("wrote", LOG)
