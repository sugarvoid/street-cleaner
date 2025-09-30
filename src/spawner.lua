Spawner = Object:extend()

function Spawner:new()

end

function Spawner:update()

end

function Spawner:add_guy(e_type)
    local guy = nil
    if e_type == "door" then
        local idx = get_spawn_index("d")
        guy = DoorGuy(idx)
    elseif e_type == "window" then
        local idx = get_spawn_index("w")
        guy = WindowGuy(idx)
    elseif e_type == "runner" then
        guy = RunnerGuy()
    elseif e_type == "jumper" then
        guy = JumperGuy()
    end

    table.insert(enemies, guy)
end

function update_lane(lane, occupied)
    lanes[lane][2] = occupied
end

function get_spawn_index(e_letter)
    --local letter = "w"
    local s_data = {}
    local tries = 10

    repeat
        tries = tries - 1
        if tries <= 0 then
            --TODO: Fins better way to prevent infitnate loop
            return -2
        end
        s_data = get_random_item(SPAWN_DATA)
    until string.sub(s_data.id, 1, 1) == e_letter and s_data.available == true

    SPAWN_DATA[s_data.index].available = false
    return s_data.index

    --if string.sub(s_data.id, 1, 1) == "d" and s_data.available == true then
    --end
end
