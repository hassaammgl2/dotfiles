import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import qs.theme
import qs.state

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: false
            aboveWindows: true
            WlrLayershell.namespace: "quickshell-dock"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            property bool shown: false
            property bool menuHot: false
            property int hoverIndex: -1
            property int holds: 0
            property int grab: -1
            property real pressX: 0
            property bool moved: false

            readonly property int dockH: 90
            readonly property int hitH: 10
            readonly property int dockW: Math.max(72, apps.implicitWidth + 20)

            implicitWidth: dockW
            implicitHeight: dockH

            anchors {
                bottom: true
                left: true
            }

            margins {
                bottom: Theme.barReserve("bottom")
                left: Math.max(0, Math.round((modelData.width - dockW) / 2))
            }

            mask: Region {
                item: hit
            }

            function pointerEntered(): void {
                holds += 1;
                hideDelay.stop();
                shown = true;
            }

            function pointerLeft(): void {
                holds = Math.max(0, holds - 1);
                if (holds > 0)
                    return;
                if (zone.containsMouse) {
                    holds = 1;
                    return;
                }
                hideDelay.restart();
            }

            function indexAt(mx: real, my: real): int {
                const origin = apps.mapToItem(hit, 0, 0);
                const x = mx - origin.x;
                const y = my - origin.y;
                if (x < 0 || y < 0 || y > apps.height)
                    return -1;
                let cursor = 0;
                for (let i = 0; i < rep.count; i++) {
                    const item = rep.itemAt(i);
                    if (!item)
                        continue;
                    if (x >= cursor && x < cursor + item.width)
                        return i;
                    cursor += item.width + apps.spacing;
                }
                return -1;
            }

            function overMenu(mx: real, my: real): bool {
                const p = menuBtn.mapFromItem(hit, mx, my);
                return p.x >= 0 && p.y >= 0 && p.x <= menuBtn.width && p.y <= menuBtn.height;
            }

            function launch(index: int): void {
                const list = DockState.entries;
                if (index < 0 || index >= list.length)
                    return;
                const app = list[index];
                if (!app || app.missing || !app.execute)
                    return;
                app.execute();
            }

            Item {
                id: hit
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: win.shown ? win.dockH : win.hitH
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: Theme.motion.normal
                        easing.type: Theme.motion.enter
                    }
                }

                Text {
                    id: caption
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: pill.top
                    anchors.bottomMargin: 4
                    text: {
                        if (win.menuHot)
                            return "Apps";
                        const list = DockState.entries;
                        if (win.hoverIndex < 0 || win.hoverIndex >= list.length)
                            return "";
                        return list[win.hoverIndex].name || "";
                    }
                    color: Theme.colors.text
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.caption
                    opacity: text.length > 0 && win.shown ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.motion.fast
                        }
                    }
                }

                Rectangle {
                    id: pill
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: win.hitH
                    width: win.dockW
                    height: 56
                    radius: 20
                    color: Theme.withAlpha(Theme.colors.surface, 0.96)
                    border.width: 1
                    border.color: Theme.colors.border
                    opacity: win.shown ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.motion.fast
                            easing.type: Theme.motion.enter
                        }
                    }

                    Row {
                        id: apps
                        anchors.centerIn: parent
                        spacing: 4

                        Repeater {
                            id: rep
                            model: DockState.entries

                            Item {
                                required property var modelData
                                required property int index
                                width: 46
                                height: 46

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 42
                                    height: 42
                                    radius: 14
                                    color: win.hoverIndex === index || win.grab === index ? Theme.colors.accentSoft : "transparent"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Theme.motion.fast
                                        }
                                    }
                                }

                                IconImage {
                                    anchors.centerIn: parent
                                    implicitSize: 28
                                    visible: !modelData.missing
                                    source: modelData.missing ? "" : Quickshell.iconPath(modelData.icon || "application-x-executable")
                                    scale: win.hoverIndex === index || win.grab === index ? 1.08 : 1

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: Theme.motion.fast
                                            easing.type: Theme.motion.enter
                                        }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: !!modelData.missing
                                    text: String(modelData.name || "?").charAt(0).toUpperCase()
                                    color: Theme.colors.text
                                    font.family: Theme.font.ui
                                    font.pixelSize: Theme.type.title
                                    font.weight: Font.DemiBold
                                }
                            }
                        }

                        Item {
                            id: menuBtn
                            width: 46
                            height: 46

                            Rectangle {
                                anchors.centerIn: parent
                                width: 42
                                height: 42
                                radius: 14
                                color: win.menuHot || OverlayState.launcher ? Theme.colors.accentSoft : "transparent"

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.motion.fast
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: Theme.icons.launcher
                                    color: Theme.colors.accent
                                    font.family: Theme.font.icon
                                    font.pixelSize: 20
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: zone
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: win.hoverIndex >= 0 || win.menuHot ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onEntered: win.pointerEntered()
                    onExited: {
                        win.hoverIndex = -1;
                        win.menuHot = false;
                        win.pointerLeft();
                    }
                    onPressed: mouse => {
                        if (mouse.button !== Qt.LeftButton || win.overMenu(mouse.x, mouse.y))
                            return;
                        win.moved = false;
                        win.pressX = mouse.x;
                        win.grab = win.indexAt(mouse.x, mouse.y);
                    }
                    onReleased: win.grab = -1
                    onCanceled: win.grab = -1
                    onPositionChanged: mouse => {
                        if (!win.shown)
                            return;
                        win.menuHot = win.overMenu(mouse.x, mouse.y);
                        win.hoverIndex = win.menuHot ? -1 : win.indexAt(mouse.x, mouse.y);
                        if (!pressed || win.grab < 0)
                            return;
                        if (Math.abs(mouse.x - win.pressX) > 10)
                            win.moved = true;
                        if (!win.moved)
                            return;
                        const to = win.indexAt(mouse.x, mouse.y);
                        if (to < 0 || to === win.grab)
                            return;
                        DockState.move(win.grab, to);
                        win.grab = to;
                        win.hoverIndex = to;
                    }
                    onClicked: mouse => {
                        if (win.overMenu(mouse.x, mouse.y)) {
                            OverlayState.toggleLauncher();
                            return;
                        }
                        if (mouse.button === Qt.RightButton) {
                            const removeAt = win.indexAt(mouse.x, mouse.y);
                            if (removeAt >= 0)
                                DockState.removeAt(removeAt);
                            return;
                        }
                        if (win.moved)
                            return;
                        win.launch(win.indexAt(mouse.x, mouse.y));
                    }
                }
            }

            Timer {
                id: hideDelay
                interval: 80
                repeat: false
                onTriggered: {
                    if (win.holds > 0)
                        return;
                    win.shown = false;
                }
            }
        }
    }
}
