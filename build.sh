# This script should be run inside the Docker container.

set -euo pipefail

# Locales
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Paths
export GOOGLE_SERVICES_JSON="/config/google-services.json"
export ANDROID_HOME=/opt/android/sdk
export HOME=/home/circleci

# App config
export PACKAGE_ID=ch.coredump.chat
export SUPPLY_PACKAGE_NAME=$PACKAGE_ID
export MAIN_APP_IDENTIFIER=$PACKAGE_ID
export APP_NAME="Coredump Chat"

# Build config
export BUILD_FOR_RELEASE=true
export REPLACE_ASSETS=true
export BRANCH_TO_BUILD=integration
export COMMIT_CHANGES_TO_GIT=false
export RESET_GIT_BRANCH=false

# Extract build number
export MM_BUILD=$(cat android/app/build.gradle | grep "versionCode \([0-9]\{3,\}\)" | sed 's/[^0-9]//g')

# Gradle keystore setup
mkdir -p ~/.gradle
echo "MATTERMOST_RELEASE_STORE_FILE=/config/coredump-chat.jks" > ~/.gradle/gradle.properties
echo "MATTERMOST_RELEASE_KEY_ALIAS=coredumpchat" >> ~/.gradle/gradle.properties
cat /config/gradle.properties >> ~/.gradle/gradle.properties

# Install npm dependencies
npm install

# Revert any changes from previous builds
git checkout android/app/
git checkout package-lock.json

# Install fastlane dependencies
cd fastlane && bundle install && cd ..

# Update files related to push services
set -x
cp "$GOOGLE_SERVICES_JSON" android/app/google-services.json
PROJECT_NUMBER=$(grep '"project_number": "[0-9]*"' $GOOGLE_SERVICES_JSON | sed 's/.*"\([0-9]*\)".*/\1/')
sed -i 's/gcmSenderId" android:value="[0-9]*\\0"/gcmSenderId" android:value="'$PROJECT_NUMBER'\\0"/' android/app/src/main/AndroidManifest.xml
set +x

# Prepare
make pre-run

# Build
make build-android
echo "Built APKs:"
ls -lah *.apk
sudo cp "Coredump Chat.apk" "/out/Coredump Chat $MM_BUILD.apk"
