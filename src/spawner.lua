Spawner = Object:extend()

function Spawner:new()

end

function Spawner:update()

end

function Spawner:add_guy(e_type)
    local guy = nil
    if e_type == "door" then
        local idx = get_spawn_index("d")
        if idx ~= -2 then
            guy = DoorGuy(idx)
        end
    elseif e_type == "window" then
        local idx = get_spawn_index("w")
        if idx ~= -2 then
            guy = WindowGuy(idx)
        end
    elseif e_type == "runner" then
        guy = RunnerGuy()
    elseif e_type == "jumper" then
        local idx = get_spawn_index("w")
        if idx ~= -2 then
            guy = JumperGuy(idx)
        end
    end
    if guy ~= nil then
        table.insert(enemies, guy)
    end
    
end

function update_lane(lane, occupied)
    lanes[lane][2] = occupied
end

function get_spawn_index(e_letter)
    local s_data = {}
    local tries = 25

    repeat
        tries = tries - 1
        if tries <= 0 then
            return -2
        end
        s_data = get_random_item(SPAWN_DATA)
    until string.sub(s_data.id, 1, 1) == e_letter and s_data.available == true

    SPAWN_DATA[s_data.index].available = false
    return s_data.index

    --if string.sub(s_data.id, 1, 1) == "d" and s_data.available == true then
    --end
end
