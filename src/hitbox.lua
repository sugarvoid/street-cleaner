Hitbox = Object:extend()

function Hitbox:new(owner, x, y, w, h, ox, oy)
    self.x = x or 0
    self.y = y or 0
    self.w = w
    self.h = h
    self.__ox = ox or 0
    self.__oy = oy or 0
    self.__owner = owner
end

function Hitbox:update()
    if self.__owner then
        self.x = self.__owner.position.x + self.__ox
        self.y = self.__owner.position.y + self.__oy
    end
end

function Hitbox:draw()
    love.graphics.push("all")
    love.graphics.setLineWidth(1)
    set_color_from_hex("#ff0000")
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    love.graphics.pop()
end
