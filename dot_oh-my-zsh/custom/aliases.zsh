# Put files in this folder to add your own custom functionality.
# See: https://github.com/ohmyzsh/ohmyzsh/wiki/Customization
#
# Files in the custom/ directory will be:
# - loaded automatically by the init script, in alphabetical order
# - loaded last, after all built-ins in the lib/ directory, to override them
# - ignored by git by default
#
# Example: add custom/shortcuts.zsh for shortcuts to your local projects
#
# brainstormr=~/Projects/development/planetargon/brainstormr
# cd $brainstormr


# ----------------------
# Aliases - For a full list of active aliases, run `alias`.
# ----------------------
alias l="ls" # List files in current directory
alias o="open ." # Open the current directory in Finder
alias c="clear" # faster clearing
alias zshconfig="code ~/.zshrc"

# ----------------------
# Git Aliases
# ----------------------
alias gaa='git add .; echo "Files staged.";'
alias gcm='git commit -m'
alias gpsh='git push'
alias gss='git status -s'
alias gs='echo ""; echo "*********************************************"; echo -e "   DO NOT FORGET TO PULL BEFORE COMMITTING"; echo "*********************************************"; echo ""; git status'
alias gl='git log --oneline'

alias music='cd "$ICLOUD_DRIVE"/MUSIC'
# alias music="cd '/Users/devdogfish/Library/Mobile Documents/com~apple~CloudDocs'"



# ------------
# SSH Aliases
# ------------
alias ssh-devdogfish='eval "$(ssh-agent -s)"; ssh-add ~/.ssh/github_rsa_devdogfish; ssh-add -l;'
