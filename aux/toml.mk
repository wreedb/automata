TOML_DIR := deps/toml/src

TOML_SOURCES = datetime.d package.d serialize.d toml.d
TOML_SOURCES := $(addprefix $(TOML_DIR)/toml/,$(TOML_SOURCES))

TOML_OBJECTS = $(patsubst $(TOML_DIR)/toml/%.d,toml.%.o,$(TOML_SOURCES))
TOML_OBJECTS := $(subst /,.,$(TOML_OBJECTS))
TOML_OBJECTS := $(addprefix $(BUILDDIR)/,$(TOML_OBJECTS))

TOML_LIB := $(BUILDDIR)/libtoml.a
