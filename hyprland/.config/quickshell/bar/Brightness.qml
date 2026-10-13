import Quickshell
import Quickshell.Hyprland
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
        icon: OsdState.brightnessIcon
        onClicked: event => {
            if (root.ignoreClick)
                return;
            pop.visible = !pop.visible;
        }
        onWheel: delta => {
            const step = delta > 0 ? 0.05 : -0.05;
            OsdState.setBri(OsdState.bri + step, true);
        }
    }

    PopupWindow {
        id: pop

        visible: false
        color: "transparent"
        implicitWidth: 280
        implicitHeight: 118
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
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Brightness"
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    Text {
                        text: `${Math.round(OsdState.bri * 100)}%`
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 12
                    }
                }

                PopSlider {
                    Layout.fillWidth: true
                    value: OsdState.bri
                    onApplied: next => OsdState.setBri(next, true)
                }
            }
        }
    }
}
