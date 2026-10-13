pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.state

Singleton {
    id: root

    function mix(a: color, b: color, t: real): color {
        const x = Math.max(0, Math.min(1, t));
        return Qt.rgba(a.r + (b.r - a.r) * x, a.g + (b.g - a.g) * x, a.b + (b.b - a.b) * x, 1);
    }

    function withAlpha(c: color, a: real): color {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function barReserve(edge: string): int {
        return 0;
    }

    function osdX(screenW: int): int {
        return Math.round((Math.max(0, screenW) - osd.width) / 2);
    }

    function launcherCols(screenW: int): int {
        if (screenW >= 2560)
            return 6;
        if (screenW >= 1920)
            return 5;
        return 4;
    }

    function panelWidth(screenW: int): int {
        return Math.min(340, Math.max(280, Math.round(screenW * 0.26)));
    }

    readonly property QtObject colors: QtObject {
        readonly property color background: pal.background
        readonly property color surface: root.mix(pal.background, pal.foreground, 0.07)
        readonly property color surfaceElevated: root.mix(pal.background, pal.foreground, 0.12)
        readonly property color surfaceVariant: pal.color0
        readonly property color text: pal.foreground
        readonly property color textSecondary: root.mix(pal.foreground, pal.background, 0.28)
        readonly property color textMuted: pal.color8
        readonly property color accent: pal.color4
        readonly property color accentStrong: pal.color12
        readonly property color accentSoft: root.withAlpha(pal.color4, 0.2)
        readonly property color success: pal.color2
        readonly property color warning: pal.color3
        readonly property color error: pal.color1
        readonly property color info: pal.color6
        readonly property color border: root.withAlpha(pal.foreground, 0.1)
        readonly property color borderSubtle: root.withAlpha(pal.foreground, 0.06)
        readonly property color scrim: root.withAlpha(pal.background, 0.45)
        readonly property color onAccent: pal.background
    }

    readonly property QtObject font: QtObject {
        readonly property string ui: "Adwaita Sans"
        readonly property string mono: "JetBrainsMono Nerd Font"
        readonly property string icon: "JetBrainsMono Nerd Font"
    }

    readonly property QtObject type: QtObject {
        readonly property int display: 56
        readonly property int headline: 26
        readonly property int title: 15
        readonly property int body: 13
        readonly property int label: 12
        readonly property int caption: 11
        readonly property int mono: 12
        readonly property int monoSmall: 11
        readonly property int icon: 16
        readonly property int iconSm: 14
        readonly property int iconLg: 20
    }

    readonly property QtObject space: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 24
        readonly property int xxl: 32
    }

    readonly property QtObject r: QtObject {
        readonly property int xs: 6
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 20
        readonly property int pill: 999
    }

    readonly property QtObject motion: QtObject {
        readonly property int fast: 110
        readonly property int normal: 170
        readonly property int slow: 240
        readonly property int enter: Easing.OutCubic
        readonly property int exit: Easing.InCubic
    }

    readonly property QtObject icons: QtObject {
        readonly property string launcher: ""
        readonly property string power: "󰐥"
        readonly property string lock: "󰌾"
        readonly property string logout: "󰗽"
        readonly property string sleep: "󰒲"
        readonly property string reboot: "󰜉"
        readonly property string search: "󰍉"
        readonly property string close: "󰅖"
        readonly property string wifi: "󰤨"
        readonly property string wifiOff: "󰤮"
        readonly property string wifiFair: "󰤢"
        readonly property string ethernet: "󰈀"
        readonly property string bluetooth: "󰂯"
        readonly property string bluetoothOff: "󰂲"
        readonly property string bluetoothConn: "󰂱"
        readonly property string volume: "󰕾"
        readonly property string volumeLow: "󰖀"
        readonly property string volumeMute: "󰝟"
        readonly property string mic: "󰍬"
        readonly property string micOff: "󰍭"
        readonly property string brightness: "󰃠"
        readonly property string brightnessLow: "󰃞"
        readonly property string battery: "󰁹"
        readonly property string cpu: "󰍛"
        readonly property string widgets: "󰄛"
        readonly property string tray: "󰇷"
        readonly property string play: "󰐊"
        readonly property string pause: "󰏤"
        readonly property string next: "󰒭"
        readonly property string prev: "󰒮"
        readonly property string stop: "󰓛"
        readonly property string music: "󰝚"
        readonly property string screenshot: "󰹑"
        readonly property string region: "󰆞"
        readonly property string window: "󰖯"
        readonly property string copy: "󰆏"
        readonly property string save: "󰆓"
        readonly property string eye: "󰈈"
        readonly property string eyeOff: "󰈉"
        readonly property string calendar: "󰸗"
        readonly property string uptime: "󰔟"
        readonly property string refresh: "󰑐"
        readonly property string lockSmall: "󰌾"
        readonly property string chevronLeft: "󰅁"
        readonly property string chevronRight: "󰅂"
        readonly property string clipboard: "󰅌"
        readonly property string image: "󰋩"
        readonly property string raise: "󰆧"
    }

    readonly property QtObject bar: QtObject {
        readonly property int size: 44
        readonly property int item: 36
        readonly property int icon: 18
        readonly property int pill: 26
    }

    readonly property QtObject osd: QtObject {
        readonly property int width: 260
        readonly property int height: 52
    }

    FileView {
        path: `${Quickshell.env("HOME")}/.cache/wallust/quickshell.json`
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: pal
            property string background: "#17171F"
            property string foreground: "#FDF4F3"
            property string cursor: "#87A6B5"
            property string color0: "#42414C"
            property string color1: "#3B4764"
            property string color2: "#446D7F"
            property string color3: "#82828C"
            property string color4: "#598F93"
            property string color5: "#899A94"
            property string color6: "#BBA8A7"
            property string color7: "#F4E7E6"
            property string color8: "#ABA2A1"
            property string color9: "#3C4B73"
            property string color10: "#477E95"
            property string color11: "#848393"
            property string color12: "#36939A"
            property string color13: "#B7CDC5"
            property string color14: "#FAE0DE"
            property string color15: "#F4E7E6"
        }
    }
}
