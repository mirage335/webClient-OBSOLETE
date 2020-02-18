#!/usr/bin/env bash

#Universal debugging filesystem.
_user_log-ub() {
	# DANGER Do NOT create automatically, or reference any existing directory!
	! [[ -d "$HOME"/.ubcore/userlog ]] && cat - > /dev/null 2>&1 && return 0
	
	#Terminal session may be used - the sessionid may be set through .bashrc/.ubcorerc .
	if [[ "$sessionid" != "" ]]
	then
		cat - >> "$HOME"/.ubcore/userlog/u-"$sessionid".log
		return 0
	fi
	cat - >> "$HOME"/.ubcore/userlog/u-undef.log
	
	return 0
}

#Cyan. Harmless status messages.
_messagePlain_nominal() {
	echo -e -n '\E[0;36m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Blue. Diagnostic instrumentation.
_messagePlain_probe() {
	echo -e -n '\E[0;34m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Blue. Diagnostic instrumentation.
_messagePlain_probe_expr() {
	echo -e -n '\E[0;34m '
	echo -e -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Blue. Diagnostic instrumentation.
_messagePlain_probe_var() {
	echo -e -n '\E[0;34m '
	
	echo -n "$1"'= '
	
	eval echo -e -n \$"$1"
	
	echo -e -n ' \E[0m'
	echo
	return 0
}
_messageVar() {
	_messagePlain_probe_var "$@"
}

#Green. Working as expected.
_messagePlain_good() {
	echo -e -n '\E[0;32m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Yellow. May or may not be a problem.
_messagePlain_warn() {
	echo -e -n '\E[1;33m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Red. Will result in missing functionality, reduced performance, etc, but not necessarily program failure overall.
_messagePlain_bad() {
	echo -e -n '\E[0;31m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

##Parameters
#"--shell", ""
#"--profile"
#"--parent", "--embed", "--return", "--devenv"
#"--call", "--script" "--bypass"

ub_import=
ub_import_param=
ub_import_script=
ub_loginshell=

[[ "${BASH_SOURCE[0]}" != "${0}" ]] && ub_import="true"
([[ "$1" == '--profile' ]] || [[ "$1" == '--script' ]] || [[ "$1" == '--call' ]] || [[ "$1" == '--return' ]] || [[ "$1" == '--devenv' ]] || [[ "$1" == '--shell' ]] || [[ "$1" == '--bypass' ]] || [[ "$1" == '--parent' ]] || [[ "$1" == '--embed' ]]) && ub_import_param="$1" && shift
([[ "$0" == "/bin/bash" ]] || [[ "$0" == "-bash" ]] || [[ "$0" == "/usr/bin/bash" ]] || [[ "$0" == "bash" ]]) && ub_loginshell="true"	#Importing ubiquitous bash into a login shell with "~/.bashrc" is the only known cause for "_getScriptAbsoluteLocation" to return a result such as "/bin/bash".
[[ "$ub_import" == "true" ]] && ! [[ "$ub_loginshell" == "true" ]] && ub_import_script="true"

_messagePlain_probe_expr '$0= '"$0"'\n ''$1= '"$1"'\n ''ub_import= '"$ub_import"'\n ''ub_import_param= '"$ub_import_param"'\n ''ub_import_script= '"$ub_import_script"'\n ''ub_loginshell= '"$ub_loginshell" | _user_log-ub

# DANGER Prohibited import from login shell. Use _setupUbiquitous, call from another script, or manually set importScriptLocation.
# WARNING Import from shell can be detected. Import from script cannot. Asserting that script has been imported is possible. Asserting that script has not been imported is not possible. Users may be protected from interactive mistakes. Script developers are NOT protected.
if [[ "$ub_import_param" == "--profile" ]]
then
	if ([[ "$profileScriptLocation" == "" ]] ||  [[ "$profileScriptFolder" == "" ]]) && _messagePlain_bad 'import: profile: missing: profileScriptLocation, missing: profileScriptFolder' | _user_log-ub
	then
		return 1 >/dev/null 2>&1
		exit 1
	fi
elif ([[ "$ub_import_param" == "--parent" ]] || [[ "$ub_import_param" == "--embed" ]] || [[ "$ub_import_param" == "--return" ]] || [[ "$ub_import_param" == "--devenv" ]])
then
	if ([[ "$scriptAbsoluteLocation" == "" ]] || [[ "$scriptAbsoluteFolder" == "" ]] || [[ "$sessionid" == "" ]]) && _messagePlain_bad 'import: parent: missing: scriptAbsoluteLocation, missing: scriptAbsoluteFolder, missing: sessionid' | _user_log-ub
	then
		return 1 >/dev/null 2>&1
		exit 1
	fi
elif [[ "$ub_import_param" == "--call" ]] || [[ "$ub_import_param" == "--script" ]] || [[ "$ub_import_param" == "--bypass" ]] || [[ "$ub_import_param" == "--shell" ]] || ([[ "$ub_import" == "true" ]] && [[ "$ub_import_param" == "" ]])
then
	if ([[ "$importScriptLocation" == "" ]] ||  [[ "$importScriptFolder" == "" ]]) && _messagePlain_bad 'import: call: missing: importScriptLocation, missing: importScriptFolder' | _user_log-ub
	then
		return 1 >/dev/null 2>&1
		exit 1
	fi
elif [[ "$ub_import" != "true" ]]	#"--shell", ""
then
	_messagePlain_warn 'import: undetected: cannot determine if imported' | _user_log-ub
	true #no problem
else	#FAIL, implies [[ "$ub_import" == "true" ]]
	_messagePlain_bad 'import: fall: fail' | _user_log-ub
	return 1 >/dev/null 2>&1
	exit 1
fi

#Override.
# DANGER: Recursion hazard. Do not create overrides without checking that alternate exists.

# WARNING: Only partially compatible.
if ! type md5sum > /dev/null 2>&1 && type md5 > /dev/null 2>&1
then
	md5sum() {
		md5 "$@"
	}
fi

# DANGER: No production use. Testing only.
# WARNING: Only partially compatible.
#if ! type md5 > /dev/null 2>&1 && type md5sum > /dev/null 2>&1
#then
#	md5() {
#		md5sum "$@"
#	}
#fi


# WARNING: DANGER: Compatibility may not be guaranteed!
if ! type unionfs-fuse > /dev/null 2>&1 && type unionfs > /dev/null 2>&1 && man unionfs | grep 'unionfs-fuse - A userspace unionfs implementation' > /dev/null 2>&1
then
	unionfs-fuse() {
		unionfs "$@"
	}
fi

if ! type qemu-arm-static > /dev/null 2>&1 && type qemu-arm > /dev/null 2>&1
then
	qemu-arm-static() {
		qemu-arm "$@"
	}
fi

if ! type qemu-armeb-static > /dev/null 2>&1 && type qemu-armeb > /dev/null 2>&1
then
	qemu-armeb-static() {
		qemu-armeb "$@"
	}
fi


#Override (Program).

#Override, cygwin.

# ATTENTION: User must launch "tmux" (no parameters) in a graphical Cygwin terminal.
# Launches graphical application through "tmux new-window" if available.
# https://superuser.com/questions/531787/starting-windows-gui-program-in-windows-through-cygwin-sshd-from-ssh-client
_workaround_cygwin_tmux() {
	if pgrep -u "$USER" ^tmux$ > /dev/null 2>&1
	then
		tmux new-window "$@"
		return "$?"
	fi
	
	"$@"
	return "$?"
}

if ! type nmap > /dev/null 2>&1 && type '/cygdrive/c/Program Files/Nmap/nmap.exe' > /dev/null 2>&1
then
	nmap() {
		'/cygdrive/c/Program Files/Nmap/nmap.exe' "$@"
	}
fi

if ! type nmap > /dev/null 2>&1 && type '/cygdrive/c/Program Files (x86)/Nmap/nmap.exe' > /dev/null 2>&1
then
	nmap() {
		'/cygdrive/c/Program Files (x86)/Nmap/nmap.exe' "$@"
	}
fi

# DANGER: Severely differing functionality. Intended only to stand in for "ip addr show" and similar.
if ! type ip > /dev/null 2>&1 && type 'ipconfig' > /dev/null 2>&1 && uname -a | grep -i cygwin > /dev/null 2>&1
then
	ip() {
		if [[ "$1" == "addr" ]] && [[ "$2" == "show" ]]
		then
			ipconfig
			return $?
		fi
		
		return 1
	}
fi



# WARNING: Native 'vncviewer.exe' is a GUI app, and cannot be launched directly from Cygwin SSH server.

#if ! type vncviewer > /dev/null 2>&1 && type '/cygdrive/c/Program Files/TigerVNC/vncviewer.exe' > /dev/null 2>&1

if type '/cygdrive/c/Program Files/TigerVNC/vncviewer.exe' > /dev/null 2>&1 && uname -a | grep -i cygwin > /dev/null 2>&1
then
	export override_cygwin_vncviewer='true'
	vncviewer() {
		_workaround_cygwin_tmux '/cygdrive/c/Program Files/TigerVNC/vncviewer.exe' "$@"
	}
fi

if type '/cygdrive/c/Program Files (x86)/TigerVNC/vncviewer.exe' > /dev/null 2>&1 && uname -a | grep -i cygwin > /dev/null 2>&1
then
	export override_cygwin_vncviewer='true'
	vncviewer() {
		_workaround_cygwin_tmux '/cygdrive/c/Program Files (x86)/TigerVNC/vncviewer.exe' "$@"
	}
fi


#####Utilities

_test_getAbsoluteLocation_sequence() {
	_start
	
	local testScriptLocation_actual
	local testScriptLocation
	local testScriptFolder
	
	local testLocation_actual
	local testLocation
	local testFolder
	
	#script location/folder work directories
	mkdir -p "$safeTmp"/sAL_dir
	cp "$scriptAbsoluteLocation" "$safeTmp"/sAL_dir/script
	ln -s "$safeTmp"/sAL_dir/script "$safeTmp"/sAL_dir/lnk
	[[ ! -e "$safeTmp"/sAL_dir/script ]] && _stop 1
	[[ ! -e "$safeTmp"/sAL_dir/lnk ]] && _stop 1
	
	ln -s "$safeTmp"/sAL_dir "$safeTmp"/sAL_lnk
	[[ ! -e "$safeTmp"/sAL_lnk/script ]] && _stop 1
	[[ ! -e "$safeTmp"/sAL_lnk/lnk ]] && _stop 1
	
	#_getScriptAbsoluteLocation
	testScriptLocation_actual=$("$safeTmp"/sAL_dir/script _getScriptAbsoluteLocation)
	[[ "$safeTmp"/sAL_dir/script != "$testScriptLocation_actual" ]] && echo 'crit: "$safeTmp"/sAL_dir/script != "$testScriptLocation_actual"' && _stop 1
	
	testScriptLocation=$("$safeTmp"/sAL_dir/script _getScriptAbsoluteLocation)
	[[ "$testScriptLocation" != "$testScriptLocation_actual" ]] && echo 'crit: ! location "$safeTmp"/sAL_dir/script' && _stop 1
	testScriptLocation=$("$safeTmp"/sAL_dir/lnk _getScriptAbsoluteLocation)
	[[ "$testScriptLocation" != "$testScriptLocation_actual" ]] && echo 'crit: ! location "$safeTmp"/sAL_dir/lnk' && _stop 1
	
	testScriptLocation=$("$safeTmp"/sAL_lnk/script _getScriptAbsoluteLocation)
	[[ "$testScriptLocation" != "$testScriptLocation_actual" ]] && echo 'crit: ! location "$safeTmp"/sAL_lnk/script' && _stop 1
	testScriptLocation=$("$safeTmp"/sAL_lnk/lnk _getScriptAbsoluteLocation)
	[[ "$testScriptLocation" != "$testScriptLocation_actual" ]] && echo 'crit: ! location "$safeTmp"/sAL_lnk/lnk' && _stop 1
	
	#_getScriptAbsoluteFolder
	testScriptFolder_actual=$("$safeTmp"/sAL_dir/script _getScriptAbsoluteFolder)
	[[ "$safeTmp"/sAL_dir != "$testScriptFolder_actual" ]] && echo 'crit: "$safeTmp"/sAL_dir != "$testScriptFolder_actual"' && _stop 1
	
	testScriptFolder=$("$safeTmp"/sAL_dir/script _getScriptAbsoluteFolder)
	[[ "$testScriptFolder" != "$testScriptFolder_actual" ]] && echo 'crit: ! folder "$safeTmp"/sAL_dir/script' && _stop 1
	testScriptFolder=$("$safeTmp"/sAL_dir/lnk _getScriptAbsoluteFolder)
	[[ "$testScriptFolder" != "$testScriptFolder_actual" ]] && echo 'crit: ! folder "$safeTmp"/sAL_dir/lnk' && _stop 1
	
	testScriptFolder=$("$safeTmp"/sAL_lnk/script _getScriptAbsoluteFolder)
	[[ "$testScriptFolder" != "$testScriptFolder_actual" ]] && echo 'crit: ! folder "$safeTmp"/sAL_lnk/script' && _stop 1
	testScriptFolder=$("$safeTmp"/sAL_lnk/lnk _getScriptAbsoluteFolder)
	[[ "$testScriptFolder" != "$testScriptFolder_actual" ]] && echo 'crit: ! folder "$safeTmp"/sAL_lnk/lnk' && _stop 1
	
	
	#_getAbsoluteLocation
	testLocation_actual=$("$safeTmp"/sAL_dir/script _getAbsoluteLocation "$safeTmp"/sAL_dir/script)
	[[ "$safeTmp"/sAL_dir/script != "$testLocation_actual" ]] && echo 'crit: "$safeTmp"/sAL_dir/script != "$testLocation_actual"' && _stop 1
	
	testLocation=$("$safeTmp"/sAL_dir/script _getAbsoluteLocation "$safeTmp"/sAL_dir/script)
	[[ "$testLocation" != "$testLocation_actual" ]] && echo 'crit: ! location "$safeTmp"/sAL_dir/script' && _stop 1
	testLocation=$("$safeTmp"/sAL_dir/lnk _getAbsoluteLocation "$safeTmp"/sAL_dir/lnk)
	[[ "$testLocation" != "$testLocation_actual" ]] && echo 'crit: ! location "$safeTmp"/sAL_dir/lnk' && _stop 1
	
	testLocation=$("$safeTmp"/sAL_lnk/script _getAbsoluteLocation "$safeTmp"/sAL_lnk/script)
	[[ "$testLocation" != "$testLocation_actual" ]] && echo 'crit: ! location "$safeTmp"/sAL_lnk/script' && _stop 1
	testLocation=$("$safeTmp"/sAL_lnk/lnk _getAbsoluteLocation "$safeTmp"/sAL_lnk/lnk)
	[[ "$testLocation" != "$testLocation_actual" ]] && echo 'crit: ! location "$safeTmp"/sAL_lnk/lnk' && _stop 1
	
	#_getAbsoluteFolder
	testFolder_actual=$("$safeTmp"/sAL_dir/script _getAbsoluteFolder "$safeTmp"/sAL_dir/script)
	[[ "$safeTmp"/sAL_dir != "$testFolder_actual" ]] && echo 'crit: "$safeTmp"/sAL_dir != "$testFolder_actual"' && _stop 1
	
	testFolder=$("$safeTmp"/sAL_dir/script _getAbsoluteFolder "$safeTmp"/sAL_dir/script)
	[[ "$testFolder" != "$testFolder_actual" ]] && echo 'crit: ! folder "$safeTmp"/sAL_dir/script' && _stop 1
	testFolder=$("$safeTmp"/sAL_dir/lnk _getAbsoluteFolder "$safeTmp"/sAL_dir/script)
	[[ "$testFolder" != "$testFolder_actual" ]] && echo 'crit: ! folder "$safeTmp"/sAL_dir/lnk' && _stop 1
	
	testFolder=$("$safeTmp"/sAL_lnk/script _getAbsoluteFolder "$safeTmp"/sAL_lnk/script)
	[[ "$testFolder" != "$testFolder_actual" ]] && echo 'crit: ! folder "$safeTmp"/sAL_lnk/script' && _stop 1
	testFolder=$("$safeTmp"/sAL_lnk/lnk _getAbsoluteFolder "$safeTmp"/sAL_lnk/script)
	[[ "$testFolder" != "$testFolder_actual" ]] && echo 'crit: ! folder "$safeTmp"/sAL_lnk/lnk' && _stop 1
	
	_stop
}

_test_getAbsoluteLocation() {
	"$scriptAbsoluteLocation" _test_getAbsoluteLocation_sequence "$@"
	[[ "$?" != "0" ]] && _stop 1
	return 0
}

#https://unix.stackexchange.com/questions/293892/realpath-l-vs-p
_test_realpath_L_s_sequence() {
	_start
	local functionEntryPWD
	functionEntryPWD="$PWD"
	
	
	local testPath_actual
	local testPath
	
	mkdir -p "$safeTmp"/src
	mkdir -p "$safeTmp"/sub
	ln -s  "$safeTmp"/src "$safeTmp"/sub/lnk
	
	echo > "$safeTmp"/sub/point
	
	ln -s "$safeTmp"/sub/point "$safeTmp"/sub/lnk/ref
	
	#correct
	#"$safeTmp"/sub/ref
	#realpath -L "$safeTmp"/sub/lnk/../ref
	
	#default, wrong
	#"$safeTmp"/ref
	#realpath -P "$safeTmp"/sub/lnk/../ref
	#echo -n '>'
	#readlink -f "$safeTmp"/sub/lnk/../ref
	
	testPath_actual="$safeTmp"/sub/ref
	
	cd "$functionEntryPWD"
	testPath=$(_realpath_L "$safeTmp"/sub/lnk/../ref)
	[[ "$testPath" != "$testPath_actual" ]] && echo 'crit: ! _realpath_L' && _stop 1
	
	cd "$safeTmp"
	testPath=$(_realpath_L ./sub/lnk/../ref)
	[[ "$testPath" != "$testPath_actual" ]] && echo 'crit: ! _realpath_L' && _stop 1
	
	#correct
	#"$safeTmp"/sub/lnk/ref
	#realpath -L -s "$safeTmp"/sub/lnk/ref
	
	#default, wrong for some use cases
	#"$safeTmp"/sub/point
	#realpath -L "$safeTmp"/sub/lnk/ref
	#echo -n '>'
	#readlink -f "$safeTmp"/sub/lnk/ref
	
	testPath_actual="$safeTmp"/sub/lnk/ref
	
	cd "$functionEntryPWD"
	testPath=$(_realpath_L_s "$safeTmp"/sub/lnk/ref)
	[[ "$testPath" != "$testPath_actual" ]] && echo 'crit: ! _realpath_L_s' && _stop 1
	
	cd "$safeTmp"
	testPath=$(_realpath_L_s ./sub/lnk/ref)
	[[ "$testPath" != "$testPath_actual" ]] && echo 'crit: ! _realpath_L_s' && _stop 1
	
	
	cd "$functionEntryPWD"
	_stop
}

_test_realpath_L_s() {
	#Optional safety check. Nonconformant realpath solution should be caught by synthetic test cases.
	#_compat_realpath
	#! [[ -e "$compat_realpath_bin" ]] && [[ "$compat_realpath_bin" != "" ]] && echo 'crit: missing: realpath' && _stop 1
	
	"$scriptAbsoluteLocation" _test_realpath_L_s_sequence "$@"
	[[ "$?" != "0" ]] && _stop 1
	return 0
}

_test_realpath_L() {
	_test_realpath_L_s "$@"
}

_test_realpath() {
	_test_realpath_L_s "$@"
}

_test_readlink_f_sequence() {
	_start
	
	echo > "$safeTmp"/realFile
	ln -s "$safeTmp"/realFile "$safeTmp"/linkA
	ln -s "$safeTmp"/linkA "$safeTmp"/linkB
	
	local currentReadlinkResult
	currentReadlinkResult=$(readlink -f "$safeTmp"/linkB)
	
	local currentReadlinkResultBasename
	currentReadlinkResultBasename=$(basename "$currentReadlinkResult")
	
	if [[ "$currentReadlinkResultBasename" != "realFile" ]]
	then
		#echo 'fail: readlink -f'
		_stop 1
	fi
	
	_stop 0
}

_test_readlink_f() {
	if ! "$scriptAbsoluteLocation" _test_readlink_f_sequence
	then
		echo 'fail: readlink -f'
		_stop 1
	fi
	
	return 0
}

_compat_realpath() {
	[[ -e "$compat_realpath_bin" ]] && [[ "$compat_realpath_bin" != "" ]] && return 0
	
	#Workaround, Mac. See https://github.com/mirage335/ubiquitous_bash/issues/1 .
	export compat_realpath_bin=/opt/local/libexec/gnubin/realpath
	[[ -e "$compat_realpath_bin" ]] && [[ "$compat_realpath_bin" != "" ]] && return 0
	
	export compat_realpath_bin=$(which realpath)
	[[ -e "$compat_realpath_bin" ]] && [[ "$compat_realpath_bin" != "" ]] && return 0
	
	export compat_realpath_bin=/bin/realpath
	[[ -e "$compat_realpath_bin" ]] && [[ "$compat_realpath_bin" != "" ]] && return 0
	
	export compat_realpath_bin=/usr/bin/realpath
	[[ -e "$compat_realpath_bin" ]] && [[ "$compat_realpath_bin" != "" ]] && return 0
	
	# ATTENTION
	# Command "readlink -f" or text processing can be used as fallbacks to obtain absolute path
	# https://stackoverflow.com/questions/3572030/bash-script-absolute-path-with-osx
	
	export compat_realpath_bin=""
	return 1
}

_compat_realpath_run() {
	! _compat_realpath && return 1
	
	"$compat_realpath_bin" "$@"
}

_realpath_L() {
	if ! _compat_realpath_run -L . > /dev/null 2>&1
	then
		readlink -f "$@"
		return
	fi
	
	realpath -L "$@"
}

_realpath_L_s() {
	if ! _compat_realpath_run -L . > /dev/null 2>&1
	then
		readlink -f "$@"
		return
	fi
	
	realpath -L -s "$@"
}


#Critical prerequsites.
_getAbsolute_criticalDep() {
	#! type realpath > /dev/null 2>&1 && return 1
	! type readlink > /dev/null 2>&1 && return 1
	! type dirname > /dev/null 2>&1 && return 1
	
	#Known to succeed under BusyBox (OpenWRT), NetBSD, and common Linux variants. No known failure modes. Extra precaution.
	! readlink -f . > /dev/null 2>&1 && return 1
	
	return 0
}
! _getAbsolute_criticalDep && exit 1

#Retrieves absolute path of current script, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#However, will dereference symlinks IF the script location itself is a symlink. This is to allow symlinking to scripts to function normally.
#Suitable for allowing scripts to find other scripts they depend on. May look like an ugly hack, but it has proven reliable over the years.
_getScriptAbsoluteLocation() {
	if [[ "$0" == "-"* ]]
	then
		return 1
	fi
	
	local absoluteLocation
	if [[ (-e $PWD\/$0) && ($0 != "") ]] && [[ "$0" != "/"* ]]
	then
		absoluteLocation="$PWD"\/"$0"
		absoluteLocation=$(_realpath_L_s "$absoluteLocation")
	else
		absoluteLocation=$(_realpath_L "$0")
	fi
	
	if [[ -h "$absoluteLocation" ]]
	then
		absoluteLocation=$(readlink -f "$absoluteLocation")
		absoluteLocation=$(_realpath_L "$absoluteLocation")
	fi
	echo $absoluteLocation
}
alias getScriptAbsoluteLocation=_getScriptAbsoluteLocation

#Retrieves absolute path of current script, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#Suitable for allowing scripts to find other scripts they depend on.
_getScriptAbsoluteFolder() {
	if [[ "$0" == "-"* ]]
	then
		return 1
	fi
	
	dirname "$(_getScriptAbsoluteLocation)"
}
alias getScriptAbsoluteFolder=_getScriptAbsoluteFolder

#Retrieves absolute path of parameter, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#Suitable for finding absolute paths, when it is desirable not to interfere with symlink specified folder structure.
_getAbsoluteLocation() {
	if [[ "$1" == "-"* ]]
	then
		return 1
	fi
	
	if [[ "$1" == "" ]]
	then
		echo
		return
	fi
	
	local absoluteLocation
	if [[ (-e $PWD\/$1) && ($1 != "") ]] && [[ "$1" != "/"* ]]
	then
		absoluteLocation="$PWD"\/"$1"
		absoluteLocation=$(_realpath_L_s "$absoluteLocation")
	else
		absoluteLocation=$(_realpath_L "$1")
	fi
	echo "$absoluteLocation"
}
alias getAbsoluteLocation=_getAbsoluteLocation

#Retrieves absolute path of parameter, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#Suitable for finding absolute paths, when it is desirable not to interfere with symlink specified folder structure.
_getAbsoluteFolder() {
	if [[ "$1" == "-"* ]]
	then
		return 1
	fi
	
	local absoluteLocation=$(_getAbsoluteLocation "$1")
	dirname "$absoluteLocation"
}
alias getAbsoluteLocation=_getAbsoluteLocation

_getScriptLinkName() {
	! [[ -e "$0" ]] && return 1
	! [[ -L "$0" ]] && return 1
	
	! type basename > /dev/null 2>&1 && return 1
	
	local scriptLinkName
	scriptLinkName=$(basename "$0")
	
	[[ "$scriptLinkName" == "" ]] && return 1
	echo "$scriptLinkName"
}

#https://unix.stackexchange.com/questions/27021/how-to-name-a-file-in-the-deepest-level-of-a-directory-tree?answertab=active#tab-top
_filter_lowestPath() {
	awk -F'/' 'NF > depth {
depth = NF;
deepest = $0;
}
END {
print deepest;
}'
}

#https://stackoverflow.com/questions/1086907/can-find-or-any-other-tool-search-for-files-breadth-first
_filter_highestPath() {
	awk -F'/' '{print "", NF, $F}' | sort -n | awk '{print $2}' | head -n 1
}

_recursion_guard() {
	! [[ -e "$1" ]] && return 1
	
	! type "$1" >/dev/null 2>&1 && return 1
	
	local launchGuardScriptAbsoluteLocation
	launchGuardScriptAbsoluteLocation=$(_getScriptAbsoluteLocation)
	local launchGuardTestAbsoluteLocation
	launchGuardTestAbsoluteLocation=$(_getAbsoluteLocation "$1")
	[[ "$launchGuardScriptAbsoluteLocation" == "$launchGuardTestAbsoluteLocation" ]] && return 1
	
	return 0
}

#Checks whether command or function is available.
# DANGER Needed by safeRMR .
_checkDep() {
	if ! type "$1" >/dev/null 2>&1
	then
		echo "$1" missing
		_stop 1
	fi
}

_tryExec() {
	type "$1" >/dev/null 2>&1 && "$1"
}

_tryExecFull() {
	type "$1" >/dev/null 2>&1 && "$@"
}

#Fails if critical global variables point to nonexistant locations. Code may be duplicated elsewhere for extra safety.
_failExec() {
	[[ ! -e "$scriptAbsoluteLocation" ]] && return 1
	[[ ! -e "$scriptAbsoluteFolder" ]] && return 1
	return 0
}

#Portable sanity checked "rm -r" command.
# DANGER Last line of defense against catastrophic errors where "rm -r" or similar would be used!
# WARNING Not foolproof. Use to guard against systematic errors, not carelessness.
# WARNING Do NOT rely upon outside of internal programmatic usage inside script!
# WARNING Consider using this function even if program control flow can be proven safe. Redundant checks just might catch catastrophic memory errors.
#"$1" == directory to remove
_safeRMR() {
	! type _getAbsolute_criticalDep > /dev/null 2>&1 && return 1
	! _getAbsolute_criticalDep && return 1
	
	#Fail sooner, avoiding irrelevant error messages. Especially important to cases where an upstream process has already removed the "$safeTmp" directory of a downstream process which reaches "_stop" later.
	! [[ -e "$1" ]] && return 1
	
	[[ ! -e "$scriptAbsoluteLocation" ]] && return 1
	[[ ! -e "$scriptAbsoluteFolder" ]] && return 1
	_failExec || return 1
	
	#if [[ ! -e "$0" ]]
	#then
	#	return 1
	#fi
	
	if [[ "$1" == "" ]]
	then
		return 1
	fi
	
	if [[ "$1" == "/" ]]
	then
		return 1
	fi
	
	if [[ "$1" == "-"* ]]
	then
		return 1
	fi
	
	#Blacklist.
	[[ "$1" == "/home" ]] && return 1
	[[ "$1" == "/home/" ]] && return 1
	[[ "$1" == "/home/$USER" ]] && return 1
	[[ "$1" == "/home/$USER/" ]] && return 1
	[[ "$1" == "/$USER" ]] && return 1
	[[ "$1" == "/$USER/" ]] && return 1
	
	[[ "$1" == "/tmp" ]] && return 1
	[[ "$1" == "/tmp/" ]] && return 1
	
	[[ "$1" == "$HOME" ]] && return 1
	[[ "$1" == "$HOME/" ]] && return 1
	
	#Whitelist.
	local safeToRM=false
	
	local safeScriptAbsoluteFolder
	#safeScriptAbsoluteFolder="$(_getScriptAbsoluteFolder)"
	safeScriptAbsoluteFolder="$scriptAbsoluteFolder"
	
	[[ "$1" == "./"* ]] && [[ "$PWD" == "$safeScriptAbsoluteFolder"* ]] && safeToRM="true"
	
	[[ "$1" == "$safeScriptAbsoluteFolder"* ]] && safeToRM="true"
	
	#[[ "$1" == "/home/$USER"* ]] && safeToRM="true"
	[[ "$1" == "/tmp/"* ]] && safeToRM="true"
	
	# WARNING: Allows removal of temporary folders created by current ubiquitous bash session only.
	[[ "$sessionid" != "" ]] && [[ "$1" == *"$sessionid"* ]] && safeToRM="true"
	
	[[ "$safeToRM" == "false" ]] && return 1
	
	#Safeguards/
	[[ "$safeToDeleteGit" != "true" ]] && [[ -d "$1" ]] && [[ -e "$1" ]] && find "$1" 2>/dev/null | grep -i '\.git$' >/dev/null 2>&1 && return 1
	
	#Validate necessary tools were available for path building and checks.
	#! type realpath > /dev/null 2>&1 && return 1
	! type readlink > /dev/null 2>&1 && return 1
	! type dirname > /dev/null 2>&1 && return 1
	! type basename > /dev/null 2>&1 && return 1
	
	if [[ -e "$1" ]]
	then
		#sleep 0
		#echo "$1"
		# WARNING Recommend against adding any non-portable flags.
		rm -rf "$1" > /dev/null 2>&1
	fi
}

#Portable sanity checking for less, but, dangerous, commands.
# WARNING Not foolproof. Use to guard against systematic errors, not carelessness.
# WARNING Do NOT rely upon outside of internal programmatic usage inside script!
#"$1" == file/directory path to sanity check
_safePath() {
	! type _getAbsolute_criticalDep > /dev/null 2>&1 && return 1
	! _getAbsolute_criticalDep && return 1
	
	[[ ! -e "$scriptAbsoluteLocation" ]] && return 1
	[[ ! -e "$scriptAbsoluteFolder" ]] && return 1
	_failExec || return 1
	
	#if [[ ! -e "$0" ]]
	#then
	#	return 1
	#fi
	
	if [[ "$1" == "" ]]
	then
		return 1
	fi
	
	if [[ "$1" == "/" ]]
	then
		return 1
	fi
	
	if [[ "$1" == "-"* ]]
	then
		return 1
	fi
	
	#Blacklist.
	[[ "$1" == "/home" ]] && return 1
	[[ "$1" == "/home/" ]] && return 1
	[[ "$1" == "/home/$USER" ]] && return 1
	[[ "$1" == "/home/$USER/" ]] && return 1
	[[ "$1" == "/$USER" ]] && return 1
	[[ "$1" == "/$USER/" ]] && return 1
	
	[[ "$1" == "/tmp" ]] && return 1
	[[ "$1" == "/tmp/" ]] && return 1
	
	[[ "$1" == "$HOME" ]] && return 1
	[[ "$1" == "$HOME/" ]] && return 1
	
	#Whitelist.
	local safeToRM=false
	
	local safeScriptAbsoluteFolder
	#safeScriptAbsoluteFolder="$(_getScriptAbsoluteFolder)"
	safeScriptAbsoluteFolder="$scriptAbsoluteFolder"
	
	[[ "$1" == "./"* ]] && [[ "$PWD" == "$safeScriptAbsoluteFolder"* ]] && safeToRM="true"
	
	[[ "$1" == "$safeScriptAbsoluteFolder"* ]] && safeToRM="true"
	
	#[[ "$1" == "/home/$USER"* ]] && safeToRM="true"
	[[ "$1" == "/tmp/"* ]] && safeToRM="true"
	
	# WARNING: Allows removal of temporary folders created by current ubiquitous bash session only.
	[[ "$sessionid" != "" ]] && [[ "$1" == *"$sessionid"* ]] && safeToRM="true"
	
	[[ "$safeToRM" == "false" ]] && return 1
	
	#Safeguards/
	[[ "$safeToDeleteGit" != "true" ]] && [[ -d "$1" ]] && [[ -e "$1" ]] && find "$1" 2>/dev/null | grep -i '\.git$' >/dev/null 2>&1 && return 1
	
	#Validate necessary tools were available for path building and checks.
	#! type realpath > /dev/null 2>&1 && return 1
	! type readlink > /dev/null 2>&1 && return 1
	! type dirname > /dev/null 2>&1 && return 1
	! type basename > /dev/null 2>&1 && return 1
	
	if [[ -e "$1" ]]
	then
		#sleep 0
		#echo "$1"
		# WARNING Recommend against adding any non-portable flags.
		return 0
	fi
}

# DANGER Last line of defense against catastrophic errors when using "delete" flag with rsync or similar!
_safeBackup() {
	! type _getAbsolute_criticalDep > /dev/null 2>&1 && return 1
	! _getAbsolute_criticalDep && return 1
	
	[[ ! -e "$scriptAbsoluteLocation" ]] && return 1
	[[ ! -e "$scriptAbsoluteFolder" ]] && return 1
	
	#Fail sooner, avoiding irrelevant error messages. Especially important to cases where an upstream process has already removed the "$safeTmp" directory of a downstream process which reaches "_stop" later.
	! [[ -e "$1" ]] && return 1
	
	[[ "$1" == "" ]] && return 1
	[[ "$1" == "/" ]] && return 1
	[[ "$1" == "-"* ]] && return 1
	
	[[ "$1" == "/home" ]] && return 1
	[[ "$1" == "/home/" ]] && return 1
	[[ "$1" == "/home/$USER" ]] && return 1
	[[ "$1" == "/home/$USER/" ]] && return 1
	[[ "$1" == "/$USER" ]] && return 1
	[[ "$1" == "/$USER/" ]] && return 1
	
	[[ "$1" == "/root" ]] && return 1
	[[ "$1" == "/root/" ]] && return 1
	[[ "$1" == "/root/$USER" ]] && return 1
	[[ "$1" == "/root/$USER/" ]] && return 1
	[[ "$1" == "/$USER" ]] && return 1
	[[ "$1" == "/$USER/" ]] && return 1
	
	[[ "$1" == "/tmp" ]] && return 1
	[[ "$1" == "/tmp/" ]] && return 1
	
	[[ "$1" == "$HOME" ]] && return 1
	[[ "$1" == "$HOME/" ]] && return 1
	
	! type realpath > /dev/null 2>&1 && return 1
	! type readlink > /dev/null 2>&1 && return 1
	! type dirname > /dev/null 2>&1 && return 1
	! type basename > /dev/null 2>&1 && return 1
	
	return 0
}

# DANGER Last line of defense against catastrophic errors when using "delete" flag with rsync or similar!
# WARNING Intended for direct copy/paste inclusion into independent launch wrapper scripts. Kept here for redundancy as well as example and maintenance.
_command_safeBackup() {
	! type _command_getAbsolute_criticalDep > /dev/null 2>&1 && return 1
	! _command_getAbsolute_criticalDep && return 1
	
	[[ ! -e "$commandScriptAbsoluteLocation" ]] && return 1
	[[ ! -e "$commandScriptAbsoluteFolder" ]] && return 1
	
	#Fail sooner, avoiding irrelevant error messages. Especially important to cases where an upstream process has already removed the "$safeTmp" directory of a downstream process which reaches "_stop" later.
	! [[ -e "$1" ]] && return 1
	
	[[ "$1" == "" ]] && return 1
	[[ "$1" == "/" ]] && return 1
	[[ "$1" == "-"* ]] && return 1
	
	[[ "$1" == "/home" ]] && return 1
	[[ "$1" == "/home/" ]] && return 1
	[[ "$1" == "/home/$USER" ]] && return 1
	[[ "$1" == "/home/$USER/" ]] && return 1
	[[ "$1" == "/$USER" ]] && return 1
	[[ "$1" == "/$USER/" ]] && return 1
	
	[[ "$1" == "/root" ]] && return 1
	[[ "$1" == "/root/" ]] && return 1
	[[ "$1" == "/root/$USER" ]] && return 1
	[[ "$1" == "/root/$USER/" ]] && return 1
	[[ "$1" == "/$USER" ]] && return 1
	[[ "$1" == "/$USER/" ]] && return 1
	
	[[ "$1" == "/tmp" ]] && return 1
	[[ "$1" == "/tmp/" ]] && return 1
	
	[[ "$1" == "$HOME" ]] && return 1
	[[ "$1" == "$HOME/" ]] && return 1
	
	#! type realpath > /dev/null 2>&1 && return 1
	! type readlink > /dev/null 2>&1 && return 1
	! type dirname > /dev/null 2>&1 && return 1
	! type basename > /dev/null 2>&1 && return 1
	
	return 0
}



_all_exist() {
	local currentArg
	for currentArg in "$@"
	do
		! [[ -e "$currentArg" ]] && return 1
	done
	
	return 0
}

_wait_not_all_exist() {
	while ! _all_exist "$@"
	do
		sleep 0.1
	done
}

#http://stackoverflow.com/questions/687948/timeout-a-command-in-bash-without-unnecessary-delay
_timeout() { ( set +b; sleep "$1" & "${@:2}" & wait -n; r=$?; kill -9 `jobs -p`; exit $r; ) } 

_terminate() {
	local processListFile
	processListFile="$scriptAbsoluteFolder"/.pidlist_$(_uid)
	
	local currentPID
	
	cat "$safeTmp"/.pid >> "$processListFile" 2> /dev/null
	
	while read -r currentPID
	do
		pkill -P "$currentPID"
		kill "$currentPID"
	done < "$processListFile"
	
	rm "$processListFile"
}

_terminateMetaHostAll() {
	! ls -d -1 ./.m_*/.pid > /dev/null 2>&1 && return 0
	
	local processListFile
	processListFile="$scriptAbsoluteFolder"/.pidlist_$(_uid)
	
	local currentPID
	
	cat ./.m_*/.pid >> "$processListFile" 2> /dev/null
	
	while read -r currentPID
	do
		pkill -P "$currentPID"
		kill "$currentPID"
	done < "$processListFile"
	
	rm "$processListFile"
	
	! ls -d -1 ./.m_*/.pid > /dev/null 2>&1 && return 0
	sleep 0.3
	! ls -d -1 ./.m_*/.pid > /dev/null 2>&1 && return 0
	sleep 1
	! ls -d -1 ./.m_*/.pid > /dev/null 2>&1 && return 0
	sleep 3
	! ls -d -1 ./.m_*/.pid > /dev/null 2>&1 && return 0
	sleep 10
	! ls -d -1 ./.m_*/.pid > /dev/null 2>&1 && return 0
	sleep 20
	! ls -d -1 ./.m_*/.pid > /dev/null 2>&1 && return 0
	sleep 20
	! ls -d -1 ./.m_*/.pid > /dev/null 2>&1 && return 0
	sleep 20
	! ls -d -1 ./.m_*/.pid > /dev/null 2>&1 && return 0
	
	return 1
}

_terminateAll() {
	_terminateMetaHostAll
	
	local processListFile
	processListFile="$scriptAbsoluteFolder"/.pidlist_$(_uid)
	
	local currentPID
	
	
	cat ./.s_*/.pid >> "$processListFile" 2> /dev/null
	
	cat ./.e_*/.pid >> "$processListFile" 2> /dev/null
	cat ./.m_*/.pid >> "$processListFile" 2> /dev/null
	
	cat ./w_*/.pid >> "$processListFile" 2> /dev/null
	
	while read -r currentPID
	do
		pkill -P "$currentPID"
		kill "$currentPID"
	done < "$processListFile"
	
	rm "$processListFile"
}

_condition_lines_zero() {
	local currentLineCount
	currentLineCount=$(wc -l)
	
	[[ "$currentLineCount" == 0 ]] && return 0
	return 1
}

#Generates random alphanumeric characters, default length 18.
_uid() {
	local curentLengthUID

	currentLengthUID="18"
	! [[ -z "$uidLengthPrefix" ]] && ! [[ "$uidLengthPrefix" -lt "18" ]] && currentLengthUID="$uidLengthPrefix"
	! [[ -z "$1" ]] && currentLengthUID="$1"

	cat /dev/urandom 2> /dev/null | base64 2> /dev/null | tr -dc 'a-zA-Z0-9' 2> /dev/null | head -c "$currentLengthUID" 2> /dev/null
}

_compat_stat_c_run() {
	local functionOutput
	
	functionOutput=$(stat -c "$@" 2> /dev/null)
	[[ "$?" == "0" ]] && echo "$functionOutput" && return 0
	
	#BSD
	if stat --help 2>&1 | grep '\-f ' > /dev/null 2>&1
	then
		functionOutput=$(stat -f "$@" 2> /dev/null)
		[[ "$?" == "0" ]] && echo "$functionOutput" && return 0
	fi
	
	return 1
}

_permissions_directory_checkForPath() {
	local parameterAbsoluteLocation
	parameterAbsoluteLocation=$(_getAbsoluteLocation "$1")
	
	local checkScriptAbsoluteFolder="$(_getScriptAbsoluteFolder)"
	
	[[ "$parameterAbsoluteLocation" == "$PWD" ]] && ! [[ "$parameterAbsoluteLocation" == "$checkScriptAbsoluteFolder" ]] && return 1
	
	local permissions_readout=$(_compat_stat_c_run "%a" "$1")
	
	local permissions_user
	local permissions_group
	local permissions_other
	
	permissions_user=$(echo "$permissions_readout" | cut -c 1)
	permissions_group=$(echo "$permissions_readout" | cut -c 2)
	permissions_other=$(echo "$permissions_readout" | cut -c 3)
	
	[[ "$permissions_user" -gt "7" ]] && return 1
	[[ "$permissions_group" -gt "7" ]] && return 1
	[[ "$permissions_other" -gt "5" ]] && return 1
	
	#Above checks considered sufficient in typical cases, remainder for sake of example. Return true (safe).
	return 0
	
	local permissions_uid
	local permissions_gid
	
	permissions_uid=$(_compat_stat_c_run "%u" "$1")
	permissions_gid=$(_compat_stat_c_run "%g" "$1")
	
	#Normally these variables are available through ubiqutious bash, but this permissions check may be needed earlier in that global variables setting process.
	local permissions_host_uid
	local permissions_host_gid
	
	permissions_host_uid=$(id -u)
	permissions_host_gid=$(id -g)
	
	[[ "$permissions_uid" != "$permissions_host_uid" ]] && return 1
	[[ "$permissions_uid" != "$permissions_host_gid" ]] && return 1
	
	return 0
}

#Checks whether the repository has unsafe permissions for adding binary files to path. Used as an extra safety check by "_setupUbiquitous" before adding a hook to the user's default shell environment.
_permissions_ubiquitous_repo() {
	local parameterAbsoluteLocation
	parameterAbsoluteLocation=$(_getAbsoluteLocation "$1")
	
	[[ ! -e "$parameterAbsoluteLocation" ]] && return 0
	
	! _permissions_directory_checkForPath "$parameterAbsoluteLocation" && return 1
	
	[[ -e "$parameterAbsoluteLocation"/_bin ]] && ! _permissions_directory_checkForPath "$parameterAbsoluteLocation"/_bin && return 1
	[[ -e "$parameterAbsoluteLocation"/_bundle ]] && ! _permissions_directory_checkForPath "$parameterAbsoluteLocation"/_bundle && return 1
	
	return 0
}

#Checks whether currently set "$scriptBin" and similar locations are actually safe.
# WARNING Keep in mind this is necessarily run only after PATH would already have been modified, and does not guard against threats already present on the local machine.
_test_permissions_ubiquitous() {
	[[ ! -e "$scriptAbsoluteFolder" ]] && _stop 1
	
	! _permissions_directory_checkForPath "$scriptAbsoluteFolder" && _stop 1
	
	[[ -e "$scriptBin" ]] && ! _permissions_directory_checkForPath "$scriptBin" && _stop 1
	[[ -e "$scriptBundle" ]] && ! _permissions_directory_checkForPath "$scriptBundle" && _stop 1
	
	return 0
}



#Takes "$@". Places in global array variable "globalArgs".
# WARNING Adding this globalvariable to the "structure/globalvars.sh" declaration or similar to be overridden at script launch is not recommended.
#"${globalArgs[@]}"
_gather_params() {
	export globalArgs=("${@}")
}

_self_critial() {
	_priority_critical_pid "$$"
}

_self_interactive() {
	_priority_interactive_pid "$$"
}

_self_background() {
	_priority_background_pid "$$"
}

_self_idle() {
	_priority_idle_pid "$$"
}

_self_app() {
	_priority_app_pid "$$"
}

_self_zero() {
	_priority_zero_pid "$$"
}


#Example.
_priority_critical() {
	_priority_dispatch "_priority_critical_pid"
}

_priority_critical_pid_root() {
	! _wantSudo && return 1
	
	sudo -n ionice -c 2 -n 2 -p "$1"
	! sudo -n renice -15 -p "$1" && return 1
	
	return 0
}

_priority_critical_pid() {
	[[ "$1" == "" ]] && return 1
	
	_priority_critical_pid_root "$1" && return 0
	
	ionice -c 2 -n 4 -p "$1"
	! renice 0 -p "$1" && return 1
	
	return 1
}

_priority_interactive_pid_root() {
	! _wantSudo && return 1
	
	sudo -n ionice -c 2 -n 2 -p "$1"
	! sudo -n renice -10 -p "$1" && return 1
	
	return 0
}

_priority_interactive_pid() {
	[[ "$1" == "" ]] && return 1
	
	_priority_interactive_pid_root "$1" && return 0
	
	ionice -c 2 -n 4 -p "$1"
	! renice 0 -p "$1" && return 1
	
	return 1
}

_priority_app_pid_root() {
	! _wantSudo && return 1
	
	sudo -n ionice -c 2 -n 3 -p "$1"
	! sudo -n renice -5 -p "$1" && return 1
	
	return 0
}

_priority_app_pid() {
	[[ "$1" == "" ]] && return 1
	
	_priority_app_pid_root "$1" && return 0
	
	ionice -c 2 -n 4 -p "$1"
	! renice 0 -p "$1" && return 1
	
	return 1
}

_priority_background_pid_root() {
	! _wantSudo && return 1
	
	sudo -n ionice -c 2 -n 5 -p "$1"
	! sudo -n renice +5 -p "$1" && return 1
	
	return 0
}

_priority_background_pid() {
	[[ "$1" == "" ]] && return 1
	
	if ! type ionice > /dev/null 2>&1 || ! groups | grep -E 'wheel|sudo' > /dev/null 2>&1
	then
		renice +5 -p "$1"
		return 0
	fi
	
	_priority_background_pid_root "$1" && return 0
	
	ionice -c 2 -n 5 -p "$1"
	
	renice +5 -p "$1"
}



_priority_idle_pid_root() {
	! _wantSudo && return 1
	
	sudo -n ionice -c 3 -p "$1"
	! sudo -n renice +15 -p "$1" && return 1
	
	return 0
}

_priority_idle_pid() {
	[[ "$1" == "" ]] && return 1
	
	if ! type ionice > /dev/null 2>&1 || ! groups | grep -E 'wheel|sudo' > /dev/null 2>&1
	then
		renice +15 -p "$1"
		return 0
	fi
	
	_priority_idle_pid_root "$1" && return 0
	
	#https://linux.die.net/man/1/ionice
	ionice -c 3 -p "$1"
	
	renice +15 -p "$1"
}

_priority_zero_pid_root() {
	! _wantSudo && return 1
	
	sudo -n ionice -c 2 -n 4 -p "$1"
	! sudo -n renice 0 -p "$1" && return 1
	
	return 0
}

_priority_zero_pid() {
	[[ "$1" == "" ]] && return 1
	
	_priority_zero_pid_root "$1" && return 0
	
	#https://linux.die.net/man/1/ionice
	ionice -c 2 -n 4 -p "$1"
	
	renice 0 -p "$1"
}

# WARNING: Untested.
_priority_dispatch() {
	local processListFile
	processListFile="$scriptAbsoluteFolder"/.pidlist_$(_uid)
	
	echo "$1" >> "$processListFile"
	pgrep -P "$1" 2>/dev/null >> "$processListFile"
	
	local currentPID
	
	while read -r currentPID
	do
		"$@" "$currentPID"
	done < "$processListFile"
	
	rm "$processListFile"
}

# WARNING: Untested.
_priority_enumerate_pid() {
	[[ "$1" == "" ]] && return 1
	
	echo "$1"
	pgrep -P "$1" 2>/dev/null
}

_priority_enumerate_pattern() {
	local processListFile
	processListFile="$scriptAbsoluteFolder"/.pidlist_$(_uid)
	
	echo -n >> "$processListFile"
	
	pgrep "$1" >> "$processListFile"
	
	
	local parentListFile
	parentListFile="$scriptAbsoluteFolder"/.pidlist_$(_uid)
	
	echo -n >> "$parentListFile"
	
	local currentPID
	
	while read -r currentPID
	do
		pgrep -P "$currentPID" 2>/dev/null > "$parentListFile"
	done < "$processListFile"
	
	cat "$processListFile"
	cat "$parentListFile"
	
	
	rm "$processListFile"
	rm "$parentListFile"
}

_instance_internal() {
	! [[ -e "$1" ]] && return 1
	! [[ -d "$1" ]] && return 1
	! [[ -e "$2" ]] && return 1
	! [[ -d "$2" ]] && return 1
	rsync -q -ax --exclude "/.cache" --exclude "/.git" "$@"
}

#echo -n
_safeEcho() {
	printf '%s' "$1"
	shift
	
	[[ "$@" == "" ]] && return 0
	
	local currentArg
	for currentArg in "$@"
	do
		printf '%s' " "
		printf '%s' "$currentArg"
	done
	return 0
}

#echo
_safeEcho_newline() {
	_safeEcho "$@"
	printf '\n'
}

#Universal debugging filesystem.
#End user function.
_user_log() {
	# DANGER Do NOT create automatically, or reference any existing directory!
	! [[ -d "$HOME"/.ubcore/userlog ]] && cat - > /dev/null 2>&1 && return 0
	
	cat - >> "$HOME"/.ubcore/userlog/user.log
	
	return 0
}

_monitor_user_log() {
	! [[ -d "$HOME"/.ubcore/userlog ]] && return 1
	
	tail -f "$HOME"/.ubcore/userlog/*
}

#Universal debugging filesystem.
#"generic/ubiquitousheader.sh"
_user_log-ub() {
	# DANGER Do NOT create automatically, or reference any existing directory!
	! [[ -d "$HOME"/.ubcore/userlog ]] && cat - > /dev/null 2>&1 && return 0
	
	#Terminal session may be used - the sessionid may be set through .bashrc/.ubcorerc .
	if [[ "$sessionid" != "" ]]
	then
		cat - >> "$HOME"/.ubcore/userlog/u-"$sessionid".log
		return 0
	fi
	cat - >> "$HOME"/.ubcore/userlog/u-undef.log
	
	return 0
}

_monitor_user_log-ub() {
	! [[ -d "$HOME"/.ubcore/userlog ]] && return 1
	
	tail -f "$HOME"/.ubcore/userlog/u-*
}

#Universal debugging filesystem.
_user_log_anchor() {
	# DANGER Do NOT create automatically, or reference any existing directory!
	! [[ -d "$HOME"/.ubcore/userlog ]] && cat - > /dev/null 2>&1 && return 0
	
	#Terminal session may be used - the sessionid may be set through .bashrc/.ubcorerc .
	if [[ "$sessionid" != "" ]]
	then
		cat - >> "$HOME"/.ubcore/userlog/a-"$sessionid".log
		return 0
	fi
	cat - >> "$HOME"/.ubcore/userlog/a-undef.log
	
	return 0
}

_monitor_user_log_anchor() {
	! [[ -d "$HOME"/.ubcore/userlog ]] && return 1
	
	tail -f "$HOME"/.ubcore/userlog/a-*
}

#Universal debugging filesystem.
_user_log_template() {
	# DANGER Do NOT create automatically, or reference any existing directory!
	! [[ -d "$HOME"/.ubcore/userlog ]] && cat - > /dev/null 2>&1 && return 0
	
	#Terminal session may be used - the sessionid may be set through .bashrc/.ubcorerc .
	if [[ "$sessionid" != "" ]]
	then
		cat - >> "$HOME"/.ubcore/userlog/t-"$sessionid".log
		return 0
	fi
	cat - >> "$HOME"/.ubcore/userlog/t-undef.log
	
	return 0
}

_messageColors() {
	echo -e '\E[1;37m 'white' \E[0m'
	echo -e '\E[0;30m 'black' \E[0m'
	echo -e '\E[0;34m 'blue' \E[0m'
	echo -e '\E[1;34m 'blue_light' \E[0m'
	echo -e '\E[0;32m 'green' \E[0m'
	echo -e '\E[1;32m 'green_light' \E[0m'
	echo -e '\E[0;36m 'cyan' \E[0m'
	echo -e '\E[1;36m 'cyan_light' \E[0m'
	echo -e '\E[0;31m 'red' \E[0m'
	echo -e '\E[1;31m 'red_light' \E[0m'
	echo -e '\E[0;35m 'purple' \E[0m'
	echo -e '\E[1;35m 'purple_light' \E[0m'
	echo -e '\E[0;33m 'brown' \E[0m'
	echo -e '\E[1;33m 'yellow' \E[0m'
	echo -e '\E[0;30m 'gray' \E[0m'
	echo -e '\E[1;37m 'gray_light' \E[0m'
	return 0
}

#Purple. User must do something manually to proceed. NOT to be used for dependency installation requests - use probe, bad, and fail statements for that.
_messagePlain_request() {
	echo -e -n '\E[0;35m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Cyan. Harmless status messages.
#"generic/ubiquitousheader.sh"
_messagePlain_nominal() {
	echo -e -n '\E[0;36m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Blue. Diagnostic instrumentation.
#"generic/ubiquitousheader.sh"
_messagePlain_probe() {
	echo -e -n '\E[0;34m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Blue. Diagnostic instrumentation.
#"generic/ubiquitousheader.sh"
_messagePlain_probe_expr() {
	echo -e -n '\E[0;34m '
	echo -e -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Blue. Diagnostic instrumentation.
#"generic/ubiquitousheader.sh"
_messagePlain_probe_var() {
	echo -e -n '\E[0;34m '
	
	echo -n "$1"'= '
	
	eval echo -e -n \$"$1"
	
	echo -e -n ' \E[0m'
	echo
	return 0
}
_messageVar() {
	_messagePlain_probe_var "$@"
}

#Green. Working as expected.
#"generic/ubiquitousheader.sh"
_messagePlain_good() {
	echo -e -n '\E[0;32m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Yellow. May or may not be a problem.
#"generic/ubiquitousheader.sh"
_messagePlain_warn() {
	echo -e -n '\E[1;33m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Red. Will result in missing functionality, reduced performance, etc, but not necessarily program failure overall.
_messagePlain_bad() {
	echo -e -n '\E[0;31m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Blue. Diagnostic instrumentation.
#Prints "$@" and runs "$@".
# WARNING: Use with care.
_messagePlain_probe_cmd() {
	echo -e -n '\E[0;34m '
	
	_safeEcho "$@"
	
	echo -e -n ' \E[0m'
	echo
	
	"$@"
	
	return
}
_messageCMD() {
	_messagePlain_probe_cmd "$@"
}

#Demarcate major steps.
_messageNormal() {
	echo -e -n '\E[1;32;46m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Demarcate major failures.
_messageError() {
	echo -e -n '\E[1;33;41m '
	echo -n "$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Demarcate need to fetch/generate dependency automatically - not a failure condition.
_messageNEED() {
	_messageNormal "NEED"
	#echo " NEED "
}

#Demarcate have dependency already, no need to fetch/generate.
_messageHAVE() {
	_messageNormal "HAVE"
	#echo " HAVE "
}

_messageWANT() {
	_messageNormal "WANT"
	#echo " WANT "
}

#Demarcate where PASS/FAIL status cannot be absolutely proven. Rarely appropriate - usual best practice is to simply progress to the next major step.
_messageDONE() {
	_messageNormal "DONE"
	#echo " DONE "
}

_messagePASS() {
	_messageNormal "PASS"
	#echo " PASS "
}

#Major failure. Program stopped.
_messageFAIL() {
	_messageError "FAIL"
	#echo " FAIL "
	_stop 1
}

_messageWARN() {
	echo
	echo "$@"
	return 0
}


_messageProcess() {
	local processString
	processString="$1""..."
	
	local processStringLength
	processStringLength=${#processString}
	
	local currentIteration
	currentIteration=0
	
	local padLength
	let padLength=40-"$processStringLength"
	
	[[ "$processStringLength" -gt "38" ]] && _messageNormal "$processString" && return 0
	
	echo -e -n '\E[1;32;46m '
	
	echo -n "$processString"
	
	echo -e -n '\E[0m'
	
	while [[ "$currentIteration" -lt "$padLength" ]]
	do
		echo -e -n ' '
		let currentIteration="$currentIteration"+1
	done
	
	return 0
}

_mustcarry() {
	grep "$1" "$2" > /dev/null 2>&1 && return 0
	
	echo "$1" >> "$2"
	return
}

#Gets filename extension, specifically any last three characters in given string.
#"$1" == filename
_getExt() {
	echo "$1" | tr -dc 'a-zA-Z0-9.' | tr '[:upper:]' '[:lower:]' | tail -c 4
}

#Reports either the directory provided, or the directory of the file provided.
_findDir() {
	local dirIn=$(_getAbsoluteLocation "$1")
	dirInLogical=$(_realpath_L_s "$dirIn")
	
	if [[ -d "$dirInLogical" ]]
	then
		echo "$dirInLogical"
		return
	fi
	
	echo $(_getAbsoluteFolder "$dirInLogical")
	return
	
}

_discoverResource() {
	
	[[ "$scriptAbsoluteFolder" == "" ]] && return 1
	
	local testDir
	testDir="$scriptAbsoluteFolder" ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return 0
	testDir="$scriptAbsoluteFolder"/.. ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return 0
	testDir="$scriptAbsoluteFolder"/../.. ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return 0
	testDir="$scriptAbsoluteFolder"/../../.. ; [[ -e "$testDir"/"$1" ]] && echo "$testDir"/"$1" && return 0
	
	return 1
}

_rmlink() {
	[[ "$1" == "/dev/null" ]] && return 1
	
	[[ -h "$1" ]] && rm -f "$1" && return 0
	
	! [[ -e "$1" ]] && return 0
	
	return 1
}

#Like "ln -sf", but will not proceed if target is not link and exists (ie. will not erase files).
_relink_procedure() {
	#Do not update correct symlink.
	local existingLinkTarget
	existingLinkTarget=$(readlink "$2")
	[[ "$existingLinkTarget" == "$1" ]] && return 0
	
	! [[ "$relinkRelativeUb" == "true" ]] && _rmlink "$2" && ln -s "$1" "$2" && return 0
	
	if [[ "$relinkRelativeUb" == "true" ]]
	then
		_rmlink "$2" && ln -s --relative "$1" "$2" && return 0
	fi
	
	return 1
}

_relink() {
	[[ "$2" == "/dev/null" ]] && return 1
	[[ "$relinkRelativeUb" == "true" ]] && export relinkRelativeUb=""
	_relink_procedure "$@"
}

_relink_relative() {
	export relinkRelativeUb=""
	
	[[ "$relinkRelativeUb" != "true" ]] && ln --help 2>/dev/null | grep '\-\-relative' > /dev/null 2>&1 && export relinkRelativeUb="true"
	[[ "$relinkRelativeUb" != "true" ]] && ln 2>&1 | grep '\-\-relative' > /dev/null 2>&1 && export relinkRelativeUb="true"
	[[ "$relinkRelativeUb" != "true" ]] && man ln 2>/dev/null | grep '\-\-relative' > /dev/null 2>&1 && export relinkRelativeUb="true"
	
	_relink_procedure "$@"
	export relinkRelativeUb=""
	unset relinkRelativeUb
}

#Copies files only if source/destination do match. Keeps files in a completely written state as often as possible.
_cpDiff() {
	! diff "$1" "$2" > /dev/null 2>&1 && cp "$1" "$2"
}

_test_channel_fifo() {
	_getDep mkfifo
	
	#if ! dd if=$("$scriptAbsoluteLocation" _channel_host_fifo cat /dev/zero) of=/dev/null bs=1M count=10 iflag=fullblock > /dev/null 2>&1
	if ! dd if=$("$scriptAbsoluteLocation" _channel_host_fifo cat /dev/zero) of=/dev/null bs=10000000 count=10 > /dev/null 2>&1
	then
		echo 'fail: channel: fifo'
		_stop 1
	fi
}

_test_channel() {
	_tryExec "_test_channel_fifo"
}

_set_channel() {
	export channelTmp="$scriptAbsoluteFolder""$tmpPrefix"/.c_"$sessionid"
}

_prepare_channel() {
	mkdir -p "$channelTmp"
}

_stop_channel_allow() {
	export channelStop="true"
}
_stop_channel_prohibit() {
	export channelStop="false"
}

_rm_instance_channel() {
	[[ "$channelStop" != "true" ]] && return 0
	export channelStop="false"
	
	if [[ "$channelTmp" != "" ]] && [[ "$channelTmp" == *"$sessionid"* ]] && [[ -e "$channelTmp" ]]
	then
		_safeRMR "$channelTmp"
		[[ -e "$channelTmp" ]] && sleep 0.1 && _safeRMR "$channelTmp"
		[[ -e "$channelTmp" ]] && sleep 0.3 && _safeRMR "$channelTmp"
		[[ -e "$channelTmp" ]] && sleep 1 && _safeRMR "$channelTmp"
		[[ -e "$channelTmp" ]] && sleep 3 && _safeRMR "$channelTmp"
		[[ -e "$channelTmp" ]] && sleep 3 && _safeRMR "$channelTmp"
		[[ -e "$channelTmp" ]] && sleep 3 && _safeRMR "$channelTmp"
	fi
}

_channel_fifo_example() {
	cat /dev/urandom | base64
}

_channel_fifo_sequence() {
	_stop_channel_allow
	
	"$@" 2>/dev/null > "$commandFIFO"
	
	_rm_instance_channel
}

_channel_host_fifo_sequence() {
	_stop_channel_prohibit
	_set_channel
	_prepare_channel
	
	export commandFIFO="$channelTmp"/cmdfifo
	mkfifo "$commandFIFO"
	
	echo "$commandFIFO"
	
	
	#nohup "$scriptAbsoluteLocation" --embed _channel_fifo_sequence "$@" >/dev/null 2>&1 &
	"$scriptAbsoluteLocation" --embed _channel_fifo_sequence "$@" >/dev/null 2>&1 &
	#disown -h $!
	disown -a -h
}

# example: dd if=$(./ubiquitous_bash.sh _channel_host_fifo _channel_fifo_example) of=/dev/null
# example: dd if=$(./ubiquitous_bash.sh _channel_host_fifo cat /dev/zero) of=/dev/null bs=1M count=10000 iflag=fullblock
_channel_host_fifo() {
	"$scriptAbsoluteLocation" _channel_host_fifo_sequence "$@"
}


#Waits for the process PID specified by first parameter to end. Useful in conjunction with $! to provide process control and/or PID files. Unlike wait command, does not require PID to be a child of the current shell.
_pauseForProcess() {
	while ps --no-headers -p $1 &> /dev/null
	do
		sleep 0.3
	done
}
alias _waitForProcess=_pauseForProcess
alias waitForProcess=_pauseForProcess

_test_daemon() {
	_getDep pkill
}

#To ensure the lowest descendents are terminated first, the file must be created in reverse order. Additionally, PID files created before a prior reboot must be discarded and ignored.
_prependDaemonPID() {
	
	#Reset locks from before prior reboot.
	_readLocked "$daemonPidFile"lk
	_readLocked "$daemonPidFile"op
	_readLocked "$daemonPidFile"cl
	
	while true
	do
		_createLocked "$daemonPidFile"op && break
		sleep 0.1
	done
	
	#Removes old PID file if not locked during current UNIX session (ie. since latest reboot).  Prevents termination of non-daemon PIDs.
	if ! _readLocked "$daemonPidFile"lk
	then
		rm -f "$daemonPidFile"
		rm -f "$daemonPidFile"t
	fi
	_createLocked "$daemonPidFile"lk
	
	[[ ! -e "$daemonPidFile" ]] && echo >> "$daemonPidFile"
	cat - "$daemonPidFile" >> "$daemonPidFile"t
	mv "$daemonPidFile"t "$daemonPidFile"
	
	rm -f "$daemonPidFile"op
}

#By default, process descendents will be terminated first. Doing so is essential to reaching sub-proesses of sub-scripts, without manual user input.
#https://stackoverflow.com/questions/34438189/bash-sleep-process-not-getting-killed
_daemonSendTERM() {
	#Terminate descendents if parent has not been able to quit.
	pkill -P "$1"
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 0.1
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 0.3
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 2
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 6
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 9
	
	#Kill descendents if parent has not been able to quit.
	pkill -KILL -P "$1"
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 0.1
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 0.3
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 2
	
	#Terminate parent if parent has not been able to quit.
	kill -TERM "$1"
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 0.1
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 0.3
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 2
	
	#Kill parent if parent has not been able to quit.
	kill KILL "$1"
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 0.1
	! ps -p "$1" >/dev/null 2>&1 && return 0
	sleep 0.3
	
	#Failure to immediately kill parent is an extremely rare, serious error.
	ps -p "$1" >/dev/null 2>&1 && return 1
	return 0
}

#No production use.
_daemonSendKILL() {
	pkill -KILL -P "$1"
	kill -KILL "$1"
}

#True if any daemon registered process is running.
_daemonAction() {
	[[ ! -e "$daemonPidFile" ]] && return 1
	
	local currentLine
	local processedLine
	local daemonStatus
	
	while IFS='' read -r currentLine || [[ -n "$currentLine" ]]; do
		processedLine=$(echo "$currentLine" | tr -dc '0-9')
		if [[ "$processedLine" != "" ]] && ps -p "$processedLine" >/dev/null 2>&1
		then
			daemonStatus="up"
			[[ "$1" == "status" ]] && return 0
			[[ "$1" == "terminate" ]] && _daemonSendTERM "$processedLine"
			[[ "$1" == "kill" ]] && _daemonSendKILL "$processedLine"
		fi
	done < "$daemonPidFile"
	
	[[ "$daemonStatus" == "up" ]] && return 0
	return 1
}

_daemonStatus() {
	_daemonAction "status"
}

#No production use.
_waitForTermination() {
	_daemonStatus && sleep 0.1
	_daemonStatus && sleep 0.3
	_daemonStatus && sleep 1
	_daemonStatus && sleep 2
}
alias _waitForDaemon=_waitForTermination

#Kills background process using PID file.
_killDaemon() {
	#Do NOT proceed if PID values may be invalid.
	! _readLocked "$daemonPidFile"lk && return 1
	
	#Do NOT proceed if daemon is starting (opening).
	_readLocked "$daemonPidFile"op && return 1
	
	! _createLocked "$daemonPidFile"cl && return 1
	
	#Do NOT proceed if daemon is starting (opening).
	_readLocked "$daemonPidFile"op && return 1
	
	_daemonAction "terminate"
	
	#Do NOT proceed to detele lock/PID files unless daemon can be confirmed down.
	_daemonStatus && return 1
	
	rm -f "$daemonPidFile" >/dev/null 2>&1
	rm -f "$daemonPidFile"lk
	rm -f "$daemonPidFile"cl
	
	return 0
}

_cmdDaemon() {
	export isDaemon=true
	
	"$@" &
	
	#Any PID which may be part of a daemon may be appended to this file.
	echo "$!" | _prependDaemonPID
}

#Executes self in background (ie. as daemon).
_execDaemon() {
	#_daemonStatus && return 1
	
	_cmdDaemon "$scriptAbsoluteLocation"
}

_launchDaemon() {
	_start
	
	_killDaemon
	
	
	_execDaemon
	while _daemonStatus
	do
		sleep 5
	done
	
	
	
	
	
	_stop
}

#Remote TERM signal wrapper. Verifies script is actually running at the specified PID before passing along signal to trigger an emergency stop.
#"$1" == pidFile
#"$2" == sessionid (optional for cleaning up stale systemd files)
_remoteSigTERM() {
	[[ ! -e "$1" ]] && [[ "$2" != "" ]] && _unhook_systemd_shutdown "$2"
	
	[[ ! -e "$1" ]] && return 0
	
	pidToTERM=$(cat "$1")
	
	kill -TERM "$pidToTERM"
	
	_pauseForProcess "$pidToTERM"
}

_embed_here() {
	cat << CZXWXcRMTo8EmM8i4d
#!/usr/bin/env bash

export scriptAbsoluteLocation="$scriptAbsoluteLocation"
export scriptAbsoluteFolder="$scriptAbsoluteFolder"
export sessionid="$sessionid"
. "$scriptAbsoluteLocation" --embed "\$@"
CZXWXcRMTo8EmM8i4d
}

_embed() {
	export sessionid="$1"
	"$scriptAbsoluteLocation" --embed "$@"
}

#"$@" == URL
_fetch() {
	if type axel > /dev/null 2>&1
	then
		axel "$@"
		return 0
	fi
	
	wget "$@"
	
	return 0
}

_validatePort() {
	[[ "$1" -lt "1024" ]] && return 1
	[[ "$1" -gt "65535" ]] && return 1
	
	return 0
}

_testFindPort() {
	! _wantGetDep ss
	! _wantGetDep sockstat
	
	# WARNING: Cygwin port range detection not yet implemented.
	if uname -a | grep -i cygwin > /dev/null 2>&1
	then
		! type nmap > /dev/null 2>&1 && echo "missing socket detection" && _stop 1
		return 0
	fi
	
	! type ss > /dev/null 2>&1 && ! type sockstat > /dev/null 2>&1 && echo "missing socket detection" && _stop 1
	
	local machineLowerPort=$(cat /proc/sys/net/ipv4/ip_local_port_range 2> /dev/null | cut -f1)
	local machineUpperPort=$(cat /proc/sys/net/ipv4/ip_local_port_range 2> /dev/null | cut -f2)
	
	[[ "$machineLowerPort" == "" ]] && echo "warn: autodetect: lower_port"
	[[ "$machineUpperPort" == "" ]] && echo "warn: autodetect: upper_port"
	[[ "$machineLowerPort" == "" ]] || [[ "$machineUpperPort" == "" ]] && return 0
	
	[[ "$machineLowerPort" -lt "1024" ]] && echo "invalid lower_port" && _stop 1
	[[ "$machineLowerPort" -lt "32768" ]] && echo "warn: low lower_port"
	[[ "$machineLowerPort" -gt "32768" ]] && echo "warn: high lower_port"
	
	[[ "$machineUpperPort" -gt "65535" ]] && echo "invalid upper_port" && _stop 1
	[[ "$machineUpperPort" -gt "60999" ]] && echo "warn: high upper_port"
	[[ "$machineUpperPort" -lt "60999" ]] && echo "warn: low upper_port"
	
	local testFoundPort
	testFoundPort=$(_findPort)
	! _validatePort "$testFoundPort" && echo "invalid port discovery" && _stop 1
}

#True if port open (in use).
_checkPort_local() {
	[[ "$1" == "" ]] && return 1
	
	if type ss > /dev/null 2>&1
	then
		ss -lpn | grep ':'"$1"' ' > /dev/null 2>&1
		return $?
	fi
	
	if type sockstat > /dev/null 2>&1
	then
		sockstat -46ln | grep '\.'"$1"' ' > /dev/null 2>&1
		return $?
	fi
	
	if uname -a | grep -i cygwin > /dev/null 2>&1
	then
		nmap --host-timeout 0.1 -Pn localhost -p "$1" 2> /dev/null | grep open > /dev/null 2>&1
		return $?
	fi
	
	return 1
}

#Waits a reasonable time interval for port to be open (in use).
#"$1" == port
_waitPort_local() {
	local checksDone
	checksDone=0
	while ! _checkPort_local "$1" && [[ "$checksDone" -lt 72 ]]
	do
		let checksDone+=1
		sleep 0.1
	done
	
	local checksDone
	checksDone=0
	while ! _checkPort_local "$1" && [[ "$checksDone" -lt 72 ]]
	do
		let checksDone+=1
		sleep 0.3
	done
	
	local checksDone
	checksDone=0
	while ! _checkPort_local "$1" && [[ "$checksDone" -lt 72 ]]
	do
		let checksDone+=1
		sleep 1
	done
	
	return 0
}


#http://unix.stackexchange.com/questions/55913/whats-the-easiest-way-to-find-an-unused-local-port
_findPort() {
	local lower_port
	local upper_port
	
	lower_port="$1"
	upper_port="$2"
	
	#Non public ports are between 49152-65535 (2^15 + 2^14 to 2^16 − 1).
	#Convention is to assign ports 55000-65499 and 50025-53999 to specialized servers.
	#read lower_port upper_port < /proc/sys/net/ipv4/ip_local_port_range
	[[ "$lower_port" == "" ]] && lower_port=54000
	[[ "$upper_port" == "" ]] && upper_port=54999
	
	local range_port
	local rand_max
	let range_port="upper_port - lower_port"
	let rand_max="range_port / 2"
	
	local portRangeOffset
	portRangeOffset=$RANDOM
	#let "portRangeOffset %= 150"
	let "portRangeOffset %= rand_max"
	
	[[ "$opsautoGenerationMode" == "true" ]] && [[ "$lowestUsedPort" == "" ]] && export lowestUsedPort="$lower_port"
	[[ "$opsautoGenerationMode" == "true" ]] && lower_port="$lowestUsedPort"
	
	! [[ "$opsautoGenerationMode" == "true" ]] && let "lower_port += portRangeOffset"
	
	while true
	do
		for (( currentPort = lower_port ; currentPort <= upper_port ; currentPort++ )); do
			if ! _checkPort_local "$currentPort"
			then
				sleep 0.1
				if ! _checkPort_local "$currentPort"
				then
					break 2
				fi
			fi
		done
	done
	
	if [[ "$opsautoGenerationMode" == "true" ]]
	then
		local nextUsablePort
		
		let "nextUsablePort = currentPort + 1"
		export lowestUsedPort="$nextUsablePort"
		
	fi
	
	echo "$currentPort"
	
	_validatePort "$currentPort"
}

_test_waitport() {
	_getDep nmap
}

_showPort_ipv6() {
	nmap -6 --host-timeout "$netTimeout" -Pn "$1" -p "$2" 2> /dev/null
}

_showPort_ipv4() {
	nmap --host-timeout "$netTimeout" -Pn "$1" -p "$2" 2> /dev/null
}

_checkPort_ipv6() {
	if _showPort_ipv6 "$@" | grep open > /dev/null 2>&1
	then
		return 0
	fi
	return 1
}

#Checks hostname for open port.
#"$1" == hostname
#"$2" == port
_checkPort_ipv4() {
	if _showPort_ipv4 "$@" | grep open > /dev/null 2>&1
	then
		return 0
	fi
	return 1
}

_checkPort_sequence() {
	_start
	
	local currentEchoStatus
	currentEchoStatus=$(stty --file=/dev/tty -g 2>/dev/null)
	
	local currentExitStatus
	
	if ( [[ "$1" == 'localhost' ]] || [[ "$1" == '::1' ]] || [[ "$1" == '127.0.0.1' ]] )
	then
		_checkPort_ipv4 "localhost" "$2"
		return "$?"
	fi
	
	#Lack of coproc support implies old system, which implies IPv4 only.
	#if ! type coproc >/dev/null 2>&1
	#then
	#	_checkPort_ipv4 "$1" "$2"
	#	return "$?"
	#fi
	
	( ( _showPort_ipv4 "$1" "$2" ) 2> /dev/null > "$safeTmp"/_showPort_ipv4 & )
	
	( ( _showPort_ipv6 "$1" "$2" ) 2> /dev/null > "$safeTmp"/_showPort_ipv6 & )
	
	
	local currentTimer
	currentTimer=1
	while [[ "$currentTimer" -le "$netTimeout" ]]
	do
		grep -m1 'open' "$safeTmp"/_showPort_ipv4 > /dev/null 2>&1 && _stop
		grep -m1 'open' "$safeTmp"/_showPort_ipv6 > /dev/null 2>&1 && _stop
		
		! [[ $(jobs | wc -c) -gt '0' ]] && ! grep -m1 'open' "$safeTmp"/_showPort_ipv4 && grep -m1 'open' "$safeTmp"/_showPort_ipv6 > /dev/null 2>&1 && _stop 1
		
		let currentTimer="$currentTimer"+1
		sleep 1
	done
	
	
	_stop 1
}

# DANGER: Unstable, abandoned. Reference only.
# WARNING: Limited support for older systems.
#https://unix.stackexchange.com/questions/86270/how-do-you-use-the-command-coproc-in-various-shells
#http://wiki.bash-hackers.org/syntax/keywords/coproc
#http://mywiki.wooledge.org/BashFAQ/024
#[[ $COPROC_PID ]] && kill $COPROC_PID
#coproc { bash -c '(sleep 9 ; echo test) &' ; bash -c 'echo test' ;  } ; grep -m1 test <&${COPROC[0]}
#coproc { echo test ; echo x ; } ; sleep 1 ; grep -m1 test <&${COPROC[0]}
_checkPort_sequence_coproc() {
	local currentEchoStatus
	currentEchoStatus=$(stty --file=/dev/tty -g 2>/dev/null)
	
	local currentExitStatus
	
	if ( [[ "$1" == 'localhost' ]] || [[ "$1" == '::1' ]] || [[ "$1" == '127.0.0.1' ]] )
	then
		_checkPort_ipv4 "localhost" "$2"
		return "$?"
	fi
	
	#Lack of coproc support implies old system, which implies IPv4 only.
	if ! type coproc >/dev/null 2>&1
	then
		_checkPort_ipv4 "$1" "$2"
		return "$?"
	fi
	
	#coproc { sleep 30 ; echo foo ; sleep 30 ; echo bar; } ; grep -m1 foo <&${COPROC[0]}
	#[[ $COPROC_PID ]] && kill $COPROC_PID ; coproc { ((sleep 1 ; echo test) &) ; echo x ; sleep 3 ; } ; sleep 0.1 ; grep -m1 test <&${COPROC[0]}
	
	[[ "$COPROC_PID" ]] && kill "$COPROC_PID" > /dev/null 2>&1
	coproc {
		( ( _showPort_ipv4 "$1" "$2" ) & )
		
		#[sleep] Lessens unlikely occurrence of interleaved text within "open" keyword.
		#IPv6 delayed instead of IPv4 due to likelihood of additional delay by IPv6 tunneling.
		#sleep 0.1
		
		# TODO: Better characterize problems with sleep.
		# Workaround - sleep may disable 'stty echo', which may be irreversable within SSH proxy command.
		#_timeout 0.1 cat < /dev/zero > /dev/null
		if ! ping -c 2 -i 0.1 localhost > /dev/null 2>&1
		then
			ping -c 2 -i 1 localhost > /dev/null 2>&1
		fi
		
		#[sleep] Lessens unlikely occurrence of interleaved text within "open" keyword.
		#IPv6 delayed instead of IPv4 due to likelihood of additional delay by IPv6 tunneling.
		( ( _showPort_ipv6 "$1" "$2" ) & )

		#sleep 2
		ping -c 2 -i 2 localhost > /dev/null 2>&1
	}
	grep -m1 open <&"${COPROC[0]}" > /dev/null 2>&1
	currentExitStatus="$?"
	
	stty --file=/dev/tty "$currentEchoStatus" 2> /dev/null
	
	return "$currentExitStatus"
}

#Checks hostname for open port.
#"$1" == hostname
#"$2" == port
_checkPort() {
	#local currentEchoStatus
	#currentEchoStatus=$(stty --file=/dev/tty -g 2>/dev/null)
	
	#if bash -c \""$scriptAbsoluteLocation"\"\ _checkPort_sequence\ \""$1"\"\ \""$2"\" > /dev/null 2>&1
	if "$scriptAbsoluteLocation" _checkPort_sequence "$1" "$2" > /dev/null 2>&1
	then
		#stty --file=/dev/tty "$currentEchoStatus" 2> /dev/null
		return 0
	fi
	#stty --file=/dev/tty "$currentEchoStatus" 2> /dev/null
	return 1
}


#Waits a reasonable time interval for port to be open.
#"$1" == hostname
#"$2" == port
_waitPort() {
	_checkPort "$1" "$2" && return 0
	sleep 0.1
	_checkPort "$1" "$2" && return 0
	sleep 0.1
	_checkPort "$1" "$2" && return 0
	sleep 0.1
	_checkPort "$1" "$2" && return 0
	sleep 0.1
	_checkPort "$1" "$2" && return 0
	sleep 0.1
	_checkPort "$1" "$2" && return 0
	sleep 0.1
	_checkPort "$1" "$2" && return 0
	sleep 0.1
	_checkPort "$1" "$2" && return 0
	sleep 0.1
	_checkPort "$1" "$2" && return 0
	sleep 0.3
	_checkPort "$1" "$2" && return 0
	sleep 0.3
	_checkPort "$1" "$2" && return 0
	sleep 0.6
	
	local checksDone
	checksDone=0
	while ! _checkPort "$1" "$2" && [[ "$checksDone" -lt 72 ]]
	do
		let checksDone+=1
		sleep 1
	done
	
	return 0
}

#Run command and output to terminal with colorful formatting. Controlled variant of "bash -v".
_showCommand() {
	echo -e '\E[1;32;46m $ '"$1"' \E[0m'
	"$@"
}

#Validates non-empty request.
_validateRequest() {
	echo -e -n '\E[1;32;46m Validating request '"$1"'...	\E[0m'
	[[ "$1" == "" ]] && echo -e '\E[1;33;41m BLANK \E[0m' && return 1
	echo "PASS"
	return
}

#http://www.commandlinefu.com/commands/view/3584/remove-color-codes-special-characters-with-sed
_nocolor() {
	sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
}

_noFireJail() {
	if ( [[ -L /usr/local/bin/"$1" ]] && ls -l /usr/local/bin/"$1" | grep firejail > /dev/null 2>&1 ) || ( [[ -L /usr/bin/"$1" ]] && ls -l /usr/bin/"$1" | grep firejail > /dev/null 2>&1 )
	then
		 _messagePlain_bad 'conflict: firejail: '"$1"
		 return 1
	fi
	
	return 0
}

#Copy log files to "$permaLog" or current directory (default) for analysis.
_preserveLog() {
	if [[ ! -d "$permaLog" ]]
	then
		permaLog="$PWD"
	fi
	
	cp "$logTmp"/* "$permaLog"/ > /dev/null 2>&1
}

_typeDep() {
	[[ -e /lib/"$1" ]] && return 0
	[[ -e /lib/x86_64-linux-gnu/"$1" ]] && return 0
	[[ -e /lib64/"$1" ]] && return 0
	[[ -e /lib64/x86_64-linux-gnu/"$1" ]] && return 0
	[[ -e /usr/lib/"$1" ]] && return 0
	[[ -e /usr/lib/x86_64-linux-gnu/"$1" ]] && return 0
	[[ -e /usr/local/lib/"$1" ]] && return 0
	[[ -e /usr/local/lib/x86_64-linux-gnu/"$1" ]] && return 0
	[[ -e /usr/include/"$1" ]] && return 0
	[[ -e /usr/local/include/"$1" ]] && return 0
	
	if ! type "$1" >/dev/null 2>&1
	then
		return 1
	fi
	
	return 0
}

_wantDep() {
	_typeDep "$1" && return 0
	
	_wantSudo && sudo -n "$scriptAbsoluteLocation" _typeDep "$1" && return 0
	
	return 1
}

_mustGetDep() {
	_typeDep "$1" && return 0
	
	_wantSudo && sudo -n "$scriptAbsoluteLocation" _typeDep "$1" && return 0
	
	echo "$1" missing
	_stop 1
}

_fetchDep_distro() {
	if [[ -e /etc/issue ]] && cat /etc/issue | grep 'Debian' > /dev/null 2>&1
	then
		_tryExecFull _fetchDep_debian "$@"
		return
	fi
	return 1
}

_wantGetDep() {
	_wantDep "$@" && return 0
	
	_fetchDep_distro "$@"
	
	_wantDep "$@" && return 0
	return 1
}

_getDep() {
	_wantDep "$@" && return 0
	
	_fetchDep_distro "$@"
	
	_mustGetDep "$@"
}

_apt-file_sequence() {
	_start
	
	_mustGetSudo
	#_mustGetDep su
	
	! _wantDep apt-file && sudo -n apt-get install --install-recommends -y apt-file
	_checkDep apt-file
	
	sudo -n apt-file "$@" > "$safeTmp"/pkgsOut 2> "$safeTmp"/pkgsErr
	sudo -n apt-file search bash > "$safeTmp"/checkOut 2> "$safeTmp"/checkErr
	
	while ! [[ -s "$safeTmp"/checkOut ]] || cat "$safeTmp"/pkgsErr | grep 'cache is empty' > /dev/null 2>&1
	do
		sudo -n apt-file update > "$safeTmp"/updateOut 2> "$safeTmp"/updateErr
		sudo -n apt-file "$@" > "$safeTmp"/pkgsOut 2> "$safeTmp"/pkgsErr
		sudo -n apt-file search bash > "$safeTmp"/checkOut 2> "$safeTmp"/checkErr
	done
	
	cat "$safeTmp"/pkgsOut
	#cat "$safeTmp"/pkgsErr >&2
	_stop
}

_apt-file() {
	_timeout 750 "$scriptAbsoluteLocation" _apt-file_sequence "$@"
}

_fetchDep_debianStretch_special() {
	if [[ "$1" == *"wine"* ]] && ! dpkg --print-foreign-architectures | grep i386 > /dev/null 2>&1
	then
		sudo -n dpkg --add-architecture i386
		sudo -n apt-get update
		sudo -n apt-get install --install-recommends -y wine wine32 wine64 libwine libwine:i386 fonts-wine
		return 0
	fi
	
	if [[ "$1" == "realpath" ]] || [[ "$1" == "readlink" ]] || [[ "$1" == "dirname" ]] || [[ "$1" == "basename" ]] || [[ "$1" == "sha512sum" ]] || [[ "$1" == "sha256sum" ]] || [[ "$1" == "head" ]] || [[ "$1" == "tail" ]] || [[ "$1" == "sleep" ]] || [[ "$1" == "env" ]] || [[ "$1" == "cat" ]] || [[ "$1" == "mkdir" ]] || [[ "$1" == "dd" ]] || [[ "$1" == "rm" ]] || [[ "$1" == "ln" ]] || [[ "$1" == "ls" ]] || [[ "$1" == "test" ]] || [[ "$1" == "true" ]] || [[ "$1" == "false" ]]
	then
		sudo -n apt-get install --install-recommends -y coreutils
		return 0
	fi
	
	if [[ "$1" == "mount" ]] || [[ "$1" == "umount" ]] || [[ "$1" == "losetup" ]]
	then
		sudo -n apt-get install --install-recommends -y mount
		return 0
	fi
	
	if [[ "$1" == "mountpoint" ]] || [[ "$1" == "mkfs" ]]
	then
		sudo -n apt-get install --install-recommends -y util-linux
		return 0
	fi
	
	if [[ "$1" == "mkfs.ext4" ]]
	then
		sudo -n apt-get install --install-recommends -y e2fsprogs
		return 0
	fi
	
	if [[ "$1" == "parted" ]] || [[ "$1" == "partprobe" ]]
	then
		sudo -n apt-get install --install-recommends -y parted
		return 0
	fi
	
	if [[ "$1" == "qemu-arm-static" ]] || [[ "$1" == "qemu-armeb-static" ]]
	then
		sudo -n apt-get install --install-recommends -y qemu qemu-user-static binfmt-support
		#update-binfmts --display
		return 0
	fi
	
	if [[ "$1" == "qemu-system-x86_64" ]]
	then
		sudo -n apt-get install --install-recommends -y qemu-system-x86
		return 0
	fi
	
	if [[ "$1" == "qemu-img" ]]
	then
		sudo -n apt-get install --install-recommends -y qemu-utils
		return 0
	fi
	
	if [[ "$1" == "VirtualBox" ]] || [[ "$1" == "VBoxSDL" ]] || [[ "$1" == "VBoxManage" ]] || [[ "$1" == "VBoxHeadless" ]]
	then
		sudo -n mkdir -p /etc/apt/sources.list.d
		echo 'deb http://download.virtualbox.org/virtualbox/debian stretch contrib' | sudo -n tee /etc/apt/sources.list.d/vbox.list > /dev/null 2>&1
		
		"$scriptAbsoluteLocation" _getDep wget
		! _wantDep wget && return 1
		
		# TODO Check key fingerprints match "B9F8 D658 297A F3EF C18D  5CDF A2F6 83C5 2980 AECF" and "7B0F AB3A 13B9 0743 5925  D9C9 5442 2A4B 98AB 5139" respectively.
		wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo -n apt-key add -
		wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo -n apt-key add -
		
		sudo -n apt-get update
		sudo -n apt-get install --install-recommends -y dkms virtualbox-6.0
		
		echo "WARNING: Recommend manual system configuration after install. See https://www.virtualbox.org/wiki/Downloads ."
		
		return 0
	fi
	
	if [[ "$1" == "gpg" ]]
	then
		sudo -n apt-get install --install-recommends -y gnupg
		return 0
	fi
	
	#Unlikely scenario for hosts.
	if [[ "$1" == "grub-install" ]]
	then
		sudo -n apt-get install --install-recommends -y grub2
		#sudo -n apt-get install --install-recommends -y grub-legacy
		return 0
	fi
	
	if [[ "$1" == "MAKEDEV" ]]
	then
		sudo -n apt-get install --install-recommends -y makedev
		return 0
	fi
	
	if [[ "$1" == "fgrep" ]]
	then
		sudo -n apt-get install --install-recommends -y grep
		return 0
	fi
	
	if [[ "$1" == "fgrep" ]]
	then
		sudo -n apt-get install --install-recommends -y grep
		return 0
	fi
	
	if [[ "$1" == "awk" ]]
	then
		sudo -n apt-get install --install-recommends -y mawk
		return 0
	fi
	
	if [[ "$1" == "kill" ]] || [[ "$1" == "ps" ]]
	then
		sudo -n apt-get install --install-recommends -y procps
		return 0
	fi
	
	if [[ "$1" == "find" ]]
	then
		sudo -n apt-get install --install-recommends -y findutils
		return 0
	fi
	
	if [[ "$1" == "docker" ]]
	then
		sudo -n apt-get install --install-recommends -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
		
		"$scriptAbsoluteLocation" _getDep curl
		! _wantDep curl && return 1
		
		curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo -n apt-key add -
		local aptKeyFingerprint
		aptKeyFingerprint=$(sudo -n apt-key fingerprint 0EBFCD88 2> /dev/null)
		[[ "$aptKeyFingerprint" == "" ]] && return 1
		
		sudo -n add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
		
		sudo -n apt-get update
		
		sudo -n apt-get remove -y docker docker-engine docker.io docker-ce docker
		sudo -n apt-get install --install-recommends -y docker-ce
		
		sudo -n usermod -a -G docker "$USER"
		
		return 0
	fi
	
	if [[ "$1" == "smbd" ]]
	then
		sudo -n apt-get install --install-recommends -y samba
		return 0
	fi
	
	if [[ "$1" == "atom" ]]
	then
		curl -L https://packagecloud.io/AtomEditor/atom/gpgkey | sudo -n apt-key add -
		sudo -n sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
		
		sudo -n apt-get update
		
		sudo -n apt-get install --install-recommends -y atom
		
		return 0
	fi
	
	if [[ "$1" == "GL/gl.h" ]] || [[ "$1" == "GL/glext.h" ]] || [[ "$1" == "GL/glx.h" ]] || [[ "$1" == "GL/glxext.h" ]] || [[ "$1" == "GL/dri_interface.h" ]] || [[ "$1" == "x86_64-linux-gnu/pkgconfig/dri.pc" ]]
	then
		sudo -n apt-get install --install-recommends -y mesa-common-dev
		
		return 0
	fi
	
	if [[ "$1" == "go" ]]
	then
		sudo -n apt-get install --install-recommends -y golang-go
		
		return 0
	fi
	
	if [[ "$1" == "php" ]]
	then
		sudo -n apt-get install --no-install-recommends -y php
		
		return 0
	fi
	
	if [[ "$1" == "cura-lulzbot" ]]
	then
		#Testing/Sid only as of Stretch release cycle.
		#sudo -n apt-get install --install-recommends -y rustc cargo
		
		echo "Requires manual installation. See https://www.lulzbot.com/learn/tutorials/cura-lulzbot-edition-installation-debian ."
cat << 'CZXWXcRMTo8EmM8i4d'
wget -qO - https://download.alephobjects.com/ao/aodeb/aokey.pub | sudo -n apt-key add -
sudo -n cp /etc/apt/sources.list /etc/apt/sources.list.bak && sudo -n sed -i '$a deb http://download.alephobjects.com/ao/aodeb jessie main' /etc/apt/sources.list && sudo -n apt-get update && sudo -n apt-get install cura-lulzbot
CZXWXcRMTo8EmM8i4d
		echo "(typical)"
		_stop 1
	fi
	
	if [[ "$1" =~ "FlashPrint" ]]
	then
		#Testing/Sid only as of Stretch release cycle.
		#sudo -n apt-get install --install-recommends -y rustc cargo
		
		echo "Requires manual installation. See http://www.flashforge.com/support-center/flashprint-support/ ."
		_stop 1
	fi
	
	if [[ "$1" == "cargo" ]] || [[ "$1" == "rustc" ]]
	then
		#Testing/Sid only as of Stretch release cycle.
		#sudo -n apt-get install --install-recommends -y rustc cargo
		
		echo "Requires manual installation."
cat << 'CZXWXcRMTo8EmM8i4d'
curl https://sh.rustup.rs -sSf | sh
echo '[[ -e "$HOME"/.cargo/bin ]] && export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
CZXWXcRMTo8EmM8i4d
		echo "(typical)"
		_stop 1
	fi
	
	if [[ "$1" == "firejail" ]]
	then
		echo "WARNING: Recommend manual system configuration after install. See https://firejail.wordpress.com/download-2/ ."
		echo "WARNING: Desktop override symlinks may cause problems, especially preventing proxy host jumping by CoreAutoSSH!"
		return 1
	fi
	
	
	return 1
}

_fetchDep_debianStretch_sequence() {
	_start
	
	_mustGetSudo
	
	_wantDep "$1" && _stop 0
	
	_fetchDep_debianStretch_special "$@" && _wantDep "$1" && _stop 0
	
	sudo -n apt-get install --install-recommends -y "$1" && _wantDep "$1" && _stop 0
	
	_apt-file search "$1" > "$safeTmp"/pkgsOut 2> "$safeTmp"/pkgsErr
	
	local sysPathAll
	sysPathAll=$(sudo -n bash -c "echo \$PATH")
	sysPathAll="$PATH":"$sysPathAll"
	local sysPathArray
	IFS=':' read -r -a sysPathArray <<< "$sysPathAll"
	
	local currentSysPath
	local matchingPackageFile
	local matchingPackagePattern
	local matchingPackage
	for currentSysPath in "${sysPathArray[@]}"
	do
		matchingPackageFile=""
		matchingPackagePath=""
		matchingPackage=""
		matchingPackagePattern="$currentSysPath"/"$1"
		matchingPackageFile=$(grep ': '$matchingPackagePattern'$' "$safeTmp"/pkgsOut | cut -f2- -d' ')
		matchingPackage=$(grep ': '$matchingPackagePattern'$' "$safeTmp"/pkgsOut | cut -f1 -d':')
		if [[ "$matchingPackage" != "" ]]
		then
			sudo -n apt-get install --install-recommends -y "$matchingPackage"
			_wantDep "$1" && _stop 0
		fi
	done
	matchingPackage=""
	matchingPackage=$(head -n 1 "$safeTmp"/pkgsOut | cut -f1 -d':')
	sudo -n apt-get install --install-recommends -y "$matchingPackage"
	_wantDep "$1" && _stop 0
	
	_stop 1
}

_fetchDep_debianStretch() {
	#Run up to 2 times. On rare occasion, cache will become unusable again by apt-find before an installation can be completed. Overall, apt-find is the single weakest link in the system.
	"$scriptAbsoluteLocation" _fetchDep_debianStretch_sequence "$@"
	"$scriptAbsoluteLocation" _fetchDep_debianStretch_sequence "$@"
}

_fetchDep_debian() {
	if [[ -e /etc/debian_version ]] && cat /etc/debian_version | head -c 1 | grep 9 > /dev/null 2>&1
	then
		_fetchDep_debianStretch "$@"
		return
	fi
	
	if [[ -e /etc/debian_version ]] && cat /etc/debian_version | head -c 2 | grep 10 > /dev/null 2>&1
	then
		_fetchDep_debianStretch "$@"
		return
	fi
	
	return 1
}

#https://unix.stackexchange.com/questions/39226/how-to-run-a-script-with-systemd-right-before-shutdown


_here_systemd_shutdown_action() {

cat << 'CZXWXcRMTo8EmM8i4d'
[Unit]
Description=...

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/true
CZXWXcRMTo8EmM8i4d

echo ExecStop="$scriptAbsoluteLocation" "$@"

cat << 'CZXWXcRMTo8EmM8i4d'

[Install]
WantedBy=multi-user.target
CZXWXcRMTo8EmM8i4d

}

_here_systemd_shutdown() {

cat << 'CZXWXcRMTo8EmM8i4d'
[Unit]
Description=...

[Service]
Type=oneshot
RemainAfterExit=true
CZXWXcRMTo8EmM8i4d

echo ExecStop="$scriptAbsoluteLocation" _remoteSigTERM "$safeTmp"/.pid "$sessionid"

cat << 'CZXWXcRMTo8EmM8i4d'

[Install]
WantedBy=multi-user.target
CZXWXcRMTo8EmM8i4d

}

_hook_systemd_shutdown() {
	[[ -e /etc/systemd/system/"$sessionid".service ]] && return 0
	
	! _wantSudo && return 1
	
	! [[ -e /etc/systemd/system ]] && return 0
	
	_here_systemd_shutdown | sudo -n tee /etc/systemd/system/"$sessionid".service > /dev/null
	sudo -n systemctl enable "$sessionid".service 2>&1 | sudo -n tee -a "$permaLog"/gsysd.log > /dev/null 2>&1
	sudo -n systemctl start "$sessionid".service 2>&1 | sudo -n tee -a "$permaLog"/gsysd.log > /dev/null 2>&1
}

_hook_systemd_shutdown_action() {
	[[ -e /etc/systemd/system/"$sessionid".service ]] && return 0
	
	! _wantSudo && return 1
	
	! [[ -e /etc/systemd/system ]] && return 0
	
	_here_systemd_shutdown_action "$@" | sudo -n tee /etc/systemd/system/"$sessionid".service > /dev/null
	sudo -n systemctl enable "$sessionid".service 2>&1 | sudo -n tee -a "$permaLog"/gsysd.log > /dev/null 2>&1
	sudo -n systemctl start "$sessionid".service 2>&1 | sudo -n tee -a "$permaLog"/gsysd.log > /dev/null 2>&1
	
}

#"$1" == sessionid (optional override for cleaning up stale systemd files)
_unhook_systemd_shutdown() {
	local hookSessionid
	hookSessionid="$sessionid"
	[[ "$1" != "" ]] && hookSessionid="$1"
	
	[[ ! -e /etc/systemd/system/"$hookSessionid".service ]] && return 0
	
	! _wantSudo && return 1
	
	! [[ -e /etc/systemd/system ]] && return 0
	
	[[ "$SYSTEMCTLDISABLE" == "true" ]] && echo SYSTEMCTLDISABLE | sudo -n tee -a "$permaLog"/gsysd.log > /dev/null 2>&1 && return 0
	export SYSTEMCTLDISABLE=true
	
	sudo -n systemctl disable "$hookSessionid".service 2>&1 | sudo -n tee -a "$permaLog"/gsysd.log > /dev/null 2>&1
	sudo -n rm -f /etc/systemd/system/"$hookSessionid".service 2>&1 | sudo -n tee -a "$permaLog"/gsysd.log > /dev/null 2>&1
}

#Determines if user is root. If yes, then continue. If not, exits after printing error message.
_mustBeRoot() {
if [[ $(id -u) != 0 ]]; then 
	echo "This must be run as root!"
	exit
fi
}
alias mustBeRoot=_mustBeRoot

#Determines if sudo is usable by scripts.
_mustGetSudo() {
	local rootAvailable
	rootAvailable=false
	
	rootAvailable=$(sudo -n echo true)
	
	#[[ $(id -u) == 0 ]] && rootAvailable=true
	
	! [[ "$rootAvailable" == "true" ]] && exit 1
	
	return 0
}

#Determines if sudo is usable by scripts. Will not exit on failure.
_wantSudo() {
	local rootAvailable
	rootAvailable=false
	
	rootAvailable=$(sudo -n echo true 2> /dev/null)
	
	#[[ $(id -u) == 0 ]] && rootAvailable=true
	
	! [[ "$rootAvailable" == "true" ]] && return 1
	
	return 0
}

#Returns a UUID in the form of xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
_getUUID() {
	cat /proc/sys/kernel/random/uuid
}
alias getUUID=_getUUID

_stopwatch() {
	local measureDateA
	local measureDateB
	
	measureDateA=$(date +%s%N | cut -b1-13)

	"$@"

	measureDateB=$(date +%s%N | cut -b1-13)

	bc <<< "$measureDateB - $measureDateA"
}


_start_virt_instance() {
	
	mkdir -p "$instancedVirtDir" || return 1
	mkdir -p "$instancedVirtFS" || return 1
	mkdir -p "$instancedVirtTmp" || return 1
	
	mkdir -p "$instancedVirtHome" || return 1
	###mkdir -p "$instancedVirtHomeRef" || return 1
	
	mkdir -p "$sharedHostProjectDir" > /dev/null 2>&1
	mkdir -p "$instancedProjectDir" || return 1
	
}

_start_virt_all() {
	
	_start_virt_instance
	
	mkdir -p "$globalVirtDir" || return 1
	mkdir -p "$globalVirtFS" || return 1
	mkdir -p "$globalVirtTmp" || return 1
	
	
	return 0
}

_stop_virt_instance() {
	
	_wait_umount "$instancedProjectDir"
	sudo -n rmdir "$instancedProjectDir"
	
	_wait_umount "$instancedVirtHome"
	sudo -n rmdir "$instancedVirtHome"
	###_wait_umount "$instancedVirtHomeRef"
	###sudo -n rmdir "$instancedVirtHomeRef"
	sudo -n rmdir "$instancedVirtFS"/home
	
	_wait_umount "$instancedVirtFS"
	sudo -n rmdir "$instancedVirtFS"
	_wait_umount "$instancedVirtTmp"
	sudo -n rmdir "$instancedVirtTmp"
	_wait_umount "$instancedVirtDir"
	sudo -n rmdir "$instancedVirtDir"
	
	
	
	return 0
	
}

_stop_virt_all() {
	
	_stop_virt_instance || return 1
	
	_wait_umount "$globalVirtFS" || return 1
	_wait_umount "$globalVirtTmp" || return 1
	_wait_umount "$globalVirtDir" || return 1
	
	
	
}


#Triggers before "user" and "edit" virtualization commands, to allow a single installation of a virtual machine to be used by multiple ubiquitous labs.
#Does NOT trigger for all non-user commands (eg. open, docker conversion), as these are intended for developers with awareness of associated files under "$scriptLocal".

# WARNING
# DISABLED by default. Must be explicitly enabled by setting "$ubVirtImageLocal" to "false" in "ops".

#toImage

#_closeChRoot

#_closeVBoxRaw

#_editQemu
#_editVBox

#_userChRoot
#_userQemu
#_userVBox

#_userDocker

#_dockerCommit
#_dockerLaunch
#_dockerAttach
#_dockerOn
#_dockerOff

_findInfrastructure_virtImage() {
	[[ "$ubVirtImageLocal" != "false" ]] && return 0
	
	[[ -e "$scriptLocal"/vm.img ]] && export ubVirtImageLocal="true" && return 0
	[[ -e "$scriptLocal"/vm.vdi ]] && export ubVirtImageLocal="true" && return 0
	[[ -e "$scriptLocal"/vmvdiraw.vmdi ]] && export ubVirtImageLocal="true" && return 0
	
	# WARNING: Override implies local image.
	[[ "$ubVirtImageIsRootPartition" != "" ]] && export ubVirtImageLocal="true" && return 0
	[[ "$ubVirtImageIsDevice" != "" ]] && export ubVirtImageLocal="true" && return 0
	[[ "$ubVirtImageOverride" != "" ]] && export ubVirtImageLocal="true" && return 0
	[[ "$ubVirtDeviceOverride" != "" ]] && export ubVirtImageLocal="true" && return 0
	#[[ "$ubVirtPlatformOverride" != "" ]] && export ubVirtImageLocal="true" && return 0
	
	# WARNING: Symlink implies local image (even if non-existent destination).
	[[ -h "$scriptLocal"/vm.img ]] && export ubVirtImageLocal="true" && return 0
	[[ -h "$scriptLocal"/vm.vdi ]] && export ubVirtImageLocal="true" && return 0
	[[ -h "$scriptLocal"/vmvdiraw.vmdi ]] && export ubVirtImageLocal="true" && return 0
	
	_checkSpecialLocks && export ubVirtImageLocal="true" && return 0
	
	# DANGER: Recursion hazard.
	_findInfrastructure_virtImage_script "$@"
}

# WARNING
#Overloading with "ops" is recommended.
_findInfrastructure_virtImage_script() {
	local infrastructureName=$(basename "$scriptAbsoluteFolder")
	
	local recursionExec
	local recursionExecList
	local currentRecursionExec
	
	recursionExecList+=("$scriptAbsoluteFolder"/../core/infrastructure/vm/"$infrastructureName"/ubiquitous_bash.sh)
	#recursionExecList+=("$scriptAbsoluteFolder"/../core/lab/"$infrastructureName"/ubiquitous_bash.sh)
	
	recursionExecList+=("$scriptAbsoluteFolder"/../../core/infrastructure/vm/"$infrastructureName"/ubiquitous_bash.sh)
	#recursionExecList+=("$scriptAbsoluteFolder"/../../core/lab/"$infrastructureName"/ubiquitous_bash.sh)
	
	recursionExecList+=("$scriptAbsoluteFolder"/../../../core/infrastructure/vm/"$infrastructureName"/ubiquitous_bash.sh)
	#recursionExecList+=("$scriptAbsoluteFolder"/../../../core/lab/"$infrastructureName"/ubiquitous_bash.sh)
	
	recursionExecList+=("$scriptAbsoluteFolder"/../../../../core/infrastructure/vm/"$infrastructureName"/ubiquitous_bash.sh)
	#recursionExecList+=("$scriptAbsoluteFolder"/../../../../core/lab/"$infrastructureName"/ubiquitous_bash.sh)
	
	recursionExecList+=("$scriptAbsoluteFolder"/../../../../../core/infrastructure/vm/"$infrastructureName"/ubiquitous_bash.sh)
	#recursionExecList+=("$scriptAbsoluteFolder"/../../../../../core/lab/"$infrastructureName"/ubiquitous_bash.sh)
	
	recursionExecList+=("$scriptAbsoluteFolder"/../../../../../../core/infrastructure/vm/"$infrastructureName"/ubiquitous_bash.sh)
	#recursionExecList+=("$scriptAbsoluteFolder"/../../../../../../core/lab/"$infrastructureName"/ubiquitous_bash.sh)
	
	recursionExecList+=("$scriptAbsoluteFolder"/../../../../../../../core/infrastructure/vm/"$infrastructureName"/ubiquitous_bash.sh)
	#recursionExecList+=("$scriptAbsoluteFolder"/../../../../../../../core/lab/"$infrastructureName"/ubiquitous_bash.sh)
	
	recursionExecList+=("$HOME"/core/infrastructure/vm/"$infrastructureName"/ubiquitous_bash.sh)
	
	recursionExecList+=("$HOME"/core/extra/infrastructure/vm/"$infrastructureName"/ubiquitous_bash.sh)
	
	local whichExeVM
	whichExeVM=nixexevm
	[[ "$virtOStype" == 'MSW'* ]] && whichExeVM=winexevm
	[[ "$virtOStype" == 'Windows'* ]] && whichExeVM=winexevm
	[[ "$vboxOStype" == 'Windows'* ]] && whichExeVM=winexevm
	
	
	recursionExecList+=("$scriptAbsoluteFolder"/../core/infrastructure/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../core/infrastructure/vm/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../../core/infrastructure/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../../core/infrastructure/vm/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../../../core/infrastructure/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../../../core/infrastructure/vm/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../../../../core/infrastructure/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../../../../core/infrastructure/vm/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../../../../../core/infrastructure/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../../../../../core/infrastructure/vm/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../../../../../../core/infrastructure/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../../../../../../core/infrastructure/vm/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../../../../../../../core/infrastructure/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$scriptAbsoluteFolder"/../../../../../../../core/infrastructure/vm/"$whichExeVM"/ubiquitous_bash.sh)
	
	recursionExecList+=("$HOME"/core/infrastructure/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$HOME"/core/extra/infrastructure/"$whichExeVM"/ubiquitous_bash.sh)
	
	recursionExecList+=("$HOME"/core/infrastructure/vm/"$whichExeVM"/ubiquitous_bash.sh)
	recursionExecList+=("$HOME"/core/extra/infrastructure/vm/"$whichExeVM"/ubiquitous_bash.sh)
	
	for currentRecursionExec in "${recursionExecList[@]}"
	do
		if _recursion_guard "$currentRecursionExec"
		then
			"$currentRecursionExec" "$@"
			return
		fi
	done
}


#Removes 'file://' often used by browsers.
_removeFilePrefix() {
	local translatedFileParam
	translatedFileParam=${1/#file:\/\/}
	
	_safeEcho_newline "$translatedFileParam"
}

#Translates back slash parameters (UNIX paths) to forward slash parameters (MSW paths).
_slashBackToForward() {
	local translatedFileParam
	translatedFileParam=${1//\//\\}
	
	_safeEcho_newline "$translatedFileParam"
}

_nixToMSW() {
	echo -e -n 'Z:'
	
	local localAbsoluteFirstParam
	localAbsoluteFirstParam=$(_getAbsoluteLocation "$1")
	
	local intermediateStepOne
	intermediateStepOne=_removeFilePrefix "$localAbsoluteFirstParam"
	
	_slashBackToForward "$intermediateStepOne"
}

_test_localpath() {
	_getDep realpath
}


#Determines whether test parameter is in the path of base parameter.
#"$1" == testParameter
#"$2" == baseParameter
_pathPartOf() {
	local testParameter
	testParameter="IAUjqyPF2s3gqjC0t1"
	local baseParameter
	baseParameter="JQRBqIoOVoDJuzc7k9"
	
	[[ -e "$1" ]] && testParameter=$(_getAbsoluteLocation "$1")
	[[ -e "$2" ]] && baseParameter=$(_getAbsoluteLocation "$2")
	
	[[ "$testParameter" != "$baseParameter"* ]] && return 1
	return 0
}

#Checks if file/directory exists on local filesystem, and meets other criteria. Intended to be called within the virtualization platform, through _checkBaseDirRemote . Often maintained merely for the sake of example.
_checkBaseDirLocal() {
	/bin/bash -c '[[ -e "'"$1"'" ]] && ! [[ -d "'"$1"'" ]] && [[ "'"$1"'" != "." ]] && [[ "'"$1"'" != ".." ]] && [[ "'"$1"'" != "./" ]] && [[ "'"$1"'" != "../" ]]'
}

_checkBaseDirRemote_app_localOnly() {
	false
}

_checkBaseDirRemote_app_remoteOnly() {
	[[ "$1" == "/bin/bash" ]] && return 0
}

# WARNING Strongly recommend not sharing root with guest, but this can be overridden by "ops".
_checkBaseDirRemote_common_localOnly() {
	[[ "$1" == "." ]] && return 0
	[[ "$1" == "./" ]] && return 0
	[[ "$1" == ".." ]] && return 0
	[[ "$1" == "../" ]] && return 0
	
	[[ "$1" == "/" ]] && return 0
	
	return 1
}

_checkBaseDirRemote_common_remoteOnly() {
	[[ "$1" == "/bin"* ]] && return 0
	[[ "$1" == "/lib"* ]] && return 0
	[[ "$1" == "/lib64"* ]] && return 0
	[[ "$1" == "/opt"* ]] && return 0
	[[ "$1" == "/usr"* ]] && return 0
	
	[[ "$1" == "/bin/bash" ]] && return 0
	
	#type "$1" > /dev/null 2>&1 && return 0
	
	#! [[ "$1" == "/"* ]] && return 0
	
	return 1
}

#Checks if file/directory exists on remote system. Overload this function with implementation specific to the container/virtualization solution in use (ie. docker run).
_checkBaseDirRemote() {
	_checkBaseDirRemote_common_localOnly "$1" && return 0
	_checkBaseDirRemote_common_remoteOnly "$1" && return 1
	
	_checkBaseDirRemote_app_localOnly "$1" && return 0
	_checkBaseDirRemote_app_remoteOnly "$1" && return 1
	
	[[ "$checkBaseDirRemote" == "" ]] && checkBaseDirRemote="false"
	"$checkBaseDirRemote" "$1" || return 1
	return 0
}

#Reports the highest-level directory containing all files in given parameter set.
#"$@" == parameters to search
#$checkBaseDirRemote == function to check if file/directory exists on remote system
_searchBaseDir() {
	local baseDir
	local newDir
	
	baseDir=""
	
	local processedArgs
	local currentArg
	local currentResult
	
	#Do not translate if exists on remote filesystem. Dummy check by default unless overloaded, by $checkBaseDirRemote value.
	#Intended to prevent "/bin/true" and similar from being translated, so execution of remote programs can be requested.
	for currentArg in "$@"
	do
		if _checkBaseDirRemote "$currentArg"
		then
			continue
		fi
		
		currentResult="$currentArg"
		processedArgs+=("$currentResult")
	done
	
	for currentArg in "${processedArgs[@]}"
	do
		
		if [[ ! -e "$currentArg" ]]
		then
			continue
		fi
		
		if [[ "$baseDir" == "" ]]
		then
			baseDir=$(_findDir "$currentArg")
		fi
		
		for subArg in "${processedArgs[@]}"
		do
			if [[ ! -e "$subArg" ]]
			then
				continue
			fi
			
			newDir=$(_findDir "$subArg")
			
			while [[ "$newDir" != "$baseDir"* ]]
			do
				baseDir=$(_findDir "$baseDir"/..)
				
				if [[ "$baseDir" == "/" ]]
				then
					break
				fi
			done
			
		done
		
		
		
		
	done
	
	_safeEcho_newline "$baseDir"
}

#Converts to relative path, if provided a file parameter.
#"$1" == parameter to search
#"$2" == sharedHostProjectDir
#"$3" == sharedGuestProjectDir (optional)
_localDir() {
	if _checkBaseDirRemote "$1"
	then
		_safeEcho_newline "$1"
		return
	fi
	
	if [[ ! -e "$2" ]]
	then
		_safeEcho_newline "$1"
		return
	fi
	
	if [[ ! -e "$1" ]] || ! _pathPartOf "$1" "$2"
	then
		_safeEcho_newline "$1"
		return
	fi
	
	[[ "$3" != "" ]] && _safeEcho "$3" && [[ "$3" != "/" ]] && _safeEcho "/"
	realpath -L -s --relative-to="$2" "$1"
	
}


#Takes a list of parameters, idenfities file parameters, finds a common path, and translates all parameters to that path. Essentially provides shared folder and file parameter translation for application virtualization solutions.
#Keep in mind this function has a relatively complex set of inputs and outputs, serving a critically wide variety of edgy use cases across platforms.
#"$@" == input parameters

#"$sharedHostProjectDir" == if already set, overrides the directory that will be shared, rarely used to share entire root
#"$sharedGuestProjectDir" == script default is /home/ubvrtusr/project, can be overridden, "X:" typical for MSW guests
#Setting sharedGuestProjectDir to a drive letter designation will also enable UNIX/MSW parameter translation mechanisms.

# export sharedHostProjectDir == common directory to bind mount
# export processedArgs == translated arguments to be used in place of "$@"

# WARNING Consider specified syntax for portability.
# _runExec "${processedArgs[@]}"
_virtUser() {
	export sharedHostProjectDir="$sharedHostProjectDir"
	export processedArgs
	
	[[ "$virtUserPWD" == "" ]] && export virtUserPWD="$outerPWD"
	
	if [[ -e /tmp/.X11-unix ]] && [[ "$DISPLAY" != "" ]] && type xauth > /dev/null 2>&1
	then
		export XSOCK=/tmp/.X11-unix
		export XAUTH=/tmp/.virtuser.xauth."$sessionid"
		touch $XAUTH
		xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
	fi
	
	if [[ "$sharedHostProjectDir" == "" ]]
	then
		sharedHostProjectDir=$(_searchBaseDir "$@" "$virtUserPWD")
		#sharedHostProjectDir="$safeTmp"/shared
		mkdir -p "$sharedHostProjectDir"
	fi
	
	export localPWD=$(_localDir "$virtUserPWD" "$sharedHostProjectDir" "$sharedGuestProjectDir")
	export virtUserPWD=
	
	#If $sharedGuestProjectDir matches MSW drive letter format, enable translation of other non-UNIX file parameter differences.
	local enableMSWtranslation
	enableMSWtranslation=false
	_safeEcho_newline "$sharedGuestProjectDir" | grep '^[[:alpha:]]\:\|^[[:alnum:]][[:alnum:]]\:\|^[[:alnum:]][[:alnum:]][[:alnum:]]\:' > /dev/null 2>&1 && enableMSWtranslation=true
	
	#http://stackoverflow.com/questions/15420790/create-array-in-loop-from-number-of-arguments
	#local processedArgs
	local currentArg
	local currentResult
	processedArgs=()
	for currentArg in "$@"
	do
		currentResult=$(_localDir "$currentArg" "$sharedHostProjectDir" "$sharedGuestProjectDir")
		[[ "$enableMSWtranslation" == "true" ]] && currentResult=$(_slashBackToForward "$currentResult")
		processedArgs+=("$currentResult")
	done
}

_stop_virtLocal() {
	[[ "$XAUTH" == "" ]] && return
	[[ ! -e "$XAUTH" ]] && return
	
	rm -f "$XAUTH" > /dev/null 2>&1
}

_test_virtLocal_X11() {
	! _wantGetDep xauth && echo warn: missing: xauth && return 1
	return 0
}

# TODO: Expansion needed.
_vector_virtUser() {
	export sharedHostProjectDir=
	export sharedGuestProjectDir=/home/user/project
	_virtUser /tmp
	#_safeEcho_newline "${processedArgs[0]}"
	[[ "${processedArgs[0]}" != '/home/user/project/tmp' ]] && echo 'fail: _vector_virtUser' && _messageFAIL
	
	export sharedHostProjectDir=/
	export sharedGuestProjectDir='Z:'
	_virtUser /tmp
	#_safeEcho_newline "${processedArgs[0]}"
	[[ "${processedArgs[0]}" != 'Z:\tmp' ]] && echo 'fail: _vector_virtUser' && _messageFAIL
	
	export sharedHostProjectDir=/tmp
	export sharedGuestProjectDir='/home/user/project/tmp'
	_virtUser /tmp
	#_safeEcho_newline "${processedArgs[0]}"
	[[ "${processedArgs[0]}" != '/home/user/project/tmp/.' ]] && echo 'fail: _vector_virtUser' && _messageFAIL
	
	export virtUserPWD='/tmp'
	export sharedHostProjectDir=/tmp
	export sharedGuestProjectDir='/home/user/project/tmp'
	_virtUser /tmp
	#_safeEcho_newline "${processedArgs[0]}"
	#_safeEcho_newline "$localPWD"
	[[ "$localPWD" != '/home/user/project/tmp/.' ]] && echo 'fail: _vector_virtUser' && _messageFAIL
	
	export virtUserPWD='/tmp'
	export sharedHostProjectDir=/tmp
	export sharedGuestProjectDir='/home/user/project/tmp'
	_virtUser -e /tmp
	#_safeEcho_newline "${processedArgs[0]}"
	[[ "${processedArgs[0]}" != '-e' ]] && echo 'fail: _vector_virtUser' && _messageFAIL
	
	
	return 0
}






_test_abstractfs_sequence() {
	export afs_nofs="true"
	if ! "$scriptAbsoluteLocation" _abstractfs ls "$scriptAbsoluteLocation" > /dev/null 2>&1
	then
		_stop 1
	fi
}

_test_abstractfs() {
	_getDep md5sum
	if ! "$scriptAbsoluteLocation" _test_abstractfs_sequence
	then
		echo 'fail: abstractfs: ls'
		_stop 1
	fi
}

_abstractfs() {
	#Nesting prohibited. Not fully tested.
	# WARNING: May cause infinite recursion symlinks.
	[[ "$abstractfs" != "" ]] && return 1
	
	_reset_abstractfs
	
	_prepare_abstract
	
	local abstractfs_command="$1"
	shift
	
	export virtUserPWD="$PWD"
	
	export abstractfs_puid=$(_uid)
	
	_base_abstractfs "$@"
	_name_abstractfs > /dev/null 2>&1
	[[ "$abstractfs_name" == "" ]] && return 1
	
	export abstractfs="$abstractfs_root"/"$abstractfs_name"
	
	_set_share_abstractfs
	_relink_abstractfs
	_virtUser "$@"
	
	cd "$localPWD"
	#cd "$abstractfs_base"
	#cd "$abstractfs"
	
	local commandExitStatus
	
	#_scope_terminal "${processedArgs[@]}"
	"$abstractfs_command" "${processedArgs[@]}"
	commandExitStatus=$?
	
	_set_share_abstractfs_reset
	_rmlink_abstractfs
	
	return "$commandExitStatus"
}

_reset_abstractfs() {
	export abstractfs=
	export abstractfs_base=
	export abstractfs_name=
	export abstractfs_puid=
	export abstractfs_projectafs=
}

_prohibit_rmlink_abstractfs() {
	#mkdir -p "$abstractfs_lock"/"$abstractfs_name"
	mkdir -p "$abstractfs_lock"/"$abstractfs_name"/"$abstractfs_puid"
}

_permit_rmlink_abstractfs() {
	#mkdir -p "$abstractfs_lock"/"$abstractfs_name"
	rmdir "$abstractfs_lock"/"$abstractfs_name"/"$abstractfs_puid" > /dev/null 2>&1
}

_wait_rmlink_abstractfs() {
	! [[ -e "$abstractfs_lock"/"$abstractfs_name"_rmlink ]] && return 0
	sleep 0.1
	
	! [[ -e "$abstractfs_lock"/"$abstractfs_name"_rmlink ]] && return 0
	sleep 0.3
	
	! [[ -e "$abstractfs_lock"/"$abstractfs_name"_rmlink ]] && return 0
	sleep 1
	
	! [[ -e "$abstractfs_lock"/"$abstractfs_name"_rmlink ]] && return 0
	sleep 3
	
	! [[ -e "$abstractfs_lock"/"$abstractfs_name"_rmlink ]] && return 0
	return 1
}

_rmlink_abstractfs() {
	mkdir -p "$abstractfs_lock"
	_permit_rmlink_abstractfs
	
	! _wait_rmlink_abstractfs && return 1
	
	echo > "$abstractfs_lock"/"$abstractfs_name"_rmlink
	
	rmdir "$abstractfs_lock"/"$abstractfs_name" >/dev/null 2>&1 && _rmlink "$abstractfs"
	rmdir "$abstractfs_root" >/dev/null 2>&1
	
	rm "$abstractfs_lock"/"$abstractfs_name"_rmlink
}

_relink_abstractfs() {
	! _wait_rmlink_abstractfs && return 1
	
	mkdir -p "$abstractfs_lock"
	_prohibit_rmlink_abstractfs
	
	! _wait_rmlink_abstractfs && return 1
	
	_relink "$sharedHostProjectDir" "$sharedGuestProjectDir"
}

#Precaution. Should not be a requirement in any production use.
_set_share_abstractfs_reset() {
	export sharedHostProjectDir="$sharedHostProjectDirDefault"
	export sharedGuestProjectDir="$sharedGuestProjectDirDefault"
}

# ATTENTION: Overload with "core.sh".
_set_share_abstractfs() {
	_set_share_abstractfs_reset
	
	export sharedHostProjectDir="$abstractfs_base"
	#export sharedHostProjectDir=$(_getAbsoluteFolder "$abstractfs_base")
	export sharedGuestProjectDir="$abstractfs"
	
	#Blank default. Resolves to lowest directory shared by "$PWD" and "$@" .
	#export sharedHostProjectDir="$sharedHostProjectDirDefault"
}

_describe_abstractfs() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	local testAbstractfsBase
	testAbstractfsBase="$abstractfs_base"
	[[ "$1" != "" ]] && testAbstractfsBase=$(_getAbsoluteLocation "$1")
	
	basename "$testAbstractfsBase"
	! cd "$testAbstractfsBase" >/dev/null 2>&1 && cd "$localFunctionEntryPWD" && return 1
	git rev-parse --abbrev-ref HEAD 2>/dev/null
	git remote show origin 2>/dev/null
	
	cd "$localFunctionEntryPWD"
}

_base_abstractfs() {
	export abstractfs_base=
	[[ "$@" != "" ]] && export abstractfs_base=$(_searchBaseDir "$@")
	[[ "$abstractfs_base" == "" ]] && export abstractfs_base=$(_searchBaseDir "$@" "$virtUserPWD")
}

_findProjectAFS_procedure() {
	[[ "$ub_findProjectAFS_maxheight" -gt "120" ]] && return 1
	let ub_findProjectAFS_maxheight="$ub_findProjectAFS_maxheight"+1
	export ub_findProjectAFS_maxheight
	
	if [[ -e "./project.afs" ]]
	then
		_getAbsoluteLocation "./project.afs"
		return 0
	fi
	
	[[ "$1" == "/" ]] && return 1
	
	! cd .. > /dev/null 2>&1 && return 1
	
	_findProjectAFS_procedure
}

#Recursively searches for directories containing "project.afs".
_findProjectAFS() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	cd "$1"
	
	_findProjectAFS_procedure
	
	cd "$localFunctionEntryPWD"
}

_projectAFS_here() {
	cat << CZXWXcRMTo8EmM8i4d
#!/usr/bin/env bash

export abstractfs_name="$abstractfs_name"
CZXWXcRMTo8EmM8i4d
}

_write_projectAFS() {
	local testAbstractfsBase
	testAbstractfsBase="$abstractfs_base"
	[[ "$1" != "" ]] && testAbstractfsBase=$(_getAbsoluteLocation "$1")
	
	( [[ "$nofs" == "true" ]] || [[ "$afs_nofs" == "true" ]] ) && return 0
	_projectAFS_here > "$testAbstractfsBase"/project.afs
	chmod u+x "$testAbstractfsBase"/project.afs
}

# DANGER: Mandatory strict directory 8.3 compliance for this variable! Long subdirectory/filenames permitted thereafter.
_default_name_abstractfs() {
	#If "$abstractfs_name" is not saved to file, a consistent, compressed, naming scheme, is required.
	if ( [[ "$nofs" == "true" ]] || [[ "$afs_nofs" == "true" ]] )
	then
		#echo $(basename "$abstractfs_base") | md5sum | head -c 8
		_describe_abstractfs "$@" | md5sum | head -c 8
		return
	fi
	
	cat /dev/urandom 2> /dev/null | base64 2> /dev/null | tr -dc 'a-z' 2> /dev/null | head -c "1" 2> /dev/null
	cat /dev/urandom 2> /dev/null | base64 2> /dev/null | tr -dc 'a-z0-9' 2> /dev/null | head -c "7" 2> /dev/null
}

#"$1" == "$abstractfs_base" || ""
_name_abstractfs() {
	export abstractfs_name=
	
	local testAbstractfsBase
	testAbstractfsBase="$abstractfs_base"
	[[ "$1" != "" ]] && testAbstractfsBase=$(_getAbsoluteLocation "$1")
	
	export abstractfs_projectafs=$(_findProjectAFS "$testAbstractfsBase")
	[[ "$abstractfs_projectafs" != "" ]] && [[ -e "$abstractfs_projectafs" ]] && . "$abstractfs_projectafs" --noexec
	
	if [[ "$abstractfs_name" == "" ]]
	then
		export abstractfs_name=$(_default_name_abstractfs "$testAbstractfsBase")
		if ( [[ "$nofs" == "true" ]] || [[ "$afs_nofs" == "true" ]] )
		then
			echo "$abstractfs_name"
			return
		fi
		_write_projectAFS "$testAbstractfsBase"
		export abstractfs_name=
	fi
	
	export abstractfs_projectafs=$(_findProjectAFS "$testAbstractfsBase")
	[[ "$abstractfs_projectafs" != "" ]] && [[ -e "$abstractfs_projectafs" ]] && . "$abstractfs_projectafs" --noexec
	
	( [[ "$nofs" == "true" ]] || [[ "$afs_nofs" == "true" ]] ) && [[ ! -e "$abstractfs_projectafs" ]] && return 1
	[[ "$abstractfs_name" == "" ]] && return 1
	
	echo "$abstractfs_name"
	return 0
}

_makeFakeHome_extra_layer0() {
	_relink "$1"/.bashrc "$2"/.bashrc
	_relink "$1"/.ubcore "$2"/.ubcore
	
	_relink "$1"/.Xauthority "$2"/.Xauthority
	
	_relink "$1"/.ssh "$2"/.ssh
	_relink "$1"/.gitconfig "$2"/.gitconfig
	
	mkdir -p "$2"/.config
}

_makeFakeHome_extra_layer1() {
	true
}

#"$1" == sourceHome
#"$2" == destinationHome
_makeFakeHome() {
	[[ "$1" == "" ]] && return 1
	! [[ -d "$1" ]] && return 1
	
	[[ "$2" == "" ]] && return 1
	[[ "$2" == "/home/""$USER" ]] && return 1
	! [[ -d "$2" ]] && return 1
	
	_relink "$1" "$2"/realHome
	
	_relink "$1"/Downloads "$2"/Downloads
	
	_relink "$1"/Desktop "$2"/Desktop
	_relink "$1"/Documents "$2"/Documents
	_relink "$1"/Music "$2"/Music
	_relink "$1"/Pictures "$2"/Pictures
	_relink "$1"/Public "$2"/Public
	_relink "$1"/Templates "$2"/Templates
	_relink "$1"/Videos "$2"/Videos
	
	_relink "$1"/bin "$2"/bin
	
	_relink "$1"/core "$2"/core
	_relink "$1"/project "$2"/project
	_relink "$1"/projects "$2"/projects
	
	
	
	_makeFakeHome_extra_layer0 "$@"
	_makeFakeHome_extra_layer1 "$@"
}

_unmakeFakeHome_extra_layer0() {
	_rmlink "$1"/.bashrc
	_rmlink "$1"/.ubcore
	
	_rmlink "$1"/.Xauthority
	
	_rmlink "$1"/.ssh
	_rmlink "$1"/.gitconfig
	
	rmdir "$1"/.config
}

_unmakeFakeHome_extra_layer1() {
	true
}

#"$1" == destinationHome
_unmakeFakeHome() {
	[[ "$1" == "" ]] && return 1
	[[ "$1" == "/home/""$USER" ]] && return 1
	! [[ -d "$1" ]] && return 1
	
	_rmlink "$1"/realHome
	
	_rmlink "$1"/Downloads
	
	_rmlink "$1"/Desktop
	_rmlink "$1"/Documents
	_rmlink "$1"/Music
	_rmlink "$1"/Pictures
	_rmlink "$1"/Public
	_rmlink "$1"/Templates
	_rmlink "$1"/Videos
	
	_rmlink "$1"/bin
	
	_rmlink "$1"/core
	_rmlink "$1"/project
	_rmlink "$1"/projects
	
	
	
	_unmakeFakeHome_extra_layer0 "$@"
	_unmakeFakeHome_extra_layer1 "$@"
}

_test_fakehome() {
	_getDep mount
	_getDep mountpoint
	
	_getDep rsync
	
	_wantGetDep dbus-run-session
}

#Example. Run similar code under "core.sh" before calling "_fakeHome", "_install_fakeHome", or similar, to set a specific type/location for fakeHome environment - global, instanced, or otherwise.
_arbitrary_fakeHome_app() {
	export actualFakeHome="$instancedFakeHome"
	#export actualFakeHome="$shortFakeHome"
	
	#export actualFakeHome="$globalFakeHome"
	#export actualFakeHome=""$arbitraryFakeHome"/arbitrary"
}

#"$1" == lib source path (eg. "$scriptLib"/app/.app)
#"$2" == home destination path (eg. ".app")
# WARNING: Locking mechanism not intended to be relied on.
# WARNING: Return status success may not reflect successful link/copy.
_link_fakeHome() {
	mkdir -p "$1" > /dev/null 2>&1
	mkdir -p "$actualFakeHome" > /dev/null 2>&1
	mkdir -p "$globalFakeHome" > /dev/null 2>&1
	
	#If globalFakeHome symlinks are obsolete, subsequent _instance_internal operation may overwrite valid links with them. See _install_fakeHome .
	rmdir "$globalFakeHome"/"$2" > /dev/null 2>&1
	_relink "$1" "$globalFakeHome"/"$2"
	
	if [[ "$actualFakeHome" == "$globalFakeHome" ]] || [[ "$fakeHomeEditLib" == "true" ]]
	then
		rmdir "$actualFakeHome"/"$2" > /dev/null 2>&1
		_relink "$1" "$actualFakeHome"/"$2"
		return 0
	fi
	
	#Actual files/directories will not be overwritten by symlinks when "$globalFakeHome" is copied to "$actualFakeHome". Remainder of this function dedicated to creating copies, before and instead of, symlinks.
	
	#rmdir "$actualFakeHome"/"$2" > /dev/null 2>&1
	_rmlink "$actualFakeHome"/"$2"
	
	#Waits if copy is in progress, delaying program launch.
	local lockWaitTimer
	for (( lockWaitTimer = 0 ; lockWaitTimer <= 90 ; lockWaitTimer++ )); do
		! [[ -e "$actualFakeHome"/"$2".lck ]] && break
		sleep 0.3
	done
	
	#Checks if copy has already been made.
	[[ -e "$actualFakeHome"/"$2" ]] && return 0
	
	mkdir -p "$actualFakeHome"/"$2"
	
	#Copy file.
	if ! [[ -d "$1" ]] && [[ -e "$1" ]]
	then
		rmdir "$actualFakeHome"/"$2" > /dev/null 2>&1
		
		echo > "$actualFakeHome"/"$2".lck
		cp "$1" "$actualFakeHome"/"$2"
		rm "$actualFakeHome"/"$2".lck
		return 0
	fi
	
	#Copy directory.
	echo > "$actualFakeHome"/"$2".lck
	_instance_internal "$1"/. "$actualFakeHome"/"$2"/
	rm "$actualFakeHome"/"$2".lck
	return 0
}

#Example. Override with "core.sh". Allows specific application configuration directories to reside outside of globalFakeHome, for organization, testing, and distribution.
_install_fakeHome_app() {
	#_link_fakeHome "$scriptLib"/app/.app ".app"
	
	true
}

#actualFakeHome
_install_fakeHome() {
	_install_fakeHome_app
	
	#Asterisk used where multiple global home folders are needed, following convention "$scriptLocal"/h_* . Used by webClient for _firefox_esr .
	[[ "$actualFakeHome" == "$globalFakeHome"* ]] && return 0
	
	#Any globalFakeHome links created by "_link_fakeHome" are not to overwrite copies made to instancedFakeHome directories. Related errors emitted by "rsync" are normal, and therefore, silenced.
	_instance_internal "$globalFakeHome"/. "$actualFakeHome"/ > /dev/null 2>&1
}

#Run before _fakeHome to use a ramdisk as home directory. Wrap within "_wantSudo" and ">/dev/null 2>&1" to use optionally. Especially helpful to limit SSD wear when dealing with moderately large (ie. ~2GB) fakeHome environments which must be instanced.
_mountRAM_fakeHome() {
	_mustGetSudo
	mkdir -p "$actualFakeHome"
	sudo -n mount -t ramfs ramfs "$actualFakeHome"
	sudo -n chown "$USER":"$USER" "$actualFakeHome"
	! mountpoint "$actualFakeHome" > /dev/null 2>&1 && _stop 1
	return 0
}

_umountRAM_fakeHome() {
	mkdir -p "$actualFakeHome"
	sudo -n umount "$actualFakeHome"
	mountpoint "$actualFakeHome" > /dev/null 2>&1 && _stop 1
	return 0
}

_begin_fakeHome() {
	#Recursive fakeHome prohibited. Instead, start new script session, with new sessionid, and keepFakeHome=false. Do not workaround without a clear understanding why this may endanger your application.
	[[ "$setFakeHome" == "true" ]] && return 1
	#_resetFakeHomeEnv_nokeep
	
	[[ "$realHome" == "" ]] && export realHome="$HOME"
	
	export HOME="$actualFakeHome"
	export setFakeHome=true
	
	_prepareFakeHome > /dev/null 2>&1
	
	_install_fakeHome
	
	_makeFakeHome "$realHome" "$actualFakeHome"
	
	export fakeHomeEditLib="false"
	
	export realScriptAbsoluteLocation="$scriptAbsoluteLocation"
	export realScriptAbsoluteFolder="$scriptAbsoluteFolder"
	export realSessionID="$sessionid"
}

#actualFakeHome
	#default: "$instancedFakeHome"
	#"$globalFakeHome" || "$instancedFakeHome" || "$shortFakeHome" || "$arbitraryFakeHome"/arbitrary
#keepFakeHome
	#default: true
	#"true" || "false"
# ATTENTION: WARNING: Do not remove or modify functionality of GUI workarounds without extensive testing!
_fakeHome() {
	_begin_fakeHome "$@"
	local fakeHomeExitStatus
	
	if ! _safeEcho_newline "$_JAVA_OPTIONS" | grep "$HOME" > /dev/null 2>&1
	then
		export _JAVA_OPTIONS=-Duser.home="$HOME"' '"$_JAVA_OPTIONS"
	fi
	
	# WARNING: Obviously less reliable than directly stating variable assignments.
	local fakeHomeENVvars
	
	fakeHomeENVvars+=(DISPLAY="$DISPLAY" XAUTH="$XAUTH" XAUTHORITY="$XAUTHORITY" XSOCK="$XSOCK" XDG_SESSION_DESKTOP='KDE' XDG_CURRENT_DESKTOP='KDE')
	fakeHomeENVvars+=(realHome="$realHome" keepFakeHome="$keepFakeHome" HOME="$HOME" setFakeHome="$setFakeHome")
	fakeHomeENVvars+=(TERM="${TERM}" SHELL="${SHELL}" PATH="${PATH}")
	fakeHomeENVvars+=(_JAVA_OPTIONS="${_JAVA_OPTIONS}")
	fakeHomeENVvars+=(scriptAbsoluteLocation="$scriptAbsoluteLocation" scriptAbsoluteFolder="$scriptAbsoluteFolder"realScriptAbsoluteLocation="$realScriptAbsoluteLocation" realScriptAbsoluteFolder="$realScriptAbsoluteFolder")
	fakeHomeENVvars+=(sessionid="$sessionid" realSessionID="$realSessionID" )
	
	if type dbus-run-session > /dev/null 2>&1
	then
		fakeHomeENVvars+=(dbus-run-session)
	fi
	
	#env -i DISPLAY="$DISPLAY" XAUTH="$XAUTH" XAUTHORITY="$XAUTHORITY" XSOCK="$XSOCK" XDG_SESSION_DESKTOP='KDE' XDG_CURRENT_DESKTOP='KDE' realHome="$realHome" keepFakeHome="$keepFakeHome" HOME="$HOME" setFakeHome="$setFakeHome" TERM="${TERM}" SHELL="${SHELL}" PATH="${PATH}" _JAVA_OPTIONS=${_JAVA_OPTIONS}scriptAbsoluteLocation="$scriptAbsoluteLocation" sessionid="$sessionid" scriptAbsoluteFolder="$scriptAbsoluteFolder" realSessionID="$realSessionID" realScriptAbsoluteLocation="$realScriptAbsoluteLocation" realScriptAbsoluteFolder="$realScriptAbsoluteFolder" dbus-run-session "$@"
	##env -i DISPLAY="$DISPLAY" XAUTH="$XAUTH" XAUTHORITY="$XAUTHORITY" XSOCK="$XSOCK" XDG_SESSION_DESKTOP='KDE' XDG_CURRENT_DESKTOP='KDE' realHome="$realHome" keepFakeHome="$keepFakeHome" HOME="$HOME" setFakeHome="$setFakeHome" TERM="${TERM}" SHELL="${SHELL}" PATH="${PATH}" _JAVA_OPTIONS=${_JAVA_OPTIONS}scriptAbsoluteLocation="$scriptAbsoluteLocation" scriptAbsoluteFolder="$scriptAbsoluteFolder" dbus-run-session "$@"
	##dbus-run-session "$@"
	##"$@"
	##. "$@"
	env -i "${fakeHomeENVvars[@]}" "$@"
	fakeHomeExitStatus=$?
	
	#_unmakeFakeHome > /dev/null 2>&1
	
	_resetFakeHomeEnv_nokeep
	
	return "$fakeHomeExitStatus"
}

#Do NOT keep parent session under fakeHome environment. Do NOT regain parent session if "~/.ubcore/.ubcorerc" is imported (typically upon shell launch).
# ATTENTION: WARNING: Do not remove or modify functionality of GUI workarounds without extensive testing!
_fakeHome_specific() {
	_begin_fakeHome "$@"
	local fakeHomeExitStatus
	
	if ! _safeEcho_newline "$_JAVA_OPTIONS" | grep "$HOME" > /dev/null 2>&1
	then
		export _JAVA_OPTIONS=-Duser.home="$HOME"' '"$_JAVA_OPTIONS"
	fi
	
	# WARNING: Obviously less reliable than directly stating variable assignments.
	local fakeHomeENVvars
	
	fakeHomeENVvars+=(DISPLAY="$DISPLAY" XAUTH="$XAUTH" XAUTHORITY="$XAUTHORITY" XSOCK="$XSOCK" XDG_SESSION_DESKTOP='KDE' XDG_CURRENT_DESKTOP='KDE')
	fakeHomeENVvars+=(realHome="$realHome" keepFakeHome="$keepFakeHome" HOME="$HOME" setFakeHome="$setFakeHome")
	fakeHomeENVvars+=(TERM="${TERM}" SHELL="${SHELL}" PATH="${PATH}")
	fakeHomeENVvars+=(_JAVA_OPTIONS="${_JAVA_OPTIONS}")
	#fakeHomeENVvars+=(scriptAbsoluteLocation="$scriptAbsoluteLocation" scriptAbsoluteFolder="$scriptAbsoluteFolder"realScriptAbsoluteLocation="$realScriptAbsoluteLocation" realScriptAbsoluteFolder="$realScriptAbsoluteFolder")
	#fakeHomeENVvars+=(sessionid="$sessionid" realSessionID="$realSessionID" )
	
	if type dbus-run-session > /dev/null 2>&1
	then
		fakeHomeENVvars+=(dbus-run-session)
	fi
	
	##env -i DISPLAY="$DISPLAY" XAUTH="$XAUTH" XAUTHORITY="$XAUTHORITY" XSOCK="$XSOCK" XDG_SESSION_DESKTOP='KDE' XDG_CURRENT_DESKTOP='KDE' realHome="$realHome" keepFakeHome="$keepFakeHome" HOME="$HOME" setFakeHome="$setFakeHome" TERM="${TERM}" SHELL="${SHELL}" PATH="${PATH}" _JAVA_OPTIONS=${_JAVA_OPTIONS}scriptAbsoluteLocation="$scriptAbsoluteLocation" scriptAbsoluteFolder="$scriptAbsoluteFolder" realScriptAbsoluteLocation="$realScriptAbsoluteLocation" realScriptAbsoluteFolder="$realScriptAbsoluteFolder" dbus-run-session "$@"
	#env -i DISPLAY="$DISPLAY" XAUTH="$XAUTH" XAUTHORITY="$XAUTHORITY" XSOCK="$XSOCK" XDG_SESSION_DESKTOP='KDE' XDG_CURRENT_DESKTOP='KDE' realHome="$realHome" keepFakeHome="$keepFakeHome" HOME="$HOME" setFakeHome="$setFakeHome" TERM="${TERM}" SHELL="${SHELL}" PATH="${PATH}" _JAVA_OPTIONS=${_JAVA_OPTIONS}dbus-run-session "$@"
	##dbus-run-session "$@"
	##"$@"
	##. "$@"
	env -i "${fakeHomeENVvars[@]}" "$@"
	fakeHomeExitStatus=$?
	
	#_unmakeFakeHome > /dev/null 2>&1
	
	_resetFakeHomeEnv_nokeep
	
	return "$fakeHomeExitStatus"
}

#No workarounds, run in current shell.
# WARNING: Not recommended. No production use. Do not launch GUI applications.
_fakeHome_embedded() {
	_begin_fakeHome "$@"
	local fakeHomeExitStatus
	
	if ! _safeEcho_newline "$_JAVA_OPTIONS" | grep "$HOME" > /dev/null 2>&1
	then
		export _JAVA_OPTIONS=-Duser.home="$HOME"' '"$_JAVA_OPTIONS"
	fi
	
	#env -i DISPLAY="$DISPLAY" XAUTH="$XAUTH" XAUTHORITY="$XAUTHORITY" XSOCK="$XSOCK" XDG_SESSION_DESKTOP='KDE' XDG_CURRENT_DESKTOP='KDE' realHome="$realHome" keepFakeHome="$keepFakeHome" HOME="$HOME" setFakeHome="$setFakeHome" TERM="${TERM}" SHELL="${SHELL}" PATH="${PATH}" _JAVA_OPTIONS=${_JAVA_OPTIONS}scriptAbsoluteLocation="$scriptAbsoluteLocation" scriptAbsoluteFolder="$scriptAbsoluteFolder" realScriptAbsoluteLocation="$realScriptAbsoluteLocation" realScriptAbsoluteFolder="$realScriptAbsoluteFolder" dbus-run-session "$@"
	#env -i DISPLAY="$DISPLAY" XAUTH="$XAUTH" XAUTHORITY="$XAUTHORITY" XSOCK="$XSOCK" XDG_SESSION_DESKTOP='KDE' XDG_CURRENT_DESKTOP='KDE' realHome="$realHome" keepFakeHome="$keepFakeHome" HOME="$HOME" setFakeHome="$setFakeHome" TERM="${TERM}" SHELL="${SHELL}" PATH="${PATH}" _JAVA_OPTIONS=${_JAVA_OPTIONS}scriptAbsoluteLocation="$scriptAbsoluteLocation" scriptAbsoluteFolder="$scriptAbsoluteFolder" dbus-run-session "$@"
	#dbus-run-session "$@"
	#"$@"
	. "$@"
	fakeHomeExitStatus=$?
	
	#_unmakeFakeHome > /dev/null 2>&1
	
	_resetFakeHomeEnv_nokeep
	
	return "$fakeHomeExitStatus"
}

_fakeHome_() {
	_fakeHome_embedded "$@"
}





_userFakeHome_procedure() {
	export actualFakeHome="$instancedFakeHome"
	export fakeHomeEditLib="false"
	_fakeHome "$@"
}

_userFakeHome_sequence() {
	_start
	
	_userFakeHome_procedure "$@"
	
	_stop $?
}

_userFakeHome() {
	"$scriptAbsoluteLocation" _userFakeHome_sequence "$@"
}

_editFakeHome_procedure() {
	export actualFakeHome="$globalFakeHome"
	export fakeHomeEditLib="false"
	_fakeHome "$@"
}

_editFakeHome_sequence() {
	_start
	
	_editFakeHome_procedure "$@"
	
	_stop $?
}

_editFakeHome() {
	"$scriptAbsoluteLocation" _editFakeHome_sequence "$@"
}

_userShortHome_procedure() {
	export actualFakeHome="$shortFakeHome"
	export fakeHomeEditLib="false"
	_fakeHome "$@"
}

_userShortHome_sequence() {
	_start
	
	_userShortHome_procedure "$@"
	
	_stop $?
}

_userShortHome() {
	"$scriptAbsoluteLocation" _userShortHome_sequence "$@"
}

_editShortHome_procedure() {
	export actualFakeHome="$shortFakeHome"
	export fakeHomeEditLib="true"
	_fakeHome "$@"
}

_editShortHome_sequence() {
	_start
	
	_editShortHome_procedure "$@"
	
	_stop $?
}

# WARNING: Only allows persistent modifications to directories which have been linked by "_link_fakeHome" or similar.
_editShortHome() {
	"$scriptAbsoluteLocation" _editShortHome_sequence "$@"
}

_shortHome() {
	_userShortHome "$@"
}

_memFakeHome_procedure() {
	export actualFakeHome="$instancedFakeHome"
	export fakeHomeEditLib="false"
	
	_mountRAM_fakeHome
	
	local fakeHomeExitStatus
	
	_fakeHome "$@"
	fakeHomeExitStatus=$?
	
	_umountRAM_fakeHome
	
	return "$fakeHomeExitStatus"
}

_memFakeHome_sequence() {
	_start
	
	_memFakeHome_procedure "$@"
	
	_stop $?
}

_memFakeHome() {
	"$scriptAbsoluteLocation" _memFakeHome_sequence "$@"
}

_resetFakeHomeEnv_extra() {
	true
}

_resetFakeHomeEnv_nokeep() {
	! [[ "$setFakeHome" == "true" ]] && return 0
	export setFakeHome="false"
	
	export HOME="$realHome"
	
	#export realHome=""
	
	_resetFakeHomeEnv_extra
}

_resetFakeHomeEnv() {
	#[[ "$keepFakeHome" == "true" ]] && return 0
	[[ "$keepFakeHome" != "false" ]] && return 0
	
	_resetFakeHomeEnv_nokeep
} 

#####Shortcuts

_visualPrompt() {
#+%H:%M:%S\ %Y-%m-%d\ Q%q
#+%H:%M:%S\ %b\ %d,\ %y
export PS1='\[\033[01;40m\]\[\033[01;36m\]+\[\033[01;34m\]-|\[\033[01;31m\]${?}:${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u\[\033[01;32m\]@\h\[\033[01;36m\]\[\033[01;34m\])-\[\033[01;36m\]------------------------\[\033[01;34m\]-(\[\033[01;35m\]$(date +%H:%M:%S\ .%d)\[\033[01;34m\])-\[\033[01;36m\]- -|\[\033[00m\]\n\[\033[01;40m\]\[\033[01;36m\]+\[\033[01;34m\]-|\[\033[37m\][\w]\[\033[00m\]\n\[\033[01;36m\]+\[\033[01;34m\]-|\#) \[\033[36m\]>\[\033[00m\] '
} 

#Simulated client/server discussion testing.

_log_query() {
	[[ "$1" == "" ]] && return 1
	
	tee "$1"
	
	return 0
}

_report_query_stdout() {
	[[ "$1" == "" ]] && return 1
	
	_messagePlain_probe 'stdout: strings'
	strings "$1"
	
	_messagePlain_probe 'stdout: hex'
	xxd -p "$1" | tr -d '\n'
	echo
	
	return 0
}

# ATTENTION: Overload with "core.sh" or similar.
_prepare_query_prog() {
	true
}

_prepare_query() {
	export ub_queryclientdir="$queryTmp"/client
	export qc="$ub_queryclientdir"
	
	export ub_queryclient="$ub_queryclientdir"/script
	export qce="$ub_queryclient"
	
	export ub_queryserverdir="$queryTmp"/server
	export qs="$ub_queryserverdir"
	
	export ub_queryserver="$ub_queryserverdir"/script
	export qse="$ub_queryserver"
	
	mkdir -p "$ub_queryclientdir"
	mkdir -p "$ub_queryserverdir"
	
	! [[ -e "$ub_queryclient" ]] && cp "$scriptAbsoluteLocation" "$ub_queryclient"
	! [[ -e "$ub_queryserver" ]] && cp "$scriptAbsoluteLocation" "$ub_queryserver"
	
	_prepare_query_prog "$@"
}

_queryServer_sequence() {
	_start
	
	local currentExitStatus
	
	export queryType="server"
	"$ub_queryserver" "$@"
	currentExitStatus="$?"
	
	env > env_$(_uid)
	
	_stop "$currentExitStatus"
}
_queryServer() {
	"$scriptAbsoluteLocation" _queryServer_sequence "$@"
}
_qs() {
	_queryServer "$@"
}

_queryClient_sequence() {
	_start
	
	local currentExitStatus
	
	export queryType="client"
	"$ub_queryclient" "$@"
	currentExitStatus="$?"
	
	env > env_$(_uid)
	
	_stop "$currentExitStatus"
}
_queryClient() {
	"$scriptAbsoluteLocation" _queryClient_sequence "$@"
}
_qc() {
	_queryClient "$@"
}

_query_diag() {
	echo test | _query "$@"
	local currentExitStatus="$?"
	
	_messagePlain_nominal 'diag: tx.log'
	_report_query_stdout "$queryTmp"/tx.log
	
	_messagePlain_nominal 'diag: xc.log'
	_report_query_stdout "$queryTmp"/xc.log
	
	_messagePlain_nominal 'diag: rx.log'
	_report_query_stdout "$queryTmp"/rx.log
	
	return "$currentExitStatus"
}

# ATTENTION: Overload with "core.sh" or similar.
_query() {
	_prepare_query
	
	( cd "$qc" ; _queryClient _bin cat | _log_query "$queryTmp"/tx.log | ( cd "$qs" ; _queryServer _bin cat | _log_query "$queryTmp"/xc.log | ( cd "$qc" ; _queryClient _bin cat | _log_query "$queryTmp"/rx.log ; return "${PIPESTATUS[0]}" )))
}

#Example, override with "core.sh" .
_scope_compile() {
	true
}

#Example, override with "core.sh" .
_scope_attach() {
	_messagePlain_nominal '_scope_attach'
	
	_scope_here > "$ub_scope"/.devenv
	chmod u+x "$ub_scope"/.devenv
	_scope_readme_here > "$ub_scope"/README
	
	_scope_command_write _scope_terminal_procedure
	
	_scope_command_write _scope_konsole_procedure
	_scope_command_write _scope_dolphin_procedure
	_scope_command_write _scope_eclipse_procedure
	_scope_command_write _scope_atom_procedure
	
	_scope_command_write _query
	_scope_command_write _qs
	_scope_command_write _qc
	
	#_scope_command_write _compile
	#_scope_command_external_here _compile
}

_prepare_scope() {
	#mkdir -p "$safeTmp"/scope
	mkdir -p "$scopeTmp"
	#true
}

_relink_scope() {
	#_relink "$safeTmp"/scope "$ub_scope"
	_relink "$scopeTmp" "$ub_scope"
	#_relink "$safeTmp" "$ub_scope"
	
	_relink "$safeTmp" "$ub_scope"/safeTmp
	_relink "$shortTmp" "$ub_scope"/shortTmp
	
	# DANGER: Creates infinitely recursive symlinks.
	#[[ -e "$abstractfs_projectafs" ]] && _relink "$abstractfs_projectafs" "$ub_scope"/project.afs
	#[[ -d "$abstractfs" ]] && _relink "$abstractfs" "$ub_scope"/afs
}

_ops_scope() {
	_messagePlain_nominal '_ops_scope'
	
	#Find/run ops file in project dir.
	! [[ -e "$ub_specimen"/ops ]] && ! [[ -e "$ub_specimen"/ops.sh ]] && _messagePlain_warn 'aU: undef: sketch ops'
	[[ -e "$ub_specimen"/ops ]] && _messagePlain_good 'aU: found: sketch ops: ops' && . "$ub_specimen"/ops
	[[ -e "$ub_specimen"/ops.sh ]] && _messagePlain_good 'aU: found: sketch ops: ops.sh' && . "$ub_specimen"/ops.sh
}

#"$1" == ub_specimen
#"$ub_scope_name" (default "scope")
# WARNING Multiple instances of same scope on a single specimen strictly forbidden. Launch multiple applications within a scope, not multiple scopes.
_start_scope() {
	_messagePlain_nominal '_start_scope'
	
	export ub_specimen=$(_getAbsoluteLocation "$1")
	export specimen="$ub_specimen"
	export ub_specimen_basename=$(basename "$ub_specimen")
	export basename="$ub_specimen_basename"
	[[ ! -d "$ub_specimen" ]] && _messagePlain_bad 'missing: specimen= '"$ub_specimen" && _stop 1
	[[ ! -e "$ub_specimen" ]] && _messagePlain_bad 'missing: specimen= '"$ub_specimen" && _stop 1
	
	[[ "$ub_scope_name" == "" ]] && export ub_scope_name='scope'
	
	export ub_scope="$ub_specimen"/.s_"$ub_scope_name"
	export scope="$ub_scope"
	[[ -e "$ub_scope" ]] && _messagePlain_bad 'fail: safety: multiple scopes && single specimen' && _stop 1
	[[ -L "$ub_scope" ]] && _messagePlain_bad 'fail: safety: multiple scopes && single specimen' && _stop 1
	
	#[[ -e "$ub_specimen"/.e_* ]] && _messagePlain_bad 'fail: safety: engine root scope strongly discouraged' && _stop 1
	
	#export ub_scope_tmp="$ub_scope"/s_"$sessionid"
	
	_prepare_scope "$@"
	_relink_scope "$@"
	[[ ! -d "$ub_scope" ]] && _messagePlain_bad 'fail: link scope= '"$ub_scope" && _stop 1
	#[[ ! -d "$ub_scope_tmp" ]] && _messagePlain_bad 'fail: create ub_scope_tmp= '"$ub_scope_tmp" && _stop 1
	[[ ! -d "$ub_scope"/safeTmp ]] && _messagePlain_bad 'fail: link' && _stop 1
	[[ ! -d "$ub_scope"/shortTmp ]] && _messagePlain_bad 'fail: link' && _stop 1
	
	[[ ! -e "$ub_scope"/.pid ]] && echo $$ > "$ub_scope"/.pid
	
	_messagePlain_good 'pass: prepare, relink'
	
	return 0
}

#Defaults, bash terminal, wait for kill signal, wait for EOF, etc. Override with "core.sh" . May run file manager, terminal, etc.
# WARNING: Scope should only be terminated by process or user managing this interaction (eg. by closing file manager). Manager must be aware of any inter-scope dependencies.
#"$@" <commands>
_scope_interact() {
	_messagePlain_nominal '_scope_interact'
	#read > /dev/null 2>&1
	
	_scopePrompt
	
	if [[ "$@" == "" ]]
	then
		_scope_terminal_procedure
		#_scope_eclipse_procedure
		#eclipse
# 		return
	fi
	
	"$@"
}


_scope_sequence() {
	_messagePlain_nominal 'init: scope: '"$ub_scope_name"
	_messagePlain_probe 'HOME= '"$HOME"
	
	_start
	_start_scope "$@"
	_ops_scope
	
	_scope_attach "$@"
	
	#User interaction.
	shift
	_scope_interact "$@"
	
	_stop
}

# ATTENTION: Overload with "core.sh" or similar!
_scope_prog() {
	[[ "$ub_scope_name" == "" ]] && export ub_scope_name='scope'
}

_scope() {
	_scope_prog
	[[ "$ub_scope_name" == "" ]] && export ub_scope_name='scope'
	"$scriptAbsoluteLocation" _scope_sequence "$@"
}

_scope_readme_here() {
	cat << CZXWXcRMTo8EmM8i4d
Ubiquitous Bash scope.
CZXWXcRMTo8EmM8i4d
}

#Example, override with "core.sh" .
_scope_var_here_prog() {
	cat << CZXWXcRMTo8EmM8i4d
CZXWXcRMTo8EmM8i4d
}

_scope_var_here() {
	cat << CZXWXcRMTo8EmM8i4d
export ub_specimen="$ub_specimen"
export specimen="$specimen"
export ub_specimen_basename="$ub_specimen_basename"
export basename="$basename"
export ub_scope_name="$ub_scope_name"
export ub_scope="$ub_scope"
export scope="$scope"

CZXWXcRMTo8EmM8i4d
	
	_scope_var_here_prog "$@"
}

_scope_here() {
	cat << CZXWXcRMTo8EmM8i4d
#!/usr/bin/env bash

CZXWXcRMTo8EmM8i4d

	_scope_var_here

	cat << CZXWXcRMTo8EmM8i4d

export scriptAbsoluteLocation="$scriptAbsoluteLocation"
export scriptAbsoluteFolder="$scriptAbsoluteFolder"
export sessionid="$sessionid"
. "$scriptAbsoluteLocation" --devenv "\$@"
CZXWXcRMTo8EmM8i4d
}

_scope_command_here() {
	cat << CZXWXcRMTo8EmM8i4d
#!/usr/bin/env bash

CZXWXcRMTo8EmM8i4d

	_scope_var_here

	cat << CZXWXcRMTo8EmM8i4d

export scriptAbsoluteLocation="$scriptAbsoluteLocation"
export scriptAbsoluteFolder="$scriptAbsoluteFolder"
export sessionid="$sessionid"
. "$scriptAbsoluteLocation" --devenv "$1" "\$@"
CZXWXcRMTo8EmM8i4d
}

_scope_command_external_here() {
	cat << CZXWXcRMTo8EmM8i4d
#!/usr/bin/env bash

CZXWXcRMTo8EmM8i4d

	_scope_var_here

	cat << CZXWXcRMTo8EmM8i4d

export importScriptLocation="$scriptAbsoluteLocation"
export importScriptFolder="$scriptAbsoluteFolder"
. "$scriptAbsoluteLocation" --script "$1" "\$@"
CZXWXcRMTo8EmM8i4d
}

_scope_command_write() {
	_scope_command_here "$@" > "$ub_scope"/"$1"
	chmod u+x "$ub_scope"/"$1"
}

_scope_command_external_write() {
	_scope_command_external_here "$@" > "$ub_scope"/"$1"
	chmod u+x "$ub_scope"/"$1"
}

_scopePrompt() {
	[[ "$ub_scope_name" == "" ]] && return 0
	
	export PS1='\[\033[01;40m\]\[\033[01;36m\]+\[\033[01;34m\]-|\[\033[01;31m\]${?}:${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u\[\033[01;32m\]@\h\[\033[01;36m\]\[\033[01;34m\])-\[\033[01;36m\]------------------------\[\033[01;34m\]-(\[\033[01;35m\]$(date +%H:%M:%S\ .%d)\[\033[01;34m\])-\[\033[01;36m\]- -|\[\033[00m\]\n\[\033[01;40m\]\[\033[01;36m\]+\[\033[01;34m\]-|\[\033[37m\][\w]\[\033[00m\]\n\[\033[01;36m\]+\[\033[01;34m\]-|\#) \[\033[36m\]'"$ub_scope_name"'>\[\033[00m\] '
}

_scope_terminal_procedure() {
	_tryExec '_scopePrompt'
	#_tryExec '_visualPrompt'
	
	export PATH="$PATH":"$ub_scope"
	echo
	/usr/bin/env bash --norc
	echo
}

_scope_terminal() {
	local shiftParam1
	shiftParam1="$1"
	shift
	
	_scope_prog "$@"
	_scope "$shiftParam1" "_scope_terminal_procedure" "$@"
}

_scope_eclipse_procedure() {
	_eclipse "$@"
}

_scope_eclipse() {
	local shiftParam1
	shiftParam1="$1"
	shift
	
	_scope_prog "$@"
	_scope "$shiftParam1" "_scope_eclipse_procedure" "$@"
}

_scope_atom_procedure() {
	"$scriptAbsoluteLocation" _atom_tmp_sequence "$ub_specimen" "$@"  > /dev/null 2>&1
}

# WARNING: No production use. Not to be relied upon. May be removed.
_scope_atom() {
	local shiftParam1
	shiftParam1="$1"
	shift
	
	_scope_prog "$@"
	_scope "$shiftParam1" "_scope_atom_procedure" "$@"
}

_scope_konsole_procedure() {
	_messagePlain_probe konsole --workdir "$ub_specimen" "$@"
	konsole --workdir "$ub_specimen" "$@"
}

_scope_konsole() {
	local shiftParam1
	shiftParam1="$1"
	shift
	
	_scope_prog "$@"
	_scope "$shiftParam1" "_scope_konsole_procedure" -p tabtitle="$ub_scope_name" "$@"
}

_scope_dolphin_procedure() {
	dolphin "$ub_specimen" "$@"
}

_scope_dolphin() {
	local shiftParam1
	shiftParam1="$1"
	shift
	
	_scope_prog "$@"
	_scope "$shiftParam1" "_scope_dolphin_procedure" "$@"
}

_testGit() {
	_wantGetDep git
}

#Ignores file modes, suitable for use with possibly broken filesystems like NTFS.
_gitCompatible() {
	git -c core.fileMode=false "$@"
}

_gitInfo() {
	#Git Repository Information
	export repoDir="$PWD"

	export repoName=$(basename "$repoDir")
	export bareRepoDir=../."$repoName".git
	export bareRepoAbsoluteDir=$(_getAbsoluteLocation "$bareRepoDir")

	#Set $repoHostName in user ".bashrc" or similar. May also set $repoPort including colon prefix.
	[[ "$repoHostname" == "" ]] && export repoHostname=$(hostname -f)
	
	true
}

_gitRemote() {
	_gitInfo
	
	if [[ -e "$bareRepoDir" ]]
	then
		_showGitRepoURI
		return 0
	fi
	
	if ! [[ -e "$repoDir"/.git ]]
	then
		return 1
	fi
	
	if git config --get remote.origin.url > /dev/null 2>&1
	then
		echo -n "git clone --recursive "
		git config --get remote.origin.url
		return 0
	fi
	_gitBare
}

_gitNew() {
	git init
	git add .
	git commit -a -m "first commit"
}

_gitImport() {
	cd "$scriptFolder"
	
	mkdir -p "$1"
	cd "$1"
	shift
	git clone "$@"
	
	cd "$scriptFolder"
}

_findGit_procedure() {
	cd "$1"
	shift
	
	if [[ -e "./.git" ]]
	then
		"$@"
		return 0
	fi
	
	find -L . -mindepth 1 -maxdepth 1 -type d -exec "$scriptAbsoluteLocation" _findGit_procedure '{}' "$@" \;
}

#Recursively searches for directories containing ".git".
_findGit() {
	if [[ -e "./.git" ]]
	then
		"$@"
		return 0
	fi
	
	find -L . -mindepth 1 -maxdepth 1 -type d -exec "$scriptAbsoluteLocation" _findGit_procedure '{}' "$@" \;
}

_gitPull() {
	git pull
	git submodule update --recursive
}

_gitCheck_sequence() {
	echo '-----'
	
	local checkRealpath
	checkRealpath=$(realpath .)
	local checkBasename
	checkBasename=$(basename "$checkRealpath")
	
	echo "$checkBasename"
	
	git status
}

_gitCheck() {
	_findGit "$scriptAbsoluteLocation" _gitCheck_sequence
}

_gitPullRecursive_sequence() {
	echo '-----'
	
	local checkRealpath
	checkRealpath=$(realpath .)
	local checkBasename
	checkBasename=$(basename "$checkRealpath")
	
	echo "$checkBasename"
	
	"$scriptAbsoluteLocation" _gitPull
}

# DANGER
#Updates all git repositories recursively.
_gitPullRecursive() {
	_findGit "$scriptAbsoluteLocation" _gitPullRecursive_sequence
}

# DANGER
# Pushes all changes as a commit described as "Upstream."
_gitUpstream() {
	git add -A . ; git commit -a -m "Upstream." ; git push
}
_gitUp() {
	_gitUpstream
}

# DANGER
#Removes all but the .git folder from the working directory.
#_gitFresh() {
#	find . -not -path '\.\/\.git*' -delete
#}


#####Program

_createBareGitRepo() {
	mkdir -p "$bareRepoDir"
	cd $bareRepoDir
	
	git --bare init
	
	echo "-----"
}


_setBareGitRepo() {
	cd "$repoDir"
	
	git remote rm origin
	git remote add origin "$bareRepoDir"
	git push --set-upstream origin master
	
	echo "-----"
}

_showGitRepoURI() {
	echo git clone --recursive ssh://"$USER"@"$repoHostname""$repoPort""$bareRepoAbsoluteDir" "$repoName"
	
	
	#if [[ "$repoHostname" != "" ]]
	#then
	#	clear
	#	echo ssh://"$USER"@"$repoHostname""$repoPort""$bareRepoAbsoluteDir"
	#	sleep 15
	#fi
}

_gitBareSequence() {
	_gitInfo
	
	if [[ -e "$bareRepoDir" ]]
	then
		_showGitRepoURI
		return 2
	fi
	
	if ! [[ -e "$repoDir"/.git ]]
	then
		return 1
	fi
	
	_createBareGitRepo
	
	_setBareGitRepo
	
	_showGitRepoURI
	
}

_gitBare() {
	
	"$scriptAbsoluteLocation" _gitBareSequence
	
}



_test_bup() {
	! _wantDep bup && echo 'warn: no bup'
	
	! man tar | grep '\-\-one-file-system' > /dev/null 2>&1 && echo 'warn: tar does not support one-file-system' && return 1
	! man tar | grep '\-\-xattrs' > /dev/null 2>&1 && echo 'warn: tar does not support xattrs'
	! man tar | grep '\-\-acls' > /dev/null 2>&1 && echo 'warn: tar does not support acls'
}

_bupNew() {
	export BUP_DIR="./.bup"
	
	[[ -e "$BUP_DIR" ]] && return 1
	
	bup init
}

_bupLog() {
	export BUP_DIR="./.bup"
	
	[[ ! -e "$BUP_DIR" ]] && return 1
	
	git --git-dir=./.bup log
}

_bupList() {
	export BUP_DIR="./.bup"
	
	[[ ! -e "$BUP_DIR" ]] && return 1
	
	if [[ "$1" == "" ]]
	then
		bup ls "HEAD"
		return
	fi
	[[ "$1" != "" ]] && bup ls "$@"
}

_bupStore() {
	export BUP_DIR="./.bup"
	
	[[ ! -e "$BUP_DIR" ]] && return 1
	
	! man tar | grep '\-\-one-file-system' > /dev/null 2>&1 && return 1
	! man tar | grep '\-\-xattrs' > /dev/null 2>&1 && return 1
	! man tar | grep '\-\-acls' > /dev/null 2>&1 && return 1
	
	if [[ "$1" == "" ]]
	then
		tar --one-file-system --xattrs --acls --exclude "$BUP_DIR" -cvf - . | bup split -n "HEAD" -vv
		return
	fi
	[[ "$1" != "" ]] && tar --one-file-system --xattrs --acls --exclude "$BUP_DIR" -cvf - . | bup split -n "$@" -vv
}

_bupRetrieve() {
	export BUP_DIR="./.bup"
	
	[[ ! -e "$BUP_DIR" ]] && return 1
	
	! man tar | grep '\-\-one-file-system' > /dev/null 2>&1 && return 1
	! man tar | grep '\-\-xattrs' > /dev/null 2>&1 && return 1
	! man tar | grep '\-\-acls' > /dev/null 2>&1 && return 1
	
	if [[ "$1" == "" ]]
	then
		bup join "HEAD" | tar --one-file-system --xattrs --acls -xf -
		return
	fi
	[[ "$1" != "" ]] && bup join "$@" | tar --one-file-system --xattrs --acls -xf -
}

_setupUbiquitous_here() {
	cat << CZXWXcRMTo8EmM8i4d
type sudo > /dev/null 2>&1 && groups | grep -E 'wheel|sudo' > /dev/null 2>&1 && sudo -n renice -n -10 -p \$\$ > /dev/null 2>&1

export profileScriptLocation="$ubcoreUBdir"/ubiquitous_bash.sh
export profileScriptFolder="$ubcoreUBdir"
[[ "\$scriptAbsoluteLocation" != "" ]] && . "\$scriptAbsoluteLocation" --parent _importShortcuts
[[ "\$scriptAbsoluteLocation" == "" ]] && . "\$profileScriptLocation" --profile _importShortcuts

renice -n 0 -p \$\$ > /dev/null 2>&1

true
CZXWXcRMTo8EmM8i4d
}

_configureLocal() {
	_configureFile "$1" "_local"
}

_configureFile() {
	cp "$scriptAbsoluteFolder"/"$1" "$scriptAbsoluteFolder"/"$2"
}

_configureOps() {
	echo "$@" >> "$scriptAbsoluteFolder"/ops
}

_resetOps() {
	rm "$scriptAbsoluteFolder"/ops
}

_importShortcuts() {
	_tryExec "_resetFakeHomeEnv"
	
	if ! [[ "$PATH" == *":""$HOME""/bin"* ]] && ! [[ "$PATH" == "$HOME""/bin"* ]] && [[ -e "$HOME"/bin ]] && [[ -d "$HOME"/bin ]]
	then
		export PATH="$PATH":"$HOME"/bin
	fi
	
	_tryExec "_visualPrompt"
	
	_tryExec "_scopePrompt"
}

_gitPull_ubiquitous() {
	git pull
}

_gitClone_ubiquitous() {
	git clone --depth 1 git@github.com:mirage335/ubiquitous_bash.git
}

_selfCloneUbiquitous() {
	"$scriptBin"/.ubrgbin.sh _ubrgbin_cpA "$scriptBin" "$ubcoreUBdir"/ > /dev/null 2>&1
	cp -a "$scriptAbsoluteFolder"/lean.sh "$ubcoreUBdir"/lean.sh > /dev/null 2>&1
	cp -a "$scriptAbsoluteLocation" "$ubcoreUBdir"/ubiquitous_bash.sh
}

_installUbiquitous() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	cd "$ubcoreDir"
	
	cd "$ubcoreUBdir"
	_messagePlain_nominal 'attempt: git pull'
	if [[ "$nonet" != "true" ]] && type git > /dev/null 2>&1
	then
		
		local ub_gitPullStatus
		git pull
		ub_gitPullStatus="$?"
		! cd "$localFunctionEntryPWD" && return 1
		
		[[ "$ub_gitPullStatus" == "0" ]] && _messagePlain_good 'pass: git pull' && cd "$localFunctionEntryPWD" && return 0
	fi
	_messagePlain_warn 'fail: git pull'
	
	cd "$ubcoreDir"
	_messagePlain_nominal 'attempt: git clone'
	[[ "$nonet" != "true" ]] && type git > /dev/null 2>&1 && [[ ! -e ".git" ]] && _gitClone_ubiquitous && _messagePlain_good 'pass: git clone' && return 0
	_messagePlain_warn 'fail: git clone'
	
	cd "$ubcoreDir"
	_messagePlain_nominal 'attempt: self clone'
	[[ -e ".git" ]] && _messagePlain_bad 'fail: self clone' && return 1
	_selfCloneUbiquitous && return 0
	_messagePlain_bad 'fail: self clone' && return 1
	
	return 0
	
	cd "$localFunctionEntryPWD"
}


_setupUbiquitous() {
	_messageNormal "init: setupUbiquitous"
	local ubHome
	ubHome="$HOME"
	[[ "$1" != "" ]] && ubHome="$1"
	
	export ubcoreDir="$ubHome"/.ubcore
	export ubcoreFile="$ubcoreDir"/.ubcorerc
	
	export ubcoreUBdir="$ubcoreDir"/ubiquitous_bash
	export ubcoreUBfile="$ubcoreDir"/ubiquitous_bash/ubiquitous_bash.sh
	
	_messagePlain_probe 'ubHome= '"$ubHome"
	_messagePlain_probe 'ubcoreDir= '"$ubcoreDir"
	_messagePlain_probe 'ubcoreFile= '"$ubcoreFile"
	
	_messagePlain_probe 'ubcoreUBdir= '"$ubcoreUBdir"
	_messagePlain_probe 'ubcoreUBfile= '"$ubcoreUBfile"
	
	mkdir -p "$ubcoreUBdir"
	! [[ -e "$ubcoreUBdir" ]] && _messagePlain_bad 'missing: ubcoreUBdir= '"$ubcoreUBdir" && _messageFAIL && return 1
	
	
	_messageNormal "install: setupUbiquitous"
	! _installUbiquitous && _messageFAIL && return 1
	! [[ -e "$ubcoreUBfile" ]] && _messagePlain_bad 'missing: ubcoreUBfile= '"$ubcoreUBfile" && _messageFAIL && return 1
	
	
	_messageNormal "hook: setupUbiquitous"
	! _permissions_ubiquitous_repo "$ubcoreUBdir" && _messagePlain_bad 'permissions: ubcoreUBdir = '"$ubcoreUBdir" && _messageFAIL && return 1
	
	mkdir -p "$ubHome"/bin/
	ln -sf "$ubcoreUBfile" "$ubHome"/bin/ubiquitous_bash.sh
	ln -sf "$ubcoreUBfile" "$ubHome"/bin/_winehere
	ln -sf "$ubcoreUBfile" "$ubHome"/bin/_winecfghere
	
	_setupUbiquitous_here > "$ubcoreFile"
	! [[ -e "$ubcoreFile" ]] && _messagePlain_bad 'missing: ubcoreFile= '"$ubcoreFile" && _messageFAIL && return 1
	
	
	! grep ubcore "$ubHome"/.bashrc > /dev/null 2>&1 && _messagePlain_probe "$ubcoreFile"' >> '"$ubHome"/.bashrc && echo ". ""$ubcoreFile" >> "$ubHome"/.bashrc
	! grep ubcore "$ubHome"/.bashrc > /dev/null 2>&1 && _messagePlain_bad 'missing: bashrc hook' && _messageFAIL && return 1
	
	
	echo "Now import new functionality into current shell if not in current shell."
	echo ". "'"'"$scriptAbsoluteLocation"'"' --profile _importShortcuts
	
	
	return 0
}

_setupUbiquitous_nonet() {
	local oldNoNet
	oldNoNet="$nonet"
	export nonet="true"
	_setupUbiquitous "$@"
	[[ "$oldNoNet" != "true" ]] && export nonet="$oldNoNet"
}

_upgradeUbiquitous() {
	_setupUbiquitous
}

_resetUbiquitous_sequence() {
	_start
	
	[[ ! -e "$HOME"/.bashrc ]] && return 0
	cp "$HOME"/.bashrc "$HOME"/.bashrc.bak
	cp "$HOME"/.bashrc "$safeTmp"/.bashrc
	grep -v 'ubcore' "$safeTmp"/.bashrc > "$safeTmp"/.bashrc.tmp
	mv "$safeTmp"/.bashrc.tmp "$HOME"/.bashrc
	
	[[ ! -e "$HOME"/.ubcore ]] && return 0
	rm "$HOME"/.ubcorerc
	
	_stop
}

_resetUbiquitous() {
	"$scriptAbsoluteLocation" _resetUbiquitous_sequence
}

_refresh_anchors_ubiquitous() {
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_ubide
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_ubdb
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_true
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_false
}

_anchor() {
	[[ "$scriptAbsoluteFolder" == *"ubiquitous_bash" ]] && _refresh_anchors_ubiquitous
	
	if type "_refresh_anchors" > /dev/null 2>&1
	then
		_tryExec "_refresh_anchors"
		return
	fi
	
	return 0
}


_unix_renice_execDaemon() {
	_cmdDaemon "$scriptAbsoluteLocation" _unix_renice_repeat
}

_unix_renice_daemon() {
	_priority_idle_pid "$$" > /dev/null 2>&1
	
	_start
	
	_killDaemon
	
	
	_unix_renice_execDaemon
	while _daemonStatus
	do
		sleep 5
	done
	
	_stop
}

_unix_renice_repeat() {
	while true
	do
		_unix_renice_app > /dev/null 2>&1
		sleep 10
		_unix_renice_app > /dev/null 2>&1
		sleep 10
		_unix_renice_app > /dev/null 2>&1
		sleep 10
		_unix_renice_app > /dev/null 2>&1
		sleep 10
		_unix_renice_app > /dev/null 2>&1
		sleep 10
		_unix_renice_app > /dev/null 2>&1
		sleep 10
		_unix_renice_app > /dev/null 2>&1
		sleep 10
		_unix_renice_app > /dev/null 2>&1
		sleep 10
		_unix_renice_app > /dev/null 2>&1
		sleep 10
		
		_unix_renice
		sleep 10
	done
}

_unix_renice() {
	_priority_idle_pid "$$" > /dev/null 2>&1
	
	_unix_renice_critical > /dev/null 2>&1
	_unix_renice_interactive > /dev/null 2>&1
	_unix_renice_app > /dev/null 2>&1
	_unix_renice_idle > /dev/null 2>&1
}

_unix_renice_critical() {
	local processListFile
	processListFile="$scriptAbsoluteFolder"/.pidlist_$(_uid)
	
	_priority_enumerate_pattern "^ksysguard$" >> "$processListFile"
	_priority_enumerate_pattern "^ksysguardd$" >> "$processListFile"
	_priority_enumerate_pattern "^top$" >> "$processListFile"
	_priority_enumerate_pattern "^iotop$" >> "$processListFile"
	_priority_enumerate_pattern "^latencytop$" >> "$processListFile"
	
	_priority_enumerate_pattern "^Xorg$" >> "$processListFile"
	_priority_enumerate_pattern "^modeset$" >> "$processListFile"
	
	_priority_enumerate_pattern "^smbd$" >> "$processListFile"
	_priority_enumerate_pattern "^nmbd$" >> "$processListFile"
	
	_priority_enumerate_pattern "^ssh$" >> "$processListFile"
	_priority_enumerate_pattern "^sshd$" >> "$processListFile"
	_priority_enumerate_pattern "^ssh-agent$" >> "$processListFile"
	
	_priority_enumerate_pattern "^sshfs$" >> "$processListFile"
	
	_priority_enumerate_pattern "^socat$" >> "$processListFile"
	
	#_priority_enumerate_pattern "^cron$" >> "$processListFile"
	
	local currentPID
	
	while read -r currentPID
	do
		_priority_critical_pid "$currentPID"
	done < "$processListFile"
	
	rm "$processListFile"
}

_unix_renice_interactive() {
	local processListFile
	processListFile="$scriptAbsoluteFolder"/.pidlist_$(_uid)
	
	_priority_enumerate_pattern "^kwin$" >> "$processListFile"
	_priority_enumerate_pattern "^pager$" >> "$processListFile"
	
	_priority_enumerate_pattern "^pulseaudio$" >> "$processListFile"
	
	_priority_enumerate_pattern "^synergy$" >> "$processListFile"
	_priority_enumerate_pattern "^synergys$" >> "$processListFile"
	
	_priority_enumerate_pattern "^kactivitymanagerd$" >> "$processListFile"
	
	_priority_enumerate_pattern "^dbus" >> "$processListFile"
	
	local currentPID
	
	while read -r currentPID
	do
		_priority_interactive_pid "$currentPID"
	done < "$processListFile"
	
	rm "$processListFile"
}

_unix_renice_app() {
	local processListFile
	processListFile="$scriptAbsoluteFolder"/.pidlist_$(_uid)
	
	_priority_enumerate_pattern "^plasmashell$" >> "$processListFile"
	
	_priority_enumerate_pattern "^audacious$" >> "$processListFile"
	_priority_enumerate_pattern "^vlc$" >> "$processListFile"
	
	_priority_enumerate_pattern "^firefox$" >> "$processListFile"
	
	_priority_enumerate_pattern "^dolphin$" >> "$processListFile"
	
	_priority_enumerate_pattern "^kwrite$" >> "$processListFile"
	
	_priority_enumerate_pattern "^konsole$" >> "$processListFile"
	
	_priority_enumerate_pattern "^pavucontrol$" >> "$processListFile"
	
	local currentPID
	
	while read -r currentPID
	do
		_priority_app_pid "$currentPID"
	done < "$processListFile"
	
	rm "$processListFile"
}

_unix_renice_idle() {
	local processListFile
	processListFile="$scriptAbsoluteFolder"/.pidlist_$(_uid)
	
	_priority_enumerate_pattern "^packagekitd$" >> "$processListFile"
	
	_priority_enumerate_pattern "^apt-config$" >> "$processListFile"
	
	#_priority_enumerate_pattern "^ModemManager$" >> "$processListFile"
	
	#_priority_enumerate_pattern "^sddm$" >> "$processListFile"
	
	#_priority_enumerate_pattern "^lpqd$" >> "$processListFile"
	#_priority_enumerate_pattern "^cupsd$" >> "$processListFile"
	#_priority_enumerate_pattern "^cups-browsed$" >> "$processListFile"
	
	_priority_enumerate_pattern "^akonadi" >> "$processListFile"
	_priority_enumerate_pattern "^akonadi_indexing_agent$" >> "$processListFile"
	
	#_priority_enumerate_pattern "^kdeconnectd$" >> "$processListFile"
	#_priority_enumerate_pattern "^kacceessibleapp$" >> "$processListFile"
	#_priority_enumerate_pattern "^kglobalaccel5$" >> "$processListFile"
	
	#_priority_enumerate_pattern "^kded4$" >> "$processListFile"
	#_priority_enumerate_pattern "^ksmserver$" >> "$processListFile"
	
	_priority_enumerate_pattern "^sleep$" >> "$processListFile"
	
	_priority_enumerate_pattern "^exim4$" >> "$processListFile"
	_priority_enumerate_pattern "^apache2$" >> "$processListFile"
	_priority_enumerate_pattern "^mysqld$" >> "$processListFile"
	_priority_enumerate_pattern "^ntpd$" >> "$processListFile"
	#_priority_enumerate_pattern "^avahi-daemon$" >> "$processListFile"
	
	
	local currentPID
	
	while read -r currentPID
	do
		_priority_idle_pid "$currentPID"
	done < "$processListFile"
	
	rm "$processListFile"
}



#####Basic Variable Management

#Reset prefixes.
export tmpPrefix="" 

#####Global variables.
#Fixed unique identifier for ubiquitious bash created global resources, such as bootdisc images to be automaticaly mounted by guests. Should NEVER be changed.
export ubiquitiousBashIDnano=uk4u
export ubiquitiousBashIDshort="$ubiquitiousBashIDnano"PhB6
export ubiquitiousBashID="$ubiquitiousBashIDshort"63kVcygT0q

##Parameters
#"--shell", ""
#"--profile"
#"--parent", "--return", "--devenv"
#"--call", "--script" "--bypass"
if [[ "$ub_import_param" == "--profile" ]]
then
	ub_import=true
	export scriptAbsoluteLocation="$profileScriptLocation"
	export scriptAbsoluteFolder="$profileScriptFolder"
	export sessionid=$(_uid)
	_messagePlain_probe_expr 'profile: scriptAbsoluteLocation= '"$scriptAbsoluteLocation"'\n ''profile: scriptAbsoluteFolder= '"$scriptAbsoluteFolder"'\n ''profile: sessionid= '"$sessionid" | _user_log-ub
elif ([[ "$ub_import_param" == "--parent" ]] || [[ "$ub_import_param" == "--embed" ]] || [[ "$ub_import_param" == "--return" ]] || [[ "$ub_import_param" == "--devenv" ]])  && [[ "$scriptAbsoluteLocation" != "" ]] && [[ "$scriptAbsoluteFolder" != "" ]] && [[ "$sessionid" != "" ]]
then
	ub_import=true
	true #Do not override.
	_messagePlain_probe_expr 'parent: scriptAbsoluteLocation= '"$scriptAbsoluteLocation"'\n ''parent: scriptAbsoluteFolder= '"$scriptAbsoluteFolder"'\n ''parent: sessionid= '"$sessionid" | _user_log-ub
elif [[ "$ub_import_param" == "--call" ]] || [[ "$ub_import_param" == "--script" ]] || [[ "$ub_import_param" == "--bypass" ]] || [[ "$ub_import_param" == "--shell" ]] || ([[ "$ub_import" == "true" ]] && [[ "$ub_import_param" == "" ]])
then
	ub_import=true
	export scriptAbsoluteLocation="$importScriptLocation"
	export scriptAbsoluteFolder="$importScriptFolder"
	export sessionid=$(_uid)
	_messagePlain_probe_expr 'call: scriptAbsoluteLocation= '"$scriptAbsoluteLocation"'\n ''call: scriptAbsoluteFolder= '"$scriptAbsoluteFolder"'\n ''call: sessionid= '"$sessionid" | _user_log-ub
elif [[ "$ub_import" != "true" ]]	#"--shell", ""
then
	export scriptAbsoluteLocation=$(_getScriptAbsoluteLocation)
	export scriptAbsoluteFolder=$(_getScriptAbsoluteFolder)
	export sessionid=$(_uid)
	_messagePlain_probe_expr 'default: scriptAbsoluteLocation= '"$scriptAbsoluteLocation"'\n ''default: scriptAbsoluteFolder= '"$scriptAbsoluteFolder"'\n ''default: sessionid= '"$sessionid" | _user_log-ub
else	#FAIL, implies [[ "$ub_import" == "true" ]]
	_messagePlain_bad 'import: fall: fail' | _user_log-ub
	return 1 >/dev/null 2>&1
	exit 1
fi
[[ "$importScriptLocation" != "" ]] && export importScriptLocation=
[[ "$importScriptFolder" != "" ]] && export importScriptFolder=

[[ ! -e "$scriptAbsoluteLocation" ]] && _messagePlain_bad 'missing: scriptAbsoluteLocation= '"$scriptAbsoluteLocation" | _user_log-ub && exit 1
[[ "$sessionid" == "" ]] && _messagePlain_bad 'missing: sessionid' | _user_log-ub && exit 1

export lowsessionid=$(echo -n "$sessionid" | tr A-Z a-z )

#Current directory for preservation.
export outerPWD=$(_getAbsoluteLocation "$PWD")

export initPWD="$PWD"
intInitPWD="$PWD"

#Temporary directories.
export safeTmp="$scriptAbsoluteFolder""$tmpPrefix"/w_"$sessionid"
export scopeTmp="$scriptAbsoluteFolder""$tmpPrefix"/s_"$sessionid"
export queryTmp="$scriptAbsoluteFolder""$tmpPrefix"/q_"$sessionid"
export logTmp="$safeTmp"/log
#Solely for misbehaved applications called upon.
export shortTmp=/tmp/w_"$sessionid"

export scriptBin="$scriptAbsoluteFolder"/_bin
export scriptBundle="$scriptAbsoluteFolder"/_bundle
export scriptLib="$scriptAbsoluteFolder"/_lib
#For trivial installations and virtualized guests. Exclusively intended to support _setupUbiquitous and _drop* hooks.
[[ ! -e "$scriptBin" ]] && export scriptBin="$scriptAbsoluteFolder"
[[ ! -e "$scriptBundle" ]] && export scriptBundle="$scriptAbsoluteFolder"
[[ ! -e "$scriptLib" ]] && export scriptLib="$scriptAbsoluteFolder"


export scriptLocal="$scriptAbsoluteFolder"/_local

#For system installations (exclusively intended to support _setupUbiquitous and _drop* hooks).
if [[ "$scriptAbsoluteLocation" == "/usr/local/bin"* ]] || [[ "$scriptAbsoluteLocation" == "/usr/bin"* ]]
then
	[[ "$scriptAbsoluteLocation" == "/usr/bin"* ]] && export scriptBin="/usr/share/ubcore/bin"
	[[ "$scriptAbsoluteLocation" == "/usr/local/bin"* ]] && export scriptBin="/usr/local/share/ubcore/bin"
	
	if [[ -d "$HOME" ]]
	then
		export scriptLocal="$HOME"/".ubcore"/_sys
	fi
fi

#Essentially temporary tokens which may need to be reused. 
export scriptTokens="$scriptLocal"/.tokens

#Reboot Detection Token Storage
# WARNING WIP. Not tested on all platforms. Requires a directory to be tmp/ram fs mounted. Worst case result is to preserve tokens across reboots.
#Fail-Safe
export bootTmp="$scriptLocal"
#Typical BSD
[[ -d /tmp ]] && export bootTmp='/tmp'
#Typical Linux
[[ -d /dev/shm ]] && export bootTmp='/dev/shm'

#Specialized temporary directories.

#MetaEngine/Engine Tmp Defaults (example, no production use)
#export metaTmp="$scriptAbsoluteFolder""$tmpPrefix"/.m_"$sessionid"
#export engineTmp="$scriptAbsoluteFolder""$tmpPrefix"/.e_"$sessionid"

# WARNING: Only one user per (virtual) machine. Requires _prepare_abstract . Not default.
# DANGER: Mandatory strict directory 8.3 compliance for this variable! Long subdirectory/filenames permitted thereafter.
# DANGER: Permitting multi-user access to this directory may cause unexpected behavior, including inconsitent file ownership.
#Consistent absolute path abstraction.
export abstractfs_root=/tmp/"$ubiquitiousBashIDnano"
( [[ "$bootTmp" == '/dev/shm' ]] || [[ "$bootTmp" == '/tmp' ]] ) && export abstractfs_root="$bootTmp"/"$ubiquitiousBashIDnano"
export abstractfs_lock=/"$bootTmp"/"$ubiquitiousBashID"/afslock

# Unusually, safeTmpSSH must not be interpreted by client, and therefore is single quoted.
# TODO Test safeTmpSSH variants including spaces in path.
export safeTmpSSH='~/.sshtmp/.s_'"$sessionid"

#Process control.
export pidFile="$safeTmp"/.pid
#Invalid do-not-match default.
export uPID="cwrxuk6wqzbzV6p8kPS8J4APYGX"

export daemonPidFile="$scriptLocal"/.bgpid

#export varStore="$scriptAbsoluteFolder"/var

export vncPasswdFile="$safeTmp"/.vncpasswd

#Network Defaults
[[ "$netTimeout" == "" ]] && export netTimeout=18

export AUTOSSH_FIRST_POLL=45
export AUTOSSH_POLL=45
#export AUTOSSH_GATETIME=0
export AUTOSSH_GATETIME=15

#export AUTOSSH_PORT=0

#export AUTOSSH_DEBUG=1
#export AUTOSSH_LOGLEVEL=7

#Monolithic shared files.
export lock_pathlock="$scriptLocal"/l_path
#Used to make locking operations atomic as possible.
export lock_quicktmp="$scriptLocal"/l_qt
export lock_emergency="$scriptLocal"/l_em
export lock_open="$scriptLocal"/l_o
export lock_opening="$scriptLocal"/l_opening
export lock_closed="$scriptLocal"/l_closed
export lock_closing="$scriptLocal"/l_closing
export lock_instance="$scriptLocal"/l_instance
export lock_instancing="$scriptLocal"/l_instancing

#Specialized lock files. Recommend five character or less suffix. Not all of these may yet be implemented.
export specialLocks
specialLocks=""

export lock_open_image="$lock_open"-img
specialLocks+=("$lock_open_image")

export lock_loop_image="$lock_open"-loop
specialLocks+=("$lock_loop_image")

export lock_open_chroot="$lock_open"-chrt
specialLocks+=("$lock_open_chroot")
export lock_open_docker="$lock_open"-dock
specialLocks+=("$lock_open_docker")
export lock_open_vbox="$lock_open"-vbox
specialLocks+=("$lock_open_vbox")
export lock_open_qemu="$lock_open"-qemu
specialLocks+=("$lock_open_qemu")

export specialLock=""
export specialLocks

export ubVirtImageLocal="true"

#Monolithic shared log files.
export importLog="$scriptLocal"/import.log

#Resource directories.
#export guidanceDir="$scriptAbsoluteFolder"/guidance

#Object Dir
export objectDir="$scriptAbsoluteFolder"

#Object Name
export objectName=$(basename "$objectDir")

#Modify PATH to include own directories.
if ! [[ "$PATH" == *":""$scriptAbsoluteFolder"* ]] && ! [[ "$PATH" == "$scriptAbsoluteFolder"* ]]
then
	export PATH="$PATH":"$scriptAbsoluteFolder":"$scriptBin":"$scriptBundle"
fi

export permaLog="$scriptLocal"

export HOST_USER_ID=$(id -u)
export HOST_GROUP_ID=$(id -g)

export globalArcDir="$scriptLocal"/a
export globalArcFS="$globalArcDir"/fs
export globalArcTmp="$globalArcDir"/tmp

export globalBuildDir="$scriptLocal"/b
export globalBuildFS="$globalBuildDir"/fs
export globalBuildTmp="$globalBuildDir"/tmp

#Machine information.

if [[ -e "/proc/meminfo" ]]
then
	export hostMemoryTotal=$(cat /proc/meminfo | grep MemTotal | tr -cd '[[:digit:]]')
	export hostMemoryAvailable=$(cat /proc/meminfo | grep MemAvailable | tr -cd '[[:digit:]]')
	export hostMemoryQuantity="$hostMemoryTotal"
else
	export hostMemoryTotal="384000"
	export hostMemoryAvailable="256000"
	export hostMemoryQuantity="$hostMemoryTotal"
fi

export virtGuestUserDrop="ubvrtusr"
export virtGuestUser="$virtGuestUserDrop"
[[ "$HOST_USER_ID" == 0 ]] && export virtGuestUser="root"

export globalVirtDir="$scriptLocal"/v
export globalVirtFS="$globalVirtDir"/fs
export globalVirtTmp="$globalVirtDir"/tmp

export instancedVirtDir="$scriptAbsoluteFolder"/v_"$sessionid"
export instancedVirtFS="$instancedVirtDir"/fs
export instancedVirtTmp="$instancedVirtDir"/tmp

export virtGuestHomeDrop=/home/"$virtGuestUserDrop"
export virtGuestHome="$virtGuestHomeDrop"
[[ "$HOST_USER_ID" == 0 ]] && export virtGuestHome=/root
###export virtGuestHomeRef="$virtGuestHome".ref

export instancedVirtHome="$instancedVirtFS""$virtGuestHome"
###export instancedVirtHomeRef="$instancedVirtHome".ref

export sharedHostProjectDirDefault=""
export sharedGuestProjectDirDefault="$virtGuestHome"/project

export sharedHostProjectDir="$sharedHostProjectDirDefault"
export sharedGuestProjectDir="$sharedGuestProjectDirDefault"

export instancedProjectDir="$instancedVirtHome"/project
export instancedDownloadsDir="$instancedVirtHome"/Downloads

export chrootDir="$globalVirtFS"
export vboxRaw="$scriptLocal"/vmvdiraw.vmdk

#Only globalFakeHome is persistent. All other default home directories are removed in some way by "_stop".
export globalFakeHome="$scriptLocal"/h
export instancedFakeHome="$scriptAbsoluteFolder"/h_"$sessionid"
export shortFakeHome="$shortTmp"/h

#Do not use directly as home directory. Append subdirectories.
export arbitraryFakeHome="$shortTmp"/a

#Default, override.
# WARNING: Do not disable.
export actualFakeHome="$instancedFakeHome"
export fakeHomeEditLib="false"
export keepFakeHome="true"

#Automatically assigns appropriate memory quantities to nested virtual machines.
_vars_vmMemoryAllocationDefault() {
	export vmMemoryAllocationDefault=96
	
	
	# Invalid.
	[[ "$hostMemoryQuantity" -lt "64000" ]] && return 1
	! [[ "$hostMemoryQuantity" -ge "64000" ]] && return 1
	
	
	# Embedded host typical.
	[[ "$hostMemoryQuantity" -lt "500000" ]] && export vmMemoryAllocationDefault=256 && return 1
	
	# Obsolete hardware or guest typical.
	[[ "$hostMemoryQuantity" -lt "1256000" ]] && export vmMemoryAllocationDefault=512 && return 0
	[[ "$hostMemoryQuantity" -lt "1768000" ]] && export vmMemoryAllocationDefault=1024 && return 0
	[[ "$hostMemoryQuantity" -lt "6000000" ]] && export vmMemoryAllocationDefault=1512 && return 0
	
	# Modern host typical.
	[[ "$hostMemoryQuantity" -lt "7000000" ]] && export vmMemoryAllocationDefault=2048 && return 0
	[[ "$hostMemoryQuantity" -lt "18000000" ]] && export vmMemoryAllocationDefault=2560 && return 0
	[[ "$hostMemoryQuantity" -lt "34000000" ]] && export vmMemoryAllocationDefault=3072 && return 0
	
	# Workstation typical.
	[[ "$hostMemoryQuantity" -lt "72000000" ]] && export vmMemoryAllocationDefault=4096 && return 0
	[[ "$hostMemoryQuantity" -lt "132000000" ]] && export vmMemoryAllocationDefault=4096 && return 0
	
	# Atypical host.
	export vmMemoryAllocationDefault=4096 && return 0
	
	return 1
}

#Machine allocation defaults.
_vars_vmMemoryAllocationDefault

export hostToGuestDir="$instancedVirtDir"/htg
export hostToGuestFiles="$hostToGuestDir"/files
export hostToGuestISO="$instancedVirtDir"/htg/htg.iso 




_prepareFakeHome() {
	mkdir -p "$actualFakeHome"
}

_rm_instance_fakeHome() {
	! [[ -e "$instancedFakeHome" ]] && return 0
	
	[[ -e "$instancedFakeHome" ]] && rmdir "$instancedFakeHome" > /dev/null 2>&1
	
	[[ -e "$instancedFakeHome" ]] && _unmakeFakeHome "$instancedFakeHome" > /dev/null 2>&1
	
	# DANGER Allows folders containing ".git" to be removed in all further shells inheriting this environment!
	export safeToDeleteGit="true"
	[[ -e "$instancedFakeHome" ]] && _safeRMR "$instancedFakeHome"
	export safeToDeleteGit="false"
}

_test_metaengine_sequence() {
	! _start_metaengine_host && _stop 1
	! _stop_metaengine_allow && _stop 1
	
	! _reset_me_name && _stop 1
	! _assign_me_coordinates "" "" "" "" "" "" 0 1 0 1 1 0 && _stop 1
	! _set_me_null_in && _stop 1
	
	
	! _reset_me_name && _stop 1
	! _set_me_null_in && _stop 1
	! _set_me_rand_out && _stop 1
	! _cycle_me && _stop 1
	! _set_me_null_out && _stop 1
	
	! _reset_me_name && _stop 1
	! _set_me_null_in && _stop 1
	! _assign_me_name_out "1" && _stop 1
	! _cycle_me && _stop 1
	! _assign_me_name_out "2" && _stop 1
	! _cycle_me && _stop 1
	! _assign_me_name_out "3" && _stop 1
	! _cycle_me && _stop 1
	! _set_me_null_out && _stop 1
	
	! _stop_metaengine_allow && _stop 1
	_stop
}

_test_metaengine() {
	_getDep mkfifo
	
	if ! "$scriptAbsoluteLocation" _test_metaengine_sequence > /dev/null 2>&1
	then
		echo 'fail: metaengine: internal'
		_stop 1
	fi
}

_report_metaengine() {
	_messagePlain_nominal 'init: _report_metaengine'
	
	[[ ! -e "$metaTmp" ]] && _messagePlain_bad 'missing: metaTmp'
	
	
	[[ "$metaBase" == "" ]] && _messagePlain_warn 'blank: metaBase'
	[[ "$metaObjName" == "" ]] && _messagePlain_warn 'blank: metaObjName'
	
	#[[ "$metaType" == "" ]] && _messagePlain_warn 'blank: metaID'
	
	[[ "$metaID" == "" ]] && _messagePlain_warn 'blank: metaID'
	
	[[ "$metaPath" == "" ]] && _messagePlain_warn 'blank: metaPath'
	
	[[ "$metaDir_tmp" == "" ]] && _messagePlain_warn 'blank: metaDir_tmp'
	[[ "$metaDir_base" == "" ]] && _messagePlain_warn 'blank: metaDir_base'
	[[ "$metaDir" == "" ]] && _messagePlain_warn 'blank: metaDir'
	
	[[ "$metaReg" == "" ]] && _messagePlain_warn 'blank: metaReg'
	
	[[ "$metaConfidence" == "" ]] && _messagePlain_warn 'blank: metaConfidence'
	
	[[ ! -e "$metaBase" ]] && _messagePlain_warn 'missing: metaBase'
	
	[[ ! -e "$metaDir_tmp" ]] && _messagePlain_warn 'missing: metaDir_tmp'
	[[ ! -e "$metaDir_base" ]] && _messagePlain_warn 'missing: metaDir_base'
	[[ ! -e "$metaDir" ]] && _messagePlain_warn 'missing: metaDir'
	
	[[ ! -e "$metaReg" ]] && _messagePlain_warn 'missing: metaReg'
	
	[[ ! -e "$metaDir"/ao ]] && _messagePlain_warn 'missing: "$metaDir"/ao'
	[[ ! -e "$metaDir"/bo ]] && _messagePlain_warn 'missing: "$metaDir"/bo'
	
	[[ ! -e "$in_me_a_path" ]] && _messagePlain_warn 'missing: in_me_a_path'
	[[ ! -e "$in_me_b_path" ]] && _messagePlain_warn 'missing: in_me_b_path'
}

_report_metaengine_relink_in() {
	[[ ! -e "$metaDir"/ai ]] && _messagePlain_warn 'missing: "$metaDir"/ai'
	[[ ! -e "$metaDir"/bi ]] && _messagePlain_warn 'missing: "$metaDir"/bi'
}

_report_metaengine_relink_out() {
	[[ ! -e "$out_me_a_path" ]] && _messagePlain_warn 'missing: out_me_a_path'
	[[ ! -e "$out_me_b_path" ]] && _messagePlain_warn 'missing: out_me_b_path'
}

_message_me_vars() {
	_message_me_set
	_message_me_coordinates
	_message_me_name
}

_message_me_set() {
	_messagePlain_probe '########## SET'
	
	_messageVar metaBase
	_messageVar metaObjName
	echo
	_messageVar metaID
	echo
	_messageVar metaPath
	_messageVar metaDir_tmp
	_messageVar metaDir_base
	_messageVar metaDir
	_messageVar metaReg
	_messageVar metaConfidence
	echo
	_message_me_path
}

_message_me_path() {
	_messagePlain_probe '########## PATH'
	_messageVar in_me_a_path
	_messageVar in_me_b_path
	_messageVar out_me_a_path
	_messageVar out_me_b_path
	echo
}

_message_me_coordinates() {
	_messagePlain_probe '########## IO - COORDINATES'
	_messagePlain_probe '##### ai'
	_messageVar in_me_a_z
	_messageVar in_me_a_x
	_messageVar in_me_a_y
	echo
	_messagePlain_probe '##### bi'
	_messageVar in_me_b_z
	_messageVar in_me_b_x
	_messageVar in_me_b_y
	echo
	_messagePlain_probe '##### ao'
	_messageVar out_me_a_z
	_messageVar out_me_a_x
	_messageVar out_me_a_y
	echo
	_messagePlain_probe '##### bo'
	_messageVar out_me_b_z
	_messageVar out_me_b_x
	_messageVar out_me_b_y
	echo
}

_message_me_name() {
	_messagePlain_probe '########## IO - NAMES'
	_messageVar in_me_a_name
	_messageVar in_me_b_name
	_messageVar out_me_a_name
	_messageVar out_me_b_name
}

_me_header_here() {
	cat << CZXWXcRMTo8EmM8i4d
#!/usr/bin/env bash

#Green. Working as expected.
_messagePlain_good() {
	echo -e -n '\E[0;32m '
	echo -n "\$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Yellow. May or may not be a problem.
_messagePlain_warn() {
	echo -e -n '\E[1;33m '
	echo -n "\$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

#Red. Will result in missing functionality, reduced performance, etc, but not necessarily program failure overall.
_messagePlain_bad() {
	echo -e -n '\E[0;31m '
	echo -n "\$@"
	echo -e -n ' \E[0m'
	echo
	return 0
}

CZXWXcRMTo8EmM8i4d
}

_me_var_here_script() {
	cat << CZXWXcRMTo8EmM8i4d
	
export scriptAbsoluteLocation="$scriptAbsoluteLocation"
export scriptAbsoluteFolder="$scriptAbsoluteFolder"
export sessionid="$sessionid"

CZXWXcRMTo8EmM8i4d
}

_me_var_here_prog() {
	cat << CZXWXcRMTo8EmM8i4d
CZXWXcRMTo8EmM8i4d
}

_me_var_here() {
	_me_var_here_script

	cat << CZXWXcRMTo8EmM8i4d

#Special. Signals do NOT reset metaID .
export metaEmbed="true"

#near equivalent: _set_me_host
	export metaBase="$metaBase"
	export metaObjName="$metaObjName"
	export metaTmp="$metaTmp"
	#export metaTmp="$scriptAbsoluteFolder""$tmpPrefix"/.m_"$sessionid"
	export metaProc="$metaProc"
	# WARNING: Setting metaProc to a value not including sessionid disables automatic removal by default!
	#export metaProc="$metaBase""$tmpPrefix"/.m_"$sessionid"

export metaType="$metaType"

export metaID="$metaID"

export metaPath="$metaPath"

#export metaDir_tmp="$metaTmp"/"$metaPath"
#export metaDir_base="$metaProc"/"$metaPath"

#near equivalent _set_me_dir
	#export metaDir_tmp="$metaTmp"/"$metaPath"
	#export metaDir_base="$metaProc"/"$metaPath"
	#export metaDir="$metaDir_tmp"
	export metaDir_tmp="$metaDir_tmp"
	export metaDir_base="$metaDir_base"
	export metaDir="$metaDir"
	#[[ "$metaType" == "base" ]] && export metaDir="$metaDir_base" && _messagePlain_warn 'metaType= base'
	#[[ "$metaType" == "" ]] && _messagePlain_good 'metaType= '
	[[ "$metaType" == "base" ]] && _messagePlain_warn 'metaType= base'
	[[ "$metaType" == "" ]] && _messagePlain_good 'metaType= '

export metaReg="$metaReg"
export metaConfidence="$metaConfidence"

export in_me_a_path="$in_me_a_path"
export in_me_b_path="$in_me_b_path"
export out_me_a_path="$out_me_a_path"
export out_me_b_path="$out_me_b_path"



CZXWXcRMTo8EmM8i4d
	
	_me_var_here_prog "$@"
}

_me_embed_here() {
	_me_header_here
	
	_me_var_here
	
	cat << CZXWXcRMTo8EmM8i4d


. "$scriptAbsoluteLocation" --embed "\$@"
CZXWXcRMTo8EmM8i4d
}

_me_command_here() {
	_me_header_here
	
	_me_var_here
	
	#cat << CZXWXcRMTo8EmM8i4d
#
#
#. "$scriptAbsoluteLocation" --embed "$1" "\$@"
#CZXWXcRMTo8EmM8i4d

echo -n '. "$scriptAbsoluteLocation" --embed'

local currentArg
for currentArg in "$@"
do
	echo -n ' '
	_safeEcho \""$currentArg"\"
done

echo ' "$@"'

cat << CZXWXcRMTo8EmM8i4d
# Mark task complete, if part of parallel thread set.
if [[ "$processThreadID" != "" ]]
then
	_complete_me "$processThreadID"
	rm -f "$metaProc"/_active/"$processThreadID" > /dev/null 2>&1
fi
CZXWXcRMTo8EmM8i4d

}

_me_command_here_write() {
	mkdir -p "$metaDir"
	_me_command_here "$@" > "$metaDir"/me.sh
	chmod 700 "$metaDir"/me.sh
}
_me_command_here_write_noclobber() {
	[[ -e "$metaDir"/me.sh ]] && return 0
	
	_me_command_here_write "$@"
}
_me_command() {
	_messageNormal 'write: '"$metaObjName"
	_set_me
	_me_command_here_write "$@"
	
	_messageNormal 'fork: '"$metaObjName"': '"$metaDir"/me.sh
	"$metaDir"/me.sh &
}



# ATTENTION: Declare with "core.sh" or similar if appropriate.
# WARNING: Any "$tmpPrefix" will be reset before metaengine unless explicitly declared here.
#_set_me_host_prefix() {
#	export metaPrefix="prefix"
#}

_set_me_host() {
	_set_me_base
	
	_tryExec "_set_me_host_prefix"
	
	export metaTmp="$scriptAbsoluteFolder""$metaPrefix"/.m_"$sessionid"
	
	# WARNING: Setting metaProc to a value not including sessionid disables automatic removal by default!
	# WARNING: Setting metaProc to a value not accepted by "_safeRMR" disables automatic removal by default!
	export metaProc="$scriptAbsoluteFolder""$metaPrefix"/.m_"$sessionid"
	[[ "$metaType" == "base" ]] && export metaProc="$metaBase""$metaPrefix"/.m_"$sessionid"
	#[[ "$metaType" == "" ]] && export metaProc="$scriptAbsoluteFolder""$metaPrefix"/.m_"$sessionid"
}

_reset_me_host() {
	_reset_me_base
	
	export metaTmp=
	export metaProc=
}

_set_me() {
	_messagePlain_nominal 'init: _set_me'
	
	#_set_me_base
	#_set_me_objname
	
	_set_me_uid
	
	_set_me_path
	_set_me_dir
	_set_me_reg
	
	_set_me_confidence
	
	_set_me_io_in
	_set_me_io_out
	
	_message_me_set
}

_reset_me() {
	#_reset_me_base
	#_reset_me_objname
	
	#_reset_me_host
	
	_reset_me_uid
	
	_reset_me_path
	_reset_me_dir
	_reset_me_reg
	
	_reset_me_confidence
	
	_reset_me_name
	_reset_me_coordinates
	
	_reset_me_type
	
	_reset_me_io
	
	_stop_metaengine_allow
}

_set_me_uid() {
	[[ "$metaEmbed" == "true" ]] && return 0
	export metaID=$(_uid)
}

_reset_me_uid() {
	export metaID=
}

_set_me_path() {
	export metaPath="$metaID"
}

_reset_me_path() {
	export metaPath=
}

# ATTENTION: Overload with "core.sh" if appropriate.
_set_me_dir() {
	export metaDir_tmp="$metaTmp"/"$metaPath"
	
	export metaDir_base="$metaProc"/"$metaPath"
	
	export metaDir="$metaDir_tmp"
	[[ "$metaType" == "base" ]] && export metaDir="$metaDir_base" && _messagePlain_warn 'metaDir= base'
	[[ "$metaType" == "" ]] && _messagePlain_good 'metaDir= tmp'
}

_reset_me_dir() {
	export metaDir_tmp=
	export metaDir_base=
	
	export metaDir=
}

# ATTENTION: Overload with "core.sh" if appropriate.
_set_me_reg() {
	export metaReg="$metaTmp"/_reg
	[[ "$metaType" == "base" ]] && export metaReg="$metaBase"/_reg && _messagePlain_warn 'metaReg= base'
	[[ "$metaType" == "" ]] && _messagePlain_good 'metaReg= tmp'
}

_reset_me_reg() {
	export metaReg=
}

#Intended to signal task completion, allowing shutdown of processing chain.
_set_me_confidence() {
	export metaConfidence="$metaReg"/confidence
}

_reset_me_confidence() {
	export metaConfidence=
}



# ATTENTION: Overload with "core.sh" if appropriate.
_set_me_base() {
	export metaBase=
	
	export metaBase="$outerPWD"
	
	#[[ "$@" != "" ]] && export metaengine_base=$(_searchBaseDir "$@")
	#[[ "$metaengine_base" == "" ]] && export metaengine_base=$(_searchBaseDir "$@" "$virtUserPWD")
	
	#export metaengine_base="$scriptAbsoluteLocation"
}

_reset_me_base() {
	export metaBase=
}

# ATTENTION: Overload with "core.sh" if appropriate.
# WARNING: No default production use.
_set_me_objname() {
	export metaObjName=
	
	export metaObjName="$objectName"
}

_reset_me_objname() {
	export metaObjName=
}



_reset_me_coordinates_ai() {
	export in_me_a_x=
	export in_me_a_y=
	export in_me_a_z=
}

_reset_me_coordinates_bi() {
	export in_me_b_x=
	export in_me_b_y=
	export in_me_b_z=
}

_reset_me_coordinates_ao() {
	export out_me_a_x=
	export out_me_a_y=
	export out_me_a_z=
}

_reset_me_coordinates_bo() {
	export out_me_b_x=
	export out_me_b_y=
	export out_me_b_z=
}

_reset_me_coordinates() {
	_reset_me_coordinates_ai
	_reset_me_coordinates_bi
	_reset_me_coordinates_ao
	_reset_me_coordinates_bo
}


_check_me_coordinates_ai() {
	[[ "$in_me_a_x" == "" ]] && return 1
	[[ "$in_me_a_y" == "" ]] && return 1
	[[ "$in_me_a_z" == "" ]] && return 1
	return 0
}

_check_me_coordinates_bi() {
	[[ "$in_me_b_x" == "" ]] && return 1
	[[ "$in_me_b_y" == "" ]] && return 1
	[[ "$in_me_b_z" == "" ]] && return 1
	return 0
}

_check_me_coordinates_ao() {
	[[ "$out_me_a_x" == "" ]] && return 1
	[[ "$out_me_a_y" == "" ]] && return 1
	[[ "$out_me_a_z" == "" ]] && return 1
	return 0
}

_check_me_coordinates_bo() {
	[[ "$out_me_b_x" == "" ]] && return 1
	[[ "$out_me_b_y" == "" ]] && return 1
	[[ "$out_me_b_z" == "" ]] && return 1
	return 0
}

_check_me_coordinates_in() {
	! _check_me_coordinates_ai && return 1
	! _check_me_coordinates_bi && return 1
	return 0
}

_check_me_coordinates_out() {
	! _check_me_coordinates_ao && return 1
	! _check_me_coordinates_bo && return 1
	return 0
}

_check_me_coordinates() {
	! _check_me_coordinates_ai && return 1
	! _check_me_coordinates_bi && return 1
	! _check_me_coordinates_ao && return 1
	! _check_me_coordinates_bo && return 1
	return 0
}

_reset_me_name_ai() {
	export in_me_a_name=
}

_reset_me_name_bi() {
	export in_me_b_name=
}

_reset_me_name_ao() {
	export out_me_a_name=
}

_reset_me_name_bo() {
	export out_me_b_name=
}

_reset_me_rand() {
	_reset_me_name_ai
	_reset_me_name_bi
	_reset_me_name_ao
	_reset_me_name_bo
}
_reset_me_name() {
	_reset_me_name_ai
	_reset_me_name_bi
	_reset_me_name_ao
	_reset_me_name_bo
}

_check_me_name_in() {
	[[ "$in_me_a_name" == "" ]] && return 1
	[[ "$in_me_b_name" == "" ]] && return 1
	return 0
}

_check_me_name_out() {
	[[ "$out_me_a_name" == "" ]] && return 1
	[[ "$out_me_b_name" == "" ]] && return 1
	return 0
}

_check_me_name() {
	[[ "$in_me_a_name" == "" ]] && return 1
	[[ "$in_me_b_name" == "" ]] && return 1
	[[ "$out_me_a_name" == "" ]] && return 1
	[[ "$out_me_b_name" == "" ]] && return 1
	return 0
}
_check_me_rand() {
	_check_me_name
}


_set_me_io_name_in() {
	_messagePlain_nominal 'init: _set_me_io_name_in'
	
	# Optional feature. While used, must must contain at least one file/dir.
	export in_me_a_active="$metaReg"/name/"$in_me_a_name"/_active
	export in_me_a_active_tmp="$in_me_a_active"_tmp
	export in_me_b_active="$metaReg"/name/"$in_me_b_name"/_active
	export in_me_b_active_tmp="$in_me_b_active"_tmp
	export in_me_active="$in_me_a_active"
	export in_me_active_tmp="$in_me_a_active_tmp"
	
	export in_me_a_path="$metaReg"/name/"$in_me_a_name"/ao
		[[ "$in_me_a_name" == "null" ]] && export in_me_a_path=/dev/null
	export in_me_b_path="$metaReg"/name/"$in_me_b_name"/bo
		[[ "$in_me_b_name" == "null" ]] && export in_me_b_path=/dev/null
	
	_messagePlain_good 'return: success'
	return 0
}

_set_me_io_name_out() {
	_messagePlain_nominal 'init: _set_me_io_name_out'
	
	# Optional feature. While used, must must contain at least one file/dir.
	export out_me_a_active="$metaReg"/name/"$out_me_a_name"/_active
	export out_me_a_active_tmp="$out_me_a_active"_tmp
	export out_me_b_active="$metaReg"/name/"$out_me_b_name"/_active
	export out_me_b_active_tmp="$out_me_b_active"_tmp
	export out_me_active="$out_me_a_active"
	export out_me_active_tmp="$out_me_a_active_tmp"
	
	export out_me_a_path="$metaReg"/name/"$out_me_a_name"/ao
		[[ "$out_me_a_name" == "null" ]] && export out_me_a_path=/dev/null
	export out_me_b_path="$metaReg"/name/"$out_me_b_name"/bo
		[[ "$out_me_b_name" == "null" ]] && export out_me_b_path=/dev/null
	
	_messagePlain_good 'return: success'
	return 0
}

_set_me_io_coordinates_in() {
	_messagePlain_nominal 'init: _set_me_io_coordinates_in'
	
	# WARNING: Untested.
	# Optional feature. While used, must must contain at least one file/dir.
	export in_me_a_active="$metaReg"/grid/_active/"$in_me_a_z"/"$in_me_a_x"/"$in_me_a_y"
	export in_me_a_active_tmp="$in_me_a_active"_tmp
	export in_me_b_active="$metaReg"/grid/_active/"$in_me_b_z"/"$in_me_b_x"/"$in_me_b_y"
	export in_me_b_active_tmp="$in_me_b_active"_tmp
	export in_me_active="$in_me_a_active"
	export in_me_active_tmp="$in_me_a_active_tmp"
	
	export in_me_a_path="$metaReg"/grid/"$in_me_a_z"/"$in_me_a_x"/"$in_me_a_y"
	export in_me_b_path="$metaReg"/grid/"$in_me_b_z"/"$in_me_b_x"/"$in_me_b_y"
	
	_messagePlain_good 'return: success'
	return 0
}

_set_me_io_coordinates_out() {
	_messagePlain_nominal 'init: _set_me_io_coordinates_out'
	
	# WARNING: Untested.
	# Optional feature. While used, must must contain at least one file/dir.
	export out_me_a_active="$metaReg"/grid/_active/"$out_me_a_z"/"$out_me_a_x"/"$out_me_a_y"
	export out_me_a_active_tmp="$out_me_a_active"_tmp
	export out_me_b_active="$metaReg"/grid/_active/"$out_me_b_z"/"$out_me_b_x"/"$out_me_b_y"
	export out_me_b_active_tmp="$out_me_b_active"_tmp
	export out_me_active="$out_me_a_active"
	export out_me_active_tmp="$out_me_a_active_tmp"
	
	export out_me_a_path="$metaReg"/grid/"$out_me_a_z"/"$out_me_a_x"/"$out_me_a_y"
	export out_me_b_path="$metaReg"/grid/"$out_me_b_z"/"$out_me_b_x"/"$out_me_b_y"
	
	_messagePlain_good 'return: success'
	return 0
}

#No production use.
_set_me_io_coordinates() {
	_messagePlain_nominal 'init: _set_me_io_coordinates'
	
	export in_me_a_path="$metaReg"/grid/"$in_me_a_z"/"$in_me_a_x"/"$in_me_a_y"
	export in_me_b_path="$metaReg"/grid/"$in_me_b_z"/"$in_me_b_x"/"$in_me_b_y"
	export out_me_a_path="$metaReg"/grid/"$out_me_a_z"/"$out_me_a_x"/"$out_me_a_y"
	export out_me_b_path="$metaReg"/grid/"$out_me_b_z"/"$out_me_b_x"/"$out_me_b_y"
	
	_messagePlain_good 'return: success'
	return 0
}

_set_me_io_in() {
	_messagePlain_nominal 'init: _set_me_io'
	
	! _check_me_coordinates_in && ! _check_me_name_in && _messageError 'FAIL: invalid IO coordinates and names' && _stop 1
	
	#_check_me_name && _messagePlain_good 'valid: name' && _set_me_io_name && _messagePlain_good 'return: success' && return 0
	_check_me_name_in && _messagePlain_good 'valid: name_in' && _set_me_io_name_in && _messagePlain_good 'return: success' && return 0
	
	#_check_me_coordinates && _messagePlain_good 'valid: coordinates' && _set_me_io_coordinates && _messagePlain_good 'return: success' && return 0
	_check_me_coordinates_in && _messagePlain_good 'valid: coordinates_in' && _set_me_io_coordinates_in && _messagePlain_good 'return: success' && return 0
	
	_messageError 'FAIL: undefined failure'
	_stop 1
}

_set_me_io_out() {
	_messagePlain_nominal 'init: _set_me_io'
	
	! _check_me_coordinates_out && ! _check_me_name_out && _messageError 'FAIL: invalid IO coordinates and names' && _stop 1
	
	#_check_me_name && _messagePlain_good 'valid: name' && _set_me_io_name && _messagePlain_good 'return: success' && return 0
	_check_me_name_out && _messagePlain_good 'valid: name_out' && _set_me_io_name_out && _messagePlain_good 'return: success' && return 0
	
	#_check_me_coordinates && _messagePlain_good 'valid: coordinates' && _set_me_io_coordinates && _messagePlain_good 'return: success' && return 0
	_check_me_coordinates_out && _messagePlain_good 'valid: coordinates_out' && _set_me_io_coordinates_out && _messagePlain_good 'return: success' && return 0
	
	_messageError 'FAIL: undefined failure'
	_stop 1
}

#No production use.
_set_me_io() {
	_messagePlain_nominal 'init: _set_me_io'
	
	! _check_me_coordinates && ! _check_me_name && _messageError 'FAIL: invalid IO coordinates and names' && _stop 1
	
	#_check_me_name && _messagePlain_good 'valid: name' && _set_me_io_name && _messagePlain_good 'return: success' && return 0
	_check_me_name_in && _messagePlain_good 'valid: name_in' && _set_me_io_name_in && _messagePlain_good 'return: success' && return 0
	_check_me_name_out && _messagePlain_good 'valid: name_out' && _set_me_io_name_out && _messagePlain_good 'return: success' && return 0
	
	#_check_me_coordinates && _messagePlain_good 'valid: coordinates' && _set_me_io_coordinates && _messagePlain_good 'return: success' && return 0
	_check_me_coordinates_in && _messagePlain_good 'valid: coordinates_in' && _set_me_io_coordinates_in && _messagePlain_good 'return: success' && return 0
	_check_me_coordinates_out && _messagePlain_good 'valid: coordinates_out' && _set_me_io_coordinates_out && _messagePlain_good 'return: success' && return 0
	
	_messageError 'FAIL: undefined failure'
	_stop 1
}

_reset_me_io() {
	export in_me_a_path=
	export in_me_b_path=
	export out_me_a_path=
	export out_me_b_path=
}



_assign_me_objname() {
	export metaObjName="$1"
	_messagePlain_nominal 'set: metaObjName= '"$metaObjName"
}

_set_me_type_tmp() {
	export metaType=""
	_messagePlain_nominal 'set: metaType= (tmp)'"$metaType"
}

_set_me_type_base() {
	export metaType="base"
	_messagePlain_nominal 'set: metaType= '"$metaType"
}

_reset_me_type() {
	export metaType=
}


_cycle_me_name() {
	export in_me_a_name="$out_me_a_name"
	export in_me_b_name="$out_me_b_name"
	_set_me_rand_out
	
	_messagePlain_nominal 'cycle: in_me_a_name= (out_me_a_name)'"$in_me_a_name"' ''cycle: in_me_b_name= (out_me_b_name)'"$in_me_b_name"
	_messagePlain_probe 'rand: out_me_a_name= '"$out_me_a_name"' ''rand: out_me_b_name= '"$out_me_b_name"
}
_cycle_me() {
	_cycle_me_name
}


_assign_me_name_ai() {
	export in_me_a_name="$1"
}

_assign_me_name_bi() {
	export in_me_b_name="$1"
}

_assign_me_name_ao() {
	export out_me_a_name="$1"
}

_assign_me_name_bo() {
	export out_me_b_name="$1"
}

_assign_me_name_in() {
	_assign_me_name_ai "$1"
	_assign_me_name_bi "$1"
}

_assign_me_name_out() {
	_assign_me_name_ao "$1"
	_assign_me_name_bo "$1"
}



# WARNING: Coordinate assignment by centroid for 3D pipeline representation ONLY. Detailed spatial data to be completely represented in binary formatted named buffers.
#_assign_me_coordinates aiX aiY aiZ biX biY biZ aoX aoY aoZ boX boY boZ
_assign_me_coordinates() {
	_assign_me_coordinates_ai "$1" "$2" "$3"
		shift ; shift ; shift
	_assign_me_coordinates_bi "$1" "$2" "$3"
		shift ; shift ; shift
	_assign_me_coordinates_ao "$1" "$2" "$3"
		shift ; shift ; shift
	_assign_me_coordinates_bo "$1" "$2" "$3"
}

#_assign_me... X Y Z
_assign_me_coordinates_ai() {
	export in_me_a_x="$1"
		shift
	export in_me_a_y="$1"
		shift
	export in_me_a_z="$1"
}

#_assign_me... X Y Z
_assign_me_coordinates_bi() {
	export in_me_b_x="$1"
		shift
	export in_me_b_y="$1"
		shift
	export in_me_b_z="$1"
}

#_assign_me... X Y Z
_assign_me_coordinates_ao() {
	export out_me_a_x="$1"
		shift
	export out_me_a_y="$1"
		shift
	export out_me_a_z="$1"
}

#_assign_me... X Y Z
_assign_me_coordinates_bo() {
	export out_me_b_x="$1"
		shift
	export out_me_b_y="$1"
		shift
	export out_me_b_z="$1"
}

# No known production use.
_set_me_rand_in() {
	_messagePlain_nominal 'init: _set_me_rand_in'
	local rand_uid
	rand_uid=$(_uid)
	export in_me_a_name="$rand_uid"
	export in_me_b_name="$rand_uid"
}

_set_me_rand_out() {
	_messagePlain_nominal 'init: _set_me_rand_out'
	local rand_uid
	rand_uid=$(_uid)
	export out_me_a_name="$rand_uid"
	export out_me_b_name="$rand_uid"
}

# No known production use.
_set_me_rand() {
	_messagePlain_nominal 'init: _set_me_rand'
	_set_me_rand_in
	_set_me_rand_out
}

_set_me_null_in() {
	_messagePlain_nominal 'init: _set_me_null_in'
	_assign_me_name_ai null
	_assign_me_name_bi null
}

_set_me_null_out() {
	_messagePlain_nominal 'init: _set_me_null_out'
	_assign_me_name_ao null
	_assign_me_name_bo null
}

_set_me_null() {
	_messagePlain_nominal 'init: _set_me_null'
	_set_me_null_in
	_set_me_null_out
}

_relink_metaengine_coordinates_in() {
	_messagePlain_nominal 'init: _relink_metaengine_coordinates_in'
	
	_messageCMD mkdir -p "$metaReg"/grid/"$in_me_a_z"/"$in_me_a_x"
	_messageCMD _relink_relative "$in_me_a_path" "$metaDir"/ai
	
	_messageCMD mkdir -p "$metaReg"/grid/"$in_me_b_z"/"$in_me_b_x"
	_messageCMD _relink_relative "$in_me_b_path" "$metaDir"/bi
	
	_report_metaengine_relink_in
	
	_messagePlain_good 'return: complete'
	return 0
}

_relink_metaengine_coordinates_out() {
	_messagePlain_nominal 'init: _relink_metaengine_coordinates_out'
	
	_messageCMD mkdir -p "$metaReg"/grid/"$out_me_a_z"/"$out_me_a_x"
	_messageCMD _relink_relative "$metaDir"/ao "$out_me_a_path"
	
	_messageCMD mkdir -p "$metaReg"/grid/"$out_me_b_z"/"$out_me_b_x"
	_messageCMD _relink_relative "$metaDir"/bo "$out_me_b_path"
	
	_report_metaengine_relink_out
	
	_messagePlain_good 'return: complete'
	return 0
}

#No production use.
_relink_metaengine_coordinates() {
	_messagePlain_nominal 'init: _relink_metaengine_coordinates'
	
	_messageCMD mkdir -p "$metaReg"/grid/"$in_me_a_z"/"$in_me_a_x"
	_messageCMD _relink_relative "$in_me_a_path" "$metaDir"/ai
	
	_messageCMD mkdir -p "$metaReg"/grid/"$in_me_b_z"/"$in_me_b_x"
	_messageCMD _relink_relative "$in_me_b_path" "$metaDir"/bi
	
	_messageCMD mkdir -p "$metaReg"/grid/"$out_me_a_z"/"$out_me_a_x"
	_messageCMD _relink_relative "$metaDir"/ao "$out_me_a_path"
	
	_messageCMD mkdir -p "$metaReg"/grid/"$out_me_b_z"/"$out_me_b_x"
	_messageCMD _relink_relative "$metaDir"/bo "$out_me_b_path"
	
	_messagePlain_good 'return: complete'
	return 0
}

#No production use. Untested.
_rmlink_metaengine_coordinates() {
	#_rmlink "$metaDir"/ai > /dev/null 2>&1
	#rmdir "$metaReg"/grid/"$in_me_a_z"/"$in_me_a_x" > /dev/null 2>&1
	#rmdir "$metaReg"/grid/"$in_me_a_z" > /dev/null 2>&1
	
	#_rmlink "$metaDir"/bi > /dev/null 2>&1
	#rmdir "$metaReg"/grid/"$in_me_b_z"/"$in_me_b_x" > /dev/null 2>&1
	#rmdir "$metaReg"/grid/"$in_me_b_z" > /dev/null 2>&1
	
	_rmlink "$out_me_a_path" > /dev/null 2>&1
	rmdir "$metaReg"/grid/"$out_me_a_z"/"$out_me_a_x" > /dev/null 2>&1
	rmdir "$metaReg"/grid/"$out_me_a_z" > /dev/null 2>&1
	
	_rmlink "$out_me_b_path" > /dev/null 2>&1
	rmdir "$metaReg"/grid/"$out_me_b_z"/"$out_me_b_x" > /dev/null 2>&1
	rmdir "$metaReg"/grid/"$out_me_b_z" > /dev/null 2>&1
}

_relink_metaengine_name_in() {
	_messagePlain_nominal 'init: _relink_metaengine_name'
	
	#No known production relevance.
	[[ -e "$metaReg"/name/"$metaID" ]] && _messageError 'FAIL: unexpected safety' && _stop 1
	
	_messageCMD mkdir -p "$metaReg"/name/"$in_me_a_name"
	! [[ "$in_me_a_path" == "/dev/null" ]] && _messageCMD _relink_relative "$in_me_a_path" "$metaDir"/ai
	_messageCMD mkdir -p "$metaReg"/name/"$in_me_b_name"
	! [[ "$in_me_a_path" == "/dev/null" ]] && _messageCMD _relink_relative "$in_me_b_path" "$metaDir"/bi
	
	[[ "$in_me_a_path" == "/dev/null" ]] && _relink "$in_me_a_path" "$metaDir"/ai
	[[ "$in_me_b_path" == "/dev/null" ]] && _relink "$in_me_b_path" "$metaDir"/bi
	
	# DANGER: Administrative/visualization use ONLY.
	( [[ "$in_me_a_path" == "/dev/null" ]] || [[ "$in_me_b_path" == "/dev/null" ]] ) && _relink_relative "$metaDir" "$metaReg"/name/null/"$metaID"
	
	_report_metaengine_relink_in
	
	_messagePlain_good 'return: complete'
	return 0
}

_relink_metaengine_name_out() {
	_messagePlain_nominal 'init: _relink_metaengine_name'
	
	#No known production relevance.
	[[ -e "$metaReg"/name/"$metaID" ]] && _messageError 'FAIL: unexpected safety' && _stop 1
	
	_messageCMD mkdir -p "$metaReg"/name/"$out_me_a_name"
	! [[ "$out_me_a_path" == "/dev/null" ]] && _messageCMD _relink_relative "$metaDir"/ao "$out_me_a_path"
	_messageCMD mkdir -p "$metaReg"/name/"$out_me_b_name"
	! [[ "$out_me_b_path" == "/dev/null" ]] && _messageCMD _relink_relative "$metaDir"/bo "$out_me_b_path"
	
	[[ "$out_me_a_path" == "/dev/null" ]] && rmdir "$metaDir"/ao && _relink /dev/null "$metaDir"/ao
	[[ "$out_me_b_path" == "/dev/null" ]] && rmdir "$metaDir"/bo && _relink /dev/null "$metaDir"/bo
	
	# DANGER: Administrative/visualization use ONLY.
	( [[ "$out_me_a_path" == "/dev/null" ]] || [[ "$out_me_b_path" == "/dev/null" ]] ) && _relink_relative "$metaDir" "$metaReg"/name/null/"$metaID"
	
	_report_metaengine_relink_out
	
	_messagePlain_good 'return: complete'
	return 0
}

#No production use. Unmaintained.
_relink_metaengine_name() {
	_messagePlain_nominal 'init: _relink_metaengine_name'
	
	#No known production relevance.
	[[ -e "$metaReg"/name/"$metaID" ]] && _messageError 'FAIL: unexpected safety' && _stop 1
	
	_messageCMD mkdir -p "$metaReg"/name/"$in_me_a_name"
	_messageCMD _relink_relative "$in_me_a_path" "$metaDir"/ai
	_messageCMD mkdir -p "$metaReg"/name/"$in_me_b_name"
	_messageCMD _relink_relative "$in_me_b_path" "$metaDir"/bi
	
	_messageCMD mkdir -p "$metaReg"/name/"$out_me_a_name"
	_messageCMD _relink_relative "$metaDir"/ao "$out_me_a_path"
	_messageCMD mkdir -p "$metaReg"/name/"$out_me_b_name"
	_messageCMD _relink_relative "$metaDir"/bo "$out_me_b_path"
	
	[[ "$out_me_a_path" == "/dev/null" ]] && rmdir "$metaDir"/ao && _relink /dev/null "$metaDir"/ao
	[[ "$out_me_b_path" == "/dev/null" ]] && rmdir "$metaDir"/bo && _relink /dev/null "$metaDir"/bo
	
	_messagePlain_good 'return: complete'
	return 0
}

#No production use. Untested.
_rmlink_metaengine_name() {
	
	#_rmlink "$metaDir"/ai > /dev/null 2>&1
	#rmdir "$metaReg"/name/"$in_me_a_name" > /dev/null 2>&1
	#_rmlink "$metaDir"/bi > /dev/null 2>&1
	#rmdir "$metaReg"/name/"$in_me_a_name" > /dev/null 2>&1
	
	_rmlink "$out_me_a_path" > /dev/null 2>&1
	rmdir "$metaReg"/name/"$out_me_a_name" > /dev/null 2>&1
	_rmlink "$out_me_b_path" > /dev/null 2>&1
	rmdir "$metaReg"/name/"$out_me_b_name" > /dev/null 2>&1
}


_relink_metaengine_out() {
	_messagePlain_nominal 'init: _relink_metaengine'
	
	! _check_me_coordinates_out && ! _check_me_name_out && _messageError 'FAIL: invalid IO coordinates and names' && _stop 1
	
	#_check_me_name && _messagePlain_good 'valid: name' && _prepare_metaengine_name && _relink_metaengine_name && _messagePlain_good 'return: success' && return 0
	_check_me_name_out && _messagePlain_good 'valid: name_out' && _prepare_metaengine_name && _relink_metaengine_name_out && _messagePlain_good 'return: success' && return 0
	
	#_check_me_coordinates && _messagePlain_good 'valid: coordinates' && _prepare_metaengine_coordinates && _relink_metaengine_coordinates && _messagePlain_good 'return: success' && return 0
	_check_me_coordinates_out && _messagePlain_good 'valid: coordinates_out' && _prepare_metaengine_coordinates && _relink_metaengine_coordinates_out && _messagePlain_good 'return: success' && return 0
	
	_messagePlain_bad 'stop: undefined failure'
	_stop 1
}

_relink_metaengine_in() {
	_messagePlain_nominal 'init: _relink_metaengine'
	
	! _check_me_coordinates_in && ! _check_me_name_in && _messageError 'FAIL: invalid IO coordinates and names' && _stop 1
	
	#_check_me_name && _messagePlain_good 'valid: name' && _prepare_metaengine_name && _relink_metaengine_name && _messagePlain_good 'return: success' && return 0
	_check_me_name_in && _messagePlain_good 'valid: name_in' && _prepare_metaengine_name && _relink_metaengine_name_in && _messagePlain_good 'return: success' && return 0
	
	#_check_me_coordinates && _messagePlain_good 'valid: coordinates' && _prepare_metaengine_coordinates && _relink_metaengine_coordinates && _messagePlain_good 'return: success' && return 0
	_check_me_coordinates_in && _messagePlain_good 'valid: coordinates_in' && _prepare_metaengine_coordinates && _relink_metaengine_coordinates_in && _messagePlain_good 'return: success' && return 0
	
	_messagePlain_bad 'stop: undefined failure'
	_stop 1
}

#No production use.  Unmaintained.
_relink_metaengine() {
	_messagePlain_nominal 'init: _relink_metaengine'
	
	! _check_me_coordinates && ! _check_me_name && _messageError 'FAIL: invalid IO coordinates and names' && _stop 1
	
	#_check_me_name && _messagePlain_good 'valid: name' && _prepare_metaengine_name && _relink_metaengine_name && _messagePlain_good 'return: success' && return 0
	_check_me_name_in && _messagePlain_good 'valid: name_in' && _prepare_metaengine_name && _relink_metaengine_name_in && _messagePlain_good 'return: success' && return 0
	_check_me_name_out && _messagePlain_good 'valid: name_out' && _prepare_metaengine_name && _relink_metaengine_name_out && _messagePlain_good 'return: success' && return 0
	
	#_check_me_coordinates && _messagePlain_good 'valid: coordinates' && _prepare_metaengine_coordinates && _relink_metaengine_coordinates && _messagePlain_good 'return: success' && return 0
	_check_me_coordinates_in && _messagePlain_good 'valid: coordinates_in' && _prepare_metaengine_coordinates && _relink_metaengine_coordinates_in && _messagePlain_good 'return: success' && return 0
	_check_me_coordinates_out && _messagePlain_good 'valid: coordinates_out' && _prepare_metaengine_coordinates && _relink_metaengine_coordinates_out && _messagePlain_good 'return: success' && return 0
	
	_messagePlain_bad 'stop: undefined failure'
	_stop 1
}


_prepare_metaengine_coordinates() {
	mkdir -p "$metaReg"/grid
}

_prepare_metaengine_name() {
	mkdir -p "$metaReg"/name
}

_prepare_metaengine() {
	mkdir -p "$metaTmp"
	
	[[ "$metaDir_tmp" != "" ]] && mkdir -p "$metaDir_tmp"
	[[ "$metaDir" != "" ]] && mkdir -p "$metaDir"
	
	mkdir -p "$metaReg"
	
	mkdir -p "$metaDir"/ao
	mkdir -p "$metaDir"/bo
}

_start_metaengine_host() {
	_stop_metaengine_allow
	
	[[ -e "$scriptAbsoluteFolder""$tmpPrefix"/.e_"$sessionid" ]] && _messageError 'FAIL: safety: meta conflicts engine' && _stop 1
	
	_messageNormal 'init: _start_metaengine_host'
	
	_set_me_host
	
	_start
	
	mkdir -p "$metaTmp"
	
	#_relink_relative "$safeTmp"/.pid "$metaTmp"/.pid
}

_start_metaengine() {
	_stop_metaengine_prohibit
	
	[[ -e "$scriptAbsoluteFolder""$tmpPrefix"/.e_"$sessionid" ]] && _messageError 'FAIL: safety: meta conflicts engine' && _stop 1
	
	_messageNormal 'processor: '"$metaObjName"
	_messagePlain_probe 'init: _start_metaengine'
	
	_prepare
	#_start
	
	_set_me
	_prepare_metaengine
	
	# WARNING: Processors must include "_relink_metaengine_in" and "_relink_metaengine_out" where appropriate.
	#_relink_metaengine_in
	#_relink_metaengine_out
	
	_report_metaengine
	
	echo $$ > "$metaDir"/.pid
	_relink_relative "$metaDir"/.pid "$metaDir_tmp"/.pid
	
	_me_embed_here > "$metaDir"/.metaenv.sh
	chmod 755 "$metaDir"/.metaenv.sh
	
	echo "$sessionid" > "$metaDir"/.sessionid
	_embed_here > "$metaDir"/.embed.sh
	chmod 755 "$metaDir"/.embed.sh
}

_stop_metaengine_allow() {
	export metaStop="true"
}
_stop_metaengine_prohibit() {
	export metaStop="false"
}

#Waits for files to exist, or indefinitely pauses, allowing SIGINT or similar to trigger "_stop" at any time. Former case also terminates if metaConfidence is set.
_stop_metaengine_wait() {
	_stop_metaengine_allow
	
	while ! _all_exist "$@" 
	do
		sleep 0.1
	done
	
	if [[ "$1" == "" ]]
	then
		while true
		do
			sleep 1
		done
	fi
}

_confidence_metaengine() {
	if [[ -e "$metaConfidence" ]]
	then
		local currentMetaConfidenceValue
		currentMetaConfidenceValue=$(cat "$metaConfidence")
		
		[[ "$currentMetaConfidenceValue" == '1' ]] && return 0
	fi
	
	return 1
}

#_rm_instance_metaengine_metaDir() {
#	# WARNING: No production use, heredoc unsupported.
#	[[ "$metaPreserve" == "true" ]] && return 0
#	
#	[[ "$metaDir" != "" ]] && [[ "$metaDir" == *"$sessionid"* ]] && [[ -e "$metaDir" ]] && _safeRMR "$metaDir"
#}

_rm_instance_metaengine() {
	# WARNING: Documentation only. Any "_stop" condition expected to cleanup work directory corresponding to sessionid.
	# Recommended practice is separate MetaEngine host for any intermittent processing chain.
	#_rm_instance_metaengine_metaDir
	
	[[ "$metaStop" != "true" ]] && return 0
	export metaStop="false"
	
	_terminateMetaProcessorAll_metaengine
	
	# ATTENTION: Optional feature. Copies host metaengine directories for analysis.
	if [[ "$metaLog" != "" ]] && [[ -e "$metaLog" ]]
	then
		cp -a "$metaTmp" "$metaLog"/metaTmp
		cp -a "$metaProc" "$metaLog"/metaProc
	fi
	
	#Only created if needed by meta.
	[[ "$metaTmp" != "" ]] && [[ -e "$metaTmp" ]] && _safeRMR "$metaTmp"
	
	[[ "$metaProc" != "" ]] && [[ "$metaProc" == *"$sessionid"* ]] && [[ -e "$metaProc" ]] && _safeRMR "$metaProc"
}

_complete_me_active() {
	[[ "$in_me_active" == "" ]] && return 1
	! [[ -e "$in_me_active" ]] && return 1
	
	local currentActiveProcCount
	currentActiveProcCount=$(ls -1 "$in_me_active" | wc -l | tr -dc '0-9')
	
	if [[ "$currentActiveProcCount" == '0' ]]
	then
		return 0
	fi
	
	return 1
}

_ready_me_in() {
	#! [[ -e "$in_me_a_path" ]] && _messagePlain_warn 'missing: in_me_a_path= '"$in_me_a_path"
	#! [[ -e "$in_me_b_path" ]] && _messagePlain_warn 'missing: in_me_b_path= '"$in_me_b_path"
	
	if [[ ! -e "$in_me_a_path" ]] || [[ ! -e "$in_me_b_path" ]]
	then
		return 1
	fi
	
	_messagePlain_good 'ready: in_me_a_path, in_me_b_path'
	return 0
}

_wait_metaengine_host() {
	_messagePlain_nominal 'init: _wait_metaengine_host'
	_wait_metaengine_in "$@"
}

_wait_metaengine() {
	_messagePlain_nominal 'init: _wait_metaengine'
	_wait_metaengine_in "$@"
}

# ATTENTION: Overload with "core.sh" if appropriate.
_wait_metaengine_in() {
	#_ready_me_in && return 0
	#sleep 0.1
	#_ready_me_in && return 0
	#sleep 0.3
	#_ready_me_in && return 0
	#sleep 1
	#_ready_me_in && return 0
	
	#sleep 3
	#_ready_me_in && return 0
	#sleep 10
	#_ready_me_in && return 0
	#sleep 10
	#_ready_me_in && return 0
	#sleep 10
	#_ready_me_in && return 0
	#sleep 20
	#_ready_me_in && return 0
	#sleep 20
	#_ready_me_in && return 0
	#sleep 20
	#_ready_me_in && return 0
	
	while ! _ready_me_in && ! _complete_me_active && ! [[ -e "$metaConfidence" ]]
	do
		sleep 0.1
	done
	
	if [[ -e "$metaConfidence" ]]
	then
		if [[ $(head -c 1 "$metaConfidence") == '0' ]]
		then
			_messagePlain_bad 'fail: flag: exists: false: metaConfidence= '"$metaConfidence"
			return 1
		fi
		
		_messagePlain_good 'pass: flag: exists: metaConfidence= '"$metaConfidence"
		return 1
	fi
	
	if ! _ready_me_in && _complete_me_active
	then
		rm -f "$in_me_active" > /dev/null 2>&1
		[[ -e "$in_me_active" ]] && rmdir "$in_me_active" > /dev/null 2>&1
		_messagePlain_bad 'fail: died: '"$in_me_active" && return 1
	fi
	
	return 0
	
	# Unexpected.
	! _ready_me_in && _messagePlain_bad 'unexpected: missing: in_me_a_path, in_me_b_path' && return 1
}

# "$1" == uid
_active_me() {
	_set_me_io_out
	
	mkdir -p "$out_me_active_tmp"
	echo "$$" > "$out_me_active_tmp"/"$1"
	_relink_relative "$out_me_active_tmp" "$out_me_active"
}

# "$1" == uid
_complete_me() {
	rm "$out_me_active_tmp"/"$1"
}

_terminateMetaProcessorAll_metaengine() {
	local processListFile
	processListFile="$scriptAbsoluteFolder"/.pidlist_m_$(_uid)
	
	local currentPID
	
	cat "$metaTmp"/*/.pid >> "$processListFile" 2> /dev/null
	
	while read -r currentPID
	do
		pkill -P "$currentPID" > /dev/null 2>&1
		kill "$currentPID" > /dev/null 2>&1
	done < "$processListFile"
	
	rm "$processListFile"
}

# Intended to illustrate the basic logic flow. Uses global variables for some arguments - resetting these is MANDATORY .
_example_process_rand() {
	_start_metaengine_host
	
	_set_me_null_in
	_set_me_rand_out
	_example_processor_name
	
	_cycle_me
	_example_processor_name
	
	_cycle_me
	_example_processor_name
	
	_cycle_me
	_set_me_null_out
	_example_processor_name
	
	_reset_me
	
	_stop_metaengine_wait
}

# Intended to illustrate the basic logic flow. Uses global variables for some arguments - resetting these is MANDATORY .
_example_process_name() {
	_start_metaengine_host
	
	_set_me_null_in
	_assign_me_name_out "1"
	_example_processor_name
	
	_cycle_me
	_assign_me_name_out "2"
	_example_processor_name
	
	_cycle_me
	_assign_me_name_out "3"
	_example_processor_name
	
	_cycle_me
	_set_me_null_out
	_example_processor_name
	
	_reset_me
	
	_stop_metaengine_wait
}

# Intended to illustrate the basic logic flow. Uses global variables for some arguments - resetting these is MANDATORY .
_example_process_coordinates() {
	_start_metaengine_host
	
	#_assign_me_coordinates aiX aiY aiZ biX biY biZ aoX aoY aoZ boX boY boZ
	#"$metaReg"/grid/"$z"/"$x"/"$y"
	
	_reset_me_name
	_assign_me_coordinates "" "" "" "" "" "" 0 1 0 1 1 0
	_set_me_null_in
	_example_processor_name
	
	_reset_me_name
	_assign_me_coordinates 0 1 0 1 1 0 0 2 0 1 2 0
	_example_processor_name
	
	_reset_me_name
	_assign_me_coordinates 0 2 0 1 2 0 0 3 0 1 3 0
	_example_processor_name
	
	_reset_me_name
	_assign_me_coordinates 0 3 0 1 3 0 0 4 0 1 4 0
	_example_processor_name
	
	_reset_me
	
	_stop_metaengine_wait
}

# Intended to illustrate the basic logic flow. Uses global variables for some arguments - resetting these is MANDATORY .
_example_process_base() {
	_start_metaengine_host
	
	_set_me_type_base
	
	#_assign_me_coordinates aiX aiY aiZ biX biY biZ aoX aoY aoZ boX boY boZ
	#"$metaReg"/grid/"$z"/"$x"/"$y"
	
	_reset_me_name
	_assign_me_coordinates "" "" "" "" "" "" 0 1 0 1 1 0
	_set_me_null_in
	_example_processor_name
	
	_reset_me_name
	_assign_me_coordinates 0 1 0 1 1 0 0 2 0 1 2 0
	_example_processor_name
	
	_reset_me_name
	_assign_me_coordinates 0 2 0 1 2 0 0 3 0 1 3 0
	_example_processor_name
	
	_reset_me_name
	_assign_me_coordinates 0 3 0 1 3 0 0 4 0 1 4 0
	_example_processor_name
	
	_reset_me
	
	_stop_metaengine_wait
}


# Intended to illustrate the basic logic flow. Uses global variables for some arguments - resetting these is MANDATORY .
_example_processor_name() {
	_assign_me_objname "_example_processor_name"
	
	_me_command "_example_me_processor_name"
	
	#Optional. Usually correctly orders diagnostic output.
	sleep 3
}

_example_me_processor_name() {
	_messageNormal 'launch: '"$metaObjName"
	
	! _wait_metaengine && _stop 1
	_start_metaengine
	_relink_metaengine_in
	_relink_metaengine_out
	
	#Do something.
	#> cat >
	while true
	do
		sleep 10
	done
	
	#optional, closes host upon completion
	#_stop
}


# Intended to illustrate the basic logic flow. Uses global variables for some arguments - resetting these is MANDATORY .
#"$1" == _me_processor_name
#"$2" == metaObjName (optional)
_processor_launch() {
	_assign_me_objname "$1"
	#[[ "$2" != "" ]] && _assign_me_objname "$2"
	
	_me_command "$@"
	
	#Optional. Usually correctly orders diagnostic output.
	#_wait_metaengine_host
	#sleep 3
}

_me_processor_noise() {
	_messageNormal 'launch: '"$metaObjName"
	
	! _wait_metaengine && _stop 1
	_start_metaengine
	_relink_metaengine_in
	_relink_metaengine_out
	
	_buffer_me_processor_fifo
	
	cat < /dev/urandom > "$metaDir"/ao/fifo
	
	#while true
	#do
	#	sleep 1
	#done
	
	#optional, closes host upon completion
	#_stop
}

_me_divert() {
	_buffer_me_processor_divert "$@"
}

#Registers an output to a diversion directory for processors which may support more than two inputs. Expected to be used with special processors creating their own unique registrations (ie. _reg/special).
_buffer_me_processor_divert() {
	mkdir -p "$metaReg"/"$1"/divert
	mkdir -p "$metaReg"/"$2"/divert
	
	
	_relink "$metaDir"/ao "$metaReg"/"$1"/divert/"$metaID"
	_relink "$metaDir"/bo "$metaReg"/"$2"/divert/"$metaID"
}

_me_fifo() {
	_buffer_me_processor_fifo
}

_me_snippet_reset() {
	_buffer_me_processor_snippet_reset
}

_me_snippet_write() {
	_buffer_me_processor_snippet_write
}

_me_snippet_read() {
	_buffer_me_processor_snippet_read
}

_me_snippet_read_wait() {
	_buffer_me_processor_snippet_read_wait
}

_me_confidence_full() {
	_buffer_me_processor_confidence_full
}

_me_confidence_none() {
	_buffer_me_processor_confidence_none
}

_buffer_me_processor_fifo() {
	_buffer_me_processor_fifo_rm
	
	#[[ -d "$metaDir"/ai ]] && mkfifo "$metaDir"/ai/fifo
	#[[ -d "$metaDir"/bi ]] && mkfifo "$metaDir"/bi/fifo
	
	[[ -d "$metaDir"/ao ]] && mkfifo "$metaDir"/ao/fifo
	#[[ -d "$metaDir"/bo ]] && mkfifo "$metaDir"/bo/fifo
}

_buffer_me_processor_fifo_rm() {
	rm -f "$metaDir"/ao/fifo > /dev/null 2>&1
	#rm -f "$metaDir"/bo/fifo > /dev/null 2>&1
}

_buffer_me_processor_snippet_reset() {
	echo | _buffer_me_processor_snippet_assign
}

_buffer_me_processor_snippet_write() {
	! [[ -d "$metaDir"/ao ]] && return 1
	
	cat > "$metaDir"/ao/quicktmp_snippet
	mv -n "$metaDir"/ao/quicktmp_snippet "$metaDir"/ao/snippet
	rm -f "$metaDir"/ao/quicktmp_snippet > /dev/null 2>&1
}

_buffer_me_processor_snippet_check_binary() {
	! [[ -e "$metaDir"/bi/confidence ]] && return 1
	! [[ -e "$metaDir"/ai/snippet ]] && return 1
	
	local snippetConfidence
	snippetConfidence=$(cat "$metaDir"/bi/confidence)
	
	#cat "$metaDir"/bi/confidence
	
	[[ "$snippetConfidence" == "1" ]] && return 0
	return 1
}

_buffer_me_processor_snippet_check() {
	! [[ -e "$metaDir"/bi/confidence ]] && return 1
	! [[ -e "$metaDir"/ai/snippet ]] && return 1
	
	local snippetConfidence
	snippetConfidence=$(cat "$metaDir"/bi/confidence)
	
	cat "$metaDir"/bi/confidence
	
	[[ "$snippetConfidence" == "1" ]] && return 0
	return 1
}

_buffer_me_processor_snippet_read() {
	! [[ -d "$metaDir"/ai ]] && return 1
	! [[ -d "$metaDir"/bi ]] && return 1
	
	! [[ -e "$metaDir"/ai/snippet ]] && return 1
	
	cat "$metaDir"/ai/snippet
}

_buffer_me_processor_snippet_read_wait() {
	! [[ -d "$metaDir"/ai ]] && return 1
	! [[ -d "$metaDir"/bi ]] && return 1
	
	while ! _buffer_me_processor_snippet_check_binary
	do
		sleep 0.3
	done
	
	cat "$metaDir"/ai/snippet
}

_buffer_me_processor_confidence_reset() {
	_buffer_me_processor_confidence_none
}

_buffer_me_processor_confidence_none() {
	echo 0 | _buffer_me_processor_confidence_write
}

#Typically signals snippet processor task complete.
_buffer_me_processor_confidence_full() {
	echo 1 | _buffer_me_processor_confidence_write
}

_buffer_me_processor_confidence_write() {
	! [[ -d "$metaDir"/bo ]] && return 1
	
	cat > "$metaDir"/bo/quicktmp_confidence
	mv "$metaDir"/bo/quicktmp_confidence "$metaDir"/bo/confidence
	rm -f "$metaDir"/bo/quicktmp_confidence > /dev/null 2>&1
}

# WARNING: Untested.
_me_page_read() {
	_buffer_me_processor_page_in_read "$@"
}

# WARNING: Untested.
_me_page_write() {
	_buffer_me_processor_page_out_write "$@"
}

_me_page_tick_read() {
	_buffer_me_processor_page_tick_default _me_page_read "$@"
}

_me_page_tick_write() {
	_buffer_me_processor_page_tick_default _me_page_write "$@"
}

# WARNING: High performance is not to be expected from bash implementation. C/OpenCL may be better suited.
_me_page_tick_advance() {
	_buffer_me_processor_page_tick_advance_default "$@"
}




_buffer_me_processor_page_tick() {
	local measureTickA
	local measureTickB
	local measureTickDifference
	
	measureTickA=$(cat "$bufferTick_file")
	
	while true
	do
		measureTickB=$(cat "$bufferTick_file")
		measureTickDifference=$(bc <<< "$measureTickB - $measureTickA")
		
		if [[ "$measureTickDifference" -ge "$bufferTick_count" ]]
		then
			"$@"
		fi
		
		sleep 0.005
	done
}

_buffer_me_processor_page_tick_default() {
	export bufferTick_file="$metaReg"/tick
	export bufferTick_count=1
	
	_buffer_me_processor_page_tick "$@"
	
	export bufferTick_file=
	export bufferTick_count=
}

_buffer_me_processor_page_tick_advance_default() {
	export bufferTick_file="$metaReg"/tick
	export bufferTick_count=1
	
	_buffer_me_processor_page_tick_advance "$@"
	
	export bufferTick_file=
	export bufferTick_count=
}

_buffer_me_processor_page_tick_advance() {
	! [[ -e "$bufferTick_file" ]] && _buffer_me_processor_page_tick_reset
	
	local bufferTick_current
	bufferTick_current=$(cat "$bufferTick_file")
	
	local bufferTick_next
	bufferTick_next=$(bc <<< "$bufferTick_current + 1")
	
	echo "$bufferTick_next" | _buffer_me_processor_page_tick_write
}

_buffer_me_processor_page_tick_reset() {
	echo 0 | _buffer_me_processor_page_tick_write
}

_buffer_me_processor_page_tick_write() {
	#! [[ -d "$metaReg" ]] && return 1
	
	cat > "$bufferTick_file".tmp
	mv "$bufferTick_file".tmp "$bufferTick_file"
	rm -f "$bufferTick_file".tmp > /dev/null 2>&1
}

_buffer_me_processor_page_clock() {
	local measureDateA
	local measureDateB
	local measureDateDifference
	
	measureDateA=$(date +%s%N | cut -b1-13)
	
	while true
	do
		measureDateB=$(date +%s%N | cut -b1-13)
		measureDateDifference=$(bc <<< "$measureDateB - $measureDateA")
		
		if [[ "$measureDateDifference" -ge "$bufferClock_ms" ]]
		then
			"$@"
		fi
		
		[[ "$bufferClock_ms" -ge "3000" ]] && sleep 1
		[[ "$bufferClock_ms" -ge "300" ]] && sleep 0.1
		sleep 0.005
	done
}

_buffer_me_processor_page_clock_100fps() {
	export bufferClock_ms=10
	_buffer_me_processor_page_clock "$@"
	export bufferClock_ms=
}

_buffer_me_processor_page_clock_90fps() {
	export bufferClock_ms=11
	_buffer_me_processor_page_clock "$@"
	export bufferClock_ms=
}

_buffer_me_processor_page_clock_30fps() {
	export bufferClock_ms=33
	_buffer_me_processor_page_clock "$@"
	export bufferClock_ms=
}

_buffer_me_processor_page_clock_1fps() {
	export bufferClock_ms=1000
	_buffer_me_processor_page_clock "$@"
	export bufferClock_ms=
}

_buffer_me_processor_page_clock_1fpm() {
	export bufferClock_ms=60000
	_buffer_me_processor_page_clock "$@"
	export bufferClock_ms=
}

_buffer_me_processor_page_clock_1fph() {
	export bufferClock_ms=360000
	_buffer_me_processor_page_clock "$@"
	export bufferClock_ms=
}




_buffer_me_processor_page_in_read() {
	! [[ -e "$metaDir"/bi/pointer ]] && return 1
	
	local bufferPointerRead
	
	bufferPointerRead=$(_buffer_me_processor_page_pointer_in_get_current)
	
	! [[ -e "$metaDir"/ai/"$bufferPointerRead" ]] && return 1
	
	cat "$metaDir"/ai/"$bufferPointerRead"
}


_buffer_me_processor_page_pointer_in_get_current() {
	! [[ -e "$metaDir"/bi/pointer ]] && return 1
	
	cat "$metaDir"/bi/pointer
}

_buffer_me_processor_page_pointer_out_get_previous() {
	! [[ -e "$metaDir"/bi/pointer ]] && return 1
	
	local bufferPointer
	
	bufferPointer=$(cat "$metaDir"/bi/pointer)
	
	[[ "$bufferPointer" == "0" ]] && echo 2 && return 0
	[[ "$bufferPointer" == "1" ]] && echo 0 && return 0
	[[ "$bufferPointer" == "2" ]] && echo 1 && return 0
}

_buffer_me_processor_page_pointer_out_get_next() {
	! [[ -e "$metaDir"/bi/pointer ]] && return 1
	
	local bufferPointer
	
	bufferPointer=$(cat "$metaDir"/bi/pointer)
	
	[[ "$bufferPointer" == "0" ]] && echo 1 && return 0
	[[ "$bufferPointer" == "1" ]] && echo 2 && return 0
	[[ "$bufferPointer" == "2" ]] && echo 0 && return 0
}





_buffer_me_processor_page_out_write() {
	_buffer_me_processor_page_pointer_out_advance
	
	local bufferPointerWrite
	bufferPointerNext=$(_buffer_me_processor_page_pointer_out_get_next)
	
	cat > "$metaDir"/ao/quicktmp_page"$bufferPointerWrite"
	mv "$metaDir"/ao/quicktmp_page"$bufferPointerWrite" "$metaDir"/ao/"$bufferPointerWrite"
	rm -f "$metaDir"/ao/quicktmp_page"$bufferPointerWrite" > /dev/null 2>&1
}

_buffer_me_processor_page_pointer_out_advance() {
	! [[ -d "$metaDir"/bo ]] && return 1
	
	! [[ -e "$metaDir"/bo/pointer ]] && _buffer_me_processor_page_pointer_out_reset
	
	local bufferPointerNext
	bufferPointerNext=$(_buffer_me_processor_page_pointer_out_get_next)
	
	echo "$bufferPointerNext" | _buffer_me_processor_page_pointer_out_write
}

_buffer_me_processor_page_pointer_out_get_current() {
	! [[ -e "$metaDir"/bo/pointer ]] && return 1
	
	cat "$metaDir"/bo/pointer
}

_buffer_me_processor_page_pointer_out_get_previous() {
	! [[ -e "$metaDir"/bo/pointer ]] && return 1
	
	local bufferPointer
	
	bufferPointer=$(cat "$metaDir"/bo/pointer)
	
	[[ "$bufferPointer" == "0" ]] && echo 2 && return 0
	[[ "$bufferPointer" == "1" ]] && echo 0 && return 0
	[[ "$bufferPointer" == "2" ]] && echo 1 && return 0
}

_buffer_me_processor_page_pointer_out_get_next() {
	! [[ -e "$metaDir"/bo/pointer ]] && return 1
	
	local bufferPointer
	
	bufferPointer=$(cat "$metaDir"/bo/pointer)
	
	[[ "$bufferPointer" == "0" ]] && echo 1 && return 0
	[[ "$bufferPointer" == "1" ]] && echo 2 && return 0
	[[ "$bufferPointer" == "2" ]] && echo 0 && return 0
}

#No production use.
_buffer_me_processor_page_reset() {
	_buffer_me_processor_page_pointer_reset
	
	rm -f "$metaDir"/ao/0 > /dev/null 2>&1
	rm -f "$metaDir"/ao/1 > /dev/null 2>&1
	rm -f "$metaDir"/ao/2 > /dev/null 2>&1
}

_buffer_me_processor_page_pointer_out_reset() {
	_buffer_me_processor_page_pointer_out_0
}

_buffer_me_processor_page_pointer_out_0() {
	echo 0 | _buffer_me_processor_page_pointer_out_write
}

_buffer_me_processor_page_pointer_out_1() {
	echo 1 | _buffer_me_processor_page_pointer_out_write
}

_buffer_me_processor_page_pointer_out_2() {
	echo 2 | _buffer_me_processor_page_pointer_out_write
}


_buffer_me_processor_page_pointer_out_write() {
	! [[ -d "$metaDir"/bo ]] && return 1
	
	cat > "$metaDir"/bo/quicktmp_pointer
	mv "$metaDir"/bo/quicktmp_pointer "$metaDir"/bo/pointer
	rm -f "$metaDir"/bo/quicktmp_pointer > /dev/null 2>&1
}



#####Local Environment Management (Resources)

#_prepare_prog() {
#	true
#}

_extra() {
	true
}

_prepare_abstract() {
	! mkdir -p "$abstractfs_root" && exit 1
	chmod 0700 "$abstractfs_root" > /dev/null 2>&1
	! chmod 700 "$abstractfs_root" && exit 1
	if ! chown "$USER":"$USER" "$abstractfs_root" > /dev/null 2>&1
	then
		! /sbin/chown "$USER" "$abstractfs_root" && exit 1
	fi
	
	
	! mkdir -p "$abstractfs_lock" && exit 1
	chmod 0700 "$abstractfs_lock" > /dev/null 2>&1
	! chmod 700 "$abstractfs_lock" && exit 1
	if ! chown "$USER":"$USER" "$abstractfs_lock" > /dev/null 2>&1
	then
		! /sbin/chown "$USER" "$abstractfs_root" && exit 1
	fi
}

_prepare() {
	
	! mkdir -p "$safeTmp" && exit 1
	
	! mkdir -p "$shortTmp" && exit 1
	
	! mkdir -p "$logTmp" && exit 1
	
	! mkdir -p "$scriptLocal" && exit 1
	
	! mkdir -p "$bootTmp" && exit 1
	
	#_prepare_abstract
	
	_extra
	_tryExec "_prepare_prog"
}

#####Local Environment Management (Instancing)

#_start_prog() {
#	true
#}

# ATTENTION: Consider carefully, override with "ops".
# WARNING: Unfortunate, but apparently necessary, workaround for script termintaing while "sleep" or similar run under background.
_start_stty_echo() {
	#true
	
	#stty echo --file=/dev/tty > /dev/null 2>&1
	
	export ubFoundEchoStatus=$(stty --file=/dev/tty -g 2>/dev/null)
}

_start() {
	_start_stty_echo
	
	_prepare
	
	#touch "$varStore"
	#. "$varStore"
	
	echo $$ > "$safeTmp"/.pid
	echo "$sessionid" > "$safeTmp"/.sessionid
	_embed_here > "$safeTmp"/.embed.sh
	chmod 755 "$safeTmp"/.embed.sh
	
	_tryExec "_start_prog"
}

#_saveVar_prog() {
#	true
#}

_saveVar() {
	true
	#declare -p varName > "$varStore"
	
	_tryExec "_saveVar_prog"
}

#_stop_prog() {
#	true
#}

# ATTENTION: Consider carefully, override with "ops".
# WARNING: Unfortunate, but apparently necessary, workaround for script termintaing while "sleep" or similar run under background.
_stop_stty_echo() {
	#true
	
	#stty echo --file=/dev/tty > /dev/null 2>&1
	
	[[ "$ubFoundEchoStatus" != "" ]] && stty --file=/dev/tty "$ubFoundEchoStatus" 2> /dev/null
}

_stop() {
	_stop_stty_echo
	
	_tryExec "_stop_prog"
	
	_preserveLog
	
	#Kill process responsible for initiating session. Not expected to be used normally, but an important fallback.
	local ub_stop_pid
	if [[ -e "$safeTmp"/.pid ]]
	then
		ub_stop_pid=$(cat "$safeTmp"/.pid 2> /dev/null)
		if [[ $$ != "$ub_stop_pid" ]]
		then
			pkill -P "$ub_stop_pid" > /dev/null 2>&1
			kill "$ub_stop_pid" > /dev/null 2>&1
		fi
	fi
	#Redundant, as this usually resides in "$safeTmp".
	rm -f "$pidFile" > /dev/null 2>&1
	
	if [[ -e "$scopeTmp" ]] && [[ -e "$scopeTmp"/.pid ]] && [[ "$$" == $(cat "$scopeTmp"/.pid 2>/dev/null) ]]
	then
		#Symlink, or nonexistent.
		rm -f "$ub_scope" > /dev/null 2>&1
		#Only created if needed by scope.
		[[ -e "$scopeTmp" ]] && _safeRMR "$scopeTmp"
	fi
	
	#Only created if needed by query.
	[[ -e "$queryTmp" ]] && _safeRMR "$queryTmp"
	
	#Only created if needed by engine.
	[[ -e "$engineTmp" ]] && _safeRMR "$engineTmp"
	
	_tryExec _rm_instance_metaengine
	_tryExec _rm_instance_channel
	
	_safeRMR "$shortTmp"
	_safeRMR "$safeTmp"
	
	[[ -e "$safeTmp" ]] && sleep 0.1 && _safeRMR "$safeTmp"
	[[ -e "$safeTmp" ]] && sleep 0.3 && _safeRMR "$safeTmp"
	[[ -e "$safeTmp" ]] && sleep 1 && _safeRMR "$safeTmp"
	[[ -e "$safeTmp" ]] && sleep 3 && _safeRMR "$safeTmp"
	[[ -e "$safeTmp" ]] && sleep 3 && _safeRMR "$safeTmp"
	[[ -e "$safeTmp" ]] && sleep 3 && _safeRMR "$safeTmp"
	
	_tryExec _rm_instance_fakeHome
	
	#Optionally always try to remove any systemd shutdown hook.
	#_tryExec _unhook_systemd_shutdown
	
	
	_stop_stty_echo
	if [[ "$1" != "" ]]
	then
		exit "$1"
	else
		exit 0
	fi
}

#Do not overload this unless you know why you need it instead of _stop_prog.
#_stop_emergency_prog() {
#	true
#}

#Called upon SIGTERM or similar signal.
_stop_emergency() {
	[[ "$noEmergency" == true ]] && _stop "$1"
	
	export EMERGENCYSHUTDOWN=true
	
	#Not yet using _tryExec since this function would typically result from user intervention, or system shutdown, both emergency situations in which an error message would be ignored if not useful. Higher priority is guaranteeing execution if needed and available.
	_tryExec "_closeChRoot_emergency"
	
	#Daemon uses a separate instance, and will not be affected by previous actions, possibly even if running in the foreground.
	#jobs -p >> "$daemonPidFile" #Could derrange the correct order of descendent job termination.
	_tryExec _killDaemon
	
	_tryExec _stop_virtLocal
	
	_tryExec "_stop_emergency_prog"
	
	_stop "$1"
	
}

_waitFile() {
	
	[[ -e "$1" ]] && sleep 1
	[[ -e "$1" ]] && sleep 9
	[[ -e "$1" ]] && sleep 27
	[[ -e "$1" ]] && sleep 81
	[[ -e "$1" ]] && _return 1
	
	return 0
}

#Wrapper. If lock file is present, waits for unlocking operation to complete successfully, then reports status.
#"$1" == checkFile
#"$@" == wait command and parameters
_waitFileCommands() {
	local waitCheckFile
	waitCheckFile="$1"
	shift
	
	if [[ -e "$waitCheckFile" ]]
	then
		local waitFileCommandStatus
		
		"$@"
		
		waitFileCommandStatus="$?"
		
		if [[ "$waitFileCommandStatus" != "0" ]]
		then
			return "$waitFileCommandStatus"
		fi
		
		[[ -e "$waitCheckFile" ]] && return 1
		
	fi
	
	return 0
}

#$1 == command to execute if scriptLocal path has changed, typically remove another lock file
_pathLocked() {
	[[ ! -e "$lock_pathlock" ]] && echo "k3riC28hQRLnjgkwjI" > "$lock_pathlock"
	[[ ! -e "$lock_pathlock" ]] && return 1
	
	local lockedPath
	lockedPath=$(cat "$lock_pathlock")
	
	if [[ "$lockedPath" != "$scriptLocal" ]]
	then
		rm -f "$lock_pathlock" > /dev/null 2>&1
		[[ -e "$lock_pathlock" ]] && return 1
		
		echo "$scriptLocal" > "$lock_pathlock"
		[[ ! -e "$lock_pathlock" ]] && return 1
		
		if [[ "$1" != "" ]]
		then
			"$@"
			[[ "$?" != "0" ]] && return 1
		fi
		
	fi
	
	return 0
}

_readLocked() {
	mkdir -p "$bootTmp"
	
	local rebootToken
	rebootToken=$(cat "$1" 2> /dev/null)
	
	#Remove miscellaneous files if appropriate.
	if [[ -d "$bootTmp" ]] && ! [[ -e "$bootTmp"/"$rebootToken" ]]
	then
		rm -f "$scriptLocal"/*.log && rm -f "$scriptLocal"/imagedev && rm -f "$scriptLocal"/WARNING
		
		[[ -e "$lock_quicktmp" ]] && sleep 0.1 && [[ -e "$lock_quicktmp" ]] && rm -f "$lock_quicktmp"
	fi
	
	! [[ -e "$1" ]] && return 1
	##Lock file exists.
	
	if [[ -d "$bootTmp" ]]
	then
		if ! [[ -e "$bootTmp"/"$rebootToken" ]]
		then
			##Lock file obsolete.
			
			#Remove old lock.
			rm -f "$1" > /dev/null 2>&1
			return 1
		fi
		
		##Lock file and token exists.
		return 0
	fi
	
	##Lock file exists, token cannot be found.
	return 0
	
	
	
}

#Using _readLocked before any _createLocked operation is strongly recommended to remove any lock from prior UNIX session (ie. before latest reboot).
_createLocked() {
	[[ "$uDEBUG" == true ]] && caller 0 >> "$scriptLocal"/lock.log
	[[ "$uDEBUG" == true ]] && echo -e '\t'"$sessionid"'\t'"$1" >> "$scriptLocal"/lock.log
	
	mkdir -p "$bootTmp"
	
	! [[ -e "$bootTmp"/"$sessionid" ]] && echo > "$bootTmp"/"$sessionid"
	
	# WARNING Recommend setting this to a permanent value when testing critical subsystems, such as with _userChRoot related operations.
	local lockUID="$(_uid)"
	
	echo "$sessionid" > "$lock_quicktmp"_"$lockUID"
	
	mv -n "$lock_quicktmp"_"$lockUID" "$1" > /dev/null 2>&1
	
	if [[ -e "$lock_quicktmp"_"$lockUID" ]]
	then
		[[ "$uDEBUG" == true ]] && echo -e '\t'FAIL >> "$scriptLocal"/lock.log
		rm -f "$lock_quicktmp"_"$lockUID" > /dev/null 2>&1
		return 1
	fi
	
	rm -f "$lock_quicktmp"_"$lockUID" > /dev/null 2>&1
	return 0
}

_resetLocks() {
	
	_readLocked "$lock_open"
	_readLocked "$lock_opening"
	_readLocked "$lock_closed"
	_readLocked "$lock_closing"
	_readLocked "$lock_instance"
	_readLocked "$lock_instancing"
	
}

_checkSpecialLocks() {
	local localSpecialLock
	
	localSpecialLock="$specialLock"
	[[ "$1" != "" ]] && localSpecialLock="$1"
	
	local currentLock
	
	for currentLock in "${specialLocks[@]}"
	do
		[[ "$currentLock" == "$localSpecialLock" ]] && continue
		_readLocked "$currentLock" && return 0
	done
	
	return 1
}

#Wrapper. Operates lock file for mounting shared resources (eg. persistent virtual machine image). Avoid if possible.
#"$1" == waitOpen function && shift
#"$@" == wrapped function and parameters
#"$specialLock" == additional lockfile to write
_open_sequence() {
	if _readLocked "$lock_open"
	then
		_checkSpecialLocks && return 1
		return 0
	fi
	
	_readLocked "$lock_closing" && return 1
	
	if _readLocked "$lock_opening"
	then
		if _waitFileCommands "$lock_opening" "$1"
		then
			_readLocked "$lock_open" || return 1
			return 0
		else
			return 1
		fi
	fi
	
	_createLocked "$lock_opening" || return 1
	
	shift
	
	echo "LOCKED" > "$scriptLocal"/WARNING
	
	"$@"
	
	if [[ "$?" == "0" ]]
	then
		_createLocked "$lock_open" || return 1
		
		if [[ "$specialLock" != "" ]]
		then
			_createLocked "$specialLock" || return 1
		fi
		
		rm -f "$lock_opening"
		return 0
	fi
	
	return 1
}

_open() {
	local returnStatus
	
	_open_sequence "$@"
	returnStatus="$?"
	
	export specialLock
	specialLock=""
	export specialLock
	
	return "$returnStatus"
}

#Wrapper. Operates lock file for shared resources (eg. persistent virtual machine image). Avoid if possible.
#"$1" == <"--force"> && shift
#"$1" == waitClose function && shift
#"$@" == wrapped function and parameters
#"$specialLock" == additional lockfile to remove
_close_sequence() {
	local closeForceEnable
	closeForceEnable=false
	
	if [[ "$1" == "--force" ]]
	then
		closeForceEnable=true
		shift
	fi
	
	if ! _readLocked "$lock_open" && [[ "$closeForceEnable" != "true" ]]
	then
		return 0
	fi
	
	if [[ "$specialLock" != "" ]] && [[ -e "$specialLock" ]] && ! _readLocked "$specialLock" && [[ "$closeForceEnable" != "true" ]]
	then
		return 1
	fi
	
	_checkSpecialLocks && return 1
	
	if _readLocked "$lock_closing" && [[ "$closeForceEnable" != "true" ]]
	then
		if _waitFileCommands "$lock_closing" "$1"
		then
			return 0
		else
			return 1
		fi
	fi
	
	if [[ "$closeForceEnable" != "true" ]]
	then
		_createLocked "$lock_closing" || return 1
	fi
	! _readLocked "$lock_closing" && _createLocked "$lock_closing"
	
	shift
	
	"$@"
	
	if [[ "$?" == "0" ]]
	then
		rm -f "$lock_open" || return 1
		
		if [[ "$specialLock" != "" ]] && [[ -e "$specialLock" ]]
		then
			rm -f "$specialLock" || return 1
		fi
		
		rm -f "$lock_closing"
		rm -f "$scriptLocal"/WARNING
		return 0
	fi
	
	return 1
}

_close() {
	local returnStatus
	
	_close_sequence "$@"
	returnStatus="$?"
	
	export specialLock
	specialLock=""
	export specialLock
	
	return "$returnStatus"
}

#"$1" == variable name to preserve
#shift
#"$1" == variable data to preserve
#shift
#"$@" == function to prepare other variables
_preserveVar() {
	local varNameToPreserve
	varNameToPreserve="$1"
	shift
	
	local varDataToPreserve
	varDataToPreserve="$1"
	shift
	
	"$@"
	
	[[ "$varNameToPreserve" == "" ]] && return
	[[ "$varDataToPreserve" == "" ]] && return
	
	export "$varNameToPreserve"="$varDataToPreserve"
	
	return
}


#####Installation


_vector() {
	_tryExec "_vector_virtUser"
}

#Verifies the timeout and sleep commands work properly, with subsecond specifications.
_timetest() {
	
	iterations=0
	while [[ "$iterations" -lt 10 ]]
	do
		dateA=$(date +%s)
		
		sleep 0.1
		sleep 0.1
		sleep 0.1
		sleep 0.1
		sleep 0.1
		sleep 0.1
		
		_timeout 0.1 sleep 10
		_timeout 0.1 sleep 10
		_timeout 0.1 sleep 10
		_timeout 0.1 sleep 10
		_timeout 0.1 sleep 10
		_timeout 0.1 sleep 10
		
		dateB=$(date +%s)
		
		dateDelta=$(bc <<< "$dateB - $dateA")
		
		if [[ "$dateDelta" -lt "1" ]]
		then
			_messageFAIL
			_stop 1
		fi
		
		if [[ "$dateDelta" -lt "5" ]]
		then
			_messagePASS
			return 0
		fi
		
		let iterations="$iterations + 1"
	done
	_messageFAIL
	_stop 1
}

_testarglength() {
	local testArgLength
	
	! testArgLength=$(getconf ARG_MAX) && _messageFAIL && _stop 1
	
	
	# Typical UNIX.
	if [[ "$testArgLength" -lt 131071 ]]
	then
		# Typical Cygwin. Marginal result at best.
		[[ "$testArgLength" -ge 32000 ]] && uname -a | grep -i 'cygwin' > /dev/null 2>&1 && return 0
		
		_messageFAIL && _stop 1
	fi
	
	_messagePASS
}

#_test_prog() {
#	true
#}

_test() {
	_messageNormal "Sanity..."
	
	! "$scriptAbsoluteLocation" _true && _messageFAIL && return 1
	"$scriptAbsoluteLocation" _false && _messageFAIL && return 1
	
	local santiySessionID_length
	santiySessionID_length=$(echo -n "$sessionid" | wc -c | tr -dc '0-9')
	
	[[ "$santiySessionID_length" -lt "18" ]] && _messageFAIL && return 1
	[[ "$uidLengthPrefix" != "" ]] && [[ "$santiySessionID_length" -lt "$uidLengthPrefix" ]] && _messageFAIL && return 1
	
	[[ -e "$safeTmp" ]] && _messageFAIL && return 1
	
	_start
	
	[[ ! -e "$safeTmp" ]] && _messageFAIL && return 1
	
	local currentTestUID=$(_uid 245)
	mkdir -p "$safeTmp"/"$currentTestUID"
	echo > "$safeTmp"/"$currentTestUID"/"$currentTestUID"
	
	[[ ! -e "$safeTmp"/"$currentTestUID"/"$currentTestUID" ]] && _messageFAIL && return 1
	
	rm -f "$safeTmp"/"$currentTestUID"/"$currentTestUID"
	rmdir "$safeTmp"/"$currentTestUID"
	
	[[ -e "$safeTmp"/"$currentTestUID" ]] && _messageFAIL && return 1
	
	echo 'true' > "$safeTmp"/shouldNotOverwrite
	mv "$safeTmp"/doesNotExist "$safeTmp"/shouldNotOverwrite > /dev/null 2>&1 && _messageFAIL && return 1
	[[ $(cat "$safeTmp"/shouldNotOverwrite) != "true" ]] && _messageFAIL && return 1
	rm -f "$safeTmp"/shouldNotOverwrite > /dev/null 2>&1
	
	
	_getDep flock
	
	( flock 200; echo > "$safeTmp"/ready ; sleep 3 ) 200>"$safeTmp"/flock &
	sleep 1
	if ( flock 200; ! [[ -e "$safeTmp"/ready ]] ) 200>"$safeTmp"/flock
	then
		_messageFAIL
		_stop 1
	fi
	rm -f "$safeTmp"/flock > /dev/null 2>&1
	rm -f "$safeTmp"/ready > /dev/null 2>&1
	
	ln -s /dev/null "$safeTmp"/working
	ln -s /dev/null/broken "$safeTmp"/broken
	if ! [[ -h "$safeTmp"/broken ]] || ! [[ -h "$safeTmp"/working ]] || [[ -e "$safeTmp"/broken ]] || ! [[ -e "$safeTmp"/working ]]
	then
		_messageFAIL
		_stop 1
	fi
	rm -f "$safeTmp"/working
	rm -f "$safeTmp"/broken
	
	_messagePASS
	
	
	_messageNormal "Permissions..."
	
	! _test_permissions_ubiquitous && _messageFAIL
	
	_messagePASS
	
	#Environment generated by ubiquitous bash is typically 10000 characters.
	echo -n -e '\E[1;32;46m Argument length...	\E[0m'
	
	_testarglength
	
	_messageNormal "Absolute pathfinding..."
	#_tryExec "_test_getAbsoluteLocation"
	_messagePASS
	
	echo -n -e '\E[1;32;46m Timing...		\E[0m'
	_timetest
	
	_messageNormal "Dependency checking..."
	
	## Check dependencies
	
	#"generic/filesystem"/permissions.sh
	_checkDep stat
	
	_getDep wget
	_getDep grep
	_getDep fgrep
	_getDep sed
	_getDep awk
	_getDep cut
	_getDep head
	_getDep tail
	
	_getDep wc
	
	
	! _compat_realpath && ! _wantGetDep realpath && echo 'realpath missing'
	_getDep readlink
	_getDep dirname
	_getDep basename
	
	_getDep sleep
	_getDep wait
	_getDep kill
	_getDep jobs
	_getDep ps
	_getDep exit
	
	_getDep env
	_getDep bash
	_getDep echo
	_getDep cat
	_getDep tac
	_getDep type
	_getDep mkdir
	_getDep trap
	_getDep return
	_getDep set
	
	_getDep printf
	
	_getDep dd
	
	_getDep rm
	
	_getDep find
	_getDep ln
	_getDep ls
	
	_getDep id
	
	_getDep test
	
	_getDep true
	_getDep false
	
	_getDep diff
	
	_test_readlink_f
	
	_tryExec "_test_package"
	
	_tryExec "_test_daemon"
	
	_tryExec "_testFindPort"
	_tryExec "_test_waitport"
	
	_tryExec "_testProxySSH"
	
	_tryExec "_testAutoSSH"
	
	_tryExec "_testTor"
	
	_tryExec "_testProxyRouter"
	
	#_tryExec "_test_build"
	
	_tryExec "_testGosu"
	
	_tryExec "_testMountChecks"
	_tryExec "_testBindMountManager"
	_tryExec "_testDistro"
	_tryExec "_test_fetchDebian"
	
	_tryExec "_test_image"
	_tryExec "_test_transferimage"
	
	_tryExec "_testCreatePartition"
	_tryExec "_testCreateFS"
	
	_tryExec "_test_mkboot"
	
	_tryExec "_test_abstractfs"
	_tryExec "_test_fakehome"
	_tryExec "_testChRoot"
	_tryExec "_testQEMU"
	_tryExec "_testQEMU_x64-x64"
	_tryExec "_testQEMU_x64-raspi"
	_tryExec "_testQEMU_raspi-raspi"
	_tryExec "_testVBox"
	
	_tryExec "_test_vboxconvert"
	
	_tryExec "_test_dosbox"
	
	_tryExec "_testWINE"
	
	_tryExec "_test_docker"
	
	_tryExec "_test_docker_mkimage"
	
	_tryExec "_testVirtBootdisc"
	
	_tryExec "_testExtra"
	
	_tryExec "_testGit"
	
	_tryExec "_test_bup"
	
	_tryExec "_testX11"
	
	_tryExec "_test_virtLocal_X11"
	
	_tryExec "_test_gparted"
	
	_tryExec "_test_synergy"
	
	_tryExec "_test_devatom"
	_tryExec "_test_devemacs"
	_tryExec "_test_deveclipse"
	
	_tryExec "_test_ethereum"
	_tryExec "_test_ethereum_parity"
	
	_tryExec "_test_metaengine"
	
	_tryExec "_test_channel"
	
	[[ -e /dev/urandom ]] || echo /dev/urandom missing _stop
	
	_messagePASS
	
	_messageNormal 'Vector...'
	_vector
	_messagePASS
	
	_tryExec "_test_prog"
	
	_stop
}

#_testBuilt_prog() {
#	true
#}

_testBuilt() {
	_start
	
	_messageProcess "Binary checking"
	
	_tryExec "_testBuiltIdle"
	_tryExec "_testBuiltGosu"	#Note, requires sudo, not necessary for docker .
	
	_tryExec "_test_ethereum_built"
	_tryExec "_test_ethereum_parity_built"
	
	_tryExec "_testBuiltChRoot"
	_tryExec "_testBuiltQEMU"
	
	_tryExec "_testBuiltExtra"
	
	_tryExec "_testBuilt_prog"
	
	_messagePASS
	
	_stop
}

#Creates symlink in "$HOME"/bin, to the executable at "$1", named according to its residing directory and file name.
_setupCommand() {
	mkdir -p "$HOME"/bin
	! [[ -e "$HOME"/bin ]] && return 1
	
	local clientScriptLocation
	clientScriptLocation=$(_getAbsoluteLocation "$1")
	
	local clientScriptFolder
	clientScriptFolder=$(_getAbsoluteFolder "$1")
	
	local commandName
	commandName=$(basename "$1")
	
	local clientName
	clientName=$(basename "$clientScriptFolder")
	
	_relink_relative "$clientScriptLocation" "$HOME"/bin/"$commandName""-""$clientName"
	
	
}

_setupCommand_meta() {
	mkdir -p "$HOME"/bin
	! [[ -e "$HOME"/bin ]] && return 1
	
	local clientScriptLocation
	clientScriptLocation=$(_getAbsoluteLocation "$1")
	
	local clientScriptFolder
	clientScriptFolder=$(_getAbsoluteFolder "$1")
	
	local clientScriptFolderResidence
	clientScriptFolderResidence=$(_getAbsoluteFolder "$clientScriptFolder")
	
	local commandName
	commandName=$(basename "$1")
	
	local clientName
	clientName=$(basename "$clientScriptFolderResidence")
	
	_relink_relative "$clientScriptLocation" "$HOME"/bin/"$commandName""-""$clientName"
	
	
}

_find_setupCommands() {
	find -L "$scriptAbsoluteFolder" -not \( -path \*_arc\* -prune \) "$@"
}

#Consider placing files like ' _vnc-machine-"$netName" ' in an "_index" folder for automatic installation.
_setupCommands() {
	#_find_setupCommands -name '_command' -exec "$scriptAbsoluteLocation" _setupCommand '{}' \;
	
	_tryExec "_setup_ssh_commands"
	_tryExec "_setup_command_commands"
}

#_setup_pre() {
#	true
#}

#_setup_prog() {
#	true
#}

_setup() {
	_start
	
	"$scriptAbsoluteLocation" _test || _stop 1
	
	#Only attempt build procedures if their functions have been defined from "build.sh" . Pure shell script projects (eg. CoreAutoSSH), and projects using only statically compiled binaries, need NOT include such procedures.
	local buildSupported
	type _build > /dev/null 2>&1 && type _test_build > /dev/null 2>&1 && buildSupported="true"
	
	[[ "$buildSupported" == "true" ]] && ! "$scriptAbsoluteLocation" _test_build && _stop 1
	
	if ! "$scriptAbsoluteLocation" _testBuilt
	then
		! [[ "$buildSupported" == "true" ]] && _stop 1
		[[ "$buildSupported" == "true" ]] && ! "$scriptAbsoluteLocation" _build "$@" && _stop 1
		! "$scriptAbsoluteLocation" _testBuilt && _stop 1
	fi
	
	_setupCommands
	
	_tryExec "_setup_pre"
	
	_tryExec "_setup_ssh"
	
	_tryExec "_setup_prog"
	
	_stop
}

# DANGER: Especially not expected to modify system program behavior (eg. not to modify "$HOME"/.ssh ).
# WARNING: Strictly expected to not modify anyting outside the script directory.
_setup_local() {
	export ub_setup_local='true'
	
	_setup
}

_test_package() {
	_getDep tar
	_getDep gzip
}

_package_prog() {
	true
}

# WARNING Must define "_package_license" function in ops to include license files in package!
_package() {
	_start
	mkdir -p "$safeTmp"/package
	
	_package_prog
	
	_tryExec "_package_license"
	
	_tryExec "_package_cautossh"
	
	#scriptBasename=$(basename "$scriptAbsoluteLocation")
	#cp -a "$scriptAbsoluteLocation" "$safeTmp"/package/"$scriptBasename"
	cp -a "$scriptAbsoluteLocation" "$safeTmp"/package/
	cp -a "$scriptAbsoluteFolder"/ops "$safeTmp"/package/
	cp -a "$scriptAbsoluteFolder"/ops.sh "$safeTmp"/package/
	
	#cp -a "$scriptAbsoluteFolder"/_bin "$safeTmp"
	#cp -a "$scriptAbsoluteFolder"/_config "$safeTmp"
	#cp -a "$scriptAbsoluteFolder"/_prog "$safeTmp"
	
	#cp -a "$scriptAbsoluteFolder"/_local "$safeTmp"/package/
	
	cp -a "$scriptAbsoluteFolder"/README.md "$safeTmp"/package/
	cp -a "$scriptAbsoluteFolder"/USAGE.html "$safeTmp"/package/
	
	cd "$safeTmp"/package/
	tar -czvf "$scriptAbsoluteFolder"/package.tar.gz .
	
	cd "$outerPWD"
	_stop
}

_test_prog() {
	_getDep which
	
	_getDep firefox
	_getDep chromium
	
	_noFireJail 'firefox' && _stop 1
	_noFireJail 'chromium' && _stop 1
}

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
	local currentArgs
	
	
	local currentArg
	local currentResult
	local currentProcessedArgs=()
	
	local currentFlag_includesProfileDirective
	
	for currentArg in "$@"
	do
		if [[ "$currentArg" == '-P' ]] || [[ "$currentArg" == '--profile' ]] || [[ "$currentArg" == '--ProfileManager' ]]
		then
			currentFlag_includesProfileDirective='true'
			_messagePlain_probe 'detected: profile directive'
		fi
	done
	if [[ "$currentFlag_includesProfileDirective" != 'true' ]]
	then
		currentProcessedArgs+=( '-P' )
		currentProcessedArgs+=( 'default' )
	fi
	#http://stackoverflow.com/questions/15420790/create-array-in-loop-from-number-of-arguments
	for currentArg in "$@"
	do
		currentResult="$currentArg"
		currentProcessedArgs+=("$currentResult")
	done
	
	
	
	
	if [[ -e "$scriptAbsoluteFolder"/_local/setups/firefox/firefox/firefox ]]
	then
		_messageNormal 'Launch: _local/firefox'
		_messagePlain_probe "$scriptAbsoluteFolder"/_local/setups/firefox/firefox/firefox "${currentProcessedArgs[@]}"
		"$scriptAbsoluteFolder"/_local/setups/firefox/firefox/firefox "${currentProcessedArgs[@]}"
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
			_messagePlain_probe firefox "${currentProcessedArgs[@]}"
			firefox "${currentProcessedArgs[@]}"
			return 0
		fi
	fi
	
	#if which 'firefox_quantum'
	#if _wantDep 'firefox_quantum'
	if false
	then
		_messageNormal 'Launch: firefox_quantum'
		_messagePlain_probe firefox_quantum "${currentProcessedArgs[@]}"
		firefox_quantum "${currentProcessedArgs[@]}"
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
	
	"$scriptAbsoluteLocation" _editFakeHome "$scriptAbsoluteLocation" "_firefox_command" -P default "$@"
}

# ATTENTION
# Override with "ops", point to "_firefox_editHome_multitasking", to allow "remote" instances of firefox for the user/machine global profile.
_firefox_editHome() {
	# TODO: Ideally, there should be an automatic check to determine whether a compatible firefox instance already existed, allowing "-no-remote" to be dropped.
	"$scriptAbsoluteLocation" _editFakeHome "$scriptAbsoluteLocation" "_firefox_command" -P default -no-remote "$@"
}

_firefox_userHome() {
	#Always use "-no-remote".
	"$scriptAbsoluteLocation" _userFakeHome "$scriptAbsoluteLocation" "_firefox_command" -P default -no-remote "$@"
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


_dolphin_userHome() {
	_messageNormal 'Launch: dolphin'
	_userFakeHome dolphin "$@"
}

_dolphin_editHome() {
	_messageNormal 'Launch: dolphin'
	_editFakeHome dolphin "$@"
}

_dolphin() {
	_dolphin_userHome "$@"
}

_webClient() {
	_launch "$@"
}

_fsClient() {
	_dolphin_userHome "$@"
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
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_fsClient
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_dolphin
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_dolphin_editHome
}

#####Program

#Typically launches an application - ie. through virtualized container.
_launch() {
	_firefox "$@"
}

#Typically gathers command/variable scripts from other (ie. yaml) file types (ie. AppImage recipes).
_collect() {
	false
}

#Typical program entry point, absent any instancing support.
_enter() {
	_launch "$@"
}

#Typical program entry point.
_main() {
	_start
	
	_collect
	
	_enter "$@"
	
	_stop
}

#####Network Specific Variables
#Statically embedded into monolithic ubiquitous_bash.sh/cautossh script by compile .

# WARNING Must use unique netName!
export netName=default
export gatewayName=gw-"$netName"
export LOCALSSHPORT=22

#Network Defaults
export AUTOSSH_FIRST_POLL=45
export AUTOSSH_POLL=45
#export AUTOSSH_GATETIME=0
export AUTOSSH_GATETIME=15

#export AUTOSSH_PORT=0

#export AUTOSSH_DEBUG=1
#export AUTOSSH_LOGLEVEL=7

#Example ONLY. Modify port asignments.
_get_reversePorts() {
	export matchingReversePorts
	matchingReversePorts=()
	export matchingEMBEDDED=false
	
	local matched
	
	local testHostname
	testHostname="$1"
	[[ "$testHostname" == "" ]] && testHostname=$(hostname -s)
	
	if [[ "$testHostname" == "alpha" ]]
	then
		matchingReversePorts+=( "20000" )
		
		matched=true
	fi
	
	if [[ "$testHostname" == "beta" ]]
	then
		matchingReversePorts+=( "20001" )
		export matchingEMBEDDED=true
		
		matched=true
	fi
	
	if ! [[ "$matched" == "true" ]] || [[ "$testHostname" == '*' ]]
	then
		matchingReversePorts+=( "20009" )
		matchingReversePorts+=( "20008" )
	fi
	
	export matchingReversePorts
}

_get_reversePorts
export reversePorts=("${matchingReversePorts[@]}")
export EMBEDDED="$matchingEMBEDDED"

export keepKeys_SSH=true


#####Overrides

[[ "$isDaemon" == "true" ]] && echo "$$" | _prependDaemonPID

#May allow traps to work properly in simple scripts which do not include more comprehensive "_stop" or "_stop_emergency" implementations.
if ! type _stop > /dev/null 2>&1
then
	# ATTENTION: Consider carefully, override with "ops".
	# WARNING: Unfortunate, but apparently necessary, workaround for script termintaing while "sleep" or similar run under background.
	_stop_stty_echo() {
		#true
		
		stty echo --file=/dev/tty > /dev/null 2>&1
		
		#[[ "$ubFoundEchoStatus" != "" ]] && stty --file=/dev/tty "$ubFoundEchoStatus" 2> /dev/null
	}
	_stop() {
		_stop_stty_echo
		
		if [[ "$1" != "" ]]
		then
			exit "$1"
		else
			exit 0
		fi
	}
fi
if ! type _stop_emergency > /dev/null 2>&1
then
	_stop_emergency() {
		_stop "$1"
	}
fi

#Traps, if script is not imported into existing shell, or bypass requested.
# WARNING Exact behavior of this system is critical to some use cases.
if [[ "$ub_import" != "true" ]] || [[ "$ub_import_param" == "--bypass" ]]
then
	trap 'excode=$?; _stop $excode; trap - EXIT; echo $excode' EXIT HUP QUIT PIPE 	# reset
	trap 'excode=$?; trap "" EXIT; _stop $excode; echo $excode' EXIT HUP QUIT PIPE 	# ignore
	
	trap 'excode=$?; _stop_emergency $excode; trap - EXIT; echo $excode' INT TERM	# reset
	trap 'excode=$?; trap "" EXIT; _stop_emergency $excode; echo $excode' INT TERM	# ignore
fi

#Override functions with external definitions from a separate file if available.
#if [[ -e "./ops" ]]
#then
#	. ./ops
#fi

#Override functions with external definitions from a separate file if available.
# CAUTION: Recommend only "ops" or "ops.sh" . Using both can cause confusion.
# ATTENTION: Recommend "ops.sh" only when unusually long. Specifically intended for "CoreAutoSSH" .
if [[ -e "$objectDir"/ops ]]
then
	. "$objectDir"/ops
fi
if [[ -e "$objectDir"/ops.sh ]]
then
	. "$objectDir"/ops.sh
fi
if [[ -e "$scriptLocal"/ops ]]
then
	. "$scriptLocal"/ops
fi
if [[ -e "$scriptLocal"/ops.sh ]]
then
	. "$scriptLocal"/ops.sh
fi
if [[ -e "$scriptLocal"/ssh/ops ]]
then
	. "$scriptLocal"/ssh/ops
fi
if [[ -e "$scriptLocal"/ssh/ops.sh ]]
then
	. "$scriptLocal"/ssh/ops.sh
fi

#WILL BE OVERWRITTEN FREQUENTLY.
#Intended for automatically generated shell code identifying usable resources, such as unused network ports. Do NOT use for serialization of internal variables (use $varStore for that).
if [[ -e "$objectDir"/opsauto ]]
then
	. "$objectDir"/opsauto
fi
if [[ -e "$scriptLocal"/opsauto ]]
then
	. "$scriptLocal"/opsauto
fi
if [[ -e "$scriptLocal"/ssh/opsauto ]]
then
	. "$scriptLocal"/ssh/opsauto
fi

#Wrapper function to launch arbitrary commands within the ubiquitous_bash environment, including its PATH with scriptBin.
_bin() {
	"$@"
}

#Launch internal functions as commands, and other commands, as root.
_sudo() {
	sudo -n "$scriptAbsoluteLocation" _bin "$@"
}

_true() {
	true
}
_false() {
	false
}
_echo() {
	echo "$@"
}

_diag() {
	echo "$sessionid"
}

#Stop if script is imported, parameter not specified, and command not given.
if [[ "$ub_import" == "true" ]] && [[ "$ub_import_param" == "" ]] && [[ "$1" != '_'* ]]
then
	_messagePlain_warn 'import: missing: parameter, missing: command' | _user_log-ub
	ub_import=""
	return 1 > /dev/null 2>&1
	exit 1
fi

#Set "ubOnlyMain" in "ops" overrides as necessary.
if [[ "$ubOnlyMain" != "true" ]]
then
	
	#Launch command named by link name.
	if scriptLinkCommand=$(_getScriptLinkName)
	then
		if [[ "$scriptLinkCommand" == '_'* ]]
		then
			"$scriptLinkCommand" "$@"
			internalFunctionExitStatus="$?"
			
			#Exit if not imported into existing shell, or bypass requested, else fall through to subsequent return.
			if [[ "$ub_import" != "true" ]] || [[ "$ub_import_param" == "--bypass" ]]
			then
				#export noEmergency=true
				exit "$internalFunctionExitStatus"
			fi
			ub_import=""
			return "$internalFunctionExitStatus" > /dev/null 2>&1
			exit "$internalFunctionExitStatus"
		fi
	fi
	
	# NOTICE Launch internal functions as commands.
	#if [[ "$1" != "" ]] && [[ "$1" != "-"* ]] && [[ ! -e "$1" ]]
	#if [[ "$1" == '_'* ]] || [[ "$1" == "true" ]] || [[ "$1" == "false" ]]
	if [[ "$1" == '_'* ]]
	then
		"$@"
		internalFunctionExitStatus="$?"
		
		#Exit if not imported into existing shell, or bypass requested, else fall through to subsequent return.
		if [[ "$ub_import" != "true" ]] || [[ "$ub_import_param" == "--bypass" ]]
		then
			#export noEmergency=true
			exit "$internalFunctionExitStatus"
		fi
		ub_import=""
		return "$internalFunctionExitStatus" > /dev/null 2>&1
		exit "$internalFunctionExitStatus"
		#_stop "$?"
	fi
fi

[[ "$ubOnlyMain" == "true" ]] && export ubOnlyMain="false"

#Do not continue script execution through program code if critical global variables are not sane.
[[ ! -e "$scriptAbsoluteLocation" ]] && exit 1
[[ ! -e "$scriptAbsoluteFolder" ]] && exit 1
_failExec || exit 1

#Return if script is under import mode, and bypass is not requested.
if [[ "$ub_import" == "true" ]] && [[ "$ub_import_param" != "--bypass" ]]
then
	return 0 > /dev/null 2>&1
	exit 0
fi

#####Entry

#"$scriptAbsoluteLocation" _setup


_main "$@"


