import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs.theme
import qs.state

Scope {
    id: root

    property var files: []
    property string currentFile: ""

    readonly property string wallDir: `${Quickshell.env("HOME")}/Pictures/Wallpapers`
    readonly property string wallScript: `${Quickshell.env("HOME")}/.config/hypr/scripts/wallpaper.sh`

    function fileUrl(path: string): string {
        return "file://" + encodeURI(path);
    }

    function prettyName(path: string): string {
        if (!path)
            return "";
        const n = path.split("/").pop().replace(/\.[^.]+$/, "");
        return n.replace(/[-_]+/g, " ");
    }

    function scan(): void {
        scanner.exec(["find", root.wallDir, "(", "-name", ".git", "-o", "-name", "current", ")", "-prune", "-o", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", "-o", "-iname", "*.gif", ")", "-print"]);
        currentReader.exec(["readlink", "-f", `${root.wallDir}/current`]);
    }

    Process {
        id: scanner
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(s => s.length > 0);
                lines.sort((a, b) => a.split("/").pop().localeCompare(b.split("/").pop()));
                root.files = lines;
            }
        }
    }

    Process {
        id: currentReader
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.currentFile = text.trim();
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.wallpaper
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true

            readonly property int cardW: Math.min(760, Math.floor(width * 0.48))
            readonly property int cardH: Math.min(420, Math.floor(height * 0.5))
            readonly property string currentPath: {
                if (carousel.currentIndex >= 0 && carousel.currentIndex < root.files.length)
                    return root.files[carousel.currentIndex];
                return "";
            }
            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            onVisibleChanged: {
                WallpaperState.pickerOpen = visible;
                if (visible) {
                    root.scan();
                    keySink.forceActiveFocus();
                }
            }

            function jumpToCurrent(): void {
                const i = root.files.indexOf(root.currentFile);
                carousel.currentIndex = i >= 0 ? i : 0;
            }

            function apply(path: string): void {
                if (!path)
                    return;
                OverlayState.close();
                Quickshell.execDetached(["bash", root.wallScript, "file", path]);
            }

            function applyCurrent(): void {
                win.apply(win.currentPath);
            }

            Connections {
                target: root
                function onFilesChanged(): void {
                    win.jumpToCurrent();
                }
                function onCurrentFileChanged(): void {
                    win.jumpToCurrent();
                }
            }

            HyprlandFocusGrab {
                active: win.visible
                windows: [win]
                onCleared: OverlayState.close()
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0.03, 0.025, 0.02, 0.86)

                MouseArea {
                    anchors.fill: parent
                    onClicked: OverlayState.close()
                }
            }

            Item {
                id: keySink
                anchors.fill: parent
                focus: win.visible
                z: 2

                Keys.onEscapePressed: OverlayState.close()
                Keys.onReturnPressed: win.applyCurrent()
                Keys.onEnterPressed: win.applyCurrent()
                Keys.onLeftPressed: carousel.decrementCurrentIndex()
                Keys.onRightPressed: carousel.incrementCurrentIndex()
                Keys.onUpPressed: carousel.decrementCurrentIndex()
                Keys.onDownPressed: carousel.incrementCurrentIndex()
                Keys.onPressed: event => {
                    if (event.text === "a" || event.text === "A") {
                        WallpaperState.toggle();
                        event.accepted = true;
                    }
                }

                WheelHandler {
                    onWheel: event => {
                        if (event.angleDelta.y > 0 || event.angleDelta.x < 0)
                            carousel.decrementCurrentIndex();
                        else
                            carousel.incrementCurrentIndex();
                        event.accepted = true;
                    }
                }
            }

            PathView {
                id: carousel
                z: 3
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -28
                height: win.cardH + 36
                model: root.files
                pathItemCount: Math.min(7, count)
                preferredHighlightBegin: 0.5
                preferredHighlightEnd: 0.5
                highlightRangeMode: PathView.StrictlyEnforceRange
                highlightMoveDuration: Theme.motion.slow
                flickDeceleration: 1200

                path: Path {
                    startX: 0
                    startY: carousel.height / 2
                    PathAttribute { name: "zOrder"; value: 0 }
                    PathAttribute { name: "itemScale"; value: 0.58 }
                    PathAttribute { name: "itemOpacity"; value: 0.45 }
                    PathAttribute { name: "rot"; value: 46 }

                    PathLine { x: carousel.width * 0.5; y: carousel.height / 2 }
                    PathAttribute { name: "zOrder"; value: 200 }
                    PathAttribute { name: "itemScale"; value: 1 }
                    PathAttribute { name: "itemOpacity"; value: 1 }
                    PathAttribute { name: "rot"; value: 0 }

                    PathLine { x: carousel.width; y: carousel.height / 2 }
                    PathAttribute { name: "zOrder"; value: 0 }
                    PathAttribute { name: "itemScale"; value: 0.58 }
                    PathAttribute { name: "itemOpacity"; value: 0.45 }
                    PathAttribute { name: "rot"; value: -46 }
                }

                delegate: Item {
                    id: card
                    required property var modelData
                    required property int index
                    width: win.cardW
                    height: win.cardH
                    z: PathView.onPath ? PathView.zOrder : 0
                    scale: PathView.onPath ? PathView.itemScale : 1
                    opacity: PathView.onPath ? PathView.itemOpacity : 0
                    visible: PathView.onPath

                    readonly property bool selected: PathView.isCurrentItem
                    readonly property real tilt: PathView.onPath ? PathView.rot : 0
                    readonly property bool gif: `${modelData}`.toLowerCase().endsWith(".gif")

                    transform: Rotation {
                        origin.x: card.tilt > 0 ? card.width : (card.tilt < 0 ? 0 : card.width / 2)
                        origin.y: card.height / 2
                        axis { x: 0; y: 1; z: 0 }
                        angle: card.tilt
                    }

                    Rectangle {
                        visible: card.selected
                        anchors.fill: parent
                        anchors.margins: -14
                        radius: Theme.r.xl
                        color: "transparent"
                        border.width: 1
                        border.color: Qt.alpha(Colors.accent, 0.55)
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.r.lg
                        color: Theme.colors.background
                        clip: true

                        Image {
                            anchors.fill: parent
                            visible: !(card.gif && card.selected)
                            source: root.fileUrl(modelData)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            sourceSize.width: 720
                            sourceSize.height: 405
                        }

                        AnimatedImage {
                            anchors.fill: parent
                            visible: card.gif && card.selected
                            source: card.selected && card.gif ? root.fileUrl(modelData) : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            playing: card.selected && OverlayState.wallpaper
                        }
                    }

                    Rectangle {
                        visible: card.gif
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 14
                        width: 36
                        height: 18
                        radius: Theme.r.xs
                        color: Qt.alpha(Colors.background, 0.72)
                        border.width: 1
                        border.color: Qt.alpha(Colors.accent, 0.7)

                        Text {
                            anchors.centerIn: parent
                            text: "GIF"
                            color: Colors.foreground
                            font.family: Theme.font.ui
                            font.pixelSize: Theme.type.caption
                            font.bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (card.selected)
                                win.apply(modelData);
                            else
                                carousel.currentIndex = card.index;
                        }
                    }
                }
            }

            Text {
                z: 4
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: carousel.bottom
                anchors.topMargin: 4
                text: root.files.length ? root.prettyName(win.currentPath) : "no wallpapers"
                color: Colors.foreground
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.headline
                font.weight: Font.DemiBold
            }

            Row {
                z: 5
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 26
                spacing: Theme.space.md

                Rectangle {
                    width: autoLabel.implicitWidth + 28
                    height: 32
                    radius: Theme.r.pill
                    color: WallpaperState.rotating ? Colors.accent : Qt.alpha(Colors.foreground, 0.08)
                    border.width: 1
                    border.color: WallpaperState.rotating ? Colors.accent : Qt.alpha(Colors.foreground, 0.16)

                    Text {
                        id: autoLabel
                        anchors.centerIn: parent
                        text: WallpaperState.rotating ? "Auto on" : "Auto off"
                        color: WallpaperState.rotating ? Colors.background : Colors.foreground
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.label
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WallpaperState.toggle()
                    }
                }

                Rectangle {
                    width: everyLabel.implicitWidth + 28
                    height: 32
                    radius: Theme.r.pill
                    color: Qt.alpha(Colors.foreground, 0.08)
                    border.width: 1
                    border.color: Qt.alpha(Colors.foreground, 0.16)
                    opacity: WallpaperState.rotating ? 1 : 0.55

                    Text {
                        id: everyLabel
                        anchors.centerIn: parent
                        text: `every ${WallpaperState.minutes} min`
                        color: Colors.foreground
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.label
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WallpaperState.cycleMinutes()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.files.length > 0
                    text: `${carousel.currentIndex + 1} / ${root.files.length}   ·   enter set   ·   a auto   ·   esc`
                    color: Colors.color8
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.caption
                }
            }

            Text {
                z: 4
                anchors.verticalCenter: carousel.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 28
                text: "‹"
                color: Qt.alpha(Colors.foreground, 0.7)
                font.pixelSize: 42
                visible: root.files.length > 1

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -12
                    cursorShape: Qt.PointingHandCursor
                    onClicked: carousel.decrementCurrentIndex()
                }
            }

            Text {
                z: 4
                anchors.verticalCenter: carousel.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 28
                text: "›"
                color: Qt.alpha(Colors.foreground, 0.7)
                font.pixelSize: 42
                visible: root.files.length > 1

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -12
                    cursorShape: Qt.PointingHandCursor
                    onClicked: carousel.incrementCurrentIndex()
                }
            }
        }
    }
}
