import QtQuick 2.3

Rectangle {
    id: intro
    color: window.colorControl

    Text {
        id: introText
        anchors.centerIn: if (parent != null) parent
        text: window.emptyString + qsTr("Крестики-нолики")
        color: window.colorTextDark
        font.family: roboto.name
        font.bold: true
        font.pixelSize: parent.height/20;
    }

    Text {
        id: copyright
        anchors.bottom:if (parent != null) parent.bottom
        anchors.bottomMargin: field.spacing*2
        anchors.horizontalCenter: if (parent != null) parent.horizontalCenter
        text: window.emptyString + qsTr("Владислав Артёмов © ") + new Date().getFullYear().toString()
        color: window.colorTextCopyright
        font.family: roboto.name
        font.bold: true
        font.pixelSize: parent.height/40;
    }

    //Skip intro before timer ends
    MouseArea {
        id: introMouse
        anchors.fill: if (parent != null) parent
        onClicked: {
            goAway();
        }
    }

    Timer {
        id: introTimer
        interval: 2000;
        running: true;
        onTriggered:  {
            if (intro != null) {
                goAway();
            }
        }
    }

    function goAway() {
        introLaunch.state = "goAway";
        introText.destroy(500);
        copyright.destroy(500);
        introMouse.destroy(500);
        intro.destroy(501);
    }
}
