--
--  Copyright (c) Scott Simpson
--
-- 	This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  A copy of the GNU General Public License is available at <http://www.gnu.org/licenses/>.
--    

local debugLabelWidth = 45
local debugRowHeight = 7
local debugColWidth = 40
local debugColSpacing = 5
local switch = getValue(99)
local oldSwitch = switch
local batteryIndex = 0

local function printTimer(col, row, token, attr)
	local val = token
	local x = col
    local y = row * debugRowHeight - 6
    lcd.drawTimer(x, y, val, SMLSIZE + attr)
end

local function printText(col, row, val, attr)
	local x = col
    local y = row * debugRowHeight - 6
    lcd.drawText(x, y, val, SMLSIZE + attr)
end

local function printLabel(row, val, attr)
    local y = row * debugRowHeight - 6
    lcd.drawText(0, y, "Flight #", SMLSIZE + attr)
    lcd.drawText(lcd.getLastPos(), y, val, SMLSIZE + attr)
end

local function printNum(col, row, val, attr)
	local x = col
    local y = row * debugRowHeight - 6
    lcd.drawNumber(x, y, val, SMLSIZE + attr)
end
		 
local function printmah(col, row, token, attr)
	local val = token
	local x = col
    local y = row * debugRowHeight - 6
    lcd.drawText(x, y, val, SMLSIZE + attr)
    lcd.drawText(lcd.getLastPos(), y, "mAh", SMLSIZE + attr)
end
		 
local function background() 
end

local function init() 
	-- check that we have at least one configured battery capacity
	if model.getGlobalVariable(8, 3) == 0 then
		model.setGlobalVariable(8, 3, 28)
	end

	local capacity = model.getGlobalVariable(8, 0)
	batteryIndex = -1

	-- look for the matching index for the configured battery
	if capacity > 0 then
		for i = 0, 3, 1 do
			if capacity == model.getGlobalVariable(8, 3 + i) then
				batteryIndex = i
				break
			end
		end
	end

	-- reset invalid battery setting to this first configured capacity
	if batteryIndex == -1 then
		model.setGlobalVariable(8, 0, model.getGlobalVariable(8, 3) )
		batteryIndex = 0
	end
end

local function run(event)
	lcd.clear()

	local attr = 0
	for i = 0, 7, 1 do
		local attr = 0
		local j = i + 1
--		if (i + 1)%2 == 1 then
--			attr = INVERS
--		end

		printLabel(j, j, attr)

		if model.getGlobalVariable(2, i) > 0 then
			printTimer(lcd.getLastPos() + 5 + debugColSpacing, j, model.getGlobalVariable(0, i) * 60 + model.getGlobalVariable(1, i), attr)
			printmah(lcd.getLastPos() + debugColSpacing, j, model.getGlobalVariable(2, i) * 10, attr)
			printmah(117 + debugColSpacing, j, model.getGlobalVariable(3, i) * 10, attr)
			printNum(178 + debugColSpacing, j, math.floor(model.getGlobalVariable(3, i) / model.getGlobalVariable(2, i) * 1000 + 0.5 ), attr + PREC1)
			printText(lcd.getLastPos(), j, "%", attr)
		end
	end

	switch = getValue(99)
	local capacity = model.getGlobalVariable(8, 3 + batteryIndex)
	if oldSwitch ~= switch and switch > 0 then

		batteryIndex = batteryIndex + 1
		batteryIndex = batteryIndex % 4

		capacity = model.getGlobalVariable(8, 3 + batteryIndex)
		if capacity == 0 then
			batteryIndex = 0
			capacity = model.getGlobalVariable(8, 3 + batteryIndex)
		end
		model.setGlobalVariable(8,0, capacity)
	end
	oldSwitch = switch

	printText(0, 9, "Capacity: ", 0)
	for i = 0, 3, 1 do
		local val = model.getGlobalVariable(8, 3 + i)

		if val == 0 then			
			break
		end

		if val == capacity then
			attr = INVERS
		else
			attr = 0
		end

		printText(lcd.getLastPos(),9, val * 100, attr)
		printText(lcd.getLastPos(),9, "mAh", attr)
		printText(lcd.getLastPos(),9, " ", 0)
	end
end

return {run=run, background=background, init=init}