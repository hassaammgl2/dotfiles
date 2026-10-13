import Quickshell
import Quickshell.Io
import qs.bar
import qs.overlays.notifications
import qs.overlays.launcher
import qs.overlays.power
import qs.overlays.media
import qs.overlays.screenshot
import qs.overlays.wallpaper
import qs.overlays.keybinds
import qs.overlays.clipboard
import qs.overlays.emoji
import qs.overlays.lock
import qs.overlays.osd
import qs.overlays.dashboard
import qs.overlays.desktopWidgets
import qs.overlays.controlCenter
import qs.state

Scope {
    Bar {}
    Notifications {}
    NotifSidebar {}
    LauncherOverlay {}
    PowerOverlay {}
    MediaOverlay {}
    ScreenshotOverlay {}
    WallpaperOverlay {}
    KeybindsOverlay {}
    ClipboardOverlay {}
    EmojiOverlay {}
    LockOverlay {}
    OsdOverlay {}
    DashOverlay {}
    DesktopWidgets {}
    ControlCenter {}

    IpcHandler {
        target: "control"

        function toggle(): void {
            OverlayState.toggleControlCenter();
        }

        function show(): void {
            OverlayState.showControlCenter();
        }

        function hide(): void {
            OverlayState.controlCenter = false;
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            OverlayState.toggleLauncher();
        }

        function show(): void {
            OverlayState.showLauncher();
        }

        function hide(): void {
            OverlayState.launcher = false;
        }
    }

    IpcHandler {
        target: "power"

        function toggle(): void {
            OverlayState.togglePower();
        }

        function show(): void {
            OverlayState.showPower();
        }

        function hide(): void {
            OverlayState.power = false;
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            OverlayState.toggleWallpaper();
        }

        function show(): void {
            OverlayState.showWallpaper();
        }

        function hide(): void {
            OverlayState.wallpaper = false;
        }
    }

    IpcHandler {
        target: "notifs"

        function toggle(): void {
            OverlayState.toggleNotifs();
        }

        function show(): void {
            OverlayState.showNotifs();
        }

        function hide(): void {
            OverlayState.notifs = false;
        }
    }

    IpcHandler {
        target: "keybinds"

        function toggle(): void {
            OverlayState.toggleKeybinds();
        }

        function show(): void {
            OverlayState.showKeybinds();
        }

        function hide(): void {
            OverlayState.keybinds = false;
        }
    }

    IpcHandler {
        target: "clipboard"

        function toggle(): void {
            OverlayState.toggleClipboard(false);
        }

        function toggleDelete(): void {
            OverlayState.toggleClipboard(true);
        }

        function show(): void {
            OverlayState.showClipboard(false);
        }

        function hide(): void {
            OverlayState.clipboard = false;
            OverlayState.clipboardDelete = false;
        }
    }

    IpcHandler {
        target: "emoji"

        function toggle(): void {
            OverlayState.toggleEmoji();
        }

        function show(): void {
            OverlayState.showEmoji();
        }

        function hide(): void {
            OverlayState.emoji = false;
        }
    }

    IpcHandler {
        target: "media"

        function toggle(): void {
            OverlayState.toggleMedia();
        }

        function show(): void {
            OverlayState.showMedia();
        }

        function hide(): void {
            OverlayState.media = false;
        }

        function playPause(): void {
            MediaState.toggle();
        }

        function next(): void {
            MediaState.next();
        }

        function previous(): void {
            MediaState.prev();
        }

        function stop(): void {
            MediaState.stop();
        }
    }

    IpcHandler {
        target: "screenshot"

        function toggle(): void {
            if (OverlayState.screenshot || ScreenshotState.busy)
                ScreenshotState.cancel();
            else
                ScreenshotState.begin();
        }

        function show(): void {
            if (!OverlayState.screenshot && !ScreenshotState.busy)
                ScreenshotState.begin();
        }

        function hide(): void {
            ScreenshotState.cancel();
        }
    }

    IpcHandler {
        target: "dashboard"

        function toggle(): void {
            OverlayState.toggleDashboard();
        }

        function show(): void {
            OverlayState.showDashboard();
        }

        function hide(): void {
            OverlayState.dashboard = false;
        }
    }
}
