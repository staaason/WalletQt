QT += quick

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        admin.cpp \
        main.cpp \
        model.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    admin.h \
    model.h

DISTFILES += \
    crypto-js/crypto-js.js \
    crypto-js/src/aes.js \
    crypto-js/src/aes.js \
    crypto-js/src/cipher-core.js \
    crypto-js/src/cipher-core.js \
    crypto-js/src/core.js \
    crypto-js/src/core.js \
    crypto-js/src/enc-base64.js \
    crypto-js/src/enc-base64.js \
    crypto-js/src/enc-utf16.js \
    crypto-js/src/enc-utf16.js \
    crypto-js/src/evpkdf.js \
    crypto-js/src/evpkdf.js \
    crypto-js/src/format-hex.js \
    crypto-js/src/format-hex.js \
    crypto-js/src/hmac.js \
    crypto-js/src/hmac.js \
    crypto-js/src/lib-typedarrays.js \
    crypto-js/src/lib-typedarrays.js \
    crypto-js/src/md5.js \
    crypto-js/src/md5.js \
    crypto-js/src/mode-cfb.js \
    crypto-js/src/mode-cfb.js \
    crypto-js/src/mode-ctr-gladman.js \
    crypto-js/src/mode-ctr-gladman.js \
    crypto-js/src/mode-ctr.js \
    crypto-js/src/mode-ctr.js \
    crypto-js/src/mode-ecb.js \
    crypto-js/src/mode-ecb.js \
    crypto-js/src/mode-ofb.js \
    crypto-js/src/mode-ofb.js \
    crypto-js/src/pad-ansix923.js \
    crypto-js/src/pad-ansix923.js \
    crypto-js/src/pad-iso10126.js \
    crypto-js/src/pad-iso10126.js \
    crypto-js/src/pad-iso97971.js \
    crypto-js/src/pad-iso97971.js \
    crypto-js/src/pad-nopadding.js \
    crypto-js/src/pad-nopadding.js \
    crypto-js/src/pad-zeropadding.js \
    crypto-js/src/pad-zeropadding.js \
    crypto-js/src/pbkdf2.js \
    crypto-js/src/pbkdf2.js \
    crypto-js/src/rabbit-legacy.js \
    crypto-js/src/rabbit-legacy.js \
    crypto-js/src/rabbit.js \
    crypto-js/src/rabbit.js \
    crypto-js/src/rc4.js \
    crypto-js/src/rc4.js \
    crypto-js/src/ripemd160.js \
    crypto-js/src/ripemd160.js \
    crypto-js/src/sha1.js \
    crypto-js/src/sha1.js \
    crypto-js/src/sha224.js \
    crypto-js/src/sha224.js \
    crypto-js/src/sha256.js \
    crypto-js/src/sha256.js \
    crypto-js/src/sha3.js \
    crypto-js/src/sha3.js \
    crypto-js/src/sha384.js \
    crypto-js/src/sha384.js \
    crypto-js/src/sha512.js \
    crypto-js/src/sha512.js \
    crypto-js/src/tripledes.js \
    crypto-js/src/tripledes.js \
    crypto-js/src/x64-core.js \
    crypto-js/src/x64-core.js
