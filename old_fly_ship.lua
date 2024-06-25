-- Fly ship behavior.
-- It randomly circles about and sits on the edge.

local this_ship = {}		-- Our ship function table

-- The standard local variables
local x0, y0, x, y	        -- Where we are
local colour = "cyan"           -- Our colour
local style = "ship"		-- Our style
local tick                      -- Size of a clock tick msec
local me = ship.self()		-- This is me
local ammo,shield = 0,0

local xsize,ysize = universe.size()     -- The size of the universe

local phi = 0                   -- Direction
local dphi = 0.1                -- Current turn angle per frame
local mdphi = 0.1               -- Max turn angle (abs)
local v = 1                     -- Speed
local a = 0                     -- Acceleration
local da = 0                    -- Acceleration change per frame
local maxda = 0.001             -- Max acceleration change per frame
local tda = 10                  -- Frames left until setting of new da
local maxtda = 100              -- Max when setting new tda
local mintda = 5                -- Min when setting new tda

-- The default ship interface.

function this_ship.start() end

function this_ship.get_pos() return x,y end

function this_ship.set_pos(a1, a2)
  x,y = a1,a2
  math.randomseed(a1+a2)
end

function this_ship.get_speed() return v,0 end

function this_ship.set_speed(a1, a2)
  phi = math.atan2(a2,a1)
  v = math.sqrt(a1*a1+a2*a2)
end

function this_ship.set_tick(a1) tick = a1 end

-- Movement
local function move()
   tda = tda - 1
   if tda <= 0 then
        a = 0
        tda = math.random(mintda, maxtda)
        da = math.random(-100000*maxda, 100000*maxda)/100000
        dphi = math.random(-100000*mdphi, 100000*mdphi)/100000
   end
   phi = phi + dphi
   a = a + da
   v = v + a
   -- Move
   local x0,y0 = x,y
   local nx = x + v * math.cos(phi)
   local ny = y + v * math.sin(phi)
   if universe.valid_x(nx) and universe.valid_y(ny) then
      x = nx; y = ny
   else
      dphi = 0.01
   end
   -- Sectors: Where we were and where we are now.
   local osx,osy = universe.sector(x0, y0)
   local nsx,nsy = universe.sector(x, y)
   if (osx ~= nsx or osy ~= nsy) then
      -- In new sector, move us to the right sector
      universe.rem_sector(x0, y0)
      universe.add_sector(x, y)
      -- and draw us
      esdl_server.set_ship(style, colour, x, y)
   end
end

function this_ship.tick()
   move()
end

function this_ship.zap()	-- The ship has been zapped and will die
   esdl_server.set_ship("explosion", colour, x, y)
   universe.rem_sector(x, y)
end

return this_ship		-- Return the ship table
