import QtQuick
import qs.theme
import qs.state

Item {
    id: root

    property bool showDate: false

    implicitWidth: BarState.vertical ? 36 : row.implicitWidth + 12
    implicitHeight: BarState.vertical ? col.implicitHeight + 10 : 36

    component AmpmPill: Rectangle {
        width: BarState.vertical ? 26 : 28
        height: BarState.vertical ? 14 : 16
        radius: height / 2
        color: Qt.alpha(Colors.accent, 0.28)

        Text {
            anchors.centerIn: parent
            text: Time.ampm
            color: Colors.accent
            font.family: Colors.fontFamily
            font.pixelSize: BarState.vertical ? 8 : 9
            font.weight: Font.DemiBold
            font.capitalization: Font.AllUppercase
        }
    }

    Column {
        id: col
        visible: BarState.vertical
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.showDate ? Time.month : Time.weekday
            color: Colors.color8
            font.family: Colors.fontFamily
            font.pixelSize: 9
            font.capitalization: Font.AllUppercase
            horizontalAlignment: Text.AlignHCenter
        }

        Column {
            visible: !root.showDate
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Time.hour
                color: Colors.foreground
                font.family: Colors.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Time.minute
                color: Colors.foreground
                font.family: Colors.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Text {
            visible: root.showDate
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.day
            color: Colors.foreground
            font.family: Colors.fontFamily
            font.pixelSize: 14
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
        }

        AmpmPill {
            visible: !root.showDate
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Row {
        id: row
        visible: !BarState.vertical
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.showDate ? Time.altHorizontal : Time.weekday
            color: Colors.color8
            font.family: Colors.fontFamily
            font.pixelSize: 12
            font.capitalization: Font.AllUppercase
        }

        Text {
            visible: !root.showDate
            anchors.verticalCenter: parent.verticalCenter
            text: `${Time.hour}:${Time.minute}`
            color: Colors.foreground
            font.family: Colors.fontFamily
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        AmpmPill {
            visible: !root.showDate
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: BarState.pointerEntered()
        onExited: BarState.pointerLeft()
        onClicked: root.showDate = !root.showDate
    }
}
