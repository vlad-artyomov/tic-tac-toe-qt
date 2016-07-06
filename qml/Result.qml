import QtQuick 2.3
import QtGraphicalEffects 1.0

Item {
    id: resultBox
    property string text
    property int time
    property double transparency: 0.2
    property double rad: if (repeater.itemAt(0).width/2 > 48) 48; else repeater.itemAt(0).width/2
    anchors.fill: window

    FastBlur {
        id: blur
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: container.y
        width: container.width
        height: container.height
        source: container
        radius: rad
    }

    Rectangle {
        id: rectangle
        color: "black" //window.colorContainer //window.colorResultBox;
        radius: container.radius
        opacity: transparency
        anchors.fill: parent

        ParallelAnimation {
            id: show
            running: true;
            NumberAnimation { target: rectangle; property: "opacity"; from: 0; to: transparency; duration: 200; }
            NumberAnimation { target: text; property: "opacity"; from: 0; to: 1; duration: 200; }
            NumberAnimation { target: blur; property: "radius"; from: 0; to: rad; duration: 200; }
        }

        ParallelAnimation {
            id: hide
            running: false;
            NumberAnimation { target: rectangle; property: "opacity"; from: transparency; to: 0; duration: 200; }
            NumberAnimation { target: text; property: "opacity"; from: 1; to: 0; duration: 200; }
            NumberAnimation { target: blur; property: "radius"; from: rad; to: 0; duration: 200; }
        }

        Timer {
            id: destroyerTimer
            interval: time;
            running: true;
            onTriggered:  {
                hide.start();
                Game.restart();
                resultBox.destroy(201);
            }
        }
    }

    Text {
        anchors.centerIn: blur
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        id: text
        color: window.colorTextLight
        font.family: roboto.name
        font.bold: true
        font.pixelSize: container.height/6;
        text: resultBox.text
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            hide.start();
            Game.restart();
            resultBox.destroy(201);
        }
    }
}

