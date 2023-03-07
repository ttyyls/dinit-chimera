CC         ?= cc
CFLAGS     ?= -O2
PREFIX     ?= /usr
SYSCONFDIR ?= /etc
LIBDIR     ?= $(PREFIX)/lib
LIBEXECDIR ?= $(PREFIX)/libexec
DATADIR    ?= $(PREFIX)/share
MANDIR     ?= $(DATADIR)/man/man8
SDINITDIR  ?= $(LIBDIR)/dinit.d
DINITDIR   ?= $(SYSCONFDIR)/dinit.d
EXTRA_CFLAGS = -Wall -Wextra

MANPAGES = init-modules.target.8

all: seedrng hwclock-helper

seedrng:
	$(CC) $(EXTRA_CFLAGS) $(CFLAGS) $(LDFLAGS) seedrng.c -o seedrng

hwclock-helper:
	$(CC) $(EXTRA_CFLAGS) $(CFLAGS) $(LDFLAGS) hwclock-helper.c -o hwclock-helper

clean:
	rm -f seedrng hwclock-helper

install: seedrng hwclock-helper
	install -d $(DESTDIR)$(DATADIR)
	install -d $(DESTDIR)$(SYSCONFDIR)
	install -d $(DESTDIR)$(MANDIR)
	install -d $(DESTDIR)$(LIBEXECDIR)/dinit/early
	install -d $(DESTDIR)$(SDINITDIR)/boot.d
	install -d $(DESTDIR)$(DINITDIR)
	install -d $(DESTDIR)$(DINITDIR)/boot.d
	touch $(DESTDIR)$(DINITDIR)/boot.d/.empty
	touch $(DESTDIR)$(SDINITDIR)/boot.d/.empty
	# early scripts
	for script in scripts/*.sh; do \
		install -m 755 $$script \
			$(DESTDIR)$(LIBEXECDIR)/dinit/early; \
	done
	# shutdown script
	install -m 755 dinit-shutdown $(DESTDIR)$(LIBEXECDIR)/dinit/shutdown
	# helper programs
	install -m 755 seedrng $(DESTDIR)$(LIBEXECDIR)
	install -m 755 hwclock-helper $(DESTDIR)$(LIBEXECDIR)
	# manpages
	for man in $(MANPAGES); do \
		install -m 644 man/$$man $(DESTDIR)$(MANDIR); \
	done
	# system services
	for srv in services/*; do \
		install -m 644 $$srv $(DESTDIR)$(SDINITDIR); \
	done
