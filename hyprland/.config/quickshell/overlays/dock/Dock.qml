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
            property int hoverIndex: -1

            readonly property int dockH: 90
            readonly property int hitH: 10
            readonly property int dockW: Math.max(96, apps.implicitWidth + 20)

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

                        Text {
                            visible: DockState.entries.length === 0
                            text: "edit dock.json"
                            color: Theme.colors.textMuted
                            font.family: Theme.font.ui
                            font.pixelSize: Theme.type.body
                        }

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
                                    color: win.hoverIndex === index ? Theme.colors.accentSoft : "transparent"

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
                                    scale: win.hoverIndex === index ? 1.08 : 1

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
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    cursorShape: win.hoverIndex >= 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onEntered: {
                        hideDelay.stop();
                        win.shown = true;
                    }
                    onExited: {
                        win.hoverIndex = -1;
                        hideDelay.restart();
                    }
                    onPositionChanged: mouse => {
                        if (!win.shown)
                            return;
                        win.hoverIndex = win.indexAt(mouse.x, mouse.y);
                    }
                    onClicked: mouse => win.launch(win.indexAt(mouse.x, mouse.y))
                }

                Timer {
                    id: hideDelay
                    interval: 40
                    repeat: false
                    onTriggered: win.shown = false
                }
            }
        }
    }
}
