AC_INIT(uber-script, [0.1])

AC_CONFIG_MACRO_DIR([m4])

PKG_CHECK_MODULES(APR_1, [apr-1 >= 1.5.2])
PKG_CHECK_MODULES(EVENT, [libevent >= 2.0])
PKG_CHECK_MODULES(XML, [libxml-2.0 >= 2.8])
AC_CHECK_LIB(bz2, BZ2_bzDecompress, [], [AC_MSG_ERROR([library 'bz2' is required for bzip2 support])])
PKG_CHECK_MODULES(SSL, [libssl >= 1.0])
PKG_CHECK_MODULES(ZLIB, [zlib >= 1.2.8])
PKG_CHECK_MODULES(PYTHON, [python >= 2.7])
PKG_CHECK_MODULES(YAML, [yaml-0.1 >= 0.1.4])
AC_CHECK_LIB(readline, readline, [], [AC_MSG_ERROR([library 'readline' not found])])

