# HACKING

## How to use, on a Linux machine

1. Get a fresh new WSL machine up:

   ```powershell
   # Delete old WSL
   wsl --unregister Ubuntu-24.04

   # Create new WSL
   wsl --install -d Ubuntu-24.04
   ```

1. Clone the repo, and open VSCode in it:

   ```bash
   cd ~/

   git config --global user.name "Raki Rahman"
   git config --global user.email "mdrakiburrahman@gmail.com"
   git clone https://github.com/mdrakiburrahman/deequ.git

   cd deequ/
   code .
   ```

1. Run the bootstrapper script, that installs all tools idempotently:

   ```bash
   GIT_ROOT=$(git rev-parse --show-toplevel)
   chmod +x ${GIT_ROOT}/contrib/bootstrap-dev-env.sh && ${GIT_ROOT}/contrib/bootstrap-dev-env.sh
   ```

Once Metals is installed, click:

```
Metals sidebar > Import build
```

## Build

```bash

# Test and Build
#
cd ${GIT_ROOT}
mvn clean verify
mvn clean compile

# Compile
#
COMMIT_HASH=$(git rev-parse --short HEAD)
mvn versions:set -DnewVersion=2.0.11.${COMMIT_HASH}-spark-3.4
mvn clean package -DskipTests

# Note that the code in this branch only works for Spark 3.X.
# To build for a different version of Spark, you must fork another branch.
```

## Publish

```bash
export MAVEN_REPO_ID="monitoring"
export MAVEN_REPO_USERNAME="msdata"
export PERSONAL_ACCESS_TOKEN="$(az account get-access-token --resource '499b84ac-1321-427f-aa17-267ca6975798' --query accessToken --output tsv --tenant '72f988bf-86f1-41af-91ab-2d7cd011db47')"

cp /home/boor/deequ/settings.xml ~/.m2/settings.xml

mvn deploy -DskipTests
```

## Lint

If scalastyle complains during `mvn clean verify`

```bash
error file=/home/boor/deequ/src/main/scala/com/amazon/deequ/dqdl/executors/UnsupportedRulesExecutor.scala message=Whitespace at end of line line=23 column=0
error file=/home/boor/deequ/src/main/scala/com/amazon/deequ/dqdl/executors/UnsupportedRulesExecutor.scala message=File must end with newline character
```

Fix the files like such:

```bash
changed_files=($(git status --porcelain | awk '{print $2}'))
for file in "${changed_files[@]}"; do
    sed -i -e 's/[[:space:]]*$//' -e '$a\' "$file"
done
```