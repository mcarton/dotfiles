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
vimperator: $(HOME)/.config/vimperator/vimperatorrc

$(HOME)/.config/vimperator/vimperatorrc:
	$(LN) $(PWD)/vimperator/vimperatorrc $@

### xbindkeys
xbindkeys: $(HOME)/.xbindkeysrc

$(HOME)/.xbindkeysrc:
	$(LN) $(PWD)/xbindkeys/xbindkeysrc $@

### xmodmap
xmodmap: $(HOME)/.Xmodmap

$(HOME)/.Xmodmap:
	$(LN) $(PWD)/xmodmap/Xmodmap $@

### zsh:
zsh: $(HOME)/.zshenv $(HOME)/.config/zsh/.zshrc

$(HOME)/.zshenv:
	$(LN) $(PWD)/zsh/zshenv $@

$(HOME)/.config/zsh/.zshrc:
	$(LN) $(PWD)/zsh/zshrc $@

