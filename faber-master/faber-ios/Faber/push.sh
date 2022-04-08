SCHEME="Faber-release"
IPA_NAME="$SCHEME.ipa"
PROJECT="Faber"

# Cleans the project
xcodebuild \
-workspace $PROJECT.xcworkspace \
-scheme $SCHEME \
-sdk iphoneos \
clean

# Builds the project with name $1
xcodebuild \
-workspace $PROJECT.xcworkspace \
-scheme $SCHEME \
-sdk iphoneos \
-archivePath $PWD/build/$PROJECT.xcarchive  \
ONLY_ACTIVE_ARCH=NO \
archive

# Removes the old IPA file if necessary
rm $PWD/$IPA_NAME

# Archives the build into an IPA file
xcodebuild \
-exportArchive \
-archivePath $PWD/build/$PROJECT.xcarchive \
-exportPath $PWD/ \
-exportOptionsPlist export.plist

# Removes the build directory
rm -rf $PWD/build

# Uploads IPA to Test Fairy
sh upload_test_fairy.sh $IPA_NAME $1

# Cleans up the IPA file
rm $IPA_NAME
