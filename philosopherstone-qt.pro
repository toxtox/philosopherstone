TEMPLATE = app
TARGET = philosopherstone-qt
VERSION = 0.7.5
QT += core gui network

message(LIBS_variable_at_beginning $$LIBS)

# Until now (26.12.2017) an old openssl-version (0.9.8zh) is still required, that must be compiled from sources. Here are the standard PATHES to openssl locations:
!windows:!macx {
  OPENSSL_LIB_PATH = /usr/local/ssl/lib
  OPENSSL_INCLUDE_PATH = /usr/local/ssl/include/
}
# OPENSSL_LIB_PATH = /usr/lib/arm-linux-gnueabihf
# OPENSSL_INCLUDE_PATH = /usr/include

# If you get error: "bitcoinrpc.cpp:(.text+0x3bb8): undefined reference to `SSLv23_method'" 
# or similar ssl/tls related error when compiling/linking 'qrc_bitcoin.o'
# definig ssl libs as SUBLIBS in order to link ssl-libs BEFORE system-libs 
# but this seems not to work in this *.pro file!?!?, 
# instead try 'make SUBLIBS=-L/usr/local/ssl/lib' for compiling
#SUBLIBS += $$join(OPENSSL_LIB_PATH,,-L,)
#SUBLIBS += -lssl

# WARNING hardcoded DB4.8-PATHes, change them to your PATHes
!windows:!macx {
  BDB_LIB_PATH = /usr/local/BerkeleyDB.4.8/lib/
  BDB_LIB_SUFFIX = -4.8
  BDB_INCLUDE_PATH = /usr/local/BerkeleyDB.4.8/include/
}


INCLUDEPATH += src src/json src/qt
# "QT_STATIC" has no effect if you have no static QT-libs on your system => automatic fall back to dynamic QT-libs
DEFINES += QT_STATIC QT_GUI BOOST_THREAD_USE_LIB BOOST_SPIRIT_THREADSAFE BOOST_THREAD_PROVIDES_GENERIC_SHARED_MUTEX_ON_WIN __NO_SYSTEM_INCLUDES
CONFIG += no_include_pwd
CONFIG += thread
CONFIG += static

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

# THE FOLLOWING SECTION WAS NOT TESTED ON WINDOWS-SYSTEM, if errors occure remove "windows: " at beginnung of lines
windows: BOOST_LIB_SUFFIX=-mgw71-mt-s-1_64
windows: BOOST_INCLUDE_PATH=D:/deps/x64/boost_1_64_0
windows: BOOST_LIB_PATH=D:/deps/x64/boost_1_64_0/stage/lib
windows: BDB_INCLUDE_PATH=D:/deps/x64/db-6.2.32/build_unix
windows: BDB_LIB_PATH=D:/deps/x64/db-6.2.32/build_unix
windows: OPENSSL_INCLUDE_PATH=D:/deps/x64/openssl-1.0.2l/include
windows: OPENSSL_LIB_PATH=D:/deps/x64/openssl-1.0.2l
windows: QRENCODE_INCLUDE_PATH=D:/deps/x64/qrencode-3.4.4
windows: QRENCODE_LIB_PATH=D:/deps/x64/qrencode-3.4.4/.libs


OBJECTS_DIR = build
MOC_DIR = build
UI_DIR = build

# use: qmake "RELEASE=1"
contains(RELEASE, 1) {  
  
  # Mac: compile for maximum compatibility (10.5, 32-bit)
  macx:QMAKE_CXXFLAGS += -mmacosx-version-min=10.5 -arch x86_64 -isysroot /Developer/SDKs/MacOSX10.5.sdk
  
  !windows:!macx {
    # Linux: static link
    #build an "philosopherstone-qt" that is as static as possible:
    # "LIBS = -Wl,-Bstatic" 
    
    INCLUDEPATH += $$[QT_INSTALL_HEADERS]    
    # "LIBS = -Wl,-Bstatic" clears LIBS-Variable, and sets "-Wl,-Bstatic" as first values (WARNING do not define any libraries above if you want to make a static RELEASE=1 build ):
    LIBS = -Wl,-Bstatic        
# some required QT-lib PATHES with static libs are not searched by qmake by default => adding all QT PATHES. If you have more than one QT-installations choose run the "qmake" of the desired QT-installation to use the right QT-PATHES:
    LIBS += -L$$[QT_INSTALL_LIBS] -L$$[QT_INSTALL_PLUGINS] -L$$[QT_INSTALL_PLUGINS]/platforms -L$$[QT_INSTALL_PLUGINS]/xcbglintegrations -L$$[QT_INSTALL_PLUGINS]/imageformats -L$$[QT_INSTALL_PLUGINS]/egldeviceintegrations -L$$[QT_INSTALL_PLUGINS]/bearer -L$$[QT_INSTALL_PLUGINS]/wayland-graphics-integration-client
    #maybe not mandatory:
    LIBS += -L$$[QT_INSTALL_PLUGINS]/platforminputcontexts

    LIBS += -lstdc++
    
    #static Qt-Plugins: "CONFIG -= import_plugins" avoids qmake-autogeneration of "philosopherstone-qt_plugin_import.cpp" that contains many not required plugins
    CONFIG -= import_plugins
    #QTPLUGIN.platforms = qminimal
    #QTPLUGIN.platforms = -
    # At least this QT-plugin is required: "qxcb"
    QTPLUGIN = qxcb
    
    DEFINES += INCLUDE_STATIC_QXCB_PLUGIN_IN_MAIN_CPP
    
    QMAKE_CXXFLAGS += -DQT_STATIC
    QMAKE_CFLAGS   += -DQT_STATIC        
  }
}



!win32 {
  # for extra security against potential buffer overflows: enable GCCs Stack Smashing Protection, better portability of linux builds 
  QMAKE_CXXFLAGS *= -fstack-protector-all --param ssp-buffer-size=1  
  QMAKE_LFLAGS *= -fstack-protector-all --param ssp-buffer-size=1
  # We need to exclude this for Windows cross compile with MinGW 4.2.x, as it will result in a non-working executable!
  # This can be enabled for Windows, when we switch to MinGW >= 4.4.x.  
}

# for extra security on Windows: enable ASLR and DEP via GCC linker flags
win32:QMAKE_LFLAGS *= -Wl,--dynamicbase -Wl,--nxcompat
# on Windows: enable GCC large address aware linker flag
win32:QMAKE_LFLAGS *= -Wl,-static

# use: qmake "USE_QRCODE=1"
# libqrencode (http://fukuchi.org/works/qrencode/index.en.html) must be installed for support
contains(USE_QRCODE, 1) {
  message(Building with QRCode support)
  DEFINES += USE_QRCODE
  LIBS += -lqrencode -lpthread
}

# use: qmake "USE_UPNP=1" ( enabled by default; default)
#  or: qmake "USE_UPNP=0" (disabled by default)
#  or: qmake "USE_UPNP=-" (not supported)
# miniupnpc (http://miniupnp.free.fr/files/) must be installed for support
contains(USE_UPNP, -) {
  message(Building without UPNP support)
} else {
  message(Building with UPNP support)
  count(USE_UPNP, 0) {
    USE_UPNP=1
  }
  DEFINES += USE_UPNP=$$USE_UPNP STATICLIB
  INCLUDEPATH += $$MINIUPNPC_INCLUDE_PATH
  LIBS += $$join(MINIUPNPC_LIB_PATH,,-L,) -lminiupnpc
  win32:LIBS += -liphlpapi
}

# use: qmake "USE_DBUS=1" or qmake "USE_DBUS=0"
linux:count(USE_DBUS, 0) {
  USE_DBUS=1
}
contains(USE_DBUS, 1) {
  message(Building with DBUS (Freedesktop notifications) support)
  DEFINES += USE_DBUS
  QT += dbus
}

contains(BITCOIN_NEED_QT_PLUGINS, 1) {
  DEFINES += BITCOIN_NEED_QT_PLUGINS
  QTPLUGIN += qcncodecs qjpcodecs qtwcodecs qkrcodecs qtaccessiblewidgets
}


INCLUDEPATH += src/leveldb/include src/leveldb/helpers
LIBS += $$PWD/src/leveldb/libleveldb.a $$PWD/src/leveldb/libmemenv.a
SOURCES += src/txdb-leveldb.cpp
!win32 {
  # we use QMAKE_CXXFLAGS_RELEASE even without RELEASE=1 because we use RELEASE to indicate linking preferences not -O preferences
  genleveldb.commands = cd $$PWD/src/leveldb && CC=$$QMAKE_CC CXX=$$QMAKE_CXX $(MAKE) OPT=\"$$QMAKE_CXXFLAGS $$QMAKE_CXXFLAGS_RELEASE\" libleveldb.a libmemenv.a
} else {
  # make an educated guess about what the ranlib command is called
  isEmpty(QMAKE_RANLIB) {
    QMAKE_RANLIB = $$replace(QMAKE_STRIP, strip, ranlib)
  }
  LIBS += -lshlwapi
  #genleveldb.commands = cd $$PWD/src/leveldb && CC=$$QMAKE_CC CXX=$$QMAKE_CXX TARGET_OS=OS_WINDOWS_CROSSCOMPILE $(MAKE) OPT=\"$$QMAKE_CXXFLAGS $$QMAKE_CXXFLAGS_RELEASE\" libleveldb.a libmemenv.a && $$QMAKE_RANLIB $$PWD/src/leveldb/libleveldb.a && $$QMAKE_RANLIB $$PWD/src/leveldb/libmemenv.a
}
genleveldb.target = $$PWD/src/leveldb/libleveldb.a
genleveldb.depends = FORCE
PRE_TARGETDEPS += $$PWD/src/leveldb/libleveldb.a
QMAKE_EXTRA_TARGETS += genleveldb
# Gross ugly hack that depends on qmake internals, unfortunately there is no other way to do it.
QMAKE_CLEAN += $$PWD/src/leveldb/libleveldb.a; cd $$PWD/src/leveldb ; $(MAKE) clean


# regenerate src/build.h
!windows|contains(USE_BUILD_INFO, 1) {
  genbuild.depends = FORCE
  genbuild.commands = cd $$PWD; /bin/sh share/genbuild.sh $$OUT_PWD/build/build.h
  genbuild.target = $$OUT_PWD/build/build.h
  PRE_TARGETDEPS += $$OUT_PWD/build/build.h
  QMAKE_EXTRA_TARGETS += genbuild
  DEFINES += HAVE_BUILD_INFO
}

# If we have an arm device, we can't use sse2, so define as thumb
# Because of scrypt_mine.cpp, we also have to add a compile
#     flag that states we *really* don't have SSE
# Otherwise, assume sse2 exists

#equals($$QMAKE_HOST.arch, armv7l) {
host = $$QMAKE_HOST.arch
message(FOUND $$host)
c {
isEmpty( GENERIC_ARM_CPU ) {
  equals(host, armv7l) {
    message(setting armv7l successful)    
    
    QMAKE_CXXFLAGS += -mthumb -DNOSSE -march=armv7
    QMAKE_CFLAGS +=   -mthumb -DNOSSE -march=armv7
  }
  else {  
    QMAKE_CXXFLAGS += -msse2
    QMAKE_CFLAGS += -msse2
  }
}
}

contains(RASPBERRY_PI_VERSION_2_OR_3, 2) {
  message(setting RASPBERRY_PI_VERSION_2 successful)
  # for  Raspberry PI 2 (not tested my be you could add '-Ofast' and '-ftree-vectorize -ffast-math', too)
  QMAKE_CXXFLAGS += -mthumb -DNOSSE -march=armv7-a -mtune=cortex-a8 
  QMAKE_CFLAGS +=   -mthumb -DNOSSE -march=armv7-a -mtune=cortex-a8
}

contains(RASPBERRY_PI_VERSION_2_OR_3, 3) {
  message(setting RASPBERRY_PI_VERSION_3 successful)
  # for Raspberry PI 3    
  QMAKE_CXXFLAGS += -mthumb -DNOSSE -Ofast -march=armv8-a+crc -mtune=cortex-a53 -mcpu=cortex-a53 -ftree-vectorize -ffast-math
  QMAKE_CFLAGS +=   -mthumb -DNOSSE -Ofast -march=armv8-a+crc -mtune=cortex-a53 -mcpu=cortex-a53 -ftree-vectorize -ffast-math
}  

# Use GENERIC_ARM_CPU = 1 if you have a different ARM-CPU (not "armv7l" and not a Raspberry Pi 2 or 3)
contains(GENERIC_ARM_CPU, 1) {
  message(setting GENERIC_ARM_CPU successful)
    QMAKE_CXXFLAGS += -mthumb -DNOSSE
    QMAKE_CFLAGS +=   -mthumb -DNOSSE
}

contains(USE_O3, 1) {
  message(Building O3 optimization flag)
  QMAKE_CXXFLAGS_RELEASE -= -O2
  QMAKE_CFLAGS_RELEASE -= -O2
  QMAKE_CXXFLAGS += -O3
  QMAKE_CFLAGS += -O3
}
#endif

QMAKE_CXXFLAGS_WARN_ON = -fdiagnostics-show-option -Wall -Wextra -Wno-ignored-qualifiers -Wformat -Wformat-security -Wno-unused-parameter -Wstack-protector

# Input
DEPENDPATH += src src/json src/qt
HEADERS += \
src/addrman.h \
src/alert.h \
src/allocators.h \
src/base58.h \
src/bignum.h \
src/bitcoinrpc.h \
src/checkpoints.h \
src/clientversion.h \
src/coincontrol.h \
src/compat.h \
src/crypter.h \
src/db.h \
src/init.h \
src/irc.h \
src/json/json_spirit.h \
src/json/json_spirit_error_position.h \
src/json/json_spirit_reader.h \
src/json/json_spirit_reader_template.h \
src/json/json_spirit_stream_reader.h \
src/json/json_spirit_utils.h \
src/json/json_spirit_value.h \
src/json/json_spirit_writer.h \
src/json/json_spirit_writer_template.h \
src/kernel.h \
src/key.h \
src/keystore.h \
src/main.h \
src/miner.h \
src/mruset.h \
src/net.h \
src/netbase.h \
src/pbkdf2.h \
src/protocol.h \
src/qt/aboutdialog.h \
src/qt/addressbookpage.h \
src/qt/addresstablemodel.h \
src/qt/askpassphrasedialog.h \
src/qt/bitcoinaddressvalidator.h \
src/qt/bitcoinamountfield.h \
src/qt/bitcoingui.h \
src/qt/bitcoinunits.h \
src/qt/clientmodel.h \
src/qt/coincontroldialog.h \
src/qt/coincontroltreewidget.h \
src/qt/csvmodelwriter.h \
src/qt/editaddressdialog.h \
src/qt/guiconstants.h \
src/qt/guiutil.h \
src/qt/monitoreddatamapper.h \
src/qt/notificator.h \
src/qt/optionsdialog.h \
src/qt/optionsmodel.h \
src/qt/overviewpage.h \
src/qt/qcustomplot.h \
src/qt/qtipcserver.h \
src/qt/qvalidatedlineedit.h \
src/qt/qvaluecombobox.h \
src/qt/rpcconsole.h \
src/qt/sendcoinsdialog.h \
src/qt/sendcoinsentry.h \
src/qt/signverifymessagedialog.h \
src/qt/transactiondesc.h \
src/qt/transactiondescdialog.h \
src/qt/transactionfilterproxy.h \
src/qt/transactionrecord.h \
src/qt/transactiontablemodel.h \
src/qt/transactionview.h \
src/qt/walletmodel.h \
src/script.h \
src/scrypt_mine.h \
src/serialize.h \
src/strlcpy.h \
src/sync.h \
src/ui_interface.h \
src/uint256.h \
src/util.h \
src/version.h \
src/wallet.h \
src/walletdb.h 

SOURCES += \
src/addrman.cpp \
src/alert.cpp \
src/bitcoinrpc.cpp \
src/checkpoints.cpp \
src/crypter.cpp \
src/db.cpp \
src/init.cpp \
src/irc.cpp \
src/kernel.cpp \
src/key.cpp \
src/keystore.cpp \
src/main.cpp \
src/miner.cpp \
src/net.cpp \
src/netbase.cpp \
src/noui.cpp \
src/pbkdf2.cpp \
src/protocol.cpp \
src/qt/aboutdialog.cpp \
src/qt/addressbookpage.cpp \
src/qt/addresstablemodel.cpp \
src/qt/askpassphrasedialog.cpp \
src/qt/bitcoin.cpp src/qt/bitcoingui.cpp \
src/qt/bitcoinaddressvalidator.cpp \
src/qt/bitcoinamountfield.cpp \
src/qt/bitcoinstrings.cpp \
src/qt/bitcoinunits.cpp \
src/qt/clientmodel.cpp \
src/qt/coincontroldialog.cpp \
src/qt/coincontroltreewidget.cpp \
src/qt/csvmodelwriter.cpp \
src/qt/editaddressdialog.cpp \
src/qt/guiutil.cpp \
src/qt/monitoreddatamapper.cpp \
src/qt/notificator.cpp \
src/qt/optionsdialog.cpp \
src/qt/optionsmodel.cpp \
src/qt/overviewpage.cpp \
src/qt/qcustomplot.cpp \
src/qt/qtipcserver.cpp \
src/qt/qvalidatedlineedit.cpp \
src/qt/qvaluecombobox.cpp \
src/qt/rpcconsole.cpp \
src/qt/sendcoinsdialog.cpp \
src/qt/sendcoinsentry.cpp \
src/qt/signverifymessagedialog.cpp \
src/qt/transactiondesc.cpp \
src/qt/transactiondescdialog.cpp \
src/qt/transactionfilterproxy.cpp \
src/qt/transactionrecord.cpp \
src/qt/transactiontablemodel.cpp \
src/qt/transactionview.cpp \
src/qt/walletmodel.cpp \
src/rpcblockchain.cpp \
src/rpcdump.cpp \
src/rpcmining.cpp \
src/rpcnet.cpp \
src/rpcrawtransaction.cpp \
src/rpcwallet.cpp \
src/script.cpp \
src/scrypt-arm.S \
src/scrypt_mine.cpp \
src/scrypt-x86.S \
src/scrypt-x86_64.S \
src/sync.cpp \
src/util.cpp \
src/version.cpp \
src/wallet.cpp \
src/walletdb.cpp

RESOURCES += \
src/qt/bitcoin.qrc

FORMS += \
src/qt/forms/aboutdialog.ui \
src/qt/forms/addressbookpage.ui \
src/qt/forms/askpassphrasedialog.ui \
src/qt/forms/coincontroldialog.ui \
src/qt/forms/editaddressdialog.ui \
src/qt/forms/optionsdialog.ui \
src/qt/forms/overviewpage.ui \
src/qt/forms/rpcconsole.ui \
src/qt/forms/sendcoinsdialog.ui \
src/qt/forms/sendcoinsentry.ui \
src/qt/forms/signverifymessagedialog.ui \
src/qt/forms/transactiondescdialog.ui 

contains(USE_QRCODE, 1) {
  HEADERS += src/qt/qrcodedialog.h
  SOURCES += src/qt/qrcodedialog.cpp
  FORMS += src/qt/forms/qrcodedialog.ui
}

contains(BITCOIN_QT_TEST, 1) {
  SOURCES += src/qt/test/test_main.cpp \
  src/qt/test/uritests.cpp
  HEADERS += src/qt/test/uritests.h
  DEPENDPATH += src/qt/test
  QT += testlib
  TARGET = philosopherstone-qt_test
  DEFINES += BITCOIN_QT_TEST
}

CODECFORTR = UTF-8

# for lrelease/lupdate
# also add new translations to src/qt/bitcoin.qrc under translations/
TRANSLATIONS = $$files(src/qt/locale/bitcoin_*.ts)

isEmpty(QMAKE_LRELEASE) {
  win32:QMAKE_LRELEASE = $$[QT_INSTALL_BINS]\\lrelease.exe
  else:QMAKE_LRELEASE = $$[QT_INSTALL_BINS]/lrelease
}
isEmpty(QM_DIR):QM_DIR = $$PWD/src/qt/locale
# automatically build translations, so they can be included in resource file
TSQM.name = lrelease ${QMAKE_FILE_IN}
TSQM.input = TRANSLATIONS
TSQM.output = $$QM_DIR/${QMAKE_FILE_BASE}.qm
TSQM.commands = $$QMAKE_LRELEASE ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_OUT}
TSQM.CONFIG = no_link
QMAKE_EXTRA_COMPILERS += TSQM

# "Other files" to show in Qt Creator
OTHER_FILES += \
doc/*.rst doc/*.txt doc/README README.md res/bitcoin-qt.rc src/test/*.cpp src/test/*.h src/qt/test/*.cpp src/qt/test/*.h

# platform specific defaults, if not overridden on command line
isEmpty(BOOST_LIB_SUFFIX) {
  macx:BOOST_LIB_SUFFIX = -mt
  windows:BOOST_LIB_SUFFIX = -mgw71-mt-s-1_57
}

isEmpty(BOOST_THREAD_LIB_SUFFIX) {
  BOOST_THREAD_LIB_SUFFIX = $$BOOST_LIB_SUFFIX
}

isEmpty(BDB_LIB_PATH) {
  macx:BDB_LIB_PATH = /opt/local/lib/db48
}

isEmpty(BDB_LIB_SUFFIX) {
  macx:BDB_LIB_SUFFIX = -4.8
}

isEmpty(BDB_INCLUDE_PATH) {
  macx:BDB_INCLUDE_PATH = /opt/local/include/db48
}

isEmpty(BOOST_LIB_PATH) {
  macx:BOOST_LIB_PATH = /opt/local/lib
}

isEmpty(BOOST_INCLUDE_PATH) {
  macx:BOOST_INCLUDE_PATH = /opt/local/include
}

windows:DEFINES += WIN32 WIN32_LEAN_AND_MEAN
windows:RC_FILE = src/qt/res/bitcoin-qt.rc

windows:!contains(MINGW_THREAD_BUGFIX, 0) {
  # At least qmake's win32-g++-cross profile is missing the -lmingwthrd
  # thread-safety flag. GCC has -mthreads to enable this, but it doesn't
  # work with static linking. -lmingwthrd must come BEFORE -lmingw, so
  # it is prepended to QMAKE_LIBS_QT_ENTRY.
  # It can be turned off with MINGW_THREAD_BUGFIX=0, just in case it causes
  # any problems on some untested qmake profile now or in the future.
  DEFINES += _MT BOOST_THREAD_PROVIDES_GENERIC_SHARED_MUTEX_ON_WIN
  QMAKE_LIBS_QT_ENTRY = -lmingwthrd $$QMAKE_LIBS_QT_ENTRY
}



macx:HEADERS += src/qt/macdockiconhandler.h
macx:OBJECTIVE_SOURCES += src/qt/macdockiconhandler.mm
macx:LIBS += -framework Foundation -framework ApplicationServices -framework AppKit
macx:DEFINES += MAC_OSX MSG_NOSIGNAL=0
macx:ICON = src/qt/res/icons/Philosopherstone.icns
macx:TARGET = "philosopherstone-qt"
macx:QMAKE_CFLAGS_THREAD += -pthread
macx:QMAKE_LFLAGS_THREAD += -pthread
macx:QMAKE_CXXFLAGS_THREAD += -pthread

# very likely unnessesary 
# QMAKE_LIBS_QT_ENTRY = -lssl $$OPENSSL_LIB_PATH

# Set libraries and includes at end, to use platform-defined defaults if not overridden
INCLUDEPATH += $$BOOST_INCLUDE_PATH $$BDB_INCLUDE_PATH $$OPENSSL_INCLUDE_PATH $$QRENCODE_INCLUDE_PATH
# moved ssl-libs to beginning of file for customizing more easily and for OVERRIDING platform-defined defaults
LIBS += $$join(BOOST_LIB_PATH,,-L,) $$join(BDB_LIB_PATH,,-L,) $$join(OPENSSL_LIB_PATH,,-L,) 
LIBS += -lssl
#LIBS += -lxcb
LIBS += $$join(QRENCODE_LIB_PATH,,-L,)
LIBS += -lcrypto -ldb_cxx$$BDB_LIB_SUFFIX
# -lgdi32 has to happen after -lcrypto (see  #681)
windows:LIBS += -lws2_32 -lshlwapi -lmswsock -lole32 -loleaut32 -luuid -lgdi32
LIBS += -lboost_system$$BOOST_LIB_SUFFIX -lboost_filesystem$$BOOST_LIB_SUFFIX -lboost_program_options$$BOOST_LIB_SUFFIX -lboost_thread$$BOOST_THREAD_LIB_SUFFIX
windows:LIBS += -lboost_chrono$$BOOST_LIB_SUFFIX

#LIBS += -lrt

contains(RELEASE, 1) {
  !windows:!macx {
    # Linux: turn dynamic linking back on for c/c++ runtime libraries
    LIBS += -Wl,-Bdynamic -lxcb -ldl -lpthread -lGL -lfontconfig
  }
}

!windows:!macx {
  DEFINES += LINUX
  isEmpty( RELEASE ) {
    LIBS += -lrt -ldl  
  }
}

system($$QMAKE_LRELEASE -silent $$_PRO_FILE_)

