pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool busy: false
    property bool ready: false
    property bool finishing: false
    property bool aborted: false
    property var shots: []
    property var windows: []
    property string owner: ""
    property real selX: 0
    property real selY: 0
    property real selW: 0
    property real selH: 0
    property bool hasSelection: false
    property string hoverScreen: ""
    property real hoverX: 0
    property real hoverY: 0
    property real hoverW: 0
    property real hoverH: 0
    property bool hasHover: false

    readonly property string script: `${Quickshell.env("HOME")}/.config/hypr/scripts/screenshot-capture.sh`
    readonly property string cacheRoot: `${Quickshell.env("HOME")}/.cache/quickshell/screenshot`
    readonly property string shotDir: `${Quickshell.env("HOME")}/Pictures/Screenshots`

    function begin(): void {
        if (root.busy)
            return;
        root.aborted = false;
        root.ready = false;
        root.finishing = false;
        root.shots = [];
        root.windows = [];
        root.clearSelection();
        root.busy = true;
        OverlayState.close();
        hideDelay.restart();
    }

    function cancel(): void {
        const live = root.busy || OverlayState.screenshot || hideDelay.running || freeze.running || finish.running;
        if (!live)
            return;
        root.aborted = true;
        hideDelay.stop();
        root.ready = false;
        root.finishing = false;
        root.clearSelection();
        OverlayState.screenshot = false;
        if (freeze.running)
            freeze.signal(15);
        if (finish.running)
            finish.signal(15);
        if (!freeze.running && !finish.running) {
            root.busy = false;
            root.aborted = false;
        }
    }

    function dismiss(): void {
        root.ready = false;
        root.busy = false;
        root.finishing = false;
        root.clearSelection();
        OverlayState.screenshot = false;
    }

    function clearSelection(): void {
        root.hasSelection = false;
        root.hasHover = false;
        root.owner = "";
        root.selW = 0;
        root.selH = 0;
    }

    function select(screenName: string, x: real, y: real, w: real, h: real): void {
        if (w < 2 || h < 2) {
            root.clearSelection();
            return;
        }
        root.owner = screenName;
        root.selX = x;
        root.selY = y;
        root.selW = w;
        root.selH = h;
        root.hasSelection = true;
        root.hasHover = false;
    }

    function setHover(screenName: string, x: real, y: real, w: real, h: real): void {
        if (root.hasSelection)
            return;
        if (w < 2 || h < 2) {
            root.clearHover();
            return;
        }
        root.hoverScreen = screenName;
        root.hoverX = x;
        root.hoverY = y;
        root.hoverW = w;
        root.hoverH = h;
        root.hasHover = true;
    }

    function clearHover(): void {
        root.hasHover = false;
    }

    function shotFor(screen: var): var {
        const list = root.shots;
        if (!list)
            return null;
        for (let i = 0; i < list.length; i++) {
            if (list[i].name === screen.name)
                return list[i];
        }
        for (let i = 0; i < list.length; i++) {
            if (list[i].x === screen.x && list[i].y === screen.y)
                return list[i];
        }
        return null;
    }

    function finish(action: string, src: string, x: int, y: int, w: int, h: int): void {
        if (root.finishing || !root.ready || root.busy)
            return;
        if (w < 1 || h < 1 || !src)
            return;
        root.finishing = true;
        root.busy = true;
        const out = `${root.cacheRoot}/last.png`;
        finish.exec(["bash", root.script, "finish", src, String(x), String(y), String(w), String(h), action, root.shotDir, out]);
    }

    function fail(message: string): void {
        Quickshell.execDetached(["notify-send", "-u", "critical", "Screenshot", message]);
    }

    Timer {
        id: hideDelay
        interval: 160
        repeat: false
        onTriggered: {
            if (root.aborted || !root.busy)
                return;
            freeze.exec(["bash", root.script, "freeze", root.cacheRoot]);
        }
    }

    Process {
        id: freeze

        stdout: StdioCollector {
            id: freezeOut
            waitForEnd: true
        }
        stderr: StdioCollector {
            id: freezeErr
            waitForEnd: true
        }

        onExited: (exitCode, exitStatus) => {
            if (root.aborted) {
                root.aborted = false;
                root.busy = false;
                return;
            }
            root.busy = false;
            if (exitCode !== 0) {
                const why = (freezeErr.text || "").trim().split("\n")[0];
                root.fail(why || "Capture failed");
                return;
            }
            let data = null;
            try {
                data = JSON.parse(freezeOut.text);
            } catch (e) {
                data = null;
            }
            if (!data || !data.screens || data.screens.length === 0) {
                root.fail("Capture failed");
                return;
            }
            root.shots = data.screens;
            root.windows = data.windows || [];
            root.ready = true;
            OverlayState.showScreenshot();
        }
    }

    Process {
        id: finish

        stderr: StdioCollector {
            id: finishErr
            waitForEnd: true
        }

        onExited: (exitCode, exitStatus) => {
            root.finishing = false;
            if (root.aborted) {
                root.aborted = false;
                root.busy = false;
                return;
            }
            root.busy = false;
            if (exitCode === 0) {
                root.dismiss();
                return;
            }
            const why = (finishErr.text || "").trim().split("\n")[0];
            root.fail(why || "Could not save that selection");
        }
    }
}
