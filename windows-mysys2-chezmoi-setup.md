# Windows (MSYS2) chezmoi Setup

Replace `YOU` with your GitHub username everywhere.

## Step 1 — Fix HOME (MSYS2-specific, do this FIRST)

In the MSYS2 shell:

```bash
echo $HOME
```

- If it shows `/c/Users/YOU` → skip to Step 2.
- If it shows `/home/YOU` → run this, then close and reopen MSYS2:

```bash
echo 'db_home: windows' >> /etc/nsswitch.conf
```

Reopen MSYS2 and confirm:

```bash
echo $HOME      # must now be /c/Users/YOU
```

This makes `~` point at your Windows profile so VS Code settings land in the real `%APPDATA%`.

## Step 2 — Install chezmoi

```bash
pacman -S mingw-w64-x86_64-chezmoi
```

If not found:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```

Verify:

```bash
chezmoi --version
```

## Step 3 — Pull and apply (primary path)

```bash
chezmoi init --apply git@github.com:YOU/dotfiles.git
```

No SSH key? Use HTTPS:

```bash
chezmoi init --apply https://github.com/YOU/dotfiles.git
```

This clones the full repo. `.chezmoiignore` auto-drops Mac files; only Windows
targets apply. VS Code settings/keybindings → `%APPDATA%\Code\User\`,
extensions install, shell config applies.

## Step 3b — Backup path (proxy blocks GitHub)

If Step 3 fails to pull:

1. In a browser, download:
   `https://github.com/YOU/dotfiles/archive/refs/heads/main.zip`
2. Unzip to Downloads.
3. Point chezmoi at the unzipped folder:

```bash
chezmoi init --source="/c/Users/YOU/Downloads/dotfiles-main"
chezmoi apply --source="/c/Users/YOU/Downloads/dotfiles-main" -v
```

Reconnect Git later when unblocked:

```bash
chezmoi cd
git remote add origin https://github.com/YOU/dotfiles.git
git fetch origin
git reset --hard origin/main
```

## Step 4 — Verify

```bash
chezmoi diff
chezmoi apply -v
ls -la "/c/Users/YOU/AppData/Roaming/Code/User/"
```

Confirm `settings.json` and `keybindings.json` are present there. Reload VS Code
window to pick them up.

## Step 5 — Windows-specific shell tweaks

```bash
chezmoi edit ~/.zshrc_windows      # plain shell, no templating
chezmoi apply
chezmoi cd
git add .
git commit -m "windows zshrc customizations"
git push
```

## Ongoing sync

```bash
chezmoi update      # git pull + apply (primary path only)
```

Backup path: re-download zip, re-run `chezmoi apply --source=...`.