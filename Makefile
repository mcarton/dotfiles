PWD = $(shell pwd)
LN = ln -s

.PHONY: install
install: \
    awesome \
    vim \
    vimperator \
    zsh

### 10-keyboard-layout.conf:
keyboard: \
    /usr/share/X11/xorg.conf.d/10-keyboard-layout.conf \
    /usr/share/X11/xkb/symbols/fr_perso

/usr/share/X11/xorg.conf.d/10-keyboard-layout.conf:
	$(LN) $(PWD)/keyboard/10-keyboard-layout.conf $@

/usr/share/X11/xkb/symbols/fr_perso:
	$(LN) $(PWD)/keyboard/fr_perso $@

### awesome:
awesome: \
    $(HOME)/.config/awesome/calendar2.lua \
    $(HOME)/.config/awesome/fraxbat.lua \
    $(HOME)/.config/awesome/rc.lua

$(HOME)/.config/awesome/calendar2.lua:
	$(LN) $(PWD)/awesome/calendar2.lua $@

$(HOME)/.config/awesome/fraxbat.lua:
	$(LN) $(PWD)/awesome/fraxbat.lua $@

$(HOME)/.config/awesome/rc.lua:
	$(LN) $(PWD)/awesome/rc.lua $@

### cmus:
cmus: \
    $(HOME)/.config/cmus \
    $(HOME)/.config/cmus/autosave \
    $(HOME)/.config/cmus/rc

$(HOME)/.config/cmus:
	mkdir -p $(HOME)/.config/cmus

$(HOME)/.config/cmus/autosave:
	$(LN) $(PWD)/cmus/autosave $@

$(HOME)/.config/cmus/rc:
	$(LN) $(PWD)/cmus/rc $@

### git:
git: \
    $(HOME)/.config/git \
    $(HOME)/.config/git/attributes \
    $(HOME)/.config/git/config \
    $(HOME)/.config/git/ignore \
    $(HOME)/.config/git/img-diff

$(HOME)/.config/git:
	mkdir -p $(HOME)/.config/git

$(HOME)/.config/git/attributes:
	$(LN) $(PWD)/git/attributes $@

$(HOME)/.config/git/config:
	$(LN) $(PWD)/git/config $@

$(HOME)/.config/git/ignore:
	$(LN) $(PWD)/git/ignore $@

$(HOME)/.config/git/img-diff:
	$(LN) $(PWD)/git/img-diff $@

### vim:
vim: $(HOME)/.vim/vimrc

$(HOME)/.vim/vimrc:
	$(LN) $(PWD)/vim/vimrc $@

### vimperator:
vimperator: \
    $(HOME)/.config/vimperator/vimperatorrc \
    $(HOME)/.config/vimperator/interwiki.py

$(HOME)/.config/vimperator/vimperatorrc:
	$(LN) $(PWD)/vimperator/vimperatorrc $@

/usr/bin/interwiki: vimperator/interwiki.py
	cp $(PWD)/vimperator/interwiki.py $@

### xbindkeys
xbindkeys: $(HOME)/.xbindkeysrc

$(HOME)/.xbindkeysrc:
	$(LN) $(PWD)/xbindkeys/xbindkeysrc $@

### xinitrc
xinitrc: $(HOME)/.xinitrc

$(HOME)/.xinitrc:
	$(LN) $(PWD)/xinit/xinitrc $@

### xmodmap
xmodmap: $(HOME)/.config/Xmodmap

$(HOME)/.config/Xmodmap:
	$(LN) $(PWD)/xmodmap/Xmodmap $@

### zsh:
zsh: $(HOME)/.zshenv $(HOME)/.config/zsh/.zshrc

$(HOME)/.zshenv:
	$(LN) $(PWD)/zsh/zshenv $@

$(HOME)/.config/zsh/.zshrc:
	$(LN) $(PWD)/zsh/zshrc $@

