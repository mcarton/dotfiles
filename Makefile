PWD = $(shell pwd)
LN = ln -s

.PHONY: install
install: \
    vim

### vim:
vim: $(HOME)/.vim/vimrc

$(HOME)/.vim/vimrc:
	$(LN) $(PWD)/vim/vimrc $@
