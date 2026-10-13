import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.theme
import qs.state

Item {
    id: root

    implicitWidth: btn.implicitWidth
    implicitHeight: btn.implicitHeight

    property bool ignoreClick: false
    property real lastRx: -1
    property real lastTx: -1
    property real lastAt: 0
    property real downBps: 0
    property real upBps: 0
    property string statusMsg: ""
    property string pendingSsid: ""
    property int pendingSignal: 0
    property bool showPass: false
    property bool busy: false
    property string lastAttemptSsid: ""

    readonly property bool askingPass: pendingSsid.length > 0

    readonly property var devices: Networking.devices.values

    readonly property var wifiDev: {
        const list = root.devices;
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].type === DeviceType.Wifi)
                return list[i];
        }
        return null;
    }

    readonly property var wiredDev: {
        const list = root.devices;
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].type === DeviceType.Wired && list[i].connected)
                return list[i];
        }
        return null;
    }

    readonly property var wifiNet: {
        if (!wifiDev)
            return null;
        const nets = wifiDev.networks.values;
        for (let i = 0; i < nets.length; i++) {
            if (nets[i] && nets[i].connected)
                return nets[i];
        }
        return null;
    }

    readonly property int signalPct: wifiNet ? root.pctOf(wifiNet) : 0

    readonly property int netCount: wifiDev ? wifiDev.networks.values.length : 0

    readonly property string iface: {
        if (wiredDev)
            return wiredDev.name || "";
        if (wifiDev && wifiNet)
            return wifiDev.name || "";
        if (wifiDev)
            return wifiDev.name || "";
        return "";
    }

    function fmtSpeed(bps: real): string {
        if (bps < 1024)
            return `${Math.round(bps)}B`;
        if (bps < 1048576) {
            const k = bps / 1024;
            return k < 10 ? `${k.toFixed(1)}K` : `${Math.round(k)}K`;
        }
        const m = bps / 1048576;
        return m < 10 ? `${m.toFixed(1)}M` : `${Math.round(m)}M`;
    }

    function wifiIcon(pct: int): string {
        if (pct >= 80)
            return "󰤨";
        if (pct >= 60)
            return "󰤥";
        if (pct >= 40)
            return "󰤢";
        if (pct >= 20)
            return "󰤟";
        return "󰤯";
    }

    function pctOf(net: var): int {
        if (!net)
            return 0;
        const s = Number(net.signalStrength);
        if (isNaN(s))
            return 0;
        return s <= 1 ? Math.round(s * 100) : Math.round(Math.min(100, s));
    }

    function isOpen(net: var): bool {
        if (!net)
            return false;
        return net.security === WifiSecurityType.Open || net.security === WifiSecurityType.Owe;
    }

    function needsPsk(net: var): bool {
        if (!net)
            return false;
        const s = net.security;
        return s === WifiSecurityType.WpaPsk || s === WifiSecurityType.Wpa2Psk || s === WifiSecurityType.Sae;
    }

    function openPop(): void {
        root.cancelPass();
        root.statusMsg = "";
        if (!Networking.wifiEnabled)
            Networking.wifiEnabled = true;
        if (root.wifiDev)
            root.wifiDev.scannerEnabled = true;
        pop.visible = true;
        root.rescan();
    }

    function closePop(): void {
        pop.visible = false;
        root.cancelPass();
        root.busy = false;
        if (root.wifiDev)
            root.wifiDev.scannerEnabled = false;
    }

    function cancelPass(): void {
        root.pendingSsid = "";
        root.pendingSignal = 0;
        root.showPass = false;
        passField.text = "";
    }

    function askPass(ssid: string, signalPct: int): void {
        root.pendingSsid = ssid;
        root.pendingSignal = signalPct;
        root.showPass = false;
        passField.text = "";
        root.statusMsg = "";
        root.lastAttemptSsid = ssid;
        Qt.callLater(() => passField.forceActiveFocus());
    }

    function rescan(): void {
        if (root.askingPass)
            return;
        root.statusMsg = "scanning…";
        actionProc.exec(["nmcli", "device", "wifi", "rescan"]);
        if (root.wifiDev) {
            root.wifiDev.scannerEnabled = false;
            Qt.callLater(() => {
                if (root.wifiDev && pop.visible)
                    root.wifiDev.scannerEnabled = true;
            });
        }
        statusClear.restart();
    }

    function tryConnect(net: var): void {
        if (!net || root.busy)
            return;

        if (net.connected) {
            root.busy = true;
            root.statusMsg = "disconnecting…";
            const dev = root.wifiDev ? root.wifiDev.name : "";
            if (dev.length)
                actionProc.exec(["nmcli", "device", "disconnect", dev]);
            else
                net.disconnect();
            return;
        }

        // Open network — no password
        if (root.isOpen(net)) {
            root.busy = true;
            root.lastAttemptSsid = net.name;
            root.statusMsg = `connecting to ${net.name}…`;
            actionProc.exec(["nmcli", "device", "wifi", "connect", net.name]);
            return;
        }

        // Saved network — try without asking first
        if (net.known) {
            root.busy = true;
            root.lastAttemptSsid = net.name;
            root.statusMsg = `connecting to ${net.name}…`;
            actionProc.exec(["nmcli", "device", "wifi", "connect", net.name]);
            return;
        }

        // New / other secured network — full password UI
        root.askPass(net.name, root.pctOf(net));
    }

    function submitPass(): void {
        const ssid = root.pendingSsid;
        const psk = passField.text;
        if (!ssid.length)
            return;
        if (psk.length < 8) {
            root.statusMsg = "password must be at least 8 characters";
            return;
        }
        root.busy = true;
        root.lastAttemptSsid = ssid;
        root.statusMsg = `connecting to ${ssid}…`;
        actionProc.exec(["nmcli", "device", "wifi", "connect", ssid, "password", psk]);
    }

    Timer {
        id: statusClear
        interval: 2500
        onTriggered: {
            if (root.statusMsg === "scanning…")
                root.statusMsg = root.netCount ? "" : "no networks found";
        }
    }

    Process {
        id: actionProc
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.busy = false;
                const out = text.trim();
                if (out.length && /error|fail|secret|password|denied/i.test(out)) {
                    root.statusMsg = out.split("\n").pop().replace(/^Error:\s*/i, "");
                    // wrong / missing password → keep asking
                    if (root.lastAttemptSsid.length)
                        root.askPass(root.lastAttemptSsid, root.pendingSignal);
                    return;
                }
                if (root.statusMsg.indexOf("connecting") === 0) {
                    root.statusMsg = "connected";
                    root.cancelPass();
                } else if (root.statusMsg.indexOf("disconnect") === 0) {
                    root.statusMsg = "disconnected";
                } else if (root.statusMsg === "scanning…") {
                    root.statusMsg = "";
                }
            }
        }
        stderr: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const err = text.trim();
                if (!err.length)
                    return;
                root.busy = false;
                const msg = err.split("\n")[0].replace(/^Error:\s*/i, "");
                root.statusMsg = msg.length ? msg : "connection failed";

                // Secrets / wrong password → show password panel again
                if (root.lastAttemptSsid.length) {
                    root.askPass(root.lastAttemptSsid, root.pendingSignal);
                    if (/secret|password|802-11|denied|fail/i.test(err))
                        root.statusMsg = "wrong password · try again";
                }
            }
        }
    }

    Process {
        id: poll
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const parts = text.trim().split(/\s+/);
                if (parts.length < 2)
                    return;
                const rx = parseInt(parts[0], 10);
                const tx = parseInt(parts[1], 10);
                if (isNaN(rx) || isNaN(tx))
                    return;
                const now = Date.now();
                if (root.lastRx >= 0 && root.lastAt > 0) {
                    const dt = Math.max(0.2, (now - root.lastAt) / 1000);
                    root.downBps = Math.max(0, (rx - root.lastRx) / dt);
                    root.upBps = Math.max(0, (tx - root.lastTx) / dt);
                }
                root.lastRx = rx;
                root.lastTx = tx;
                root.lastAt = now;
            }
        }
    }

    Timer {
        interval: 1000
        running: root.iface.length > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const iface = root.iface;
            if (!iface.length)
                return;
            poll.exec([
                "bash",
                "-c",
                `echo "$(cat /sys/class/net/${iface}/statistics/rx_bytes 2>/dev/null || echo 0) $(cat /sys/class/net/${iface}/statistics/tx_bytes 2>/dev/null || echo 0)"`
            ]);
        }
        onRunningChanged: {
            if (!running) {
                root.lastRx = -1;
                root.lastTx = -1;
                root.downBps = 0;
                root.upBps = 0;
            }
        }
    }

    BarButton {
        id: btn
        anchors.centerIn: parent
        icon: {
            if (wiredDev)
                return "󰈀";
            if (!Networking.wifiEnabled)
                return "󰤮";
            if (wifiNet)
                return root.wifiIcon(root.signalPct);
            return "󰤫";
        }
        iconColor: (wiredDev || wifiNet) ? Colors.foreground : Colors.color8
        active: pop.visible
        labelOnHover: false
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
        implicitWidth: 300
        implicitHeight: 420
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
            radius: 18
            color: Qt.alpha(Colors.background, 0.96)
            border.width: 1
            border.color: Colors.color0
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Wi‑Fi"
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "󰑐"
                        color: scanHover.containsMouse ? Colors.accent : Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                        visible: Networking.wifiEnabled

                        MouseArea {
                            id: scanHover
                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.rescan()
                        }
                    }

                    Rectangle {
                        width: 42
                        height: 22
                        radius: 11
                        color: Networking.wifiEnabled ? Colors.accent : Colors.color0

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: Networking.wifiEnabled ? parent.width - width - 3 : 3
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
                                Networking.wifiEnabled = !Networking.wifiEnabled;
                                if (Networking.wifiEnabled) {
                                    if (root.wifiDev)
                                        root.wifiDev.scannerEnabled = true;
                                    root.rescan();
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: !!root.wifiNet
                    text: root.wifiNet ? root.wifiNet.name : ""
                    color: Colors.accent
                    font.family: Colors.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.iface.length > 0 && (!!root.wifiNet || !!root.wiredDev)
                    spacing: 12

                    Text {
                        text: `↓ ${root.fmtSpeed(root.downBps)}`
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 11
                    }

                    Text {
                        text: `↑ ${root.fmtSpeed(root.upBps)}`
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 11
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                Text {
                    visible: root.statusMsg.length > 0 && !root.askingPass
                    text: root.statusMsg
                    color: Colors.color8
                    font.family: Colors.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Full password panel for new / other networks
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.askingPass
                    radius: 14
                    color: Qt.alpha(Colors.color0, 0.35)
                    border.width: 1
                    border.color: Qt.alpha(Colors.accent, 0.45)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        Text {
                            text: "connect to network"
                            color: Colors.color8
                            font.family: Colors.fontFamily
                            font.pixelSize: 11
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: root.wifiIcon(root.pendingSignal)
                                color: Colors.accent
                                font.family: Colors.fontFamily
                                font.pixelSize: 22
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: root.pendingSsid
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "secured · enter password"
                                    color: Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 11
                                }
                            }
                        }

                        Text {
                            visible: root.statusMsg.length > 0
                            text: root.statusMsg
                            color: Colors.secondary
                            font.family: Colors.fontFamily
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            TextField {
                                id: passField
                                Layout.fillWidth: true
                                echoMode: root.showPass ? TextInput.Normal : TextInput.Password
                                placeholderText: "Wi‑Fi password"
                                color: Colors.foreground
                                placeholderTextColor: Colors.color8
                                font.family: Colors.fontFamily
                                font.pixelSize: 13
                                enabled: !root.busy
                                background: Rectangle {
                                    radius: 12
                                    color: Colors.background
                                    border.width: 1
                                    border.color: passField.activeFocus ? Colors.accent : Colors.color0
                                }
                                leftPadding: 12
                                rightPadding: 12
                                topPadding: 10
                                bottomPadding: 10
                                onAccepted: root.submitPass()
                            }

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 12
                                color: Qt.alpha(Colors.color0, eyeHover.containsMouse ? 0.9 : 0.5)
                                border.width: 1
                                border.color: Colors.color0

                                Text {
                                    anchors.centerIn: parent
                                    text: root.showPass ? "󰈉" : "󰈈"
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 16
                                }

                                MouseArea {
                                    id: eyeHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.showPass = !root.showPass
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                height: 40
                                radius: 12
                                color: Qt.alpha(Colors.color0, cancelHover.containsMouse ? 0.8 : 0.45)
                                border.width: 1
                                border.color: Colors.color0

                                Text {
                                    anchors.centerIn: parent
                                    text: "cancel"
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    id: cancelHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.cancelPass();
                                        root.statusMsg = "";
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 40
                                radius: 12
                                opacity: root.busy ? 0.6 : 1
                                color: Qt.alpha(Colors.accent, connectHover.containsMouse ? 0.55 : 0.28)
                                border.width: 1
                                border.color: Qt.alpha(Colors.accent, 0.7)

                                Text {
                                    anchors.centerIn: parent
                                    text: root.busy ? "connecting…" : "connect"
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    id: connectHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: !root.busy
                                    onClicked: root.submitPass()
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds
                    visible: Networking.wifiEnabled && !root.askingPass
                    model: root.wifiDev ? root.wifiDev.networks : null

                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view ? ListView.view.width : 0
                        height: 44
                        radius: 12
                        color: modelData && modelData.connected ? Qt.alpha(Colors.accent, 0.22) : (rowHover.containsMouse ? Qt.alpha(Colors.color0, 0.55) : "transparent")

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            Text {
                                text: root.wifiIcon(root.pctOf(modelData))
                                color: Colors.foreground
                                font.family: Colors.fontFamily
                                font.pixelSize: 14
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: modelData ? modelData.name : ""
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: {
                                        if (!modelData)
                                            return "";
                                        if (modelData.connected)
                                            return "connected";
                                        if (modelData.stateChanging)
                                            return "working…";
                                        if (modelData.known)
                                            return "saved · tap to join";
                                        return root.isOpen(modelData) ? "open" : "secured · password needed";
                                    }
                                    color: modelData && modelData.connected ? Colors.accent : Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                }
                            }

                            Text {
                                visible: modelData && !root.isOpen(modelData)
                                text: ""
                                color: Colors.color8
                                font.family: Colors.fontFamily
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            id: rowHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: !root.busy
                            onClicked: root.tryConnect(modelData)
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !root.wifiDev || root.netCount === 0
                        text: !root.wifiDev ? "no wifi device" : (root.statusMsg === "scanning…" ? "scanning…" : "no networks · tap 󰑐")
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 12
                    }
                }

                Text {
                    visible: !Networking.wifiEnabled
                    text: "Wi‑Fi is off"
                    color: Colors.color8
                    font.family: Colors.fontFamily
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
