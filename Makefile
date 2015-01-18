doc := doc
test := test


all: doc test

clean:
	$(RM) -R $(doc)

.PHONY: doc
doc:
	luadoc -d $(doc) mods/terragenitor

.SILENT .PHONY: test
test: $(test)/*.lua
	$(foreach file,$^,lua $(file);)

