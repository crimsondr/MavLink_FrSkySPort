--Smooth tilt beta version fully functional JMMaupin 2014-09-27 
local FinaltPos = 0
local Incrementer = 0
local positionswitch = 0
local realdeathband = 0

local InSliderDeathBand = 0

-- Inputs HMI ----------------------------------
local InSpeed = 0		-- Input for desired Global speed source device
local InSlider = 0		-- Input for desired position source device
local Deathband = 0             -- Input for desired Deathband around input slider zero position

local function run ( InSpeed , InSlider, Deathband )
        
        realdeathband = ( 1024 / 100 ) * Deathband
        if InSpeed > 800 then
            positionswitch = 1
        elseif InSpeed < 800 and InSpeed >-800 then
            positionswitch = 2
        elseif InSpeed < 800 then
            positionswitch = 3
        end
        
        if InSlider >= 0 and InSlider <= realdeathband then -- zero position
            InSliderDeathBand = 0
        elseif InSlider > realdeathband then -- positiv values
            InSliderDeathBand = InSlider - realdeathband
        elseif InSlider <= 0 and InSlider >= realdeathband * -1 then -- zero negativ
            InSliderDeathBand = 0
        elseif InSlider <= realdeathband * -1 then --negativ valus
            InSliderDeathBand = InSlider + realdeathband
        end
        print(InSliderDeathBand)
        
        Incrementer = InSliderDeathBand / ( 50 * positionswitch)
	-- End Compute final position
        -- print(InSliderDeathBand)
        FinaltPos = FinaltPos + Incrementer
        if FinaltPos >= 1024 then
            FinaltPos = 1024
        end
        if FinaltPos <= -1024 then
            FinaltPos = -1024
        end
	-- Function return results
	return FinaltPos 

end

return { run=run, input={{"Spd", SOURCE}, {"Sld", SOURCE}, {"Deat %", VALUE, 0, 100, 0}} , output={ "FPos"} } -- Return Functions to OpenTX


