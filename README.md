<h1 align="center">
  <i>everything</i>.fzf
</h1>

![everything.fzf](https://github.com/junegunn/i/blob/master/everything.fzf.jpg)

## What is this?

A personal collection of simple scripts that integrate _everything_ with fzf.

They are mostly opinionated, unpolished, unextendable, inconsistent, and
unconfigurable — just the way I like them. Only tested on my MacBook.
Keep that in mind.

Hope you find some ideas useful.

## How to use

Each script is self-contained and can be run directly and individually.
You can add the repository to your `$PATH`,

```sh
[[ $PATH =~ everything.fzf ]] || PATH="/path/to/everything.fzf:$PATH"
```

or copy/symlink only the ones you like.

## Prerequisites

The scripts are written in Bash and Ruby, so both are required.

Some scripts also depend on the following programs:

- bat
- chrome-cli
- figlet
- gh
- mise
- ripgrep

```sh
brew install bash ruby bat chrome-cli figlet gh mise ripgrep
```

## Scripts

### [_apps_](https://www.apple.com/macos)[.fzf](apps.fzf)

- Select macOS applications to open

### [_chrome_](https://www.google.com/chrome/)[.fzf](chrome.fzf)

- `chrome.fzf [t|h|b]`
  - `t` for open tabs (default; requires `chrome-cli`)
    - You can press `CTRL-W` to close a tab
  - `h` for history
  - `b` for bookmarks

### [_figlet_](http://www.figlet.org/)[.fzf](figlet.fzf)

- Type in text, select a font, preview the result, and press enter to copy it
  to the clipboard.

### [_gist_](https://gist.github.com/)[.fzf](gist.fzf)

- Press enter on a gist to edit it in your editor
- To access gists on GitHub Enterprise, set the `GH_HOST` environment variable
  ```sh
  alias giste.fzf='GH_HOST=git.evil.com gist.fzf'
  ```

### [_jira_](https://www.atlassian.com/software/jira)[.fzf](jira.fzf)

```
Usage: jira.fzf URL [JQL|PROJECT...]
    -u, --user={USER:PASSWORD,PAT}   User name and password (user:password) or PAT
    -q, --query=QUERY                Initial query
        --lines=NUM_LINES            Number of lines of description to show
        --limit=MAX_ITEMS            Maximum number of items to fetch
```

```sh
jira.fzf --limit 1000 --lines 10 https://issues.apache.org/jira \
    'creator = junegunn order by updated desc'
```

### [_kube_](https://kubernetes.io/)[.fzf](kube.fzf)

```
usage: kube.fzf [p|d|j|cj|sc|sn]
  p   list all pods
  d   list all deployments
  j   list all jobs
  cj  list all cronjobs
  sc  switch to a different context
  sn  switch to a different namespace
```

### [_maccy_](https://maccy.app/)[.fzf](maccy.fzf)

- You probably don't need this unless you really need to browse your clipboard
  history with more screen estate.
- You can press `CTRL-E` to edit the selected item in your editor

### [_mise_](https://mise.jdx.dev/)[.fzf](mise.fzf)

- First select a tool, then select a version of it to use it

### [_pr_](https://docs.github.com/en/pull-requests)[.fzf](pr.fzf)

- Browse and check out a GitHub pull request for the current repository
- Press `CTRL-V` to view the pull request in Vim
- Press `CTRL-O` to open the pull request in your browser

### [_pr-by_](https://docs.github.com/en/pull-requests)[.fzf](pr-by.fzf)

- Search GitHub pull requests by a specific user across all repositories
- Press `CTRL-V` to view the pull request in Vim
- Press `CTRL-O` to open the pull request in your browser

```sh
# usage: pr-by.fzf [--limit=N] <author> [fzf-args]
pr-by.fzf junegunn
```

### [_rg_](https://github.com/BurntSushi/ripgrep)[.fzf](rg.fzf)

- See https://junegunn.github.io/fzf/tips/ripgrep-integration/

### [_gproj_](gproj.fzf)

- Pick Git repository roots discovered under configurable search roots and open them with `fzf`.
- **Optimized for speed**: ~1.2s first run, ~15ms with cache (see [PERFORMANCE.md](PERFORMANCE.md))
- **Requires tmux** for `cd` integration (prints path otherwise)
- Prerequisites: `git`, `fzf`, `tmux` (recommended: `fd` for 8x faster scanning)
- Configuration:
  - `EVERYTHING_FZF_ROOTS` — search roots (default: `~/AgodaGit:~/Personal:~/.local/share/opencode/worktree`)
  - `EVERYTHING_FZF_IGNORES` — paths to exclude (default: `.ssh`, `Downloads`, `OrbStack`, `node_modules`, etc.)
  - `GPROJ_MAX_DEPTH=N` — max search depth (default: 5, lower = faster)
  - `GPROJ_CACHE=0` — disable result caching (default: enabled, 30min TTL)
  - `GPROJ_DEBUG=1` — show timing breakdown
  - `GPROJ_NVIM_CONFIG_HOME` — override Neovim profile config home (default: `$XDG_CONFIG_HOME` or `~/dotfiles/.config`)
- Keybindings (in tmux):
  - `ENTER` — cd to selected path
  - `CTRL-V` — cd and open in nvim
  - `ALT-V` — choose a Neovim profile (via `NVIM_APPNAME`), then open selected path
  - `CTRL-E` — cd and open in VSCode
  - `CTRL-O` — print path without cd
- Example:

```sh
# In tmux - interactive selection with cd support
gproj

# Outside tmux - just prints path
cd "$(gproj)"

# Debug mode to see performance
GPROJ_DEBUG=1 gproj

# Faster scan (less depth)
GPROJ_MAX_DEPTH=3 gproj

# Custom roots
EVERYTHING_FZF_ROOTS=~/projects gproj

# Interactive testing
./tests/tmux-test-gproj.sh
```

#### Related ref

- https://deepwiki.com/search/how-to-by-pass-the-error-messa_173b0074-6697-42e9-a15b-9de95663a1bc?mode=fast
-

Does -H flag cause slowness ?

```sh
# use hacky glob prefix [. ] to prevent error like [fd error]: The pattern seems to only match files with a leading dot, but hidden...

# seems like this hacky -H does not really save lots of time

time fd -g '[. ]git' -t d ~/AgodaGit --ignore-file <(echo '!.git/')
# ~4s

time fd -H -g '\.git' -t d ~/AgodaGit
# ~5s
```

### [_ssh_](https://en.wikipedia.org/wiki/Secure_Shell)[.fzf](ssh.fzf)

- Select known hosts to open SSH connections to them in a tiled tmux split
  panes

### [_wiki_](https://www.atlassian.com/software/confluence)[.fzf](wiki.fzf)

- Browse recently viewed and modified pages in Confluence wiki
  ```
  Usage: wiki.fzf URL
      -u, --user={USER:PASSWORD,PAT}   User name and password (user:password) or PAT
  ```

## What else?

- https://github.com/junegunn/fzf-git.sh
- https://github.com/junegunn/tmux-fzf-url
- https://github.com/junegunn/tmux-fzf-maccy

## LICENSE

MIT
