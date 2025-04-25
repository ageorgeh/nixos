#!/bin/bash


# ~/.ssh/github_id

# Define the SSH key file path
SSH_KEY="$HOME/.ssh/github_id"

# Check if the SSH key already exists
if [ -f "$SSH_KEY" ]; then
  echo "SSH key already exists at $SSH_KEY. Skipping key generation."
else
  echo "SSH key not found. Generating a new SSH key for GitHub..."
  
  # Generate the SSH key
  ssh-keygen -t ed25519 -C "aghornung@gmail.com" -f "$SSH_KEY" -N ""

  echo "SSH key generated at $SSH_KEY."
  echo "Adding the SSH key to the ssh-agent..."
  
  # Start the ssh-agent and add the key
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY"
  
  echo "SSH key added to the ssh-agent."
  echo "Copy the following public key to your GitHub account:"
  cat "${SSH_KEY}.pub"
fi