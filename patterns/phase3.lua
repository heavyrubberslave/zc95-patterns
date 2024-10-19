_initial_duration_sec = 60
_steps = 100      -- Number of steps for each phase

Config = {
    name = "Phase 3",
    menu_items = {
        {
            type = "MIN_MAX",
            title = "Phase duration",
            id = 1,
            min = 10,
            max = 240,
            increment_step = 1,
            uom = "sec",
            default = _initial_duration_sec
         },
    }
}

function calcDurationPerStep(duration_per_phase)
    return duration_per_phase * 1000 / _steps -- Time per step in milliseconds
end

_step_wait_until_ms = 0  -- Tracks when the next step should occur
_phase = 1               -- Keeps track of which phase is currently being executed
_current_step = 0        -- Keeps track of the current step in the set_frequency_and_pulse_width function
_duration_per_step = calcDurationPerStep(_initial_duration_sec)

function MinMaxChange(menu_id, min_max_val)
    _duration_per_step = calcDurationPerStep(min_max_val)
end

function setFrequencyAndPulseWidthStep(startFreq, endFreq, startPulseWidth, endPulseWidth)
    local freq = startFreq + (endFreq - startFreq) * (_current_step / _steps)
    local pulseWidth = startPulseWidth + (endPulseWidth - startPulseWidth) * (_current_step / _steps)

    for channel = 1, 4, 1 do
        zc.SetFrequency(channel, freq)
        zc.SetPulseWidth(channel, pulseWidth, pulseWidth)
    end
end

function Setup(time_ms)
    for channel = 1, 4, 1 do
        zc.ChannelOn(channel)
        zc.SetPower(channel, 1000)
    end
end

function Loop(time_ms)
    
    -- Phase 1
    if _phase == 1 then
        if time_ms > _step_wait_until_ms then
            setFrequencyAndPulseWidthStep(25, 20, 160, 140)
            _current_step = _current_step + 1
            _step_wait_until_ms = time_ms + _duration_per_step  -- Schedule the next step
        end
        if _current_step >= _steps then
            _current_step = 0  -- Reset steps
            _phase = 2         -- Move to the next phase
        end

    -- Phase 2
    elseif _phase == 2 then
        if time_ms > _step_wait_until_ms then
            setFrequencyAndPulseWidthStep(20, 5, 140, 150)
            _current_step = _current_step + 1
            _step_wait_until_ms = time_ms + _duration_per_step
        end
        if _current_step >= _steps then
            _current_step = 0
            _phase = 3
        end

    -- Phase 3
    elseif _phase == 3 then
        if time_ms > _step_wait_until_ms then
            setFrequencyAndPulseWidthStep(5, 80, 150, 100)
            _current_step = _current_step + 1
            _step_wait_until_ms = time_ms + _duration_per_step
        end
        if _current_step >= _steps then
            _current_step = 0
            _phase = 4
        end

    -- Phase 4
    elseif _phase == 4 then
        if time_ms > _step_wait_until_ms then
            setFrequencyAndPulseWidthStep(80, 60, 100, 110)
            _current_step = _current_step + 1
            _step_wait_until_ms = time_ms + _duration_per_step
        end
        if _current_step >= _steps then
            _current_step = 0
            _phase = 1  -- Loop back to phase 1
        end
    end
end
