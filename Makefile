doc := doc
test := test


all: doc

clean:
	$(RM) -R $(doc)

.PHONY: doc
doc:
	luadoc -d $(doc) mods/terragenitor/

