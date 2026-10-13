import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.state

Scope {
    id: root

    IpcHandler {
        target: "bar"

        function toggle(): void {
            BarState.visible = !BarState.visible;
        }

        function show(): void {
            BarState.visible = true;
        }

        function hide(): void {
            BarState.visible = false;
        }

        function cycleEdge(): void {
            BarState.cycle();
        }

        function setEdge(edge: string): void {
            BarState.edge = edge;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            required property var modelData
            screen: modelData
            visible: BarState.visible
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: false
            aboveWindows: true
            WlrLayershell.namespace: "quickshell-bar"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            readonly property int thick: BarState.vertical ? 44 : 38
            readonly property int peek: 18
            readonly property bool revealed: BarState.pointerInside || BarState.popupHolds > 0

            anchors {
                left: BarState.edge === "left" || !BarState.vertical
                right: BarState.edge === "right" || !BarState.vertical
                top: BarState.edge === "top" || BarState.vertical
                bottom: BarState.edge === "bottom" || BarState.vertical
            }

            margins {
                left: 0
                right: 0
                top: 0
                bottom: 0
            }

            implicitWidth: BarState.vertical ? (revealed ? thick : peek) : 0
            implicitHeight: BarState.vertical ? 0 : (revealed ? thick : peek)

            MouseArea {
                id: zone
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                z: 0
                onEntered: BarState.pointerEntered()
                onExited: BarState.pointerLeft()
            }

            Rectangle {
                id: body
                z: 1
                color: Colors.background
                width: BarState.vertical ? panel.thick : parent.width
                height: BarState.vertical ? parent.height : panel.thick
                x: {
                    if (BarState.edge === "left")
                        return panel.revealed ? 0 : -panel.thick;
                    if (BarState.edge === "right")
                        return panel.revealed ? 0 : panel.peek;
                    return 0;
                }
                y: {
                    if (BarState.edge === "top")
                        return panel.revealed ? 0 : -panel.thick;
                    if (BarState.edge === "bottom")
                        return panel.revealed ? 0 : panel.peek;
                    return 0;
                }

                Behavior on x {
                    NumberAnimation {
                        duration: Theme.motion.fast
                        easing.type: Theme.motion.enter
                    }
                }

                Behavior on y {
                    NumberAnimation {
                        duration: Theme.motion.fast
                        easing.type: Theme.motion.enter
                    }
                }

                GridLayout {
                        anchors.fill: parent
                        anchors.topMargin: BarState.vertical ? 8 : 0
                        anchors.bottomMargin: BarState.vertical ? 8 : 0
                        anchors.leftMargin: BarState.vertical ? 0 : 8
                        anchors.rightMargin: BarState.vertical ? 0 : 8
                        columns: BarState.vertical ? 1 : 9
                        rows: BarState.vertical ? 9 : 1
                        flow: BarState.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
                        rowSpacing: 6
                        columnSpacing: 6

                        Launcher {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        }

                        Workspaces {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        }

                        Item {
                            Layout.fillHeight: BarState.vertical
                            Layout.fillWidth: !BarState.vertical
                        }

                        Clock {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        }

                        Item {
                            Layout.fillHeight: BarState.vertical
                            Layout.fillWidth: !BarState.vertical
                        }

                        Tray {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        }

                        StatusIcons {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        }

                        Power {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        }
                }
            }
        }
    }
}
