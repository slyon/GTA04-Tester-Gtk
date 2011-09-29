bin_PROGRAMS = gta04tester

gta04tester_SOURCES = \
	main.vala \
	gta04tester.vala

INCLUDES = \
	-include config.h \
	$(GTA04TESTER_CFLAGS) \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\"

VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi --pkg config \
	@GTA04TESTER_PACKAGES@

gta04tester_LDADD = \
	$(GTA04TESTER_LIBS)
