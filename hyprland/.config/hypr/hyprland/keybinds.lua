hl.bind("SUPER + Space", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind("SUPER + K", hl.dsp.exec_cmd("qs ipc call notifs toggle"))

hl.bind(kbSession, hl.dsp.exec_cmd("qs ipc call power toggle"))
hl.bind(kbLock, hl.dsp.exec_cmd("qs ipc call lock lock"))

hl.bind("SUPER + F7", hl.dsp.exec_cmd("qs ipc call osd brightnessUp"), { locked = true, repeating = true })
hl.bind("SUPER + F6", hl.dsp.exec_cmd("qs ipc call osd brightnessDown"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("qs ipc call osd brightnessUp"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs ipc call osd brightnessDown"), { locked = true, repeating = true })

hl.bind("CTRL + SUPER + Space", hl.dsp.exec_cmd("qs ipc call media playPause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("qs ipc call media playPause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("qs ipc call media playPause"), { locked = true })
hl.bind("CTRL + SUPER + Equal", hl.dsp.exec_cmd("qs ipc call media next"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("qs ipc call media next"), { locked = true })
hl.bind("CTRL + SUPER + Minus", hl.dsp.exec_cmd("qs ipc call media previous"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("qs ipc call media previous"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("qs ipc call media stop"), { locked = true })

for i = 1, 10 do
	local key = i % 10
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
	hl.bind("CTRL + SUPER + " .. key, hl.dsp.focus({ workspace = 10 + i }))
	hl.bind("CTRL + SUPER + ALT + " .. key, hl.dsp.window.move({ workspace = 10 + i }))
end

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(kbPrevWs, hl.dsp.focus({ workspace = "e-1" }), { repeating = true })
hl.bind(kbNextWs, hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "e-1" }), { repeating = true })
hl.bind("SUPER + Page_Down", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })

hl.bind("CTRL + SUPER + mouse_down", hl.dsp.focus({ workspace = "e-10" }))
hl.bind("CTRL + SUPER + mouse_up", hl.dsp.focus({ workspace = "e+10" }))

hl.bind(kbToggleSpecialWs, hl.dsp.workspace.toggle_special("special"))

hl.bind("SUPER + ALT + Page_Up", hl.dsp.window.move({ workspace = "e-1" }), { repeating = true })
hl.bind("SUPER + ALT + Page_Down", hl.dsp.window.move({ workspace = "e+1" }), { repeating = true })
hl.bind("SUPER + ALT + mouse_down", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("SUPER + ALT + mouse_up", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind("CTRL + SUPER + SHIFT + right", hl.dsp.window.move({ workspace = "e+1" }), { repeating = true })
hl.bind("CTRL + SUPER + SHIFT + left", hl.dsp.window.move({ workspace = "e-1" }), { repeating = true })
hl.bind("CTRL + SUPER + SHIFT + up", hl.dsp.window.move({ workspace = "special:special" }))
hl.bind("CTRL + SUPER + SHIFT + down", hl.dsp.window.move({ workspace = "e+0" }))
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:special" }))
hl.bind("ALT + D", hl.dsp.exec_cmd("qs ipc call dashboard toggle"))
hl.bind("ALT + A", hl.dsp.exec_cmd("qs ipc call widgets toggle"))
hl.bind("ALT + SHIFT + A", hl.dsp.exec_cmd("qs ipc call widgets cycle"))

hl.bind(kbWindowGroupCycleNext, hl.dsp.window.cycle_next({ next = true }), { repeating = true })
hl.bind(kbWindowGroupCyclePrev, hl.dsp.window.cycle_next({ next = false }), { repeating = true })
hl.bind("CTRL + ALT + Tab", hl.dsp.group.next(), { repeating = true })
hl.bind("CTRL + SHIFT + ALT + Tab", hl.dsp.group.prev(), { repeating = true })
hl.bind(kbToggleGroup, hl.dsp.group.toggle())
hl.bind(kbUngroup, hl.dsp.window.move({ out_of_group = true }))
hl.bind("SUPER + SHIFT + Comma", hl.dsp.group.lock({ action = "toggle" }))

hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }))

hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

hl.bind("SUPER + Minus", hl.dsp.window.resize({ x = -80, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + Equal", hl.dsp.window.resize({ x = 80, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + Minus", hl.dsp.window.resize({ x = 0, y = -80, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + Equal", hl.dsp.window.resize({ x = 0, y = 80, relative = true }), { repeating = true })
hl.bind("SUPER + ALT + left", hl.dsp.window.resize({ x = -80, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + ALT + right", hl.dsp.window.resize({ x = 80, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + ALT + up", hl.dsp.window.resize({ x = 0, y = -80, relative = true }), { repeating = true })
hl.bind("SUPER + ALT + down", hl.dsp.window.resize({ x = 0, y = 80, relative = true }), { repeating = true })

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("CTRL + SUPER + Backslash", hl.dsp.window.center())
hl.bind("CTRL + SUPER + ALT + Backslash", function()
	hl.dispatch(hl.dsp.window.float({ action = "enable" }))
	hl.dispatch(hl.dsp.window.resize({ x = 1100, y = 750 }))
	hl.dispatch(hl.dsp.window.center())
end)

hl.bind(kbPinWindow, hl.dsp.window.pin({ action = "toggle" }))
hl.bind(kbWindowFullscreen, hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(kbWindowBorderedFullscreen, hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(kbToggleWindowFloating, hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + P", hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + SHIFT + J", hl.dsp.layout("swapsplit"))
hl.bind("SUPER + bracketleft", hl.dsp.layout("splitratio -0.05"), { repeating = true })
hl.bind("SUPER + bracketright", hl.dsp.layout("splitratio +0.05"), { repeating = true })
hl.bind("CTRL + SUPER + left", hl.dsp.window.swap({ direction = "left" }))
hl.bind("CTRL + SUPER + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind("CTRL + SUPER + up", hl.dsp.window.swap({ direction = "up" }))
hl.bind("CTRL + SUPER + down", hl.dsp.window.swap({ direction = "down" }))
hl.bind("SUPER + ALT + SHIFT + left", hl.dsp.window.move({ monitor = "l" }))
hl.bind("SUPER + ALT + SHIFT + right", hl.dsp.window.move({ monitor = "r" }))
hl.bind("SUPER + ALT + SHIFT + up", hl.dsp.window.move({ monitor = "u" }))
hl.bind("SUPER + ALT + SHIFT + down", hl.dsp.window.move({ monitor = "d" }))
hl.bind(kbCloseWindow, hl.dsp.window.close())

hl.bind(kbSystemMonitor, hl.dsp.workspace.toggle_special("sysmon"))
hl.bind(kbMusic, hl.dsp.workspace.toggle_special("music"))
hl.bind(kbCommunication, hl.dsp.workspace.toggle_special("communication"))
hl.bind(kbTodo, hl.dsp.workspace.toggle_special("todo"))

hl.bind(kbTerminal, hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("kitty --title tmux -e ~/.config/hypr/scripts/tmux-session.sh"))
hl.bind(kbBrowser, hl.dsp.exec_cmd(browser))
hl.bind(kbHBrowser, hl.dsp.exec_cmd(browser_helium))
hl.bind(kbEditor, hl.dsp.exec_cmd(editor))
hl.bind(kbFileExplorer, hl.dsp.exec_cmd(fileExplorer))
hl.bind("SUPER + ALT + E", hl.dsp.exec_cmd("dolphin"))
hl.bind("ALT + T", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-bar.sh"))
hl.bind("ALT + SHIFT + T", hl.dsp.exec_cmd("~/.config/hypr/scripts/bar-orient.sh"))
hl.bind("CTRL + ALT + Escape", hl.dsp.exec_cmd("qps"))
hl.bind("CTRL + ALT + V", hl.dsp.exec_cmd("pavucontrol"))

hl.bind("Print", hl.dsp.exec_cmd("qs ipc call screenshot toggle"), { locked = true })
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("qs ipc call screenshot toggle"))
hl.bind("SUPER + SHIFT + ALT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd("wf-recorder --audio -f ~/Videos/recording_$(date +%s).mp4"))
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd("wf-recorder -f ~/Videos/recording_$(date +%s).mp4"))
hl.bind("SUPER + SHIFT + ALT + R", hl.dsp.exec_cmd('wf-recorder -g "$(slurp)" -f ~/Videos/recording_$(date +%s).mp4'))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind("ALT + W", hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))
hl.bind("ALT + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper.sh next"))
hl.bind("CTRL + ALT + W", hl.dsp.exec_cmd("qs ipc call wallpaper autoToggle"))
hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd("qs ipc call media toggle"))

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("qs ipc call osd micMute"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("qs ipc call osd volumeMute"), { locked = true })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("qs ipc call osd volumeMute"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("qs ipc call osd volumeUp"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("qs ipc call osd volumeDown"), { locked = true, repeating = true })
hl.bind("SUPER + F3", hl.dsp.exec_cmd("qs ipc call osd volumeUp"), { locked = true, repeating = true })
hl.bind("SUPER + F2", hl.dsp.exec_cmd("qs ipc call osd volumeDown"), { locked = true, repeating = true })
hl.bind("SUPER + F1", hl.dsp.exec_cmd("qs ipc call osd volumeMute"), { locked = true })

hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend-then-hibernate"), { locked = true })

hl.bind("SUPER + V", hl.dsp.exec_cmd("qs ipc call clipboard toggle"))
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd("qs ipc call clipboard toggleDelete"))
hl.bind("SUPER + Period", hl.dsp.exec_cmd("qs ipc call emoji toggle"))
hl.bind(
	"CTRL + SHIFT + ALT + V",
	hl.dsp.exec_cmd('sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"'),
	{ locked = true }
)

hl.bind("ALT + H", hl.dsp.exec_cmd("qs ipc call keybinds toggle"))

hl.bind(
	"SUPER + ALT + f12",
	hl.dsp.exec_cmd(
		'notify-send -u low -i dialog-information-symbolic \'Test notification\' "Here\'s a really long message to test truncation and wrapping\\nSwipe right, middle click, or press X to dismiss." -a \'Shell\' -A "Test1=I got it!" -A "Test2=Another action"'
	)
)
