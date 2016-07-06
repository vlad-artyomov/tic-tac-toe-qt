import QtQuick 2.3

Rectangle {
    color: window.colorControl;
    radius: 6
    border.width: window.borderWidth
    border.color: window.colorBorder

    Text {
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: window.colorTextDark
        font.family: roboto.name
        font.bold: true
        font.pixelSize: parent.height/8
        text: window.emptyString + qsTr("Владислав Артёмов\nДонНТУ\n") + new Date().getFullYear().toString()
    }
}
