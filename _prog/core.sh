##### Core

_flag_localURL() {
	local flagLocalURL
	flagLocalURL="false"
	
	_messagePlain_probe 'checking: flagLocalURL'
	
	echo "$1" | grep "^./" >/dev/null 2>&1 && flagLocalURL="true" && _messagePlain_good 'accept: flagLocalURL'
	echo "$1" | grep "^/" >/dev/null 2>&1 && flagLocalURL="true" && _messagePlain_good 'accept: flagLocalURL'
	echo "$1" | grep "^file:///" >/dev/null 2>&1 && flagLocalURL="true" && _messagePlain_good 'accept: flagLocalURL'
	
	echo "$@" | grep 'http\:\/\/' >/dev/null 2>&1 && flagLocalURL="false" && _messagePlain_warn 'reject: flagLocalURL'
	echo "$@" | grep 'https\:\/\/' >/dev/null 2>&1 && flagLocalURL="false" && _messagePlain_warn 'reject: flagLocalURL'
	
	#Local files may open in a temporary browser instance.
	[[ "$flagLocalURL" == "true" ]] && return 0
 	[[ "$flagLocalURL" != "true" ]] && return 1
}

_firefox_command() {
	if [[ -e "$scriptAbsoluteFolder"/_local/setups/firefox/firefox/firefox ]]
	then
		_messageNormal 'Launch: _local/firefox'
		_messagePlain_probe "$scriptAbsoluteFolder"/_local/setups/firefox/firefox/firefox "$@"
		"$scriptAbsoluteFolder"/_local/setups/firefox/firefox/firefox "$@"
		return 0
	fi
	
	local firefoxVersion
	if firefoxVersion=$(firefox --version | sed 's/Mozilla\ Firefox\ //g' | cut -d\. -f1)
	#if which 'firefox'
	#if _wantDep 'firefox'efox/active-update.xml
        modified:   _local/setups/firefox/firefox/application.ini
        modified:   _local/setups/firefox/firefox/browser/blocklist.xml
        deleted:    _local/setups/firefox/firefox/browser/extensions/{972ce4c6-7e08-4474-a285-3208198ce6fd}.xpi
        modified:   _local/setups/firefox/firefox/browser/features/activity-stream@mozilla.org.xpi
        modified:   _local/setups/firefox/firefox/browser/features/aushelper@mozilla.org.xpi
        modified:   _local/setups/firefox/firefox/browser/features/firefox@getpocket.com.xpi
        modified:   _local/setups/firefox/firefox/browser/features/followonsearch@mozilla.com.xpi
        modified:   _local/setups/firefox/firefox/browser/features/formautofill@mozilla.org.xpi
        modified:   _local/setups/firefox/firefox/browser/features/onboarding@mozilla.org.xpi
        modified:   _local/setups/firefox/firefox/browser/features/screenshots@mozilla.org.xpi
        modified:   _local/setups/firefox/firefox/browser/features/webcompat@mozilla.
	#if false
	then
		if [[ "$firefoxVersion" -ge "59" ]]
		then
			_messageNormal 'Launch: firefox'
			_messagePlain_probe firefox "$@"
			firefox "$@"
			return 0
		fi
	fi
	
	#if which 'firefox_quantum'
	#if _wantDep 'firefox_quantum'
	if false
	then
		_messageNormal 'Launch: firefox_quantum'
		_messagePlain_probe firefox_quantum "$@"
		firefox_quantum "$@"
		return 0
	fi
	
	return 1
}

_firefox_editHome_multitasking() {
	if _flag_localURL "$@"
	then
		_firefox_esr_userHome "$@"
		return
	fi
	
	"$scriptAbsoluteLocation" _editFakeHome "$scriptAbsoluteLocation" "_firefox_command" "$@"
}

# ATTENTION
# Override with "ops", point to "_firefox_editHome_multitasking", to allow "remote" instances of firefox for the user/machine global profile.
_firefox_editHome() {
	# TODO: Ideally, there should be an automatic check to determine whether a compatible firefox instance already existed, allowing "-no-remote" to be dropped.
	"$scriptAbsoluteLocation" _editFakeHome "$scriptAbsoluteLocation" "_firefox_command" -no-remote "$@"
}

_firefox_userHome() {
	#Always use "-no-remote".
	"$scriptAbsoluteLocation" _userFakeHome "$scriptAbsoluteLocation" "_firefox_command" -no-remote "$@"
}

_v_firefox() {
	_userQemu "$scriptAbsoluteLocation" _firefox_userHome "$@"
}

_firefox() {
	#_firefox_editHome "$@" && return 0
	_firefox_userHome "$@" && return 0
	
	_messageNormal 'Launch: _v_firefox'
	_v_firefox "$@"
}

_firefox_esr_command() {
	if [[ -e "$scriptAbsoluteFolder"/_local/setups/firefox-esr/firefox/firefox ]]
	then
		_messageNormal 'Launch: _local/firefox-esr'
		_messagePlain_probe "$scriptAbsoluteFolder"/_local/setups/firefox-esr/firefox/firefox "$@"
		"$scriptAbsoluteFolder"/_local/setups/firefox-esr/firefox/firefox "$@"
		return 0
	fi
	
	local firefoxVersion
	if firefoxVersion=$(firefox-esr --version | sed 's/Mozilla\ Firefox\ //g' | cut -d\. -f1)
	#if which 'firefox'
	#if _wantDep 'firefox'
	#if false
	then
		if [[ "$firefoxVersion" -ge "52" ]]
		then
			_messageNormal 'Launch: firefox-esr'
			_messagePlain_probe firefox-esr "$@"
			firefox-esr "$@"
			return 0
		fi
	fi
	
	#if which 'firefox-esr'
	#if _wantDep 'firefox-esr'
	if false
	then
		_messageNormal 'Launch: firefox-esr'
		_messagePlain_probe firefox-esr "$@"
		firefox-esr "$@"
		return 0
	fi
	
	return 1
}

_firefox_esr_editHome_multitasking() {
	export globalFakeHome="$scriptLocal"/h_esr
	export actualFakeHome="$scriptLocal"/h_esr
	export fakeHomeEditLib="false"
	#export keepFakeHome="false"
	_fakeHome "$scriptAbsoluteLocation" "_firefox_esr_command" "$@"
}

# ATTENTION
# Override with "ops", point to "_firefox_editHome_multitasking", to allow "remote" instances of firefox for the user/machine global profile.
_firefox_esr_editHome() {
	# TODO: Ideally, there should be an automatic check to determine whether a *compatible* firefox instance already existed, allowing "-no-remote" to be dropped.
	export globalFakeHome="$scriptLocal"/h_esr
	export actualFakeHome="$scriptLocal"/h_esr
	export fakeHomeEditLib="false"
	#export keepFakeHome="false"
	_fakeHome "$scriptAbsoluteLocation" "_firefox_esr_command" -no-remote "$@"
}

_firefox_esr_userHome() {
	export globalFakeHome="$scriptLocal"/h_esr
	export actualFakeHome="$instancedFakeHome"
	export fakeHomeEditLib="false"
	#export keepFakeHome="false"
	_fakeHome "$scriptAbsoluteLocation" "_firefox_esr_command" -no-remote "$@"
}

_v_firefox_esr() {
	_userQemu "$scriptAbsoluteLocation" _firefox_esr_userHome "$@"
}

_firefox_esr() {
	#_firefox_editHome "$@" && return 0
	_firefox_esr_userHome "$@" && return 0
	
	_messageNormal 'Launch: _v_firefox_esr'
	_v_firefox_esr "$@"
}

_chromium_command() {
	if _wantDep 'chromium'
	then
		_messageNormal 'Launch: chromium'
		_messagePlain_probe chromium "$@"
		chromium "$@"
		
		return 0
	fi
	
	return 1
}

_chromium_editHome() {
	"$scriptAbsoluteLocation" _editFakeHome "$scriptAbsoluteLocation" "_chromium_command" "$@"
}

_chromium_userHome() {
	#Should not be needed with Chromium.
	"$scriptAbsoluteLocation" _userFakeHome "$scriptAbsoluteLocation" "_chromium_command" "$@"
}

_v_chromium() {
	_userQemu "$scriptAbsoluteLocation" _chromium_editHome "$@"
}

_chromium() {
	_chromium_editHome "$@" && return 0
	#_chromium_userHome "$@" && return 0
	
	_messageNormal 'Launch: _v_chromium'
	_v_chromium "$@"
}

_webClient() {
	_launch "$@"
}

_refresh_anchors() {
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_webClient
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_firefox
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_firefox_editHome
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_firefox_editHome_multitasking
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_v_firefox
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_firefox_esr
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_firefox_esr_editHome
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_v_firefox
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_chromium
}
