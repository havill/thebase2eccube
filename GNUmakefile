GCC = gcc -Wall
binaries = thebase2eccube-pre

.PHONY: all
all: $(binaries)

thebase2eccube-pre: thebase2eccube-pre.c
	@$(GCC) $^ -o $@

.PHONY: clean
clean:
	@rm -f $(binaries)