QT += core qml quick websockets

TARGET = qml_ipl

TEMPLATE = app

CONFIG   -= app_bundle

SOURCES += main.cpp

RESOURCES += data.qrc

OTHER_FILES += qml/ipl/main.qml

DISTFILES += \
    qml/ipl/ipl.py \
    qml/ipl/admin.qml
