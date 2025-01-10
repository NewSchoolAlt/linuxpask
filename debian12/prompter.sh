#!/bin/bash

# VERY WIP


# Ensure zsh is installed
if ! command -v zsh &> /dev/null; then
  echo "Zsh is not installed. Please install zsh first."
  exit 1
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Set the custom plugins directory
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# Function to clone a plugin if it doesn't already exist
clone_plugin() {
  local repo=$1
  local plugin_dir=$2
  if [ ! -d "$plugin_dir" ]; then
    echo "Installing $(basename $plugin_dir)..."
    git clone $repo $plugin_dir
  else
    echo "$(basename $plugin_dir) is already installed."
  fi
}

# Install plugins
clone_plugin https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use
clone_plugin https://github.com/jeffreytse/zsh-bat.git $ZSH_CUSTOM/plugins/zsh-bat
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
clone_plugin https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
clone_plugin https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete

# Update the plugins list in .zshrc
echo "Updating .zshrc with the new plugins..."
sed -i.bak '/^plugins=/ s/)/ you-should-use zsh-bat zsh-syntax-highlighting zsh-autosuggestions zsh-autocomplete)/' ~/.zshrc

# Source .zshrc to apply changes
echo "Applying changes..."
source ~/.zshrc

echo "All plugins have been installed and configured. UwU"
