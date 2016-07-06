TEMPLATE = app

QT += qml quick widgets
QT += multimedia

SOURCES += main.cpp \
    cross.cpp \
    field.cpp \
    figure.cpp \
    game.cpp \
    player.cpp \
    translator.cpp \
    zero.cpp

RESOURCES += qml.qrc \
    languages.qrc \
    images.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

RC_ICONS = icon.ico

OTHER_FILES += \
    android/AndroidManifest.xml

HEADERS += \
    cross.h \
    field.h \
    figure.h \
    game.h \
    player.h \
    translator.h \
    zero.h
