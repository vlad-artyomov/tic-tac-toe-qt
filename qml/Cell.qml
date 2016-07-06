import QtQuick 2.3
import QtMultimedia 5.0

Rectangle {
    property string val: ""
    property string innerColor: ""

    id: place
    width: (flick.contentWidth - (field.rows + 1) * field.spacing) / field.rows //(container.width-(field.rows+1)*field.spacing)/field.rows
    height: width
    enabled: if (window.paused == false) true; else false
    color: window.colorEmptyCell
    radius: 3

    Rectangle {
        id: cell
        width: 0
        height: this.width
        anchors.centerIn: parent
        radius: 3
        color: place.innerColor

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        ParallelAnimation {
            id: cellAnim
            running: false;
            NumberAnimation { target: cell; property: "width"; to: place.width; duration: 200 }
            NumberAnimation { target: text; property: "font.pixelSize"; to: place.width*0.65; duration: 200 }
            onStopped: {
                cell.width = Qt.binding(function() { return place.width; });
                text.font.pixelSize = Qt.binding(function() { return place.width * 0.65; });
            }
        }

        ParallelAnimation {
            id: clearAnim
            running: false;
            NumberAnimation { target: cell; property: "width"; to: 0; duration: 200 }
            NumberAnimation { target: text; property: "font.pixelSize"; to: 0; duration: 200 }
            onStopped: {
                val = "";
                place.innerColor = window.colorEmptyCell;
                cell.width = 0;
                cell.width = Qt.binding(function() { return 0; });
                text.font.pixelSize = Qt.binding(function() { return 1; });
            }
        }

        Text {
            id: text
            anchors.centerIn: parent

            // Android & Mac OS & Windows
            anchors.horizontalCenterOffset: 0
            anchors.verticalCenterOffset: 0
            // Android & Mac OS & Windows

//                // iPad & iPad Retina
//                anchors.horizontalCenterOffset: 0
//                anchors.verticalCenterOffset: 5
//                // iPad & iPad Retina

//                // iPhone & iPhone Retina
//                anchors.horizontalCenterOffset: 0
//                anchors.verticalCenterOffset: 2
//                // iPhone & iPhone Retina

            color: window.colorTextCell
            text: place.val //index
            font.family: roboto.name
            font.bold: true
            font.pixelSize: 1;
        }

//            AnimatedImage {
//                id: bang;
//                anchors.centerIn: parent
//                anchors.fill: parent
//                source: "qrc:/images/bigbang.gif"
//                visible: false
//                playing: false
//            }

//            SoundEffect {
//                id: playSound
//                source: "qrc:/images/explosion.wav"
//            }

//            Timer {
//                id: timer
//                interval: 1300;
//                running: true;
//                onTriggered:  {
//                    bang.playing = false;
//                    bang.visible = false;
//                }
//            }
    }

    function clearCell() {
        clearAnim.start();
    }

    function positionX() {
        var x = index;
        while (x >= field.size) {
            x -= field.size;
        }

        return x;
    }

    function positionY() {
        var y = index;
        y = y/field.size;
        Math.ceil(y);
        return y;
    }

    function drawCross() {
        place.innerColor = window.colorCross;
        place.val = "X";
        cellAnim.start();
//        bang.visible = true;
//        bang.playing = true;
//        playSound.play();
//        timer.start();
    }

    function drawZero() {
        place.val = "O"
        place.innerColor = window.colorZero;
        cellAnim.start();
//        bang.visible = true;
//        bang.playing = true;
//        playSound.play();
//        timer.start();
    }

    MouseArea {
        id: mArea
        anchors.fill: parent
        onClicked: {
            if (place.val == "") {
                Game.move(positionX(), positionY());
            }
        }
    }
}

