import QtQuick 2.5
import QtQuick.Controls 1.4

Item {
    property string league
    Label {
        text: league
        MouseArea {
            anchors.fill: parent
            onClicked: {
                stackView.pop()
            }
        }
    }

}
