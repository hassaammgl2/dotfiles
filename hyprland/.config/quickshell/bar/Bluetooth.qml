import Quickshell
import Quickshell.Hyprland
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.state

Item {
    id: root

    implicitWidth: btn.implicitWidth
    implicitHeight: btn.implicitHeight

    property bool ignoreClick: false

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter && adapter.enabled
    readonly property int connectedCount: {
        let n = 0;
        for (const d of Bluetooth.devices.values) {
            if (d.connected)
                n++;
        }
        return n;
    }

    readonly property var deviceList: {
        const list = [...Bluetooth.devices.values];
        list.sort((a, b) => {
            if (a.connected !== b.connected)
                return b.connected - a.connected;
            if (a.paired !== b.paired)
                return b.paired - a.paired;
            const an = a.name || a.deviceName || "";
            const bn = b.name || b.deviceName || "";
            return an.localeCompare(bn);
        });
        return list;
    }

    visible: adapter !== null

    function labelOf(dev: var): string {
        return dev.name || dev.deviceName || dev.address || "device";
    }

    function statusOf(dev: var): string {
        if (dev.pairing)
            return "pairing…";
        if (dev.state === BluetoothDeviceState.Connecting)
            return "connecting…";
        if (dev.state === BluetoothDeviceState.Disconnecting)
            return "disconnecting…";
        if (dev.connected)
            return "connected";
        if (dev.paired)
            return "paired";
        return "available";
    }

    function openPop(): void {
        if (root.adapter) {
            if (!root.adapter.enabled)
                root.adapter.enabled = true;
            root.adapter.discovering = true;
        }
        pop.visible = true;
    }

    function closePop(): void {
        pop.visible = false;
        if (root.adapter)
            root.adapter.discovering = false;
    }

    BarButton {
        id: btn
        anchors.centerIn: parent
        icon: root.powered ? (root.connectedCount > 0 ? "󰂱" : "") : "󰂲"
        iconColor: root.powered ? Colors.foreground : Colors.color8
        active: pop.visible
        onClicked: event => {
            if (root.ignoreClick)
                return;
            if (pop.visible)
                root.closePop();
            else
                root.openPop();
        }
    }

    PopupWindow {
        id: pop

        visible: false
        color: "transparent"
        implicitWidth: 280
        implicitHeight: 360
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
                root.closePop();
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
                        text: "Bluetooth"
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 42
                        height: 22
                        radius: 11
                        color: root.powered ? Colors.accent : Colors.color0

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: root.powered ? parent.width - width - 3 : 3
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
                            onClicked: {
                                if (!root.adapter)
                                    return;
                                root.adapter.enabled = !root.adapter.enabled;
                                if (root.adapter.enabled)
                                    root.adapter.discovering = true;
                            }
                        }
                    }
                }

                Text {
                    visible: root.powered && root.adapter && root.adapter.discovering
                    text: "scanning…"
                    color: Colors.accent
                    font.family: Colors.fontFamily
                    font.pixelSize: 11
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds
                    visible: root.powered
                    model: root.deviceList

                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: 42
                        radius: 10
                        color: modelData.connected ? Qt.alpha(Colors.accent, 0.22) : (rowHover.containsMouse ? Qt.alpha(Colors.color0, 0.55) : "transparent")

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            Text {
                                text: modelData.connected ? "󰂱" : ""
                                color: Colors.foreground
                                font.family: Colors.fontFamily
                                font.pixelSize: 14
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: root.labelOf(modelData)
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: {
                                        const st = root.statusOf(modelData);
                                        if (modelData.batteryAvailable)
                                            return `${st}  ·  ${Math.round(modelData.battery <= 1 ? modelData.battery * 100 : modelData.battery)}%`;
                                        return st;
                                    }
                                    color: modelData.connected ? Colors.accent : Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                }
                            }
                        }

                        MouseArea {
                            id: rowHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: event => {
                                if (event.button === Qt.RightButton) {
                                    if (modelData.paired)
                                        modelData.forget();
                                    return;
                                }
                                if (modelData.connected)
                                    modelData.disconnect();
                                else if (modelData.paired)
                                    modelData.connect();
                                else
                                    modelData.pair();
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: "scanning…"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 12
                    }
                }

                Text {
                    visible: !root.powered
                    text: "Bluetooth is off"
                    color: Colors.color8
                    font.family: Colors.fontFamily
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
