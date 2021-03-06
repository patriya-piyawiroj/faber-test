#Test Fairy Upload
UPLOADER_VERSION=2.1
TESTFAIRY_API_KEY="921b5a44536313d611b77b4c6c4baaff039dac6c"

VINCENT_TEST_GROUP="faber_vincent"
ALL_TEST_GROUP="faber_dogfooders"

# Should email testers about new version. Set to "off" to disable email notifications.
NOTIFY="on"

# If AUTO_UPDATE is "on" all users will be prompt to update to this build next time they run the app
AUTO_UPDATE="on"

# The maximum recording duration for every test. 
MAX_DURATION="10m"

# Is video recording enabled for this build. valid values:  "on", "off", "wifi" 
VIDEO="on"

# Comment text will be included in the email sent to testers
COMMENT=""

# locations of various tools
CURL=curl

SERVER_ENDPOINT=http://app.testfairy.com

usage() {
	echo "Usage: testfairy-upload-ios.sh APP_FILENAME"
	echo
}
	
verify_tools() {
	# Check 'curl' tool
	"${CURL}" --help >/dev/null
	if [ $? -ne 0 ]; then
		echo "Could not run curl tool, please check settings"
		exit 1
	fi
}

verify_settings() {
	if [ -z "${TESTFAIRY_API_KEY}" ]; then
		usage
		echo "Please update API_KEY with your private API key, as noted in the Settings page"
		exit 1
	fi
}

# Before even going on, make sure all tools work
verify_tools
verify_settings

APP_FILENAME=$1
if [ ! -f "${APP_FILENAME}" ]; then
	usage
	echo "Can't find file: ${APP_FILENAME}"
	exit 2
fi

TESTER_GROUPS=""
if [ "$2" = "vincent" ]; then
    TESTER_GROUPS=VINCENT_TEST_GROUP
elif [ "$2" = "dogfooders" ]; then
    TESTER_GROUPS=ALL_TEST_GROUP
else
    echo "Invalid command."
fi

# Temporary file paths
DATE=`date`

/bin/echo -n "Uploading ${APP_FILENAME} to TestFairy.. "
JSON=$( "${CURL}" -s ${SERVER_ENDPOINT}/api/upload -F api_key=${TESTFAIRY_API_KEY} -F file="@${APP_FILENAME}" -F video="${VIDEO}" -F max-duration="${MAX_DURATION}" -F comment="${COMMENT}" -F testers-groups="${TESTER_GROUPS}" -F auto-update="${AUTO_UPDATE}" -F notify="${NOTIFY}" -F instrumentation="off" -A "TestFairy iOS Command Line Uploader ${UPLOADER_VERSION}" )

URL=$( echo ${JSON} | sed 's/\\\//\//g' | sed -n 's/.*"build_url"\s*:\s*"\([^"]*\)".*/\1/p' )
if [ -z "$URL" ]; then
	echo "FAILED!"
	echo
	echo "Build uploaded, but no reply from server. Please contact support@testfairy.com"
	exit 1
fi

echo "OK!"
echo
echo "Build was successfully uploaded to TestFairy and is available at:"
echo ${URL}
