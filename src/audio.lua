local currentSong = nil
local songs = {}

function load()
    songs.theme1 = love.audio.newSource("audio/theme1.mp3")
    songs.theme2 = love.audio.newSource("audio/theme2.mp3")
end

function play(song)
    if song ~= currentSong then
        stop()
        song:setLooping(true)
        currentSong = song
        love.audio.play(currentSong)
    end
end

function stop()
    if currentSong then
        love.audio.stop(currentSong)
    end
end

return {
    currentSong = currentSong,
    songs = songs,
    load = load,
    play = play,
    stop = stop,
}