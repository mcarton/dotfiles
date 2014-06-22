PWD = $(shell pwd)
LN = ln -s

.PHONY: install
install: \
    awesome \
    vim \
    vimperator \
    zsh

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

### vim:
vim: $(HOME)/.vim/vimrc

$(HOME)/.vim/vimrc:
	$(LN) $(PWD)/vim/vimrc $@

### vimperator:
vimperator: $(HOME)/.config/vimperator/vimperatorrc

$(HOME)/.config/vimperator/vimperatorrc:
	$(LN) $(PWD)/vimperator/vimperatorrc $@

### xbindkeys
xbindkeys: $(HOME)/.xbindkeysrc

$(HOME)/.xbindkeysrc:
	$(LN) $(PWD)/xbindkeys/xbindkeysrc $@

### zsh:
zsh: $(HOME)/.zshenv $(HOME)/.config/zsh/.zshrc

$(HOME)/.zshenv:
	$(LN) $(PWD)/zsh/zshenv $@

$(HOME)/.config/zsh/.zshrc:
	$(LN) $(PWD)/zsh/zshrc $@

