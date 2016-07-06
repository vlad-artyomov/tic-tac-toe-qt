import QtQuick 2.3

Rectangle {
    property string text
    property int fontSize
    property int time

    id: messagebox
    color: window.colorControl;
    radius: 6
    border.width: window.borderWidth
    border.color: window.colorButton
    anchors.centerIn: parent

    Behavior on opacity {
        NumberAnimation {
                duration: 200
        }
    }

    PropertyAnimation { id: animation; target: messagebox; property: "opacity"; from: 0; to: 1; duration: 200; running: true }

    Timer {
        id: destroyerTimer
        interval: time;
        running: true;
        onTriggered:  {
            parent.opacity = 0;
            messagebox.destroy(201)
        }
    }

    Text {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        id: buttonText
        color: window.colorTextDark
        font.family: roboto.name
        font.bold: true
        font.pointSize: fontSize-2;
        text: messagebox.text
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            parent.opacity = 0;
            messagebox.destroy(201)
        }
    }
}
