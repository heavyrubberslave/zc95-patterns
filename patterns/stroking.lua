_initial_duration_sec = 4  -- Initial stroke duration
_steps = 100      -- Number of steps for each phase

Config = {
    name = "Stroking",
    menu_items = {
        {
            type = "MIN_MAX",
            title = "Stroke duration (Ch 1+2)",
            id = 1,
            min = 1,
            max = 10,
            increment_step = 1,
            uom = "sec",
            default = _initial_duration_sec
         },
         {
            type = "MIN_MAX",
            title = "Stroke duration (Ch 3+4)",
            id = 2,
            min = 1,
            max = 10,
            increment_step = 1,
            uom = "sec",
            default = _initial_duration_sec
         },
    }
}

function calcDurationPerStep(duration_per_phase)
    return duration_per_phase * 1000 / _steps -- Time per step in milliseconds
end

-- Initialize variables for both stroking sets
_step_wait_until_ms = {0, 0}  -- Tracks when the next step should occur for each set of channels
_phase = {1, 1}               -- Keeps track of the current phase for each set of channels
_current_step = {0, 0}        -- Tracks the current step for each set of channels
_duration_per_step_ch12 = calcDurationPerStep(_initial_duration_sec)
_duration_per_step_ch34 = calcDurationPerStep(_initial_duration_sec)

-- Updates the stroke duration for the given menu item (1 for Ch1+2, 2 for Ch3+4)
function MinMaxChange(menu_id, min_max_val)
    if menu_id == 1 then
        _duration_per_step_ch12 = calcDurationPerStep(min_max_val)
    elseif menu_id == 2 then
        _duration_per_step_ch34 = calcDurationPerStep(min_max_val)
    end
end

-- Function to control frequency and pulse width for a set of channels (ch1, ch2) or (ch3, ch4)
function setFrequencyAndPulseWidthStep(idx, ch1, ch2, startFreq, endFreq, startPulseWidth, endPulseWidth)
    local freq = startFreq + (endFreq - startFreq) * (_current_step[idx] / _steps)
    local pulseWidth = startPulseWidth + (endPulseWidth - startPulseWidth) * (_current_step[idx] / _steps)

    -- First channel in the pair (ch1) moves from startFreq to endFreq
    zc.SetFrequency(ch1, freq)
    zc.SetPulseWidth(ch1, pulseWidth, pulseWidth)

    -- Second channel in the pair (ch2) moves inversely
    zc.SetFrequency(ch2, endFreq - (freq - startFreq))
    zc.SetPulseWidth(ch2, endPulseWidth - (pulseWidth - startPulseWidth), endPulseWidth - (pulseWidth - startPulseWidth))
end

function Setup(time_ms)
    for channel = 1, 4 do
        zc.ChannelOn(channel)
        zc.SetPower(channel, 1000)
    end
end

-- Function to control the Loop for one stroking set (either ch1+ch2 or ch3+ch4)
function LoopForChannels(time_ms, idx, ch1, ch2, phase1Freqs, phase2Freqs, phase1PulseWidths, phase2PulseWidths, duration_per_step)
    -- Phase 1: Stroke from ch1 to ch2
    if _phase[idx] == 1 then
        if time_ms > _step_wait_until_ms[idx] then
            setFrequencyAndPulseWidthStep(idx, ch1, ch2, phase1Freqs[1], phase1Freqs[2], phase1PulseWidths[1], phase1PulseWidths[2])
            _current_step[idx] = _current_step[idx] + 1
            _step_wait_until_ms[idx] = time_ms + duration_per_step  -- Schedule the next step
        end
        if _current_step[idx] >= _steps then
            _current_step[idx] = 0  -- Reset steps
            _phase[idx] = 2         -- Move to the next phase
        end

    -- Phase 2: Stroke back from ch2 to ch1
    elseif _phase[idx] == 2 then
        if time_ms > _step_wait_until_ms[idx] then
            setFrequencyAndPulseWidthStep(idx, ch1, ch2, phase2Freqs[1], phase2Freqs[2], phase2PulseWidths[1], phase2PulseWidths[2])
            _current_step[idx] = _current_step[idx] + 1
            _step_wait_until_ms[idx] = time_ms + duration_per_step
        end
        if _current_step[idx] >= _steps then
            _current_step[idx] = 0
            _phase[idx] = 1  -- Loop back to phase 1
        end
    end
end

function Loop(time_ms)
    -- Control stroking between channels 1 and 2
    LoopForChannels(time_ms, 1, 1, 2, {25, 60}, {60, 25}, {160, 100}, {100, 160}, _duration_per_step_ch12)

    -- Control stroking between channels 3 and 4
    LoopForChannels(time_ms, 2, 3, 4, {10, 50}, {50, 10}, {150, 120}, {120, 150}, _duration_per_step_ch34)
end
