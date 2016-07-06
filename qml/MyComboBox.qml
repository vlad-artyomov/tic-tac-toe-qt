import QtQuick 2.3
import QtGraphicalEffects 1.0

Rectangle {
    id: comboBox
    property variant items //: ["3x3 (3 в ряд)", "5x5 (4 в ряд)", "10x10 (5 в ряд)", "15x15 (5 в ряд)"]
    property alias selectedItem: chosenItemText.text;
    property alias selectedIndex: listView.currentIndex;
    signal comboClicked;

    anchors.horizontalCenter: parent.horizontalCenter
    width: 3*btnContainerSize/4
    height: buttonHeight
    color: window.colorControl;
    radius: 6
    border.width: window.borderWidth
    border.color: window.colorBorder
    smooth: true;

    Rectangle {
        id:chosenItem
        radius:4;
        width: parent.width;
        height: parent.height;
        color: "transparent"
        smooth: true;

        Text {
            anchors.centerIn: parent
            anchors.margins: 8;
            id: chosenItemText
            text: items[listView.currentIndex] //field.size.toString() + "x" + field.size.toString();
            font.family: roboto.name
            color: window.colorTextDark
            font.pixelSize: parent.height*0.4;
        }

        Image {
            id: arrowImage
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: height
            height: parent.height/3
            width: height
            rotation: 0
            source: "qrc:/images/arrow.png"
        }

        ColorOverlay {
            anchors.fill: arrowImage
            source: arrowImage
            rotation: arrowImage.rotation
            color: window.colorTextDark
        }

        MouseArea {
            anchors.fill: parent;
            onClicked: {
                comboBox.state = comboBox.state==="dropDown"?"":"dropDown"
            }
        }
    }

    Rectangle {
        id:dropDown
        width: comboBox.width;
        height: 0
        clip:true;
        anchors.top: chosenItem.bottom;
        anchors.margins: 2;
        color: window.colorControl;
        radius: 6
        border.width: window.borderWidth
        border.color: window.colorBorder

        ListView {
            id:listView
            model: comboBox.items
            height: comboBox.items.length*comboBox.height*1.2;
            currentIndex: 0
            delegate: Item {
                width: comboBox.width;
                height: comboBox.height*1.2;


                Text {
                    text: modelData
                    anchors.centerIn: parent
                    anchors.margins: 5;
                    font.family: roboto.name
                    font.pixelSize: buttonHeight/3;
                    color: if (marea.pressed === true) window.colorActiveControl; else window.colorTextDark
                }

                MouseArea {
                    id: marea
                    anchors.fill: parent;
                    onClicked: {
                        comboBox.state = ""
                        var prevSelection = chosenItemText.text
                        chosenItemText.text = modelData
                        if(chosenItemText.text != prevSelection){
                            listView.currentIndex = index;
                            comboBox.comboClicked();
                        }
                    }
                }
            }
        }
    }

    states: State {
        name: "dropDown";
        PropertyChanges { target: dropDown; height:comboBox.height*1.2*comboBox.items.length }
        PropertyChanges { target: arrowImage; rotation: 180 }
    }

    transitions: Transition {
        NumberAnimation { target: dropDown; properties: "height"; easing.type: Easing.OutExpo; duration: 500 }
        NumberAnimation { properties: "rotation"; easing.type: Easing.OutExpo; duration: 500 }
    }
}
