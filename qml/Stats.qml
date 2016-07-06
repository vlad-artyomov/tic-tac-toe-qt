import QtQuick 2.3
import QtGraphicalEffects 1.0

Rectangle {
    color: "transparent"
    enabled: if (window.paused == false) true; else false

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: menuButton.right
        anchors.leftMargin: parent.width/25
        id: x
        color: window.colorStats
        font.family: roboto.name
        font.bold: true
        font.pixelSize: parent.height*0.6
        text: "X"
    }

    Text {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -2
        id: statsText
        color: window.colorStats
        font.family: roboto.name
        font.bold: true
        font.pixelSize: {
            if (text.length == 3) parent.height*0.6;
            if (text.length == 4) parent.height*0.55;
            if (text.length == 5) parent.height*0.5;
            if (text.length > 5) parent.height*0.4;
        }
        text: "0:0"
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: restart.left
        anchors.rightMargin: parent.width/25
        id: o
        color: window.colorStats
        font.family: roboto.name
        font.bold: true
        font.pixelSize: parent.height*0.6
        text: "O"
    }

    MenuButton {
        id: restart
        width: parent.height
        height: this.width
        anchors.right: parent.right
        property int i;

        Image {
            id: restartImage
            anchors.centerIn: parent
            width: parent.width/2
            height: parent.height/2
            rotation: 90
            source: {
                if (width <= 32) "qrc:/images/restart32.png";
                else if (width > 32 && width <= 64) "qrc:/images/restart64.png";
                else if (width > 64 && width <= 128) "qrc:/images/restart128.png";
                else if (width > 128 && width <= 256) "qrc:/images/restart256.png";
                else "qrc:/images/restart512.png"
            }
            smooth: true
        }

        ColorOverlay {
            anchors.fill: restartImage
            source: restartImage
            rotation: restartImage.rotation
            color: window.colorTextLight
        }

        onClicked: {
            Game.restart();
        }
    }

    MenuButton {
        id: menuButton
        width: parent.height
        height: width
        anchors.left: parent.left

        Image {
            id: menuImage
            width: parent.width/2.5
            height: parent.height/2.5
            anchors.centerIn: parent
            source: {
                if (width <= 32) "qrc:/images/menu32.png";
                else if (width > 32 && width <= 64) "qrc:/images/menu64.png";
                else if (width > 64 && width <= 128) "qrc:/images/menu128.png";
                else if (width > 128 && width <= 256) "qrc:/images/menu256.png";
                else "menu512.png"
            }
        }

        ColorOverlay {
            anchors.fill: menuImage
            source: menuImage
            color: window.colorTextLight
        }

        onClicked: {
            window.paused = true;
            window.enabled = false;
            menuLoader.source = "MyMenu.qml";
        }
    }

    Timer {
        id: firstMoveTimer
        interval: 400
        running: false
        onTriggered: {
            Game.doAImove();
            window.enabled = true;
        }
    }

    function restart() {
        window.enabled = false;
        var i;
        for(i = 0; i < repeater.model; i++) {
            repeater.itemAt(i).clearCell();
        }
        firstMoveTimer.start()
    }

    function updateStats(winX, winO) {
        statsText.text = winX + ":" + winO;
    }
}
