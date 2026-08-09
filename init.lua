-- ==== WAYWALL GENERIC CONFIG ====
local main = require("main")

local remaps = require("remaps")

local cfg = {
    debug_text = false,

    -- ==== LOOKS ====
    resolution = { 2560, 1440 },

    bg_col = "#000000",
    toggle_bg_picture = true,
    text_col = "#FFFFFF",
    pie_chart_1 = "#EC6E4E",
    pie_chart_2 = "#46CE66",
    pie_chart_3 = "#E446C4",

    ninbot_anchor = {
        position = "topright",
        x = 0,
        y = 0,
    },
    ninbot_opacity = 1,


    -- ==== ALTERNATIVE RESOLUTIONS ====
    thin_res = { 350, 1100 },
    wide_res = { 2560, 400 },
    tall_res = { 384, 16384 },


    -- ==== MIRRORS ====
    -- Custom mirrors are defined in extras.lua.
    e_count = { enabled = false, x = 1500, y = 400, size = 5, colorkey = false, show_c = false },
    thin_pie = { enabled = false, x = 1490, y = 645, size = 4, colorkey = false },
    tall_pie = { enabled = false, x = 1490, y = 645, size = 4, colorkey = false },
    thin_percent = { enabled = false, x = 1600, y = 1100, size = 6 },
    tall_percent = { enabled = false, x = 1600, y = 1100, size = 6 },
    percentages_match_text = false,

    measuring_window = { x = 94, y = 470, w = 900, h = 500 },
    stretched_measure = false,


    -- ==== MACROS ====
    -- resolution changes
    thin = { key = "*-Grave", f3_safe = false, ingame_only = false },
    wide = { key = "*-B", f3_safe = true, ingame_only = false },
    tall = { key = "*-F4", f3_safe = false, ingame_only = false },

    -- startup actions
    toggle_fullscreen_key = "Shift-O",
    launch_paceman_key = nil,

    -- during game actions
    toggle_ninbot_key = "*-apostrophe",
    toggle_remaps_key = "Insert",


    -- ==== KEYBOARD ====
    xkb_config = {
        enabled = false,
        layout = "mc",
        rules = nil,
        variant = "basic",
        options = "caps:none",
    },
    remaps_text_config = { text = "remaps off", x = 100, y = 100, size = 2, color = "#000000" },


    -- ==== MISC ====
    sens_change = { enabled = true, normal = 4.06892586, tall = 0.2744873, raw_input = false },
    enable_resize_animations = false,
}

return main(cfg, remaps)
