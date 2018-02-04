set -euo pipefail

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Paths
export GOOGLE_SERVICES_JSON="/home/danilo/Projects/coredump/googleplay/google-services.json"
export ANDROID_HOME=/mnt/data2/android-sdk
export PATH=$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:/home/danilo/Projects/mattermost-mobile/fastlane/vendor/bundle/ruby/2.5.0/bin/:$PATH

# App config
export ANDROID_PACKAGE_ID=ch.coredump.chat
export SUPPLY_PACKAGE_NAME=$ANDROID_PACKAGE_ID
export ANDROID_APP_NAME="Coredump Chat"

# Build config
export ANDROID_BUILD_FOR_RELEASE=true
export ANDROID_REPLACE_ASSETS=true

# Revert any changes from previous builds
git checkout android/app/

# Update files related to push services
set -x
cp "$GOOGLE_SERVICES_JSON" android/app/google-services.json
PROJECT_NUMBER=$(grep '"project_number": "[0-9]*"' $GOOGLE_SERVICES_JSON | sed 's/.*"\([0-9]*\)".*/\1/')
sed -i 's/gcmSenderId" android:value="[0-9]*\\0"/gcmSenderId" android:value="'$PROJECT_NUMBER'\\0"/' android/app/src/main/AndroidManifest.xml
set +x

make pre-run
make build-android
