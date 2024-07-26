function love.load(args)
    gamestate = require 'libraries.gamestate'

    love.math.setRandomSeed(os.time())
    math.randomseed(os.time())

    local States = love.filesystem.getDirectoryItems("src/States")
    for state = 1, #States, 1 do
        require("src.States." .. string.gsub(States[state], ".lua", ""))
    end

    local addons = love.filesystem.getDirectoryItems("src/Addons")
    for a = 1, #addons, 1 do
        require("src.Addons." .. string.gsub(addons[a], ".lua", ""))
    end

    gamestate.registerEvents()
    gamestate.switch(DrawState)
end