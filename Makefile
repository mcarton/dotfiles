PWD = $(shell pwd)
LN = ln -s

.PHONY: install
install: \
    vim \
    vimperator \
    zsh

### vim:
vim: $(HOME)/.vim/vimrc

$(HOME)/.vim/vimrc:
	$(LN) $(PWD)/vim/vimrc $@

### vimperator:
vimperator: $(HOME)/.config/vimperator/vimperatorrc

$(HOME)/.config/vimperator/vimperatorrc:
	$(LN) $(PWD)/vimperator/vimperatorrc $@

### zsh:
zsh: $(HOME)/.zshenv $(HOME)/.config/zsh/.zshrc:

$(HOME)/.zshenv:
	$(LN) $(PWD)/zsh/zshenv $@

$(HOME)/.config/zsh/.zshrc:
	$(LN) $(PWD)/zsh/zshrc $@

