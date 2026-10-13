import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.theme
import qs.state

Item {
    id: root

    readonly property var occupied: {
        const ids = {};
        for (const ws of Hyprland.workspaces.values) {
            if (ws.id <= 0)
                continue;
            const windows = ws.lastIpcObject?.windows;
            ids[ws.id] = windows === undefined ? true : windows > 0;
        }
        return ids;
    }

    readonly property var wsIds: {
        let max = 5;
        for (const ws of Hyprland.workspaces.values) {
            if (ws.id > 0)
                max = Math.max(max, ws.id);
        }
        const out = [];
        for (let i = 1; i <= max; i++)
            out.push(i);
        return out;
    }

    readonly property int activeId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property int count: wsIds.length

    implicitWidth: BarState.vertical ? 36 : grid.implicitWidth
    implicitHeight: BarState.vertical ? grid.implicitHeight : 36

    function switchTo(id: int): void {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${id} })`);
    }

    Grid {
        id: grid
        anchors.centerIn: parent
        rows: BarState.vertical ? root.count : 1
        columns: BarState.vertical ? 1 : root.count
        rowSpacing: 4
        columnSpacing: 6

        Repeater {
            model: root.wsIds

            Item {
                id: btn
                required property var modelData
                readonly property int wsId: Number(modelData)
                readonly property bool focused: root.activeId === wsId
                readonly property bool exists: !!root.occupied[wsId]

                implicitWidth: 26
                implicitHeight: 26
                width: 26
                height: 26

                Rectangle {
                    anchors.fill: parent
                    radius: 13
                    color: btn.focused ? Colors.accent : (btn.exists ? Qt.alpha(Colors.foreground, 0.16) : "transparent")
                    border.width: btn.focused || btn.exists ? 0 : 1
                    border.color: Qt.alpha(Colors.foreground, 0.32)
                }

                Text {
                    anchors.centerIn: parent
                    text: `${btn.wsId}`
                    color: btn.focused ? Colors.background : (btn.exists ? Colors.foreground : Colors.color8)
                    font.family: Colors.fontFamily
                    font.pixelSize: 11
                    font.weight: btn.focused ? Font.DemiBold : Font.Normal
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: BarState.pointerEntered()
                    onExited: BarState.pointerLeft()
                    onClicked: root.switchTo(btn.wsId)
                }
            }
        }
    }
}
