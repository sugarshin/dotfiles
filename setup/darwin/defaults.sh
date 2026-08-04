#!/bin/sh

set -eux

# Keyboard
defaults write -g com.apple.keyboard.fnState -bool true
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g AppleMiniaturizeOnDoubleClick -bool false

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 16
defaults write com.apple.dock orientation -string right

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write -g AppleShowAllExtensions -bool true
defaults write com.apple.finder FXPreferredViewStyle -string clmv

# Trackpad
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

# Hot corners: top-left = Desktop (4)
defaults write com.apple.dock wvous-tl-corner -int 4
defaults write com.apple.dock wvous-tl-modifier -int 0

# Chrome: tab navigation on Cmd+Ctrl+[ / ] (matches cmux worktree switching).
# Menu titles must match Chrome's ja UI exactly. Requires a Chrome restart.
# -string is required: defaults parses a bare @^] as plist syntax and errors out.
defaults write com.google.Chrome NSUserKeyEquivalents -dict-add "次のタブを選択" -string "@^]"
defaults write com.google.Chrome NSUserKeyEquivalents -dict-add "前のタブを選択" -string "@^["

# Chrome: vertical tabs on Cmd+Ctrl+E, matching cmux's toggleSidebar and neo-tree's
# <leader>e. The default Shift+Cmd+L never reaches the menu because extension commands take
# priority over menu accelerators (1Password "lock" on Default/Profile 1, Google Translate
# on Profile 8). Cmd+Ctrl+T was tried first but Google Meet binds it to "start presenting"
# and swallows the key on its own tab; Meet's shortcuts are hard-coded and cannot be
# disabled, so keep off its Cmd+Ctrl set (T/C/P/H/M/K/J).
defaults write com.google.Chrome NSUserKeyEquivalents -dict-add "垂直タブを閉じる" -string "@^e"

# Apply Dock/Finder changes
killall Dock
killall Finder
