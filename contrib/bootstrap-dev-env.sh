#!/bin/bash
#
#
#       Sets up a dev env with all pre-reqs. This script is idempotent, it will
#       only attempt to install dependencies, if not exists.   
#
# ---------------------------------------------------------------------------------------
#

set -e
set -m

echo ""
echo "┌────────────────────────────────────┐"
echo "│ Checking for language dependencies │"
echo "└────────────────────────────────────┘"
echo ""

sudo apt update

if java -version 2>&1 | grep -q "1.8.0"; then
    echo "Java 8 already installed"
else
    echo "Installing JDK 8"
    if [ ! -f /etc/apt/sources.list.d/corretto.list ]; then
        wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add -
        echo "deb https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list
        sudo apt update
    fi
    
    sudo apt install -y java-1.8.0-amazon-corretto-jdk
fi

if [ -z "$JAVA_HOME" ] || [ "$JAVA_HOME" != "/usr/lib/jvm/java-1.8.0-amazon-corretto" ]; then
    echo "Setting JAVA_HOME..."
    export JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto
    
    if ! grep -q "JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto" ~/.bashrc; then
        echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto' >> ~/.bashrc
    fi
else
    echo "JAVA_HOME already set correctly"
fi

if ! command -v mvn &> /dev/null; then
    echo "Installing Maven"
    sudo apt install -y maven
else
    echo "Maven is already installed"
fi

if [ ! -d ~/.m2/repository ]; then
    echo "Creating Maven cache directory"
    mkdir -p ~/.m2/repository
else
    echo "Maven cache directory already exists"
fi

echo ""
echo "┌───────────────────────────────┐"
echo "│ Installing VS Code extensions │"
echo "└───────────────────────────────┘"
echo ""

code --install-extension scalameta.metals@1.42.0
code --install-extension scala-lang.scala@0.5.8
code --install-extension vscjava.vscode-java-pack@0.29.0

echo ""
echo "┌──────────┐"
echo "│ Versions │"
echo "└──────────┘"
echo ""

echo "Java: $(java -version)"
echo "Maven: $(mvn -version)"