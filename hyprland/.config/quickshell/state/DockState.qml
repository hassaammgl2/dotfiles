pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var ids: [
        "kitty",
        "brave-browser",
        "helium",
        "org.gnome.Nautilus",
        "cursor",
        "obsidian",
        "spotify"
    ]

    readonly property var entries: {
        const all = DesktopEntries.applications.values;
        const wanted = root.ids || [];
        const out = [];
        for (let i = 0; i < wanted.length; i++) {
            const raw = String(wanted[i] || "").trim();
            const key = raw.replace(/\.desktop$/i, "").toLowerCase();
            if (!key)
                continue;
            let found = null;
            for (let j = 0; j < all.length; j++) {
                const app = all[j];
                if (!app)
                    continue;
                const id = String(app.id || "").replace(/\.desktop$/i, "").toLowerCase();
                if (id === key) {
                    found = app;
                    break;
                }
            }
            if (!found) {
                for (let j = 0; j < all.length; j++) {
                    const app = all[j];
                    if (!app || app.noDisplay)
                        continue;
                    if (String(app.name || "").toLowerCase() === key) {
                        found = app;
                        break;
                    }
                }
            }
            out.push(found || {
                "id": raw,
                "name": raw,
                "missing": true
            });
        }
        return out;
    }

    function read(raw: string): void {
        if (!raw || !raw.trim().length)
            return;
        try {
            const data = JSON.parse(raw);
            if (data && data.apps)
                root.ids = data.apps;
        } catch (e) {
        }
    }

    FileView {
        path: `${Quickshell.env("HOME")}/.config/quickshell/data/dock.json`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.read(text())
    }
}
