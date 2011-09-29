# configure.ac

AC_INIT([gta04tester],[0.1])
AC_CONFIG_SRCDIR([src/main.vala])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])

# Enable silent rules is available
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AM_MAINTAINER_MODE

AC_PROG_CC
AC_PROG_CC_STDC
AM_PROG_VALAC([0.12.0])
AC_PROG_INSTALL
IT_PROG_INTLTOOL([0.35])

pkg_modules="gtk+-2.0 >= 2.14.0 gee-1.0 >= 0.5.0"
GTA04TESTER_PACKAGES="--thread --pkg gtk+-2.0 --pkg gio-2.0 --pkg posix --pkg gee-1.0"
PKG_CHECK_MODULES(GTA04TESTER, [$pkg_modules])
AC_SUBST(GTA04TESTER_CFLAGS)
AC_SUBST(GTA04TESTER_LIBS)
AC_SUBST(GTA04TESTER_PACKAGES)

GETTEXT_PACKAGE=gta04tester
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Gettext Package])
AC_SUBST(GETTEXT_PACKAGE)
AM_GNU_GETTEXT_VERSION([1.11])
AM_GLIB_GNU_GETTEXT

AC_CONFIG_FILES([
	Makefile
	data/gta04tester.desktop.in
	data/Makefile
	data/icons/Makefile
	data/icons/16x16/Makefile
	data/icons/22x22/Makefile
	data/icons/24x24/Makefile
	data/icons/32x32/Makefile
	data/icons/48x48/Makefile
	data/images/Makefile
	po/Makefile.in
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT
