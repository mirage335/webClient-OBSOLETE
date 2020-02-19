_test_prog() {
	_getDep which
	
	_getDep firefox
	_wantGetDep chromium
	
	_getDep dolphin
	
	_noFireJail 'firefox' && _stop 1
	_noFireJail 'chromium' && _stop 1
}
