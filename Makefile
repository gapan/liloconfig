DESTDIR ?= /
PACKAGE_LOCALE_DIR ?= /usr/share/locale

.PHONY: mo
mo:
	for i in `ls po/*.po`;do \
		echo "Compiling `echo $$i|sed "s|/po||"`"; \
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
	rm -f po/*.mo
	rm -f po/*~

.PHONY: cleanpo
cleanpo:
	find po/ -name '*.po' -print0 | while read -d '' -r file; do msgattrib --output-file="$$file" --no-obsolete "$$file"; done

.PHONY: install
install:
	install -d -m 755 $(DESTDIR)/sbin
	install -m 755 src/liloconfig $(DESTDIR)/sbin/
	install -d -m 755 $(DESTDIR)/var/lib/pkgtools/setup
	install -m 755 src/setup.liloconfig $(DESTDIR)/var/lib/pkgtools/setup/
	install -m 644 src/text.lilohelp $(DESTDIR)/var/lib/pkgtools/setup/
	for i in `ls po/*.mo`; do \
		install -d -m 755 \
		$(DESTDIR)/$(PACKAGE_LOCALE_DIR)/`basename $$i|sed "s/.mo//"`/LC_MESSAGES \
		2> /dev/null; \
		install -m 644 $$i \
		$(DESTDIR)/$(PACKAGE_LOCALE_DIR)/`basename $$i|sed "s/.mo//"`/LC_MESSAGES/liloconfig.mo; \
	done;

.PHONY: tx-pull
tx-pull:
	tx pull -a
	for i in `ls po/*.po`;do \
		msgfmt --statistics $$i 2>&1 | grep "^0 translated" > /dev/null && rm $$i; \
	done
	rm -f messages.mo

.PHONY: srcpkg
srcpkg:
	git archive --prefix=liloconfig/ master | xz > ../liloconfig.tar.xz
