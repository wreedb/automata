.PHONY: all default clean clean-toml clean-automata clean-docs install uninstall
.SECONDEXPANSION:

VERSION := $(shell cat .version)
DATE    := $(shell date +'%F')
MONTH   := $(shell date +'%B')
YEAR    := $(shell date +'%Y')

PREFIX ?= /usr
DATADIR ?= $(PREFIX)/share
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(DATADIR)/man

BUILDDIR := .build

DMD := ldmd

ifndef RELEASE
	DFLAGS := -fPIC -g
else
	DFLAGS := -fPIC -release -inline -O
endif

ifdef STATIC
	DFLAGS += -static
endif

AR ?= llvm-ar
ARFLAGS := rcS
RANLIB ?= llvm-ranlib

AUTOMATA_SOURCES = package.d util.d daemon.d meta.d config.d
AUTOMATA_SOURCES := $(addprefix source/automata/,$(AUTOMATA_SOURCES))
AUTOMATA_OBJECTS = $(patsubst source/automata/%.d,automata.%.o,$(AUTOMATA_SOURCES))
AUTOMATA_OBJECTS := $(subst /,.,$(AUTOMATA_OBJECTS))
AUTOMATA_OBJECTS := $(addprefix $(BUILDDIR)/,$(AUTOMATA_OBJECTS))
AUTOMATA_LIB := $(BUILDDIR)/libautomata.a


SOURCES  = main.d
SOURCES := $(addprefix source/,$(SOURCES))

OBJECTS  = $(patsubst source/%.d,source.%.o,$(SOURCES))
OBJECTS := $(subst /,.,$(OBJECTS))
OBJECTS := $(addprefix $(BUILDDIR)/,$(OBJECTS))

include aux/toml.mk

all: $(BUILDDIR) deps/toml $(TOML_LIB) $(AUTOMATA_LIB) automata
default: all

docs: doc/automata.1

DFLAGS += -Isource -I$(TOML_DIR)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

deps/toml:
	@echo -e "(\033[35mDEPS\033[m)"
	@misc/deps.sh

source/automata/meta.d: source/automata/meta.d.in
	@sed "s/@VERSION@/$(VERSION)/g" $< > $@

$(TOML_OBJECTS): $(BUILDDIR)/toml.%.o: $(TOML_DIR)/toml/$$(subst .,/,%).d
	@echo -e "(\033[34mDMD\033[m)" $(shell basename $@)
	@$(DMD) $(DFLAGS) -version=Have_toml -of$@ -c $<

$(AUTOMATA_OBJECTS): $(BUILDDIR)/automata.%.o: source/automata/$$(subst .,/,%).d
	@echo -e "(\033[34mDMD\033[m)" $(shell basename $@)
	@$(DMD) $(DFLAGS) -of$@ -c $<

$(TOML_LIB): $(TOML_OBJECTS)
	@echo -e "(\033[33mAR\033[m)" $(shell basename $@)
	@$(AR) $(ARFLAGS) $@ $^
	@$(RANLIB) $@

$(AUTOMATA_LIB): $(AUTOMATA_OBJECTS)
	@echo -e "(\033[33mAR\033[m)" $(shell basename $@)
	@$(AR) $(ARFLAGS) $@ $^
	@$(RANLIB) $@

$(OBJECTS): $(BUILDDIR)/source.%.o: source/$$(subst .,/,%).d
	@echo -e "(\033[34mDMD\033[m)" $(shell basename $@)
	@$(DMD) $(DFLAGS) -of$@ -c $<

automata: $(OBJECTS) $(AUTOMATA_LIB) $(TOML_LIB)
	@echo -e "(\033[32mLINK\033[m)" $(shell basename $@)
	@$(DMD) $(DFLAGS) -of$@ $^

doc/automata.1.rst: doc/automata.1.rst.in
	@echo -e "(\033[35mSUBST\033[m)" $@
	@sed -e "s/@VERSION@/$(VERSION)/g" \
		 -e "s/@DATE@/$(DATE)/g"       \
		 -e "s/@MONTH@/$(MONTH)/g"     \
		 -e "s/@YEAR@/$(YEAR)/g"       \
		$< > $@

doc/automata.1: doc/automata.1.rst
	@echo -e "(\033[35mRST2MAN\033[m)" $@
	@rst2man --no-generator --title=automata $< --output=$@

clean-automata:
	@echo -e "(\033[33mCLEAN\033[m) automata"
	@-rm -f $(AUTOMATA_OBJECTS) $(AUTOMATA_LIB)

clean-toml:
	@echo -e "(\033[33mCLEAN\033[m) toml"
	@-rm -f $(TOML_OBJECTS) $(TOML_LIB)

clean-docs:
	@echo -e "(\033[33mCLEAN\033[m) docs"
	@-rm -f doc/*.rst doc/*.1

clean: clean-automata clean-toml clean-docs
	@echo -e "(\033[33mCLEAN\033[m) all"
	@-rm -f $(OBJECTS) automata *.o source/automata/meta.d

distclean: clean
	@echo -e "(\033[33;1mDISTCLEAN\033[m)"
	@-rm -fr deps .build

install: automata doc/automata.1
	@echo -e "(\033[32mINSTALL\033[m)" automata
	@install -m 0755 automata -D $(DESTDIR)$(BINDIR)/automata
	@echo -e "(\033[32mINSTALL\033[m)" doc/automata.1
	@install -m 0644 doc/automata.1 -D $(DESTDIR)$(MANDIR)/man1/automata.1

uninstall:
	@echo -e "(\033[33mRM\033[m)" $(BINDIR)/automata
	@-rm -f $(DESTDIR)$(BINDIR)/automata
	@echo -e "(\033[33mRM\033[m)" $(MANDIR)/man1/automata.1
	@-rm -f $(DESTDIR)$(MANDIR)/man1/automata.1
