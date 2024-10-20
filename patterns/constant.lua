_frequency = 150
_pos_pulse_width = 150
_neg_pulse_width = 150

Config = {
    name = "Manual",
    menu_items = {
        {
            type = "MIN_MAX",
            title = "Frequency",
            id = 1,
            min = 5,
            max = 300,
            increment_step = 5,
            uom = "Hz",
            default = _frequency
         },
         {
            type = "MIN_MAX",
            title = "Pos. pulse width",
            id = 2,
            min = 5,
            max = 255,
            increment_step = 5,
            uom = "us",
            default = _pos_pulse_width
         },
         {
            type = "MIN_MAX",
            title = "Neg. pulse width",
            id = 3,
            min = 5,
            max = 255,
            increment_step = 5,
            uom = "us",
            default = _neg_pulse_width
         },
    }
}

function setFrequency(freq)
    for channel = 1, 4, 1 do
        zc.SetFrequency(channel, freq)
    end
end

function setPulseWidth(posPulseWidth, negPulseWidth)
    for channel = 1, 4, 1 do
        zc.SetPulseWidth(channel, posPulseWidth, negPulseWidth)
    end
end

function MinMaxChange(menu_id, min_max_val)
    if menu_id == 1 then
        _frequency = min_max_val
        setFrequency(_frequency)
    elseif menu_id == 2 then
        _pos_pulse_width = min_max_val
        setPulseWidth(_pos_pulse_width, _neg_pulse_width)
    elseif menu_id == 3 then
        _neg_pulse_width = min_max_val
        setPulseWidth(_pos_pulse_width, _neg_pulse_width)
    end
end

function Setup(time_ms)
    setFrequency(_frequency)
    setPulseWidth(_pos_pulse_width, _neg_pulse_width)

    for channel = 1, 4, 1 do
        zc.ChannelOn(channel)
        zc.SetPower(channel, 1000)
    end
end

function Loop(time_ms)
    -- no-op
end
