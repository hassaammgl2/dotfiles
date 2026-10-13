import Quickshell
import Quickshell.Wayland
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
            visible: OverlayState.screenshot && ScreenshotState.ready
            color: Theme.colors.background
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "quickshell-screenshot"

            readonly property var shot: ScreenshotState.shotFor(modelData)
            readonly property color scrim: Qt.rgba(0, 0, 0, 0.48)
            readonly property bool selectedHere: ScreenshotState.hasSelection && ScreenshotState.owner === modelData.name
            readonly property var hole: {
                if (win.selectedHere)
                    return {
                        "x": ScreenshotState.selX,
                        "y": ScreenshotState.selY,
                        "w": ScreenshotState.selW,
                        "h": ScreenshotState.selH
                    };
                if (!ScreenshotState.hasSelection && ScreenshotState.hasHover && ScreenshotState.hoverScreen === modelData.name)
                    return {
                        "x": ScreenshotState.hoverX,
                        "y": ScreenshotState.hoverY,
                        "w": ScreenshotState.hoverW,
                        "h": ScreenshotState.hoverH
                    };
                return null;
            }
            readonly property var actions: [
                {
                    "id": "copy",
                    "label": "Copy",
                    "icon": Theme.icons.copy,
                    "primary": false
                },
                {
                    "id": "save",
                    "label": "Save",
                    "icon": Theme.icons.save,
                    "primary": false
                },
                {
                    "id": "both",
                    "label": "Copy + Save",
                    "icon": Theme.icons.screenshot,
                    "primary": true
                }
            ]
            readonly property string sizeText: {
                if (!win.selectedHere || win.hole === null || img.status !== Image.Ready)
                    return "";
                const c = win.pixels(win.hole);
                return `${c.w} × ${c.h}`;
            }

            property bool dragging: false
            property bool dragMoved: false
            property bool eatRelease: false
            property real dragX: 0
            property real dragY: 0

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            function rectFrom(x1: real, y1: real, x2: real, y2: real): var {
                const left = Math.max(0, Math.min(x1, x2));
                const top = Math.max(0, Math.min(y1, y2));
                const right = Math.min(win.width, Math.max(x1, x2));
                const bottom = Math.min(win.height, Math.max(y1, y2));
                return {
                    "x": left,
                    "y": top,
                    "w": Math.max(0, right - left),
                    "h": Math.max(0, bottom - top)
                };
            }

            function windowAt(px: real, py: real): var {
                const list = ScreenshotState.windows;
                if (!list)
                    return null;
                const sx = win.modelData.x;
                const sy = win.modelData.y;
                const sw = win.width;
                const sh = win.height;
                let best = null;
                let bestArea = 0;
                for (let i = 0; i < list.length; i++) {
                    const item = list[i];
                    let x = item.x - sx;
                    let y = item.y - sy;
                    let right = x + item.w;
                    let bottom = y + item.h;
                    if (x < 0)
                        x = 0;
                    if (y < 0)
                        y = 0;
                    if (right > sw)
                        right = sw;
                    if (bottom > sh)
                        bottom = sh;
                    const ww = right - x;
                    const hh = bottom - y;
                    if (ww < 2 || hh < 2)
                        continue;
                    if (px < x || py < y || px >= right || py >= bottom)
                        continue;
                    const area = ww * hh;
                    if (!best || area < bestArea) {
                        best = {
                            "x": x,
                            "y": y,
                            "w": ww,
                            "h": hh
                        };
                        bestArea = area;
                    }
                }
                return best;
            }

            function pixels(rect: var): var {
                const iw = Math.max(1, img.sourceSize.width);
                const ih = Math.max(1, img.sourceSize.height);
                const sx = iw / Math.max(1, win.width);
                const sy = ih / Math.max(1, win.height);
                let x = Math.round(rect.x * sx);
                let y = Math.round(rect.y * sy);
                let w = Math.round(rect.w * sx);
                let h = Math.round(rect.h * sy);
                if (x < 0)
                    x = 0;
                if (y < 0)
                    y = 0;
                if (x > iw - 1)
                    x = iw - 1;
                if (y > ih - 1)
                    y = ih - 1;
                if (w < 1)
                    w = 1;
                if (h < 1)
                    h = 1;
                if (x + w > iw)
                    w = iw - x;
                if (y + h > ih)
                    h = ih - y;
                return {
                    "x": x,
                    "y": y,
                    "w": w,
                    "h": h
                };
            }

            function act(action: string): void {
                if (win.dragging || !win.shot || win.hole === null || img.status !== Image.Ready || !win.selectedHere)
                    return;
                const c = win.pixels(win.hole);
                ScreenshotState.finish(action, win.shot.path, c.x, c.y, c.w, c.h);
            }

            Shortcut {
                sequence: "Escape"
                enabled: win.visible
                onActivated: ScreenshotState.cancel()
            }

            Shortcut {
                sequence: "Return"
                enabled: win.visible
                onActivated: win.act("both")
            }

            Shortcut {
                sequence: "Enter"
                enabled: win.visible
                onActivated: win.act("both")
            }

            Shortcut {
                sequence: "Ctrl+C"
                enabled: win.visible
                onActivated: win.act("copy")
            }

            Shortcut {
                sequence: "Ctrl+S"
                enabled: win.visible
                onActivated: win.act("save")
            }

            Image {
                id: img
                anchors.fill: parent
                visible: win.shot !== null
                source: win.shot ? `file://${win.shot.path}` : ""
                fillMode: Image.Stretch
                cache: false
                asynchronous: false
                smooth: true
                mipmap: true
            }

            Rectangle {
                z: 1
                visible: win.hole === null
                anchors.fill: parent
                color: win.scrim
            }

            Rectangle {
                z: 1
                visible: win.hole !== null
                x: 0
                y: 0
                width: parent.width
                height: win.hole ? win.hole.y : 0
                color: win.scrim
            }

            Rectangle {
                z: 1
                visible: win.hole !== null
                x: 0
                y: win.hole ? win.hole.y + win.hole.h : 0
                width: parent.width
                height: win.hole ? Math.max(0, parent.height - y) : 0
                color: win.scrim
            }

            Rectangle {
                z: 1
                visible: win.hole !== null
                x: 0
                y: win.hole ? win.hole.y : 0
                width: win.hole ? win.hole.x : 0
                height: win.hole ? win.hole.h : 0
                color: win.scrim
            }

            Rectangle {
                z: 1
                visible: win.hole !== null
                x: win.hole ? win.hole.x + win.hole.w : 0
                y: win.hole ? win.hole.y : 0
                width: win.hole ? Math.max(0, parent.width - x) : 0
                height: win.hole ? win.hole.h : 0
                color: win.scrim
            }

            Rectangle {
                z: 2
                visible: win.hole !== null
                x: win.hole ? win.hole.x : 0
                y: win.hole ? win.hole.y : 0
                width: win.hole ? win.hole.w : 0
                height: win.hole ? win.hole.h : 0
                color: "transparent"
                border.width: 2
                border.color: win.selectedHere ? Theme.colors.accent : Theme.withAlpha(Theme.colors.text, 0.9)
            }

            MouseArea {
                id: pad
                z: 3
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.CrossCursor
                preventStealing: true

                onPressed: mouse => {
                    if (mouse.button !== Qt.LeftButton) {
                        if (ScreenshotState.hasSelection)
                            ScreenshotState.clearSelection();
                        else
                            ScreenshotState.cancel();
                        return;
                    }
                    win.eatRelease = false;
                    win.dragging = true;
                    win.dragMoved = false;
                    win.dragX = mouse.x;
                    win.dragY = mouse.y;
                    ScreenshotState.clearSelection();
                }

                onPositionChanged: mouse => {
                    if (win.dragging) {
                        if (Math.abs(mouse.x - win.dragX) > 6 || Math.abs(mouse.y - win.dragY) > 6)
                            win.dragMoved = true;
                        if (!win.dragMoved)
                            return;
                        const rect = win.rectFrom(win.dragX, win.dragY, mouse.x, mouse.y);
                        ScreenshotState.select(win.modelData.name, rect.x, rect.y, rect.w, rect.h);
                        return;
                    }
                    const hit = win.windowAt(mouse.x, mouse.y);
                    if (hit)
                        ScreenshotState.setHover(win.modelData.name, hit.x, hit.y, hit.w, hit.h);
                    else if (ScreenshotState.hoverScreen === win.modelData.name)
                        ScreenshotState.clearHover();
                }

                onReleased: mouse => {
                    if (mouse.button !== Qt.LeftButton)
                        return;
                    if (win.eatRelease) {
                        win.eatRelease = false;
                        win.dragging = false;
                        return;
                    }
                    const moved = win.dragMoved && ScreenshotState.selW >= 8 && ScreenshotState.selH >= 8;
                    win.dragging = false;
                    win.dragMoved = false;
                    if (moved)
                        return;
                    const hit = win.windowAt(mouse.x, mouse.y);
                    if (hit)
                        ScreenshotState.select(win.modelData.name, hit.x, hit.y, hit.w, hit.h);
                    else
                        ScreenshotState.clearSelection();
                }

                onDoubleClicked: mouse => {
                    if (mouse.button !== Qt.LeftButton)
                        return;
                    win.eatRelease = true;
                    win.dragging = false;
                    win.dragMoved = false;
                    ScreenshotState.select(win.modelData.name, 0, 0, win.width, win.height);
                }

                onExited: {
                    if (ScreenshotState.hoverScreen === win.modelData.name)
                        ScreenshotState.clearHover();
                }
            }

            Column {
                z: 5
                visible: !ScreenshotState.hasSelection
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 28
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Drag a region    ·    Click a window    ·    Double-click this screen"
                    color: Theme.colors.text
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.body
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Enter copies and saves    ·    Esc cancels"
                    color: Theme.colors.textMuted
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.caption
                }
            }

            Rectangle {
                z: 5
                visible: win.sizeText.length > 0 && win.hole !== null
                x: win.hole ? Math.max(8, win.hole.x) : 0
                y: {
                    if (!win.hole)
                        return 0;
                    const above = win.hole.y - height - 8;
                    if (above >= 8)
                        return above;
                    return Math.min(win.height - height - 8, win.hole.y + 8);
                }
                implicitWidth: sizeLabel.implicitWidth + 16
                implicitHeight: sizeLabel.implicitHeight + 8
                radius: Theme.r.sm
                color: Theme.withAlpha(Theme.colors.background, 0.92)
                border.width: 1
                border.color: Theme.colors.border

                Text {
                    id: sizeLabel
                    anchors.centerIn: parent
                    text: win.sizeText
                    color: Theme.colors.text
                    font.family: Theme.font.mono
                    font.pixelSize: Theme.type.monoSmall
                }
            }

            Row {
                id: tools
                z: 6
                visible: win.selectedHere && !win.dragging && win.hole !== null
                spacing: 8
                x: {
                    if (!win.hole)
                        return 12;
                    let px = win.hole.x + win.hole.w - width;
                    if (px < 12)
                        px = 12;
                    if (px + width > win.width - 12)
                        px = Math.max(12, win.width - 12 - width);
                    return px;
                }
                y: {
                    if (!win.hole)
                        return 12;
                    let py = win.hole.y + win.hole.h + 10;
                    if (py + height > win.height - 12)
                        py = win.hole.y - height - 10;
                    if (py < 12)
                        py = 12;
                    return py;
                }

                Repeater {
                    model: win.actions

                    Rectangle {
                        required property var modelData
                        required property int index
                        implicitWidth: buttonRow.implicitWidth + 22
                        implicitHeight: 36
                        radius: Theme.r.pill
                        color: modelData.primary ? Theme.colors.accent : Theme.withAlpha(Theme.colors.background, 0.94)
                        border.width: 1
                        border.color: modelData.primary ? Theme.colors.accent : Theme.colors.border

                        Row {
                            id: buttonRow
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.icon
                                color: modelData.primary ? Theme.colors.onAccent : Theme.colors.text
                                font.family: Theme.font.icon
                                font.pixelSize: Theme.type.icon
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                color: modelData.primary ? Theme.colors.onAccent : Theme.colors.text
                                font.family: Theme.font.ui
                                font.pixelSize: Theme.type.body
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: win.act(modelData.id)
                        }
                    }
                }
            }

            Text {
                z: 5
                visible: win.shot === null
                anchors.centerIn: parent
                text: "This screen was not captured"
                color: Theme.colors.text
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.body
            }
        }
    }
}
