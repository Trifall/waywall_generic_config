-- ==== WAYWALL ====
local waywall = require("waywall")
local helpers = require("waywall.helpers")

-- ==== USER CONFIG ====
local cfg = require("config")
local keyboard_remaps = require("remaps").remapped_kb
local other_remaps = require("remaps").normal_kb

-- ==== RESOURCES ====
local waywall_config_path = os.getenv("HOME") .. "/.config/waywall/"
local bg_path = waywall_config_path .. "resources/background.png"
local tall_overlay_path = waywall_config_path .. "resources/overlay_tall.png"
local thin_overlay_path = waywall_config_path .. "resources/overlay_thin.png"
local wide_overlay_path = waywall_config_path .. "resources/overlay_wide.png"

local nb_path = waywall_config_path .. "resources/Ninjabrain-Bot-1.5.2.jar"
local overlay_path = waywall_config_path .. "resources/measuring_overlay.png"
local stretched_overlay_path = waywall_config_path .. "resources/stretched_overlay.png"

local read_file = function(name)
    local file = io.open(waywall_config_path .. name, "r")
    if file then
        local data = file:read("*a")
        file:close()
        return data
    else
        print("Error: File \"" .. name .. "\" not found.")
        return ""
    end
end

-- ==== INITS ====
local remaps_active = true
local rebind_text = nil
local thin_active = false

-- ==== CONFIG TABLE ====
local config = {
    input = {
        layout = (cfg.remaps_config.enabled and cfg.remaps_config.layout_name) or "us",
        repeat_rate = 40,
        repeat_delay = 300,
        remaps = keyboard_remaps,
        sensitivity = (cfg.sens_change.enabled and cfg.sens_change.normal) or 1.0,
        confine_pointer = false,
    },
    theme = {
        background = cfg.bg_col,
        background_png = cfg.toggle_bg_picture and bg_path or nil,
        ninb_anchor = cfg.ninbot_anchor,
        ninb_opacity = cfg.ninbot_opacity,
    },
    experimental = {
        debug = false,
        jit = false,
        tearing = false,
        scene_add_text = true,
    },
    shaders = {
        ["pie_chart"] = {
            vertex = read_file("shaders/general.vert"),
            fragment = read_file("shaders/colors.glsl") .. "\n" .. read_file("shaders/pie_chart.frag"),
        },
        ["pie_border"] = {
            vertex = read_file("shaders/general.vert"),
            fragment = read_file("shaders/colors.glsl") .. "\n" .. read_file("shaders/pie_border.frag"),
        },
        ["text"] = {
            vertex = read_file("shaders/general.vert"),
            fragment = read_file("shaders/colors.glsl") .. "\n" .. read_file("shaders/text.frag"),
        },
        ["text_bg"] = {
            vertex = read_file("shaders/general.vert"),
            fragment = read_file("shaders/colors.glsl") .. "\n" .. read_file("shaders/text_bg.frag"),
        },
        ["text_colored"] = {
            vertex = read_file("shaders/general.vert"),
            fragment = read_file("shaders/text_colored.frag"),
        },
        ["text_colored_bg"] = {
            vertex = read_file("shaders/general.vert"),
            fragment = read_file("shaders/text_colored_bg.frag"),
        },
    },
}


-- ==== NINJABRAIN ====
local is_ninb_running = function()
    local handle = io.popen("exec pgrep -f 'Ninjabrain.*jar'")
    local result = handle:read("*l")
    handle:close()
    return result ~= nil
end

-- ==== MIRRORS ====
local make_mirror = function(options)
    local this = nil

    return function(enable)
        if enable and not this then
            this = waywall.mirror(options)
        elseif this and not enable then
            this:close()
            this = nil
        end
    end
end

local mirrors = {
    c_e_counter = make_mirror({
        src = { x = 1, y = 28, w = 64, h = 18 },
        dst = { x = 1500, y = 300, w = 298, h = 84 },
        depth = 2,
        shader = "text",
    }),
    c_e_counter_shadow = make_mirror({
        src = { x = 1, y = 28, w = 64, h = 18 },
        dst = { x = 1505, y = 305, w = 298, h = 84 },
        depth = 1,
        shader = "text_bg",
    }),

    o_m_counter = make_mirror({
        src = { x = 45, y = 154, w = 74, h = 10 },
        dst = { x = 1500, y = 495, w = 340, h = 45 },
        depth = 2,
        shader = "text",
    }),
    o_m_counter_shadow = make_mirror({
        src = { x = 45, y = 154, w = 74, h = 10 },
        dst = { x = 1503, y = 498, w = 340, h = 45 },
        depth = 1,
        shader = "text_bg",
    }),

    pitch_counter = make_mirror({
        src = { x = 177, y = 118, w = 80, h = 10 },
        dst = { x = 1500, y = 550, w = 294, h = 45 },
        depth = 2,
        shader = "text",
    }),
    pitch_counter_shadow = make_mirror({
        src = { x = 177, y = 118, w = 80, h = 10 },
        dst = { x = 1503, y = 553, w = 294, h = 45 },
        depth = 1,
        shader = "text_bg",
    }),

    yaw_counter = make_mirror({
        src = { x = 177, y = 128, w = 80, h = 10 },
        dst = { x = 1500, y = 600, w = 294, h = 45 },
        depth = 2,
        shader = "text",
    }),
    yaw_counter_shadow = make_mirror({
        src = { x = 177, y = 128, w = 80, h = 10 },
        dst = { x = 1503, y = 603, w = 294, h = 45 },
        depth = 1,
        shader = "text_bg",
    }),

    e_counter = make_mirror({
        src = { x = 13, y = 37, w = 37, h = 9 },
        dst = { x = cfg.e_count.x, y = cfg.e_count.y, w = 37 * cfg.e_count.size, h = 9 * cfg.e_count.size },
        color_key = cfg.e_count.colorkey and {
            input = "#DDDDDD",
            output = cfg.text_col,
        } or nil,
    }),

    thin_pie_blockentities = make_mirror({
        src = cfg.res_1440
            and { x = 10, y = 694, w = 340, h = 178 }
            or { x = 0, y = 674, w = 340, h = 178 },
        dst = { x = cfg.thin_pie.x, y = cfg.thin_pie.y, w = 420 * cfg.thin_pie.size / 4, h = 423 * cfg.thin_pie.size / 4 },
        color_key = {
            input = "#EC6E4E",
            output = cfg.pie_chart_1,
        },
    }),
    thin_pie_unspecified = make_mirror({
        src = cfg.res_1440
            and { x = 10, y = 694, w = 340, h = 178 }
            or { x = 0, y = 674, w = 340, h = 178 },
        dst = { x = cfg.thin_pie.x, y = cfg.thin_pie.y, w = 420 * cfg.thin_pie.size / 4, h = 423 * cfg.thin_pie.size / 4 },
        color_key = {
            input = "#46CE66",
            output = cfg.pie_chart_2,
        },
    }),
    thin_pie_destroyProgress = make_mirror({
        src = cfg.res_1440
            and { x = 10, y = 694, w = 340, h = 178 }
            or { x = 0, y = 674, w = 340, h = 178 },
        dst = { x = cfg.thin_pie.x, y = cfg.thin_pie.y, w = 420 * cfg.thin_pie.size / 4, h = 423 * cfg.thin_pie.size / 4 },
        color_key = {
            input = "#CC6C46",
            output = cfg.pie_chart_2,
        },
    }),
    thin_pie_prepare = make_mirror({
        src = cfg.res_1440
            and { x = 10, y = 694, w = 340, h = 178 }
            or { x = 0, y = 674, w = 340, h = 178 },
        dst = { x = cfg.thin_pie.x, y = cfg.thin_pie.y, w = 420 * cfg.thin_pie.size / 4, h = 423 * cfg.thin_pie.size / 4 },
        color_key = {
            input = "#464C46",
            output = cfg.pie_chart_2,
        },
    }),
    thin_pie_entities = make_mirror({
        src = cfg.res_1440
            and { x = 10, y = 694, w = 340, h = 178 }
            or { x = 0, y = 674, w = 340, h = 178 },
        dst = { x = cfg.thin_pie.x, y = cfg.thin_pie.y, w = 420 * cfg.thin_pie.size / 4, h = 423 * cfg.thin_pie.size / 4 },
        color_key = {
            input = "#E446C4",
            output = cfg.pie_chart_3,
        },
    }),

    tall_pie_blockentities = make_mirror({
        src = { x = 44, y = 15978, w = 340, h = 178 },
        dst = { x = cfg.tall_pie.x, y = cfg.tall_pie.y, w = 420 * cfg.tall_pie.size / 4, h = 423 * cfg.tall_pie.size / 4 },
        color_key = {
            input = "#EC6E4E",
            output = cfg.pie_chart_1,
        },
    }),
    tall_pie_unspecified = make_mirror({
        src = { x = 44, y = 15978, w = 340, h = 178 },
        dst = { x = cfg.tall_pie.x, y = cfg.tall_pie.y, w = 420 * cfg.tall_pie.size / 4, h = 423 * cfg.tall_pie.size / 4 },
        color_key = {
            input = "#46CE66",
            output = cfg.pie_chart_2,
        },
    }),
    tall_pie_destroyProgress = make_mirror({
        src = { x = 44, y = 15978, w = 340, h = 178 },
        dst = { x = cfg.tall_pie.x, y = cfg.tall_pie.y, w = 420 * cfg.tall_pie.size / 4, h = 423 * cfg.tall_pie.size / 4 },
        color_key = {
            input = "#CC6C46",
            output = cfg.pie_chart_2,
        },
    }),
    tall_pie_prepare = make_mirror({
        src = { x = 44, y = 15978, w = 340, h = 178 },
        dst = { x = cfg.tall_pie.x, y = cfg.tall_pie.y, w = 420 * cfg.tall_pie.size / 4, h = 423 * cfg.tall_pie.size / 4 },
        color_key = {
            input = "#464C46",
            output = cfg.pie_chart_2,
        },
    }),
    tall_pie_entities = make_mirror({
        src = { x = 44, y = 15978, w = 340, h = 178 },
        dst = { x = cfg.tall_pie.x, y = cfg.tall_pie.y, w = 420 * cfg.tall_pie.size / 4, h = 423 * cfg.tall_pie.size / 4 },
        color_key = {
            input = "#E446C4",
            output = cfg.pie_chart_3,
        },
    }),

    -- plain pie chart mirror (thin) - just mirrors the pie chart as-is
    thin_pie_all = make_mirror({
        src = cfg.res_1440
            and { x = 10, y = 694, w = 340, h = 178 }
            or { x = 0, y = 674, w = 340, h = 178 },
        dst = { x = cfg.thin_pie.x, y = cfg.thin_pie.y, w = 420 * cfg.thin_pie.size / 4, h = 423 * cfg.thin_pie.size / 4 },
    }),

    thin_percent = make_mirror({
        src = cfg.res_1440
            and { x = 257, y = 879, w = 33, h = 40 }
            or { x = 247, y = 859, w = 33, h = 38 },
        dst = { x = cfg.thin_percent.x, y = cfg.thin_percent.y, w = 33 * cfg.thin_percent.size, h = 40 * cfg.thin_percent.size },
        depth = 2,
        shader = "text_colored",
    }),
    thin_percent_shadow = make_mirror({
        src = cfg.res_1440
            and { x = 257, y = 879, w = 33, h = 40 }
            or { x = 247, y = 859, w = 33, h = 38 },
        dst = { x = cfg.thin_percent.x + 3, y = cfg.thin_percent.y + 3, w = 33 * cfg.thin_percent.size, h = 40 * cfg.thin_percent.size },
        depth = 1,
        shader = "text_colored_bg",
    }),

    -- plain pie chart mirror (tall) - just mirrors the pie chart as-is
    tall_pie_all = make_mirror({
        src = { x = 44, y = 15978, w = 340, h = 178 },
        dst = { x = cfg.tall_pie.x, y = cfg.tall_pie.y, w = 420 * cfg.tall_pie.size / 4, h = 423 * cfg.tall_pie.size / 4 },
    }),

    tall_percent = make_mirror({
        src = { x = 291, y = 16163, w = 33, h = 40 },
        dst = { x = cfg.tall_percent.x, y = cfg.tall_percent.y, w = 33 * cfg.tall_percent.size, h = 40 * cfg.tall_percent.size },
        depth = 2,
        shader = "text_colored",
    }),
    tall_percent_shadow = make_mirror({
        src = { x = 291, y = 16163, w = 33, h = 40 },
        dst = { x = cfg.tall_percent.x + 3, y = cfg.tall_percent.y + 3, w = 33 * cfg.tall_percent.size, h = 40 * cfg.tall_percent.size },
        depth = 1,
        shader = "text_colored_bg",
    }),

    eye_measure = make_mirror({
        src = cfg.stretched_measure
            and { x = 177, y = 7902, w = 30, h = 580 }
            or { x = 162, y = 7902, w = 60, h = 580 },
        dst = cfg.res_1440
            and { x = 94, y = 470, w = 900, h = 500 }
            or { x = 30, y = 340, w = 700, h = 400 },
    }),
}


-- ==== IMAGES ====
local make_image = function(path, dst)
    local this = nil

    return function(enable)
        if enable and not this then
            this = waywall.image(path, dst)
        elseif this and not enable then
            this:close()
            this = nil
        end
    end
end

local images = {
    measuring_overlay = make_image(overlay_path, {
        dst = cfg.res_1440
            and { x = 94, y = 470, w = 900, h = 500 }
            or { x = 30, y = 340, w = 700, h = 400 },
    }),
    stretched_overlay = make_image(stretched_overlay_path, {
        dst = cfg.res_1440
            and { x = 94, y = 470, w = 900, h = 500 }
            or { x = 30, y = 340, w = 700, h = 400 },
    }),
    tall_overlay = make_image(tall_overlay_path, {
        dst = cfg.res_1440
            and { x = 0, y = 0, w = 2560, h = 1440 }
            or { x = 0, y = 0, w = 1920, h = 1080 },
    }),
    thin_overlay = make_image(thin_overlay_path, {
        dst = cfg.res_1440
            and { x = 0, y = 0, w = 2560, h = 1440 }
            or { x = 0, y = 0, w = 1920, h = 1080 },
    }),
    wide_overlay = make_image(wide_overlay_path, {
        dst = cfg.res_1440
            and { x = 0, y = 0, w = 2560, h = 1440 }
            or { x = 0, y = 0, w = 1920, h = 1080 },
    }),
}


-- ==== OBJECT MANAGEMENT ====
local show_mirrors = function(f3, tall, thin, wide)
    images.tall_overlay(tall)
    images.thin_overlay(thin)
    images.wide_overlay(wide)

    mirrors.eye_measure(tall)
    if cfg.stretched_measure then
        images.stretched_overlay(tall)
    else
        images.measuring_overlay(tall)
    end

    mirrors.c_e_counter(f3)
    mirrors.c_e_counter_shadow(f3)
    mirrors.o_m_counter(f3)
    mirrors.o_m_counter_shadow(f3)
    mirrors.pitch_counter(f3)
    mirrors.pitch_counter_shadow(f3)
    mirrors.yaw_counter(f3)
    mirrors.yaw_counter_shadow(f3)

    if cfg.thin_pie.enabled then
        mirrors.thin_pie_all(thin)
    end

    if cfg.thin_percent.enabled then
        mirrors.thin_percent(thin)
        mirrors.thin_percent_shadow(thin)
    end

    if cfg.tall_pie.enabled then
        mirrors.tall_pie_all(tall)
    end

    if cfg.tall_percent.enabled then
        mirrors.tall_percent(tall)
        mirrors.tall_percent_shadow(tall)
    end
end


-- ==== RESIZING STATES ====
local thin_enable = function()
    show_mirrors(true, false, true, false)
    thin_active = true
    if cfg.sens_change.enabled then
        waywall.set_sensitivity(cfg.sens_change.normal)
    end
end

local tall_enable = function()
    show_mirrors(true, true, false, false)
    if cfg.sens_change.enabled and not thin_active then
        waywall.set_sensitivity(cfg.sens_change.tall)
    end
    thin_active = false
end
local wide_enable = function()
    show_mirrors(false, false, false, true)
    if cfg.sens_change.enabled then
        waywall.set_sensitivity(cfg.sens_change.normal)
    end
    thin_active = false
end

local res_disable = function()
    show_mirrors(false, false, false, false)
    if cfg.sens_change.enabled then
        waywall.set_sensitivity(cfg.sens_change.normal)
    end
    thin_active = false
end

-- ==== RESOLUTIONS ====
local make_res = function(width, height, enable, disable)
    return function()
        local active_width, active_height = waywall.active_res()

        if active_width == width and active_height == height then
            if cfg.enable_resize_animations then
                os.execute('echo "0x0" > ~/.resetti_state')
                waywall.sleep(17)
            end
            waywall.set_resolution(0, 0)
            disable()
        else
            if cfg.enable_resize_animations then
                os.execute(string.format('echo "%dx%d" > ~/.resetti_state', width, height))
                waywall.sleep(17)
            end
            waywall.set_resolution(width, height)
            enable()
        end
    end
end

local resolutions = {
    thin = make_res(cfg.res_1440 and 350 or 340, cfg.res_1440 and 1100 or 1080, thin_enable, res_disable),
    tall = make_res(384, 16384, tall_enable, res_disable),
    wide = make_res(cfg.res_1440 and 2560 or 1920, cfg.res_1440 and 400 or 300, wide_enable, res_disable),
}

local function resize_helper(mode, run)
    return function()
        if not remaps_active then
            return false
        end
        if mode.f3_safe and waywall.get_key("F3") then
            return false
        end
        run()
    end
end


-- ==== KEYBINDS ====
config.actions = {

    [cfg.thin.key] = resize_helper(cfg.thin, function() resolutions.thin() end),
    [cfg.wide.key] = resize_helper(cfg.wide, function() resolutions.wide() end),
    [cfg.tall.key] = resize_helper(cfg.tall, function() resolutions.tall() end),

    [cfg.toggle_ninbot_key] = function()
        print("DEBUG: toggle_ninbot_key pressed")
        local running = is_ninb_running()
        print("DEBUG: is_ninb_running() returned: " .. tostring(running))
        
        if not running then
            print("DEBUG: Launching ninjabrain...")
            waywall.exec("java -Dawt.useSystemAAFontSettings=on -jar " .. nb_path)
            waywall.show_floating(true)
        else
            print("DEBUG: Toggling floating window...")
            helpers.toggle_floating()
        end
    end,

    ["*-C"] = function()
        if waywall.get_key("F3") then
            waywall.press_key("C")
            waywall.show_floating(true)
        else
            return false
        end
    end,

    [cfg.toggle_fullscreen_key] = waywall.toggle_fullscreen,

    [cfg.toggle_remaps_key] = function()
        if rebind_text then
            rebind_text:close()
            rebind_text = nil
        end
        if remaps_active then
            remaps_active = false
            waywall.set_remaps(other_remaps)
            if cfg.remaps_config.enabled then waywall.set_keymap({ layout = "us" }) end
            rebind_text = waywall.text(cfg.remaps_text_config.text,
                {
                    x = cfg.remaps_text_config.x,
                    y = cfg.remaps_text_config.y,
                    color = cfg.remaps_text_config.color,
                    size = cfg.remaps_text_config.size
                })
        else
            remaps_active = true
            waywall.set_remaps(keyboard_remaps)
            if cfg.remaps_config.enabled then waywall.set_keymap({ layout = cfg.remaps_config.layout_name }) end
        end
    end,
}


return config
