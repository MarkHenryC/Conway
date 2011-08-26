-- Conway's Life in Lua for Corona
-- Mark H Carolan 2010

-- Slightly enhanced version:
-- Dead cells fade out rather than switch off

local width = display.contentWidth
local height = display.contentHeight

-- 4 is pretty slow but more interesting,
-- 8 is smoother but of course blockier.
-- Either way, runs much nicer in the Mac
-- simulator than on a 3GS.

local cellW = 4
local cellH = 4
local gridWidth = width / cellW
local gridHeight = height / cellH

local gridA, gridB = {}, {}
local visual = display.newGroup()

-- Put in some initial random data:

for i = 1, gridHeight do
	local rowA, rowB = {}, {}
	for j = 1, gridWidth do
		local cell = math.random(0, 255)
		rowA[#rowA+ 1] = cell
		rowB[#rowB+ 1] = 0
		local r = display.newRect(0, 0, cellW, cellH)
		visual:insert(r)
		r.x = (j-1) * cellW
		r.y = (i-1) * cellH
	end
	gridA[#gridA + 1] = rowA
	gridB[#gridB + 1] = rowB
end

-- Calculate new cells in backbuffer

local fore = gridA
local back = gridB

local function swap()
	fore, back = back, fore -- nice Lua feature
end

local me
local leftPos, rightPos, upPos, downPos
local ul, ml, bl, uc, bc, ur, mr, br, v

function update()
	for row = 1, gridHeight do
		for col = 1, gridWidth do
			me = fore[row][col]
			if me > 0 then me = me-1 end			
			leftPos = (col == 1 and gridWidth or col-1)
			rightPos = (col == gridWidth and 1 or col+1)
			upPos = (row == 1 and gridHeight or row-1)
			downPos = (row == gridHeight and 1 or row+1)
			
			ul = fore[upPos][leftPos] < 128 and 0 or 1
			ml = fore[row][leftPos] < 128 and 0 or 1
			bl = fore[downPos][leftPos] < 128 and 0 or 1
			uc = fore[upPos][col] < 128 and 0 or 1
			bc = fore[downPos][col] < 128 and 0 or 1
			ur = fore[upPos][rightPos] < 128 and 0 or 1
			mr = fore[row][rightPos] < 128 and 0 or 1
			br = fore[downPos][rightPos] < 128 and 0 or 1
			
			local v = ul+ml+bl+uc+bc+ur+mr+br
			
			back[row][col]  = me
			if me >= 128 then	-- active cell
				if v < 2 or v > 3 then
					back[row][col] = 127 -- die
				end
			else -- inactive
				if v == 3 then
					back[row][col] = 255 -- new life
				end
			end
			
		end
	end
end

function draw()
	for i = 1, gridHeight do
		for j = 1, gridWidth do
			visual[(i-1) * gridWidth + j]:setFillColor(fore[i][j], 32, 16)
		end
	end
end

function enterFrame(event)
	update()
	swap()
	draw()
end

-- Allow user to draw into grid:

function click(event)
	local cellX = math.ceil(event.x / cellW)
	local cellY = math.ceil(event.y / cellH)
	
	if event.phase == "began" then
		back[cellY][cellX] = 255
		visual[(cellY-1) * gridWidth + cellX]:setFillColor(back[cellY][cellX], 32, 16)
		Runtime:removeEventListener("enterFrame", enterFrame)
	elseif event.phase == "moved" then
		back[cellY][cellX] = 255
		visual[(cellY-1) * gridWidth + cellX]:setFillColor(back[cellY][cellX], 32, 16)
	elseif event.phase == "ended" then
		swap()
		draw()
		Runtime:addEventListener("enterFrame", enterFrame)
	end
end

display.getCurrentStage():addEventListener("touch", click)

Runtime:addEventListener("enterFrame", enterFrame)