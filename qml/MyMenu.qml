import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Item {
    property double btnContainerSize: {
        if (window.width >= window.height*0.8)  {
            window.height*0.8;
        }
        else {
            window.width;
        }
    }
    property int space: {
        if (window.height <= 400) 12;
        else if (window.height > 400 && window.height <= 640) 18;
        else if (window.height > 640 && window.height <= 960) 24;
        else if (window.height > 960 &&  window.height <= 1440) 36;
        else 42;
    }
    property int buttonHeight: btnContainerSize/7

    id: menu
    width: window.width
    height: window.height

    Rectangle {
        id: background
        anchors.fill: parent
        color: window.colorContainer
        opacity: 0.9
    }

    ParallelAnimation {
        running: if (window.running === true) true; else false;
        NumberAnimation { target: menu; property: "opacity"; from: 0; to: 1; duration: 400 }
        NumberAnimation { target: menu; property: "height"; from: 0; to: window.height; duration: 300 }
        onStopped: window.enabled = true;
    }

    Timer {
        id: menuHide
        interval: 500;
        running: false;
        onTriggered: {
            if (window.running === false) window.running = true;
            menu.state = "base state";
            menuLoader.source = "";
            window.enabled = true;
            window.focus = true
        }
    }

    states: [
        State {
            name: "gameMode"
            PropertyChanges {
                target: maincol;
                anchors.verticalCenterOffset: window.height
            }
            PropertyChanges {
                target: gameMode;
                anchors.verticalCenterOffset: 0
            }
        },

        State {
            name: "options"
            PropertyChanges {
                target: maincol;
                anchors.horizontalCenterOffset: -1.5*window.width
            }
            PropertyChanges {
                target: options;
                anchors.horizontalCenterOffset: 0
            }
        },

        State {
            name: "about"
            PropertyChanges {
                target: maincol;
                anchors.horizontalCenterOffset: -1.5*window.width
            }
            PropertyChanges {
                target: about;
                anchors.horizontalCenterOffset: 0
            }
        },

        State {
            name: "away"
            PropertyChanges {
                target: menu;
                height: 0;
                opacity: 0;
            }
            PropertyChanges {
                target: maincol;
                anchors.verticalCenterOffset: window.height
                opacity: 0
            }
            PropertyChanges {
                target: gameMode;
                anchors.verticalCenterOffset: 0
                opacity: 0
            }
        },

        State {
            name: "away1"
            PropertyChanges {
                target: menu;
                height: 0;
                opacity: 0;
            }
            PropertyChanges {
                target: maincol;
                anchors.verticalCenterOffset: 0
                opacity: 0
            }
            PropertyChanges {
                target: gameMode;
                anchors.verticalCenterOffset: -window.height
                opacity: 0
            }
        }
    ]

    transitions: Transition {
        PropertyAnimation {
            properties: "anchors.horizontalCenterOffset";
            easing.type: Easing.OutCubic;
            duration: 500
        }

        PropertyAnimation {
            properties: "anchors.verticalCenterOffset";
            easing.type: Easing.OutCubic;
            duration: 500
        }
        PropertyAnimation {
            properties: "height";
            easing.type: Easing.OutCubic;
            duration: 400
        }
        PropertyAnimation {
            properties: "opacity";
            easing.type: Easing.OutCubic;
            duration: 500
        }
    }

    Column {
        id: maincol
        spacing: space
        anchors.centerIn: parent

        Behavior on opacity {
            NumberAnimation {
                    duration: 200
            }
        }

        MenuButton {
            width: 3*btnContainerSize/4
            height: buttonHeight
            text: window.emptyString + qsTr("Продолжить");
            visible: if (window.running === false) false; else true
            onClicked: {
                Game.setDifficulty(slider.value);
                window.paused = false;
                window.enabled = false;
                menu.state = "away1";
                menuHide.start();
            }
        }

        MenuButton {
            width: 3*btnContainerSize/4
            height: buttonHeight
            text: window.emptyString + qsTr("Новая игра")
            onClicked: {
                menu.state = "gameMode"
            }
        }

        MenuButton {
            width: 3*btnContainerSize/4
            height: buttonHeight
            text: window.emptyString + qsTr("Настройки")
            onClicked: {
                onClicked: menu.state = "options";
            }
        }

        MenuButton {
            width: 3*btnContainerSize/4
            height: buttonHeight
            text: window.emptyString + qsTr("Об авторе")
            onClicked: {
                menu.state = "about";
            }
        }

        MenuButton {
            width: 3*btnContainerSize/4
            height: buttonHeight
            text: window.emptyString + qsTr("Выход")
            onClicked: Qt.quit()
        }
    }

    Column {
        id: gameMode
        spacing: space
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -window.height

        Behavior on opacity {
            NumberAnimation {
                    duration: 200
            }
        }

        MenuButton {
            width: 3*btnContainerSize/4
            height: buttonHeight
            text: window.emptyString + qsTr("Против компьютера")
            onClicked: {
                //menu.opacity = 0;
                window.paused = false;
                window.enabled = false;
                menu.state = "away";
                menuHide.start();
                Game.setDifficulty(slider.value);
                Game.setAImode(true);
                Game.start();
            }
        }

        MenuButton {
            width: 3*btnContainerSize/4
            height: buttonHeight
            text: window.emptyString + qsTr("Два игрока")
            onClicked: {
                //menu.opacity = 0;
                window.paused = false;
                window.enabled = false;
                menu.state = "away";
                menuHide.start();
                Game.setDifficulty(slider.value);
                Game.setAImode(false);
                Game.start();
            }
        }

        MenuButton {
            width: 3*btnContainerSize/4
            height: buttonHeight
            text: window.emptyString + qsTr("Назад")
            onClicked: {
                menu.state = "base state";
            }
        }
    }

    Flickable {
        id: options
        contentHeight: window.height - 2*space
        contentWidth: optionsColumn.width
        height: window.height - 2*space
        width: optionsColumn.width
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 1.5*window.width
        anchors.verticalCenterOffset: 0
        clip: true

        states: [
            State {
                name: "open"
                PropertyChanges {
                    target: themeText;
                    visible: true
                }
                PropertyChanges {
                    target: themeComboBox;
                    visible: true
                }
                PropertyChanges {
                    target: langText;
                    visible: true
                }
                PropertyChanges {
                    target: langComboBox;
                    visible: true
                }
                PropertyChanges {
                    target: dots;
                    visible: false
                }
                PropertyChanges {
                    target: options;
                    contentHeight: optionsColumn.height + 3*comboBox.height + space
                    contentY: {
                        if (contentHeight > height) {
                            contentHeight - height
                        }
                        else {
                            0
                        }
                    }
                }
            }
        ]

        Behavior on contentY { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

        Column {
            id: optionsColumn
            spacing: space/1.5
            anchors.centerIn: parent

            Text {
                id: label
                anchors.horizontalCenter: parent.horizontalCenter
                color: window.colorTextLight
                font.family: roboto.name
                font.bold: true
                font.pixelSize: comboBox.height/2;
                text: "<b> - " + window.emptyString + qsTr("Размер поля") + " - </b>"
                //anchors.verticalCenter: comboBox.verticalCenter
            }

            MyComboBox {
                id: comboBox
                items: ["3x3 (3 " + window.emptyString + qsTr("в ряд") + ")",
                        "5x5 (4 " + window.emptyString + qsTr("в ряд") + ")",
                        "10x10 (5 " + window.emptyString + qsTr("в ряд") + ")",
                        "15x15 (5 " + window.emptyString + qsTr("в ряд") + ")"]
                selectedIndex: {
                    if (window.fieldSize === 3) 0
                    else if (window.fieldSize === 5) 1
                    else if (window.fieldSize === 10) 2
                    else 3
                }

                z: 30
                onComboClicked: {
                    field.size = parseInt(selectedItem);
                    flick.resetFieldView();
                    Game.setFieldSize(field.size);
                    Game.restart();
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: window.colorTextLight
                font.family: roboto.name
                font.bold: true
                font.pixelSize: comboBox.height/2;
                text: "<b> - " + window.emptyString + qsTr("Сложность") + " - </b>"
            }

            Rectangle {
                width: 3*btnContainerSize/4
                height: buttonHeight
                color: window.colorControl;
                radius: 6
                border.width: window.borderWidth
                border.color: window.colorBorder

                Slider {
                    id: slider
                    anchors.centerIn: parent
                    width: btnContainerSize*0.6
                    height: parent.height/2
                    minimumValue: 0
                    maximumValue: 1
                    value: window.difficulty
                    onValueChanged: {
                        window.difficulty = value;
                        if (typeof(Game) != 'undefined') {
                            Game.setDifficulty(value)
                        }
                    }

                    style: SliderStyle {
                        groove:
                            Rectangle {
                            radius: 100
                            width: slider.width
                            height: slider.height/4

                            Rectangle {
                                width: parent.width
                                height: parent.height
                                radius: parent.radius
                                color: window.colorEmptyCell
                            }

                            Rectangle {
                                height: parent.height
                                radius: parent.radius
                                width: styleData.handlePosition
                                color: window.colorActiveControl
                            }
                        }

                        handle: Rectangle {
                            id: thumb
                            color: control.pressed ? window.colorActiveControl : window.colorThumb
                            height: slider.height
                            width: height
                            radius: 100
                            border.width: 1
                            border.color: control.pressed ? window.colorActiveControl : window.colorEmptyCell
                        }
                    }
                }
            }

            Text {
                id: firstMoveText
                anchors.horizontalCenter: parent.horizontalCenter
                color: window.colorTextLight
                font.family: roboto.name
                font.bold: true
                font.pixelSize: comboBox.height/2;
                text: "<b> - " + window.emptyString + qsTr("Первый ход") + " - </b>"
                //anchors.verticalCenter: comboBox.verticalCenter
            }

            Rectangle {
                width: 3*btnContainerSize/4
                height: buttonHeight
                color: window.colorControl
                radius: 6
                border.width: window.borderWidth
                border.color: window.colorBorder

                Text {
                    id: firstMove
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: space
                    color: window.colorTextDark
                    font.family: roboto.name
                    font.pixelSize: buttonHeight*0.4;
                    text: window.emptyString + qsTr("Комп. игрок")
                }

                SwitchControl {
                    id: switchFirstMove
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: space
                    height: buttonHeight/2
                    width: height*2
                    checked: window.aiGoFirst
                    state: {
                        if (checked) "true"
                        else "false"
                    }

                    onCheck: {
                        Game.setAIgoFirst(true);
                        window.aiGoFirst = true
                    }
                    onUncheck: {
                        Game.setAIgoFirst(false);
                        window.aiGoFirst = false
                    }
                }
            }

            Rectangle {
                id: dots
                width: 3*btnContainerSize/4
                height: buttonHeight/2
                color: "transparent"

                Row {
                    spacing: space
                    anchors.centerIn: parent
                    Repeater {
                        model: 3
                        Rectangle {
                            width: buttonHeight/4
                            height: width
                            color: window.colorThumb
                            radius: 100
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        options.state = "open"
                    }
                }
            }

            Text {
                id: themeText
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                color: window.colorTextLight
                font.family: roboto.name
                font.bold: true
                font.pixelSize: comboBox.height/2;
                text: "<b> - " + window.emptyString + qsTr("Цветовая тема") + " - </b>"
                //anchors.verticalCenter: comboBox.verticalCenter
            }

            MyComboBox {
                id: themeComboBox
                visible: false
                z: 20
                items: ["Habrahabr", "2048", "Dark side"]
                selectedIndex: {
                    if (window.theme === "Habrahabr") 0
                    else if (window.theme === "2048") 1
                    else 2
                }
                onComboClicked: {
                    if (selectedIndex == 0) window.setThemeHabrahabr()
                    if (selectedIndex == 1) window.setThemeDefault()
                    if (selectedIndex == 2) window.setThemeDarkside()
                    field.restoreField();
                    Game.setTheme(selectedItem);
                }
            }

            Text {
                id: langText
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                color: window.colorTextLight
                font.family: roboto.name
                font.bold: true
                font.pixelSize: comboBox.height/2;
                text: "<b> - " + window.emptyString + qsTr("Язык (Language)") + " - </b>"
                //anchors.verticalCenter: comboBox.verticalCenter
            }

            MyComboBox {
                id: langComboBox
                visible: false
                z: 10
                items: ["Русский", "English"]
                selectedIndex: {
                    if (window.language === "Русский") 0
                    else 1
                }

                onComboClicked: {
                    Translator.changeLanguage(selectedItem.toString());
                }
            }

            MenuButton {
                width: 3*btnContainerSize/4
                height: buttonHeight
                anchors.horizontalCenter: parent.horizontalCenter
                text: window.emptyString + qsTr("Назад")
                onClicked: {
                    options.state = "base state"
                    menu.state = "base state";
                }
            }
        }
    }

    Column {
        id: about
        spacing: space
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 1.5*window.width

        About {
            width: 3*btnContainerSize/4
            height: buttonHeight*3
        }

        MenuButton {
            width: 3*btnContainerSize/4
            height: buttonHeight
            text: window.emptyString + qsTr("Назад")
            onClicked: {
                menu.state = "base state";
            }
        }
    }
}
