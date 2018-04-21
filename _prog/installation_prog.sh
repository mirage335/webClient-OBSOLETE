_test_prog() {
	_getDep which
	
	_getDep firefox
	_getDep chromium
	
	_noFireJail 'firefox' && _stop 1
	_noFireJail 'chromium' && _stop 1
}
