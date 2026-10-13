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
        "obsidian"
    ]
    property string saved: ""

    readonly property var entries: {
        const all = DesktopEntries.applications.values;
        const wanted = root.ids || [];
        const out = [];
        for (let i = 0; i < wanted.length; i++) {
            const raw = String(wanted[i] || "").trim();
            const key = root.norm(raw);
            if (!key)
                continue;
            let found = null;
            for (let j = 0; j < all.length; j++) {
                const app = all[j];
                if (!app)
                    continue;
                if (root.norm(app.id) === key) {
                    found = app;
                    break;
                }
            }
            if (!found) {
                for (let j = 0; j < all.length; j++) {
                    const app = all[j];
                    if (!app || app.noDisplay)
                        continue;
                    if (root.norm(app.name) === key) {
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

    function norm(id): string {
        return String(id || "").replace(/\.desktop$/i, "").trim().toLowerCase();
    }

    function entryId(app): string {
        return String(app && app.id || "").replace(/\.desktop$/i, "").trim();
    }

    function contains(id): bool {
        const key = root.norm(id);
        const list = root.ids || [];
        for (let i = 0; i < list.length; i++) {
            if (root.norm(list[i]) === key)
                return true;
        }
        return false;
    }

    function search(query): var {
        const q = String(query || "").trim().toLowerCase();
        const all = DesktopEntries.applications.values;
        const out = [];
        const seen = {};
        for (let i = 0; i < all.length; i++) {
            const app = all[i];
            if (!app || app.noDisplay || !app.name)
                continue;
            const id = root.entryId(app);
            if (!id || seen[id.toLowerCase()])
                continue;
            const blob = `${app.name} ${app.genericName || ""} ${app.comment || ""} ${id}`.toLowerCase();
            if (q && blob.indexOf(q) < 0)
                continue;
            seen[id.toLowerCase()] = true;
            out.push({
                "id": id,
                "name": app.name,
                "icon": app.icon || "application-x-executable"
            });
        }
        out.sort((a, b) => String(a.name).localeCompare(String(b.name)));
        return out.slice(0, 80);
    }

    function save(): void {
        const body = JSON.stringify({
            "apps": (root.ids || []).slice()
        }, null, 4) + "\n";
        if (body === root.saved)
            return;
        root.saved = body;
        store.setText(body);
    }

    function toggle(id): void {
        const key = root.norm(id);
        if (!key)
            return;
        const list = (root.ids || []).slice();
        const at = list.findIndex(item => root.norm(item) === key);
        if (at >= 0)
            list.splice(at, 1);
        else
            list.push(String(id).replace(/\.desktop$/i, "").trim());
        root.ids = list;
        root.save();
    }

    function removeAt(index: int): void {
        const list = (root.ids || []).slice();
        if (index < 0 || index >= list.length)
            return;
        list.splice(index, 1);
        root.ids = list;
        root.save();
    }

    function move(from: int, to: int): void {
        const list = (root.ids || []).slice();
        if (from < 0 || to < 0 || from >= list.length || to >= list.length || from === to)
            return;
        const item = list.splice(from, 1)[0];
        list.splice(to, 0, item);
        root.ids = list;
        root.save();
    }

    function read(raw): void {
        if (!raw || !String(raw).trim().length)
            return;
        try {
            const data = JSON.parse(raw);
            const apps = data && data.apps;
            if (!Array.isArray(apps))
                return;
            const next = [];
            for (let i = 0; i < apps.length; i++) {
                const id = String(apps[i] || "").replace(/\.desktop$/i, "").trim();
                if (id)
                    next.push(id);
            }
            root.ids = next;
            root.saved = JSON.stringify({
                "apps": next
            }, null, 4) + "\n";
        } catch (e) {
        }
    }

    FileView {
        id: store
        path: `${Quickshell.env("HOME")}/.config/quickshell/data/dock.json`
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
