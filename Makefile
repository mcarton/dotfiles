PWD = $(shell pwd)
LN = ln -s

.PHONY: install
install: \
    vim \
    vimperator

### vim:
vim: $(HOME)/.vim/vimrc

$(HOME)/.vim/vimrc:
	$(LN) $(PWD)/vim/vimrc $@

### vimperator:
vimperator: $(HOME)/.config/vimperator/vimperatorrc

$(HOME)/.config/vimperator/vimperatorrc:
	$(LN) $(PWD)/vimperator/vimperatorrc $@

