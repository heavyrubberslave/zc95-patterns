_initial_duration_suck_sec = 1500  -- Longer suction duration for stronger vacuum feel
_initial_duration_release_sec = 500  -- Quick release phase
_steps_suck = 150  -- More steps for suction phase to smooth out the build-up
_steps_release = 50  -- Fewer steps for release to make it faster

Config = {
    name = "Milking",
    menu_items = {
        {
            type = "MIN_MAX",
            title = "Suction duration",
            id = 1,
            min = 200,
            max = 5000,
            increment_step = 100,
            uom = "ms",
            default = _initial_duration_suck_sec
         },
         {
            type = "MIN_MAX",
            title = "Release duration",
            id = 2,
            min = 200,
            max = 5000,
            increment_step = 100,
            uom = "ms",
            default = _initial_duration_release_sec
         },
    }
}

function calcDurationPerStep(duration_per_phase, steps)
    return duration_per_phase / steps -- Time per step in milliseconds
end

-- Initial durations per step
_duration_per_step_suck = calcDurationPerStep(_initial_duration_suck_sec, _steps_suck)
_duration_per_step_release = calcDurationPerStep(_initial_duration_release_sec, _steps_release)

-- Variable to track timing
_step_wait_until_ms = 0
_phase = 1  -- Start with suction phase
_current_step = 0

-- Handle configuration changes
function MinMaxChange(menu_id, min_max_val)
    if menu_id == 1 then
        _duration_per_step_suck = calcDurationPerStep(min_max_val, _steps_suck)
    elseif menu_id == 2 then
        _duration_per_step_release = calcDurationPerStep(min_max_val, _steps_release)
    end
end

-- Function to set frequency and pulse width for the suction/release phases
function setFrequencyAndPulseWidthStep(startFreq, endFreq, startPulseWidth, endPulseWidth, steps)
    local freq = startFreq + (endFreq - startFreq) * (_current_step / steps)
    local pulseWidth = startPulseWidth + (endPulseWidth - startPulseWidth) * (_current_step / steps)

    zc.SetFrequency(1, freq)
    zc.SetPulseWidth(1, pulseWidth, pulseWidth)
end

function Setup(time_ms)
    zc.ChannelOn(1)
    zc.SetPower(1, 1000)
end

function Loop(time_ms)
    -- Suction phase
    if _phase == 1 then
        if time_ms > _step_wait_until_ms then
            -- Suction: Increase frequency and pulse width slowly with more steps
            setFrequencyAndPulseWidthStep(25, 80, 100, 180, _steps_suck)
            _current_step = _current_step + 1
            _step_wait_until_ms = time_ms + _duration_per_step_suck
        end
        if _current_step >= _steps_suck then
            _current_step = 0  -- Reset steps
            _phase = 2  -- Move to release phase
        end

    -- Release phase
    elseif _phase == 2 then
        if time_ms > _step_wait_until_ms then
            -- Release: Decrease frequency and pulse width quickly with fewer steps
            setFrequencyAndPulseWidthStep(80, 25, 180, 100, _steps_release)
            _current_step = _current_step + 1
            _step_wait_until_ms = time_ms + _duration_per_step_release
        end
        if _current_step >= _steps_release then
            _current_step = 0  -- Reset steps
            _phase = 1  -- Loop back to suction phase
        end
    end
end
