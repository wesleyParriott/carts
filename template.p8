pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main loops--

-- all of the entities
-- put a update function to update it 
-- put a draw function to draw it 
Entities = {}

function _init()
	
end

function _update()
	for e in all(entities) do 
		if e.update ~= nil then
			e:update()
		end
	end
end

function _draw()
 cls()
	for e in all(entities) do
		if e.draw ~= nil then
			e:draw()
		end
	end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
