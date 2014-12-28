PWD = $(shell pwd)
LN = ln -s

.PHONY: install
install: \
    keyboard \
    vimperator

### keyboard:
keyboard: \
    /usr/share/X11/xorg.conf.d/10-keyboard-layout.conf \
    /usr/share/X11/xkb/symbols/fr_perso

/usr/share/X11/xorg.conf.d/10-keyboard-layout.conf:
	$(LN) $(PWD)/keyboard/10-keyboard-layout.conf $@

/usr/share/X11/xkb/symbols/fr_perso:
	$(LN) $(PWD)/keyboard/fr_perso $@

### vimperator:
vimperator: $(HOME)/.config/vimperator/interwiki.py

/usr/bin/interwiki: vimperator/interwiki.py
	cp $(PWD)/vimperator/interwiki.py $@

