PWD = $(shell pwd)
LN = ln -s

.PHONY: FORCE
install: submodules cli gui

submodules: FORCE
	git submodule update --init --recursive

cli: submodules FORCE
	${PWD}/dotbot/bin/dotbot -d "${PWD}" -c cli.conf.yaml

gui: submodules FORCE
	${PWD}/dotbot/bin/dotbot -d "${PWD}" -c gui.conf.yaml

### keyboard:
keyboard: FORCE \
    /usr/share/X11/xorg.conf.d/10-keyboard-layout.conf \
    /usr/share/X11/xkb/symbols/fr_perso

/usr/share/X11/xorg.conf.d/10-keyboard-layout.conf: FORCE
	$(LN) $(PWD)/keyboard/10-keyboard-layout.conf $@

/usr/share/X11/xkb/symbols/fr_perso: FORCE
	$(LN) $(PWD)/keyboard/fr_perso $@

### vim:
vim_spell:
	mkdir -p ~/.vim/spell
	wget http://ftp.vim.org/vim/runtime/spell/fr.utf-8.spl -O ~/.vim/spell/fr.utf-8.spl
	wget http://ftp.vim.org/vim/runtime/spell/fr.utf-8.sug -O ~/.vim/spell/fr.utf-8.sug
