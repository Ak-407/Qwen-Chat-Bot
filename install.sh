#!/bin/bash

# Install Ollama (Replace with correct install URL if available)
echo "Installing Ollama..."
wget https://ollama.com/download --quiet --output-document=ollama-install.sh
chmod +x ollama-install.sh
./ollama-install.sh
