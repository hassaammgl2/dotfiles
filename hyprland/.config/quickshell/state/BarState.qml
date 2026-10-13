pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property alias edge: adapter.edge
    property alias visible: adapter.visible
    property int popupHolds: 0
    property int pointerHolds: 0
    property bool pointerInside: false

    readonly property bool vertical: edge === "left" || edge === "right"

    function popupOpened(): void {
        popupHolds++;
    }

    function popupClosed(): void {
        if (popupHolds > 0)
            popupHolds--;
    }

    function pointerEntered(): void {
        pointerHolds++;
        pointerInside = true;
        leaveDelay.stop();
    }

    function pointerLeft(): void {
        pointerHolds = Math.max(0, pointerHolds - 1);
        if (pointerHolds === 0)
            leaveDelay.restart();
    }

    Timer {
        id: leaveDelay
        interval: 80
        repeat: false
        onTriggered: {
            if (root.pointerHolds === 0)
                root.pointerInside = false;
        }
    }

    function cycle(): void {
        const order = ["top", "bottom", "left", "right"];
        const i = Math.max(0, order.indexOf(edge));
        edge = order[(i + 1) % order.length];
    }

    FileView {
        path: Quickshell.statePath("bar.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter
            property string edge: "left"
            property bool visible: true
        }
    }
}
