pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool rotating: false
    property bool pickerOpen: false
    property int minutes: 30

    readonly property var choices: [10, 30, 60]
    readonly property string wallScript: `${Quickshell.env("HOME")}/.config/hypr/scripts/wallpaper.sh`

    function toggle(): void {
        rotating = !rotating;
        save();
    }

    function cycleMinutes(): void {
        let i = choices.indexOf(minutes);
        if (i < 0)
            i = 1;
        minutes = choices[(i + 1) % choices.length];
        save();
    }

    function save(): void {
        store.setText(JSON.stringify({
            "rotating": root.rotating,
            "minutes": root.minutes
        }, null, 4) + "\n");
    }

    function read(raw: string): void {
        try {
            const data = JSON.parse(raw);
            root.rotating = !!data.rotating;
            const mins = Number(data.minutes);
            root.minutes = choices.indexOf(mins) >= 0 ? mins : 30;
        } catch (e) {
        }
    }

    Timer {
        id: clock
        interval: Math.max(1, root.minutes) * 60 * 1000
        repeat: true
        running: root.rotating && !root.pickerOpen
        onTriggered: Quickshell.execDetached(["bash", root.wallScript, "random"])
    }

    onMinutesChanged: {
        if (clock.running)
            clock.restart();
    }

    FileView {
        id: store
        path: `${Quickshell.env("HOME")}/.config/quickshell/data/wallpaper.json`
        watchChanges: true
        atomicWrites: true
        onFileChanged: reload()
        onLoaded: root.read(text())
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                root.save();
        }
    }
}
