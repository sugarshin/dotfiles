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

# Apply Dock/Finder changes
killall Dock
killall Finder
