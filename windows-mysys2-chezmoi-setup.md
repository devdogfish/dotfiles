# Windows VS Code — verify / fix chezmoi-managed files

Run these on the **Windows MSYS2 shell**, in order. Stop if anything looks off.

## 1. See what chezmoi thinks it manages

```bash
chezmoi managed | grep -i code
```

**Expected**: two lines ending in `keybindings.json` and `settings.json` under `AppData/Roaming/Code/User/`.
**If empty**: the Windows stubs don't exist in the repo → skip to step 5.

## 2. See what's actually on disk

```bash
ls -la "$HOME/AppData/Roaming/Code/User/"
```

**Expected**: `keybindings.json` and `settings.json` present.

## 3. Confirm they match the repo

```bash
chezmoi diff
```

**Expected**: empty (no diff). Anything printed = drift between repo and live files.

## 4. Force re-apply if drift exists

```bash
chezmoi apply -v
```

Verbose; prints every file it writes. Then re-run step 3 — should now be empty.

## 5. If step 1 was empty — add the missing Windows stubs

This is the "repo is incomplete" case. From either machine:

```bash
chezmoi cd
mkdir -p "AppData/Roaming/Code/User"
printf '{{ template "vscode-keybindings.json" . }}\n' > "AppData/Roaming/Code/User/keybindings.json.tmpl"
printf '{{ template "vscode-settings.json" . }}\n'    > "AppData/Roaming/Code/User/settings.json.tmpl"
git add AppData
git commit -m "add Windows VS Code stubs"
git push
```

Then on Windows:

```bash
chezmoi update    # pull + apply
```

Re-run steps 1–3 to verify.

## 6. Reload VS Code

Cmd/Ctrl+Shift+P → "Developer: Reload Window" so VS Code re-reads the files.
