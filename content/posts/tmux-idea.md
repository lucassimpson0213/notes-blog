+++
title = "A good tmux project idea"
date = "2026-02-19"
updated = "2022-05-01"
[taxonomies]
tags=["osdev"]

[extra]

comment = true
+++


# Session Problem
I have so many different tabs open and things that I work on and it's hard to keep track of them
I want to work on my homelab, which involves an ssh into a remote host, and it involves editing a local repo and
then pushing and pulling on the host.
I also work on Rust doing kernel work, or other projects.

## Tmuxp
   Tmuxp is a tmux manager that allows you to start tmux-sessions and windows by using a config file such as a json or a yaml config file


Here's an example:

```json
{
  "windows": [
    {
      "panes": [
        {
          "shell_command": [
            "cd /var/log",
            "ls -al | grep \\.log"
          ]
        },
        "echo hello",
        "echo hello",
        "echo hello"
      ],
      "shell_command_before": [
        "cd ~/"
      ],
      "layout": "tiled",
      "window_name": "dev window"
    }
  ],
  "session_name": "4-pane-split"
}
```


# The idea

I would love to define sessions using a json file that includes config info

```json{
  "name": "myproj",
  "windows": {
    "code": ["nvim .", "git status -sb"],
    "run": ["docker compose up", "docker compose logs -f"]
  }
}
```

```
This would allow me to get things up and moving faster if I start this in my zshrc file
