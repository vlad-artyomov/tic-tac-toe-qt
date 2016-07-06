import QtQuick 2.3

Rectangle {
    property bool checked: false
    signal check
    signal uncheck

    id: background
    color: window.colorEmptyCell;
    radius: 100
    border.width: 2
    border.color: window.colorBorder

    states: [
        State {
            name: "true";
            PropertyChanges { target: thumb; anchors.horizontalCenterOffset: thumb.width/2}
            PropertyChanges { target: background; color: window.colorActiveControl; }
        },
        State {
            name: "false"
            PropertyChanges { target: thumb; anchors.horizontalCenterOffset: -thumb.width/2}
            PropertyChanges { target: background; color: window.colorEmptyCell; }
        }
    ]

    transitions: Transition {
        PropertyAnimation {
            properties: "anchors.horizontalCenterOffset";
            easing.type: Easing.OutBack;
            duration: 500
        }
        PropertyAnimation {
            properties: "color";
            duration: 250
        }
    }

    Rectangle {
        id: thumb
        height: parent.height
        width: parent.width/2
        radius: 100
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -width/2
        color: window.colorThumb
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            if (parent.checked) {
                background.checked = false
                thumb.state = "false"
                parent.uncheck();
            }
            else {
                background.checked = true
                thumb.state = "true"
                parent.check();
            }
        }
    }
}
