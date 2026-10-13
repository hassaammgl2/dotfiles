import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.theme
import qs.state

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.launcher
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true

            readonly property int cell: 118
            readonly property int colCount: 6
            readonly property var apps: {
                const q = search.text.trim().toLowerCase();
                const all = DesktopEntries.applications.values;
                const out = [];
                for (let i = 0; i < all.length; i++) {
                    const a = all[i];
                    if (a.noDisplay || !a.name)
                        continue;
                    if (!q) {
                        out.push(a);
                        continue;
                    }
                    const keys = (a.keywords || []).join(" ");
                    const blob = `${a.name} ${a.genericName} ${a.comment} ${a.id} ${keys}`.toLowerCase();
                    if (blob.includes(q))
                        out.push(a);
                }
                out.sort((a, b) => a.name.localeCompare(b.name));
                return out;
            }
            readonly property var currentApp: {
                const i = grid.currentIndex;
                if (i >= 0 && i < win.apps.length)
                    return win.apps[i];
                return null;
            }
            property var menuApp: null
            property real menuX: 0
            property real menuY: 0
            readonly property bool menuPinned: menuApp ? DockState.contains(DockState.entryId(menuApp)) : false
            readonly property var menuActions: [
                {
                    "label": "Open",
                    "action": "open",
                    "on": true
                },
                {
                    "label": "Pin to dock",
                    "action": "pin",
                    "on": !menuPinned
                },
                {
                    "label": "Unpin from dock",
                    "action": "unpin",
                    "on": menuPinned
                }
            ]

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            onVisibleChanged: {
                menuApp = null;
                if (visible) {
                    search.text = "";
                    grid.currentIndex = 0;
                    search.forceActiveFocus();
                }
            }

            function launch(entry: var): void {
                if (!entry)
                    return;
                entry.execute();
                OverlayState.close();
            }

            function showMenu(entry: var, tileItem: Item): void {
                if (!entry || !tileItem)
                    return;
                menuApp = entry;
                const pos = tileItem.mapToItem(layer, tileItem.width / 2, tileItem.height + 6);
                menuX = pos.x;
                menuY = pos.y;
            }

            function pinMenu(): void {
                if (!menuApp)
                    return;
                const id = DockState.entryId(menuApp);
                if (id && !DockState.contains(id))
                    DockState.toggle(id);
            }

            function unpinMenu(): void {
                if (!menuApp)
                    return;
                const id = DockState.entryId(menuApp);
                if (id && DockState.contains(id))
                    DockState.toggle(id);
            }

            function launchCurrent(): void {
                win.launch(win.currentApp);
            }

            function moveSel(dx: int, dy: int): void {
                const count = grid.count;
                if (count === 0)
                    return;
                const c = Math.max(1, Math.floor(grid.width / grid.cellWidth));
                let i = grid.currentIndex;
                if (i < 0)
                    i = 0;
                i += dx + dy * c;
                if (i < 0)
                    i = 0;
                if (i > count - 1)
                    i = count - 1;
                grid.currentIndex = i;
            }

            HyprlandFocusGrab {
                active: win.visible
                windows: [win]
                onCleared: OverlayState.close()
            }

            Shortcut {
                sequence: "Escape"
                enabled: win.visible
                onActivated: {
                    if (win.menuApp)
                        win.menuApp = null;
                    else
                        OverlayState.close();
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Colors.background, 0.55)

                MouseArea {
                    anchors.fill: parent
                    onClicked: OverlayState.close()
                }
            }

            Column {
                id: stage
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: 16
                anchors.bottomMargin: 12
                width: win.cell * win.colCount
                spacing: 14
                opacity: win.visible ? 1 : 0
                scale: win.visible ? 1 : 0.96
                transformOrigin: Item.Center

                Behavior on opacity {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                Column {
                    id: clockBlock
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: `${Time.weekday}  ·  ${Time.day} ${Time.month}`
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: `${Time.hour}:${Time.minute} ${Time.ampm.toLowerCase()}`
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 34
                        font.weight: Font.DemiBold
                    }
                }

                Rectangle {
                    id: searchBox
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(420, stage.width)
                    height: 48
                    radius: 24
                    color: Qt.alpha(Colors.color0, 0.72)
                    border.width: 1
                    border.color: Qt.alpha(Colors.accent, search.activeFocus ? 0.7 : 0.28)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 10

                        Text {
                            text: ""
                            color: Colors.accent
                            font.family: Colors.fontFamily
                            font.pixelSize: 14
                        }

                        TextField {
                            id: search
                            Layout.fillWidth: true
                            placeholderText: "find"
                            color: Colors.foreground
                            placeholderTextColor: Colors.color8
                            font.family: Colors.fontFamily
                            font.pixelSize: 15
                            background: Item {}
                            selectByMouse: true
                            onTextChanged: {
                                grid.currentIndex = 0;
                                grid.positionViewAtBeginning();
                                win.menuApp = null;
                            }
                            Keys.onEscapePressed: {
                                if (win.menuApp)
                                    win.menuApp = null;
                                else
                                    OverlayState.close();
                            }
                            Keys.onReturnPressed: win.launchCurrent()
                            Keys.onEnterPressed: win.launchCurrent()
                            Keys.onLeftPressed: event => {
                                win.moveSel(-1, 0);
                                event.accepted = true;
                            }
                            Keys.onRightPressed: event => {
                                win.moveSel(1, 0);
                                event.accepted = true;
                            }
                            Keys.onUpPressed: event => {
                                win.moveSel(0, -1);
                                event.accepted = true;
                            }
                            Keys.onDownPressed: event => {
                                win.moveSel(0, 1);
                                event.accepted = true;
                            }
                        }
                    }
                }

                Column {
                    id: titleBlock
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    width: parent.width

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: win.currentApp ? win.currentApp.name : (search.text.length ? "nothing" : `${win.apps.length} apps`)
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: win.apps.length ? `${win.apps.length} apps  ·  scroll  ·  right-click to pin` : "nothing"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        width: Math.min(420, stage.width)
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                GridView {
                    id: grid
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: win.cell * win.colCount
                    height: Math.max(cellHeight * 2, stage.height - clockBlock.height - searchBox.height - titleBlock.height - stage.spacing * 3)
                    cellWidth: win.cell
                    cellHeight: 112
                    clip: true
                    interactive: true
                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.StopAtBounds
                    highlightFollowsCurrentItem: true
                    cacheBuffer: cellHeight * 4
                    model: win.apps

                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            id: tile
                            anchors.centerIn: parent
                            width: 96
                            height: 96
                            radius: 22
                            color: grid.currentIndex === index ? Qt.alpha(Colors.accent, 0.32) : (hover.containsMouse ? Qt.alpha(Colors.color0, 0.55) : Qt.alpha(Colors.color0, 0.22))
                            border.width: grid.currentIndex === index ? 1 : 0
                            border.color: Qt.alpha(Colors.accent, 0.9)
                            scale: grid.currentIndex === index ? 1.06 : 1

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 90
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Rectangle {
                                visible: DockState.contains(DockState.entryId(modelData))
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 8
                                width: 7
                                height: 7
                                radius: 4
                                color: Colors.accent
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 8

                                IconImage {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    implicitSize: 42
                                    source: Quickshell.iconPath(modelData.icon || "application-x-executable")
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 84
                                    text: modelData.name
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onEntered: grid.currentIndex = index
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton)
                                    win.showMenu(modelData, tile);
                                else
                                    win.launch(modelData);
                            }
                        }
                    }
                }
            }

            Item {
                id: layer
                anchors.fill: parent
                z: 5
                enabled: win.menuApp !== null

                MouseArea {
                    anchors.fill: parent
                    onClicked: win.menuApp = null
                }

                Rectangle {
                    id: appMenu
                    z: 2
                    visible: win.menuApp !== null
                    width: 176
                    height: menuCol.implicitHeight + 10
                    radius: 14
                    color: Qt.alpha(Colors.color0, 0.94)
                    border.width: 1
                    border.color: Qt.alpha(Colors.accent, 0.35)
                    x: Math.max(8, Math.min(win.menuX - width / 2, parent.width - width - 8))
                    y: Math.max(8, Math.min(win.menuY, parent.height - height - 8))

                    MouseArea {
                        anchors.fill: parent
                    }

                    Column {
                        id: menuCol
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 5
                        width: parent.width - 10
                        spacing: 2

                        Repeater {
                            model: win.menuActions

                            Rectangle {
                                required property var modelData
                                width: menuCol.width
                                height: 32
                                radius: 10
                                color: rowMouse.containsMouse && modelData.on ? Qt.alpha(Colors.accent, 0.32) : "transparent"
                                opacity: modelData.on ? 1 : 0.38

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    text: modelData.label
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    id: rowMouse
                                    anchors.fill: parent
                                    enabled: modelData.on
                                    hoverEnabled: true
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        if (modelData.action === "open")
                                            win.launch(win.menuApp);
                                        else if (modelData.action === "pin")
                                            win.pinMenu();
                                        else
                                            win.unpinMenu();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
