DrawState = {}

local function _compareTuples(tuple1, tuple2)
    if #tuple1 ~= #tuple2 then
        return false
    end

    for i = 1, #tuple1 do
        if tuple1[i] ~= tuple2[i] then
            return false
        end
    end

    return true
end

local function _convert(data)
    local terminalColors = {
        black = "\033[30m",
        red = "\033[31m",
        green = "\033[32m",
        yellow = "\033[33m",
        blue = "\033[34m",
        magenta = "\033[35m",
        cyan = "\033[36m",
        white = "\033[37m",
        brightBlack = "\033[90m",
        brightRed = "\033[91m",
        brightGreen = "\033[92m",
        brightYellow = "\033[93m",
        brightBlue = "\033[94m",
        brightMagenta = "\033[95m",
        brightCyan = "\033[96m",
        brightWhite = "\033[97m"
    }

    local terminalMap = {
        {{0, 0, 0}, terminalColors["black"]},
        {{128, 0, 0}, terminalColors["red"]},
        {{0, 128, 0}, terminalColors["green"]},
        {{128, 128, 0}, terminalColors["yellow"]},
        {{0, 0, 128}, terminalColors["blue"]},
        {{128, 0, 128}, terminalColors["magenta"]},
        {{0, 128, 128}, terminalColors["cyan"]},
        {{192, 192, 192}, terminalColors["white"]},
        {{128, 128, 128}, terminalColors["brightBlack"]},
        {{255, 0, 0}, terminalColors["brightRed"]},
        {{0, 255, 0}, terminalColors["brightGreen"]},
        {{255, 255, 0}, terminalColors["brightYellow"]},
        {{0, 0, 255}, terminalColors["brightBlue"]},
        {{255, 0, 255}, terminalColors["brightMagenta"]},
        {{0, 255, 255}, terminalColors["brightCyan"]},
        {{255, 255, 255}, terminalColors["brightWhite"]}
    }

    local charMaps = {
        ["255"] = " ",
        ["191"] = "▓",
        ["128"] = "▒",
        ["64"] = "░",
        ["0"] = "*"
    }

    local out = {}
    local filename = data:getFilename()
    data:open("r")
    local fd = data:read("data")

    local img = love.image.newImageData(fd)
    
    print(img:getWidth(), img:getHeight())

    for y = 0, img:getHeight() - 1, 1 do
        local r = {}
        for x = 0, img:getWidth() - 1, 1 do
            local pxr, pxg, pxb, pxa = love.math.colorToBytes(img:getPixel(x, y))
            local curPixel = {pxr, pxg, pxb}
            local curChar = charMaps[tostring(pxa)]
            for i = 1, #terminalMap, 1 do
                if _compareTuples(curPixel, terminalMap[i][1]) then
                    table.insert(r, {{love.math.colorFromBytes(unpack(terminalMap[i][1]))}, curChar})
                end

            end
        end
        table.insert(out, r)
    end

    local outfile = io.open("exported/" .. (filename:match("[^\\/]+$")):gsub("%.[^.]+$", "") .. ".rpd", "w")

    for y = 1, #out, 1 do
        for x = 1, #out[y], 1 do
            local curPixel = out[y][x]
            if curPixel[2] == " " then
                termview:setCursorBackColor(curPixel[1][1], curPixel[1][2], curPixel[1][3], 1)
            else
                termview:setCursorBackColor(0, 0, 0, 1)
                termview:setCursorColor(curPixel[1][1], curPixel[1][2], curPixel[1][3], 1)
            end
            
            if curPixel[2] then
                termview:print(x, y, curPixel[2])
            end
        outfile:write(string.format("[%s;%s;%s]:{%s;%s}:%s&", curPixel[1][1], curPixel[1][2], curPixel[1][3], x, y, string.byte(curPixel[2])))
        end
    end
    outfile:close()
end

function DrawState:enter()
    terminal = require 'src.Components.Modules.Terminal'
    moonshine = require 'libraries.moonshine'

    fxEnable = true

    effect = moonshine(moonshine.effects.scanlines)
    .chain(moonshine.effects.crt)
    .chain(moonshine.effects.glow)
    effect.scanlines.opacity = 0.6
    effect.glow.min_luma = 0.2

    local pxfont = love.graphics.newFont("assets/fonts/compaqthin.ttf", 16)

    termview = terminal(love.graphics.getWidth(), love.graphics.getHeight(), pxfont)
    
    print(termview.width, termview.height)



    termview.speed = 5000

end

function DrawState:draw()
    effect(function()
        termview:draw()
    end)
end

function DrawState:update(elapsed)
    termview:update(elapsed)
end

function DrawState:filedropped(file)
    termview:setCursorBackColor(terminal.schemes.basic["black"])
    termview:setCursorColor(terminal.schemes.basic["white"])
    termview:clear(1, 1, termview.width, termview.height)
    _convert(file)
end

function DrawState:keypressed(k)
    if k == "f1" then
        termview:setCursorBackColor(terminal.schemes.basic["black"])
        termview:setCursorColor(terminal.schemes.basic["white"])
        termview:clear(1, 1, termview.width, termview.height)
    end
    if k == "f5" then
        fxEnable = not fxEnable
        if fxEnable then
            effect.enable("glow", "scanlines", "crt")
        else
            effect.disable("glow", "scanlines", "crt")
        end
    end
end

return DrawState