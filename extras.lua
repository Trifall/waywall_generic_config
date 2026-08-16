local waywall = require("waywall")
local helpers = require("waywall.helpers")

local config_path = os.getenv("HOME") .. "/.config/waywall/"

local function read_file(path)
    local file = assert(io.open(config_path .. path, "r"))
    local contents = file:read("*a")
    file:close()
    return contents
end

local function add_res_mirror(options, resolution)
    helpers.res_mirror(options, resolution[1], resolution[2])
end

return function(config, cfg)
    local vertex = read_file("shaders/general.vert")
    local colors = read_file("shaders/colors.glsl") .. "\n"

    config.shaders = {
        pie_chart = {
            vertex = vertex,
            fragment = colors .. read_file("shaders/pie_chart.frag"),
        },
        pie_border = {
            vertex = vertex,
            fragment = colors .. read_file("shaders/pie_border.frag"),
        },
        text = {
            vertex = vertex,
            fragment = colors .. read_file("shaders/text.frag"),
        },
        text_bg = {
            vertex = vertex,
            fragment = colors .. read_file("shaders/text_bg.frag"),
        },
        text_colored = {
            vertex = vertex,
            fragment = read_file("shaders/text_colored.frag"),
        },
        text_colored_bg = {
            vertex = vertex,
            fragment = read_file("shaders/text_colored_bg.frag"),
        },
    }

    local counter_mirrors = {
        {
            src = { x = 1, y = 28, w = 64, h = 18 },
            dst = { x = 1500, y = 300, w = 298, h = 84 },
            depth = 2,
            shader = "text",
        },
        {
            src = { x = 1, y = 28, w = 64, h = 18 },
            dst = { x = 1505, y = 305, w = 298, h = 84 },
            depth = 1,
            shader = "text_bg",
        },
        {
            src = { x = 45, y = 154, w = 74, h = 10 },
            dst = { x = 1500, y = 495, w = 340, h = 45 },
            depth = 2,
            shader = "text",
        },
        {
            src = { x = 45, y = 154, w = 74, h = 10 },
            dst = { x = 1503, y = 498, w = 340, h = 45 },
            depth = 1,
            shader = "text_bg",
        },
        {
            src = { x = 177, y = 118, w = 80, h = 10 },
            dst = { x = 1500, y = 550, w = 294, h = 45 },
            depth = 2,
            shader = "text",
        },
        {
            src = { x = 177, y = 118, w = 80, h = 10 },
            dst = { x = 1503, y = 553, w = 294, h = 45 },
            depth = 1,
            shader = "text_bg",
        },
        {
            src = { x = 177, y = 128, w = 80, h = 10 },
            dst = { x = 1500, y = 600, w = 294, h = 45 },
            depth = 2,
            shader = "text",
        },
        {
            src = { x = 177, y = 128, w = 80, h = 10 },
            dst = { x = 1503, y = 603, w = 294, h = 45 },
            depth = 1,
            shader = "text_bg",
        },
    }

    for _, mirror in ipairs(counter_mirrors) do
        add_res_mirror(mirror, cfg.thin_res)
        add_res_mirror(mirror, cfg.tall_res)
    end

    if cfg.mob_spawner.enabled then
        local source_width = cfg.mob_spawner.source_size[1]
        local source_height = cfg.mob_spawner.source_size[2]
        local dst = {
            x = cfg.mob_spawner.x,
            y = cfg.mob_spawner.y,
            w = 33 * cfg.mob_spawner.size,
            h = 9 * cfg.mob_spawner.size,
        }

        for i = 0, 3 do
            local src = {
                x = source_width - 93,
                y = source_height - 221 + 8 * i,
                w = 33,
                h = 9,
            }

            helpers.res_mirror({
                src = src,
                dst = dst,
                depth = 3,
                color_key = { input = "#4DE1CA", output = cfg.mob_spawner.color },
            }, 0, 0)
            helpers.res_mirror({
                src = src,
                dst = {
                    x = dst.x + cfg.mob_spawner.shadow_offset,
                    y = dst.y + cfg.mob_spawner.shadow_offset,
                    w = dst.w,
                    h = dst.h,
                },
                depth = 2,
                color_key = { input = "#4DE1CA", output = cfg.mob_spawner.shadow },
            }, 0, 0)
        end
    end

    add_res_mirror({
        src = { x = 10, y = 694, w = 340, h = 178 },
        dst = { x = 1490, y = 645, w = 420, h = 423 },
    }, cfg.thin_res)
    add_res_mirror({
        src = { x = 44, y = 15978, w = 340, h = 178 },
        dst = { x = 1490, y = 645, w = 420, h = 423 },
    }, cfg.tall_res)

    add_res_mirror({
        src = { x = 257, y = 879, w = 33, h = 40 },
        dst = { x = 1600, y = 1100, w = 198, h = 240 },
        depth = 2,
        shader = "text_colored",
    }, cfg.thin_res)
    add_res_mirror({
        src = { x = 257, y = 879, w = 33, h = 40 },
        dst = { x = 1603, y = 1103, w = 198, h = 240 },
        depth = 1,
        shader = "text_colored_bg",
    }, cfg.thin_res)
    add_res_mirror({
        src = { x = 291, y = 16163, w = 33, h = 40 },
        dst = { x = 1600, y = 1100, w = 198, h = 240 },
        depth = 2,
        shader = "text_colored",
    }, cfg.tall_res)
    add_res_mirror({
        src = { x = 291, y = 16163, w = 33, h = 40 },
        dst = { x = 1603, y = 1103, w = 198, h = 240 },
        depth = 1,
        shader = "text_colored_bg",
    }, cfg.tall_res)

    config.actions["*-C"] = function()
        if waywall.get_key("F3") then
            waywall.press_key("C")
            waywall.show_floating(true)
        else
            return false
        end
    end
end
