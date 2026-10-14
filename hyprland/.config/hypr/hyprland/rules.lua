hl.window_rule({
    name = "opacity-override",
    match = { fullscreen = false },
    opacity = windowOpacity,
})

hl.window_rule({
    name = "kitty-opaque",
    match = { class = "kitty" },
    opacity = 1,
})

hl.window_rule({
    name = "opaque-native",
    match = { class = "equibop|org\\.quickshell|imv|swappy" },
    opaque = true,
})

hl.window_rule({
    name = "center-float",
    match = { float = true, xwayland = false },
    center = true,
})

local float_classes = {
    "guifetch", "yad", "zenity", "wev",
    "org\\.gnome\\.FileRoller", "file-roller",
    "blueman-manager", "com\\.github\\.GradienceTeam\\.Gradience",
    "feh", "imv", "system-config-printer", "org\\.quickshell",
}

for _, cls in ipairs(float_classes) do
    hl.window_rule({
        name = "float-" .. cls,
        match = { class = cls },
        float = true,
    })
end

hl.window_rule({
    name = "nmtui-float",
    match = { class = "kitty", title = "nmtui" },
    float = true,
    size = { "60%", "70%" },
    center = true,
})

hl.window_rule({
    name = "gnome-settings",
    match = { class = "org\\.gnome\\.Settings" },
    float = true,
    size = { "70%", "80%" },
    center = true,
})

hl.window_rule({
    name = "pavucontrol",
    match = { class = "org\\.pulseaudio\\.pavucontrol|yad-icon-browser" },
    float = true,
    size = { "60%", "70%" },
    center = true,
})

hl.window_rule({
    name = "nwg-look",
    match = { class = "nwg-look" },
    float = true,
    size = { "50%", "60%" },
    center = true,
})

hl.window_rule({
    name = "special-sysmon",
    match = { class = "btop" },
    workspace = "special:sysmon",
})

hl.window_rule({
    name = "special-music",
    match = { class = "feishin|Spotify|Supersonic|Cider|com\\.github\\.th_ch\\.youtube_music|Plexamp" },
    workspace = "special:music",
})

hl.window_rule({
    name = "special-music-title",
    match = { initial_title = "Spotify( Free)?" },
    workspace = "special:music",
})

hl.window_rule({
    name = "special-communication",
    match = { class = "discord|equibop|vesktop|whatsapp" },
    workspace = "special:communication",
})

hl.window_rule({
    name = "special-todo",
    match = { class = "Todoist" },
    workspace = "special:todo",
})

hl.window_rule({
    name = "modal-float",
    match = { modal = true },
    float = true,
    center = true,
})

hl.window_rule({
    name = "dialog-float",
    match = { title = ".*(Select|Open)( a)? (File|Folder)(s)?.*" },
    float = true,
})

hl.window_rule({
    name = "dialog-float-fileops",
    match = { title = ".*File (Operation|Upload)( Progress)?.*" },
    float = true,
})

hl.window_rule({
    name = "dialog-float-props",
    match = { title = ".* Properties" },
    float = true,
})

hl.window_rule({
    name = "dialog-float-export",
    match = { title = ".*Export Image as PNG.*" },
    float = true,
})

hl.window_rule({
    name = "dialog-float-gimp",
    match = { title = ".*GIMP Crash Debug.*" },
    float = true,
})

hl.window_rule({
    name = "dialog-float-save",
    match = { title = ".*Save As.*" },
    float = true,
})

hl.window_rule({
    name = "dialog-float-library",
    match = { title = "Library" },
    float = true,
})

hl.window_rule({
    name = "pip-move",
    match = { title = ".*Picture(-| )in(-| )[Pp]icture.*" },
    move = "100%-w-2%% 100%-w-3%%",
    keep_aspect_ratio = true,
    float = true,
    pin = true,
})

hl.window_rule({
    name = "creative-opaque",
    match = { class = "krita|gimp|inkscape|darktable|resolve|kdenlive|shotcut|blender|godot" },
    opaque = true,
})

hl.window_rule({
    name = "ueberzugpp-float",
    match = { class = "^(ueberzugpp_.*)$" },
    float = true,
    no_initial_focus = true,
})

hl.window_rule({
    name = "steam-rounding",
    match = { class = "steam" },
    rounding = 10,
})

hl.window_rule({
    name = "steam-friends-float",
    match = { class = "steam", title = "Friends List" },
    float = true,
})

hl.window_rule({
    name = "games-opaque",
    match = { class = "(steam_app_(default|[0-9]+))|gamescope" },
    opaque = true,
    immediate = true,
    idle_inhibit = "always",
})

hl.window_rule({
    name = "minecraft-launcher-float",
    match = { class = "com-atlauncher-App", title = "ATLauncher Console" },
    float = true,
})

hl.window_rule({
    name = "pandora-launcher-float",
    match = { class = "PandoraLauncher", title = "Minecraft Game Output" },
    float = true,
})

hl.window_rule({
    name = "fusion360-noblur",
    match = { class = "fusion360\\.exe", title = "Fusion360|(Marking Menu)" },
    no_blur = true,
})

hl.window_rule({
    name = "xwayland-popups",
    match = { xwayland = true, title = "win[0-9]+" },
    no_dim = true,
    no_shadow = true,
    rounding = 10,
})

hl.workspace_rule({
    workspace = "w[tv1]s[false]",
    gaps_out = singleWindowGapsOut,
})

hl.workspace_rule({
    workspace = "f[1]s[false]",
    gaps_out = singleWindowGapsOut,
})

hl.layer_rule({
    name = "fade-hyprpicker",
    match = { namespace = "hyprpicker" },
    animation = "fade",
})

hl.layer_rule({
    name = "fade-slurp",
    match = { namespace = "selection" },
    animation = "fade",
})

hl.layer_rule({
    name = "fade-wayfreeze",
    match = { namespace = "wayfreeze" },
    animation = "fade",
})

hl.layer_rule({
    name = "quickshell-blur",
    match = { namespace = "quickshell" },
    blur = true,
    ignore_alpha = 0.45,
})

hl.layer_rule({
    name = "quickshell-bar",
    match = { namespace = "quickshell-bar" },
    blur = false,
})

hl.layer_rule({
    name = "quickshell-notifications",
    match = { namespace = "quickshell-notifications" },
    blur = false,
})
