##### Core

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
	#if _wantDep 'firefox'
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


