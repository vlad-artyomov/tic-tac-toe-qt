import QtQuick 2.3

Rectangle {
    property string text
    signal clicked

    color: {
        if (mArea.pressed) window.colorActiveControl;
        else window.colorButton;
    }

    radius: 6
    border.width: window.borderWidth
    border.color: window.colorBorder


    MouseArea {
        id: mArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            parent.clicked();
        }
    }

    Text {
        anchors.centerIn: parent
        color: window.colorTextLight
        font.family: roboto.name
        font.weight: Font.Bold
        font.pixelSize: parent.height*0.45;
        text: parent.text
    }
}
