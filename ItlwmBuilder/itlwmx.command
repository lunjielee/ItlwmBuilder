#!/bin/bash

prompt() {
    dialogTitle="Intel Wi-Fi Drivers Builder"
    authPass=$(/usr/bin/osascript <<EOT
        tell application "System Events"
            activate
            repeat
                display dialog "This application requires administrator privileges. Please enter your administrator account password below to continue:" ¬
                    default answer "" ¬
                    with title "$dialogTitle" ¬
                    with hidden answer ¬
                    buttons {"Quit", "Continue"} default button 2
                if button returned of the result is "Quit" then
                    return 1
                    exit repeat
                else if the button returned of the result is "Continue" then
                    set pswd to text returned of the result
                    set usr to short user name of (system info)
                    try
                        do shell script "echo test" user name usr password pswd with administrator privileges
                        return pswd
                        exit repeat
                    end try
                end if
            end repeat
        end tell
    EOT
    )

    if [ "$authPass" == 1 ]
    then
        /bin/echo "User aborted. Exiting..."
        exit 0
    fi

    sudo () {
        /bin/echo $authPass | /usr/bin/sudo -S "$@"
    }
}

BUILD_DIR="${1}/itlwm_Clone"
FINAL_DIR="${2}/itlwmx_Completed"


builditlwm() {
  xcodebuild -scheme fw_genx -sdk macosx10.15 BUILD_DIR=${BUILD_DIR}/itlwm/build build >/dev/null || exit 1
  xcodebuild -scheme itlwmx -sdk macosx10.15 BUILD_DIR=${BUILD_DIR}/itlwm/build build >/dev/null || exit 1
}
buildheliport() {
  pod install >/dev/null || exit 1
  xcodebuild -workspace HeliPort.xcworkspace -scheme HeliPort BUILD_DIR=${BUILD_DIR}/HeliPort/build build >/dev/null || exit 1
}

copyBuildProducts() {
  cp -r "${BUILD_DIR}/itlwm/build/Debug/itlwmx.kext" "${FINAL_DIR}"
  cp -r "${BUILD_DIR}/HeliPort/build/Debug/HeliPort.app" "${FINAL_DIR}"
  echo "All Done!..."
}

PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

if [ ! -d "${BUILD_DIR}" ]; then
  mkdir -p "${BUILD_DIR}"
else
  rm -rf "${BUILD_DIR}/"
  mkdir -p "${BUILD_DIR}"
fi

cd "${BUILD_DIR}"

echo "Cloning itlwm repo..."
git clone https://github.com/OpenIntelWireless/itlwm.git >/dev/null || exit 1
cd "${BUILD_DIR}/itlwm"
echo "Compiling the latest commited Debug version of itlwmx..."
builditlwm
echo "itlwmx Debug Completed..."
echo""

cd "${BUILD_DIR}"

echo "Cloning HeliPort repo..."
git clone https://github.com/OpenIntelWireless/HeliPort.git >/dev/null || exit 1
cd "${BUILD_DIR}/HeliPort"
echo "Compiling the latest commited Debug version of HeliPort..."
buildheliport
echo " HeliPort Completed..."


if [ ! -d "${FINAL_DIR}" ]; then
  mkdir -p "${FINAL_DIR}"
  copyBuildProducts
#  rm -rf "${BUILD_DIR}/"
else
  rm -rf "${FINAL_DIR}"/*
  copyBuildProducts
#  rm -rf "${BUILD_DIR}/"
fi
