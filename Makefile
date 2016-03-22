
.PHONY: mo
mo:
	for i in `ls po/*.po`;do \
		echo "Compiling `echo $$j|sed "s|/po||"`"; \
		msgfmt $$i -o `echo $$i | sed "s/\.po//"`.mo; \
	done

.PHONY: pot
pot:
	xgettext --from-code=utf-8 -L shell -o po/liloconfig.pot src/liloconfig

.PHONY: update-po
update-po: pot
	for i in `ls po/*.po`; do \
		echo "Merging $$i translation..."; \
		msgmerge -U $$i po/liloconfig.pot; \
	done

.PHONY: clean
clean:
	rm -f po/*~

.PHONY: cleanpo
cleanpo:
	find po/ -name '*.po' -print0 | while read -d '' -r file; do msgattrib --output-file="$$file" --no-obsolete "$$file"; done
