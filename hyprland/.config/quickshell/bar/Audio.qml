import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.state

Item {
    id: root

    implicitWidth: btn.implicitWidth
    implicitHeight: btn.implicitHeight

    property bool ignoreClick: false

    BarButton {
        id: btn
        anchors.centerIn: parent
        active: pop.visible
        icon: OsdState.volumeIcon
        iconColor: OsdState.muted ? Colors.color8 : Colors.foreground
        onClicked: event => {
            if (root.ignoreClick)
                return;
            if (event.button === Qt.RightButton) {
                OsdState.volumeMute(true);
                return;
            }
            pop.visible = !pop.visible;
        }
        onWheel: delta => {
            const step = delta > 0 ? 0.05 : -0.05;
            OsdState.setVol(OsdState.vol + step, true);
        }
    }

    PopupWindow {
        id: pop

        visible: false
        color: "transparent"
        implicitWidth: 280
        implicitHeight: 320
        onVisibleChanged: visible ? BarState.popupOpened() : BarState.popupClosed()
        grabFocus: true

        anchor {
            item: root
            edges: BarState.edge === "right" ? Edges.Left : (BarState.edge === "top" ? Edges.Bottom : (BarState.edge === "bottom" ? Edges.Top : Edges.Right))
            gravity: BarState.edge === "right" ? Edges.Left : (BarState.edge === "top" ? Edges.Bottom : (BarState.edge === "bottom" ? Edges.Top : Edges.Right))
            adjustment: PopupAdjustment.Slide
            margins.left: 4
            margins.right: 4
            margins.top: 4
            margins.bottom: 4
        }

        HyprlandFocusGrab {
            active: pop.visible
            windows: [pop]
            onCleared: {
                pop.visible = false;
                root.ignoreClick = true;
                Qt.callLater(() => {
                    root.ignoreClick = false;
                });
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: Colors.background
            border.width: 1
            border.color: Colors.color0
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Sound"
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    Text {
                        text: `${Math.round(OsdState.vol * 100)}%`
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 12
                    }

                    Rectangle {
                        width: 42
                        height: 22
                        radius: 11
                        color: OsdState.ready && !OsdState.muted ? Colors.accent : Colors.color0

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: OsdState.ready && !OsdState.muted ? parent.width - width - 3 : 3
                            color: Colors.foreground

                            Behavior on x {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: OsdState.volumeMute(true)
                        }
                    }
                }

                PopSlider {
                    Layout.fillWidth: true
                    value: OsdState.vol
                    dimmed: OsdState.muted
                    onApplied: next => OsdState.setVol(next, true)
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: OsdState.micMuted ? "󰍭" : "󰍬"
                        color: OsdState.micMuted ? Colors.color8 : Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                    }

                    PopSlider {
                        Layout.fillWidth: true
                        value: OsdState.micVol
                        dimmed: OsdState.micMuted
                        onApplied: next => OsdState.setMic(next, true)
                    }

                    Text {
                        text: `${Math.round(OsdState.micVol * 100)}%`
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 11
                    }
                }

                Text {
                    text: "Output"
                    color: Colors.color8
                    font.family: Colors.fontFamily
                    font.pixelSize: 11
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds
                    model: OsdState.sinks

                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool current: OsdState.sink && modelData && OsdState.sink.id === modelData.id
                        width: ListView.view.width
                        height: 36
                        radius: 10
                        color: current ? Qt.alpha(Colors.accent, 0.22) : (rowHover.containsMouse ? Qt.alpha(Colors.color0, 0.55) : "transparent")

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            text: OsdState.nodeLabel(modelData)
                            color: Colors.foreground
                            font.family: Colors.fontFamily
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea {
                            id: rowHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Pipewire.preferredDefaultAudioSink = modelData
                        }
                    }
                }
            }
        }
    }
}
