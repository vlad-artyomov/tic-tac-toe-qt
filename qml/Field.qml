import QtQuick 2.3

Grid {
    property int size
    property int space: window.width >= window.height*0.8 ? window.height*0.75/200 : window.width*0.9/200;
    anchors.centerIn: parent
    rows: size;
    columns: size;
    spacing: if (size < 10) 1 + 2*space; else 1 + space

    function drawFigure(sign, position) {
        //Cross
        if (sign === true) {
            repeater.itemAt(position).drawCross();
        }
        //Zero
        else {
            repeater.itemAt(position).drawZero();
        }
    }

    function showWinner(positions, winnerName) {
        var i;

        for(i=0; i<positions.length; i++) {
            repeater.itemAt(positions[i]).innerColor = window.colorWinner;
        }

        var newObject = Qt.createQmlObject(' Result {
            time: 2000
        }', window);
        newObject.text = winnerName;
    }

    function restoreField() {
        var i;

        for(i=0; i<repeater.count; i++) {
            if (repeater.itemAt(i).val === "X") {
                repeater.itemAt(i).innerColor = window.colorCross;
            }
            else {
                repeater.itemAt(i).innerColor = window.colorZero;
            }
        }
    }
}
