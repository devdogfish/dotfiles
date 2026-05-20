# My Dotfiles

This repo stores my config files (VS Code, shell, scripts) and keeps them in
sync across my Mac and Windows machines using **chezmoi**.

---

## What chezmoi does (plain English)

chezmoi keeps one Git repo with all my config files in it. On any computer, it
takes the files from this repo and copies them to where they actually belong
(like `~/.zshrc` or the VS Code settings folder).

The key idea: **the repo holds the source, not the live files.** I never edit
`~/.zshrc` directly anymore. I edit the copy chezmoi keeps, then run a command
that writes it out to the real location.

How it handles Mac vs Windows differences:

- File names get prefixes that mean something. `dot_zshrc` becomes `~/.zshrc`.
  `private_` means restricted permissions. `executable_` means the file is
  made runnable.
- A file called `.chezmoiignore` lists which files to skip depending on the
  operating system. That's how my Mac ignores Windows files and vice versa.
- Shared content (like VS Code settings) lives once in a `.chezmoitemplates`
  folder. Both the Mac path and the Windows path just point at that one shared
  copy, so I only edit settings in one place.

Nothing is "compiled" inside the repo. The repo always holds the plain source.
The final, real files get generated on each machine when I run `chezmoi apply`.

---

## What's in this setup

| Thing | How it's handled |
|---|---|
| `.zshrc` | Shared `dot_zshrc`. At the bottom it loads `~/.zshrc_darwin` (Mac) or `~/.zshrc_windows` (Windows). Each holds OS-specific aliases, plain shell, no template code. |
| VS Code settings | Real content lives in `.chezmoitemplates/vscode-settings.json`. Mac and Windows each have a tiny file pointing at it. |
| VS Code keybindings | Same pattern as settings. |
| VS Code extensions | Listed in `dot_vscode-extensions.txt`. A `run_onchange_` script auto-installs them whenever that list changes. |
| `~/bin` scripts | Stored in `bin/`. Executable files keep their run permission. Nested `.git` folders are ignored. |
| Editor | `$EDITOR` set to `code --wait` in `.zshrc` so `chezmoi edit` opens VS Code and waits. |

The `.chezmoiignore` file makes sure each machine only applies its own paths:
Mac ignores `AppData/` and `.zshrc_windows`, Windows ignores `private_Library/`
and `.zshrc_darwin`.

---

## Daily use (either machine)

```bash
chezmoi edit ~/.zshrc       # edit the source (opens VS Code)
chezmoi apply               # write changes to the real file
chezmoi cd                  # jump into the repo
git add . && git commit -m "..." && git push
```

Edit shared VS Code settings directly:

```bash
chezmoi cd
code .chezmoitemplates/vscode-settings.json
chezmoi apply
```

Pull changes made on the other machine:

```bash
chezmoi update              # git pull + apply in one step
```

Preview before applying anything:

```bash
chezmoi diff
```

---

## First-time setup on a new Mac

```bash
brew install chezmoi
chezmoi init --apply git@github.com:devdogfish/dotfiles.git
```

## First-time setup on Windows (MSYS2)

See `windows-mysys2-chezmoi-setup.md` in this repo for the full step-by-step,
including the MSYS2 `HOME` fix and the offline backup (zip) method.

Short version:

```bash
echo $HOME                                  # must be /c/Users/devdogfish
pacman -S mingw-w64-x86_64-chezmoi          # or: sh -c "$(curl -fsLS get.chezmoi.io)"
chezmoi init --apply git@github.com:devdogfish/dotfiles.git
```

---

## Pull down just ONE file from the repo

To grab a single file from the repo without cloning everything (handy if a
proxy blocks Git, or you just want one file quickly), use curl on the raw URL:

```bash
curl -O https://raw.githubusercontent.com/devdogfish/dotfiles/main/windows-mysys2-chezmoi-setup.md
```

`-O` saves it with its original name in the current folder. Change the path at
the end to any file in the repo (e.g. `dot_zshrc`, `README.md`). Replace `devdogfish`
with your GitHub username and `main` with the branch if different.