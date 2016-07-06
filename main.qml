import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import Qt.labs.settings 1.0
import "qrc:/qml"

Window {
    id: mainWindow
    visibility: Window.Maximized
    visible: true
//    width: 800  //PC only
//    height: 600 //PC only
    minimumWidth: 240
    minimumHeight: 320
    title: window.emptyString + qsTr("Крестики-нолики")

    FontLoader { id: roboto; source: "qrc:/images/Roboto-Medium.ttf" }

    Rectangle {
        id: window
        objectName: "window"
        anchors.fill: parent
        color: colorWindow

        property bool running: false
        property bool paused: true

        property int spacingUI: {
            if (window.height <= 800) 10;
            else 20;
        }

        Keys.onReleased: {
            if (event.key === Qt.Key_Back) {
                window.paused = true;
                window.enabled = false;
                menuLoader.source = "qrc:/qml/MyMenu.qml";
                event.accepted = true
                focus = false
            }
        }

//        MenuButton {
//            id: test
//            width: 80
//            height: width/3
//            anchors.top: parent.top
//            anchors.left: parent.left
//            anchors.margins: 5
//            border.width: 0
//            text: "Тест"
//            onClicked: {
//                Game.aiBattleStart(time.value);
//            }
//        }

//        Slider {
//            id: time
//            width: test.width
//            height: width/3
//            anchors.top: test.bottom
//            anchors.left: parent.left
//            anchors.margins: 5
//            minimumValue: 100
//            maximumValue: 1000
//            value: 550
//        }

        Stats {
            id: stats
            objectName: "stats"
            height: container.height/5
            width: container.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: window.top
            anchors.topMargin: (window.height - this.height - 2*window.spacingUI - container.height)/2;
        }

        Rectangle {
            id: container
            objectName: "container"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: stats.bottom
            anchors.topMargin: 2*window.spacingUI
            color: window.colorContainer
            radius: 3
            clip: true

            height: {
                if (window.width >= window.height*0.8)  {
                    height: window.height*0.75;
                }
                else {
                    height: window.width*0.9;
                }
            }
            width: this.height

            Behavior on height {
                NumberAnimation {
                        duration: 200
                }
            }

            Flickable {
                id: flick
                anchors.fill: parent
                contentWidth: parent.width
                contentHeight: parent.height
                boundsBehavior: Flickable.StopAtBounds

                function resetFieldView() {
                    flick.contentWidth = Qt.binding(function() { return parent.width; });
                    flick.contentHeight = Qt.binding(function() { return parent.height; });
                    flick.interactive = true
                    flick.returnToBounds()
                }

                PinchArea {
                    width: Math.max(flick.contentWidth, flick.width)
                    height: Math.max(flick.contentHeight, flick.height)

                    property real initialWidth
                    property real initialHeight
                    onPinchStarted: {
                        flick.interactive = false
                        initialWidth = flick.contentWidth
                        initialHeight = flick.contentHeight
                    }

                    onPinchUpdated: {
                        // adjust content pos due to drag
                        flick.contentX += pinch.previousCenter.x - pinch.center.x
                        flick.contentY += pinch.previousCenter.y - pinch.center.y

                        // resize content
                        if (initialWidth * pinch.scale >= container.width && initialWidth * pinch.scale <= container.width*3) {
                            flick.resizeContent(initialWidth * pinch.scale, initialHeight * pinch.scale, pinch.center)
                        }
                        if (initialWidth * pinch.scale < container.width) {
                            flick.resizeContent(container.width, container.height, pinch.center)
                        }
                    }

                    onPinchFinished: {
                        // Move its content within bounds.
                        flick.interactive = true
                        flick.returnToBounds()
                    }

                    Field {
                        id: field
                        objectName: "field"
                        size: 5
                        Repeater {
                            id: repeater
                            objectName: "repeater"
                            model: field.size*field.size
                            signal cellChanged(int index)
                            Cell {
                                id: cell
                                objectName: "cell"
                            }
                        }
                    }
                }
            }
        }

        Loader {
            id: menuLoader
            anchors.centerIn: parent
            source: "qrc:/qml/MyMenu.qml"
        }

        //Cache while loading
        Result {
            time: 1
            rad: 10
        }

        Intro {
            id: introLaunch
            width: window.width
            height: window.height
            anchors.horizontalCenter: window.horizontalCenter
            anchors.verticalCenter: window.verticalCenter

            states: [
                State {
                    name: "goAway"
                    PropertyChanges {
                        target: introLaunch;
                        anchors.verticalCenterOffset: window.height
                    }
                }
            ]

            transitions: [
                Transition {
                    PropertyAnimation {
                        properties: "anchors.verticalCenterOffset";
                        easing.type: Easing.OutCubic;
                        duration: 500
                    }
                }
            ]
        }

        property double difficulty
        property bool aiGoFirst
        property string emptyString
        property string language
        property int fieldSize;
        property string theme;
        property int borderWidth: {
            if (window.height <= 400) 1;
            else if (window.height > 400 && window.height <= 640) 2;
            else if (window.height > 640 && window.height <= 960) 3;
            else if (window.height > 960 &&  window.height <= 1440) 4;
            else 5;
        }

        property string colorWindow
        property string colorContainer
        property string colorControl
        property string colorBorder
        property string colorTextLight
        property string colorTextDark
        property string colorButton
        property string colorTextCopyright
        property string colorButtonPressed
        property string colorResultBox
        property string colorActiveControl
        property string colorEmptyCell
        property string colorZero
        property string colorCross
        property string colorWinner
        property string colorTextCell
        property string colorStats
        property string colorThumb

        function setThemeDefault() {
            colorWindow = "#faf8ef"
            colorContainer = "#bcada0"
            colorControl = "#eee4da"
            colorBorder = colorWindow
            colorResultBox = "#edc53f"
            colorStats = colorContainer

            colorZero = "#f2b179"
            colorCross = colorControl
            colorWinner = "#f66b3b" //"#f65e3b"

            colorTextDark = "#776e65"
            colorTextCopyright = "#bbada0"
            colorTextLight = colorWindow
            colorTextCell = colorTextDark

            colorButton = "#f59563"
            colorActiveControl = "#f65e3b"
            colorEmptyCell = "#ccc0b3"
            colorThumb = colorWindow

            theme = "2048"
        }

        function setThemeDarkside() {
            colorWindow = "#191919"
            colorContainer = "#424242"
            colorEmptyCell = "#616161"
            colorBorder = "#00bbd3"
            colorResultBox = "#edc53f"
            colorStats = "#eeeeee"

            colorZero = "#E7EDED" //"#DF740C"
            colorCross = "#6FC3DF"
            colorWinner = colorResultBox

            colorTextDark = "#666666"
            colorTextCopyright = "#9e9e9e"
            colorTextLight = "#eeeeee"
            colorTextCell = colorEmptyCell

            colorButton = "#394249"
            colorActiveControl = "#00bcd4"
            colorControl = "#e3e3e3"
            colorThumb = colorTextLight

            theme = "Dark side"
        }

        function setThemeHabrahabr() {
            colorWindow = "#fafafa"
            colorContainer = "#9e9e9e"
            colorEmptyCell = "#adadad"
            colorBorder = colorWindow
            colorResultBox = "#edc53f"
            colorStats = colorContainer

            colorZero = "#8e6d61"
            colorCross = "#84b1c1"
            colorWinner = colorResultBox

            colorTextDark = "#666666"
            colorTextCopyright = "#9e9e9e"
            colorTextLight = "#fdfefe"
            colorTextCell = "#fdfefe"

            colorButton = "#95bbc8"
            colorActiveControl = "#8eaab4"
            colorControl = "#eeeeee"
            colorThumb = colorWindow

            theme = "Habrahabr"
        }
    }
}
