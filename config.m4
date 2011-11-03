dnl +----------------------------------------------------------------------+
dnl | PHP Version 5                                                        |
dnl +----------------------------------------------------------------------+
dnl | Copyrght (C) 1997-2011 The PHP Group                                 |
dnl +----------------------------------------------------------------------+
dnl | This source file is subject to version 3.01 of the PHP license,      |
dnl | that is bundled with this package in the file LICENSE, and is        |
dnl | available through the world-wide-web at the following url:           |
dnl | http://www.php.net/license/3_01.txt                                  |
dnl | If you did not receive a copy of the PHP license and are unable to   |
dnl | obtain it through the world-wide-web, please send a note to          |
dnl | license@php.net so we can mail you a copy immediately.               |
dnl +----------------------------------------------------------------------+
dnl | Author: Ruslan Osmanov <osmanov@php.net>                             |
dnl +----------------------------------------------------------------------+

PHP_ARG_WITH(eio, for eio support,
[  --with-eio               Include eio support])

PHP_ARG_ENABLE(eio-debug, for eio debug support,
[  --enable-eio-debug       Enable eio debug support], no, no)

dnl {{{ Debug support
if test "$PHP_EIO_DEBUG" != "no"; then
    CFLAGS="$CFLAGS -Wall -g -ggdb -O0"
    AC_DEFINE(EIO_DEBUG,1,[Enable eio debug support])
fi
dnl }}}

dnl {{{ eio support 
if test "$PHP_EIO" != "no"; then

    dnl {{{ Include paths
    SEARCH_PATH="/usr/local /usr /opt"
    
    dnl {{{ --with-eio
    SEARCH_FOR="include/eio.h"
    if test -r $PHP_EIO/$SEARCH_FOR; then # path given as parameter
        EIO_DIR=$PHP_EIO
    else # search default path list
        AC_MSG_CHECKING([for eio files in default path])
        for i in $SEARCH_PATH ; do
            if test -r $i/$SEARCH_FOR; then
                EIO_DIR=$i
                AC_MSG_RESULT(found in $i)
            fi
        done
    fi
    if test -z "$EIO_DIR"; then
        AC_MSG_RESULT([not found])
        AC_MSG_ERROR([Please reinstall libeio])
    fi
    PHP_ADD_INCLUDE($EIO_DIR/include)
    dnl }}}
    
    dnl {{{ sys/eventfd.h
    SEARCH_FOR="include/sys/eventfd.h"
    AC_MSG_CHECKING([for sys/eventfd.h in default path])
    for i in $SEARCH_PATH ; do
        if test -r $i/$SEARCH_FOR; then
            EVENTFD_DIR=$i
            AC_MSG_RESULT(found in $i)
        fi
    done
    if test -z "$EVENTFD_DIR"; then
        AC_MSG_RESULT([not found])
        AC_MSG_ERROR([Please install glibc 2.8 or greater])
    fi
    PHP_ADD_INCLUDE($EVENTFD_DIR/include)
    dnl }}}
    
    dnl {{{ linux/falloc.h
    SEARCH_FOR="include/linux/falloc.h"
    AC_MSG_CHECKING([for falloc.h file in default path])
    for i in $SEARCH_PATH ; do
        if test -r $i/$SEARCH_FOR; then
            FALLOC_DIR=$i
            AC_MSG_RESULT(found in $i)
        fi
    done
    if test -z "$FALLOC_DIR"; then
        AC_MSG_RESULT([not found])
        AC_MSG_ERROR([Please install Linux headers, or make sure $SEARCH_FOR is available])
    fi
    PHP_ADD_INCLUDE($FALLOC_DIR/include)
    dnl }}}

    dnl }}}

    dnl {{{ Library checks
    # --with-eio -> check for lib and symbol presence
    LIBNAME=eio
    LIBSYMBOL=eio_init

    PHP_CHECK_LIBRARY($LIBNAME,$LIBSYMBOL,
    [
    PHP_ADD_LIBRARY_WITH_PATH($LIBNAME, $EIO_DIR/lib, EIO_SHARED_LIBADD)
    AC_DEFINE(HAVE_EIOLIB,1,[ ])
    ],[
    AC_MSG_ERROR([wrong eio lib version or lib not found])
    ],[
    -L$EIO_DIR/lib
    ])

    PHP_SUBST(EIO_SHARED_LIBADD)
    dnl }}}

    dnl Build extension 
    eio_src="php_eio.c eio_fe.c"
    PHP_NEW_EXTENSION(eio, $eio_src, $ext_shared,,$CFLAGS)
fi
dnl }}}

dnl vim: ft=m4.sh et fdm=marker:
