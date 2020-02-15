Copyright (C) 2018 mirage335

See the end of the file for license conditions.
See license.txt for webClient license conditions.

Web browser containment framework.

Automatically forces FireFox and Chromium to use a "HOME" folder neighboring the shell script itself, launching a virtual machine if necessary.

# Usage
./_firefox

./_firefox_editHome_multitasking

./_chromium

Remove "_local/h" ".gitignore" exlcusion to track web browser profile under git repository.

FireFox will not report "profile in use" errors when run under non-persistent/user modes, which use temporary directories. However, FireFox still cannot be run multiple times under persistent/edit modes if any other FireFox profile is active on the desktop.

FireFox ESR is required to support TiddlyFox extension for editing TiddlyWiki files.

Infrequently edited FireFox profiles will cause a "Refresh Firefox" prompt. Add boolean 'browser.disableResetPrompt=true' under 'about:config' to disable.

# Prerequsites

## Firefox Binaries

Download and install firefox binary archives, and extract to '_local/setups' directories.

* _local/setups/firefox/firefox-0.0.0.tar.bz2
* _local/setups/firefox/firefox/firefox

* _local/setups/firefox-esr/firefox-0.0.0esr.tar.bz2
* _local/setups/firefox-esr/firefox/firefox

# Design
Ubiquitous Bash FakeHome virtualization redirects the apparent home directory as seen by FireFox and Chromium.

If appropriate native binaries are not available, the "nixexevm" virtual machine will be launched. Either a "_local/vm.img" file, or a "$HOME"/core/nixexevm/ubiquitous_bash.sh script, containing a Debian operating system.

All functionality is defined by "_prog/core.sh".

All functionality is demonstrated by this worst-case internal command.
_userQemu "$scriptAbsoluteLocation" _userFakeHome "$scriptAbsoluteLocation" "_firefox_command" -no-remote "$@"

"_userQemu" - Directive to launch a Virtual Machine, with directory sharing and file translated parameters.
"$scriptAbsoluteLocation" - Absolute path of the "ubiquitous_bash.sh" script itself.
"_userFakeHome" - Directive to launch with "$HOME" variable pointed at a temporary directory named "h_"<random> .
"_firefox_command" - FireFox binary found on the system.
"-no-remote" - Parameter for FireFox itself. Given the "$HOME"/.mozilla directory is temporary, there is no need for process sharing.

# Future Work
* MSW/Cygwin host support.


__Copyright__
This file is part of webClient.

webClient is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

webClient is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with webClient.  If not, see <http://www.gnu.org/licenses/>.
