# zc95-patterns

Collection of patterns written in Lua for the [ZC95 e-stim device](https://github.com/CrashOverride85/zc95).

The scripts can be uploaded to the e-stim device via WiFi. [See documentation](https://github.com/CrashOverride85/zc95/blob/main/docs/RemoteAccess.md#lua_uploadpy).

## Constant
Gives you full manual control over a constant sensation for all 4 channels equally.

Frquency and pulse width (positive and negative) can be adjusted independently. Frquency from 5 to 300 Hz, positive and negative pulse width from 5 to 255 us.

While it's technically not a pattern, this program can be very useful to determine specific frequencies and pulse widths to cause a desired sensation. Also it's useful if a constant stimulation is required.

## Phase 3
This e-stim pattern consists of four distinct phases, each lasting for a specified duration (default is 60s, but can be adjusted) and broken into 100 gradual steps. The frequencies and pulse widths vary between each step, gradually transitioning from a starting value to an ending value within each phase. Each phase is designed to produce different sensations as it progresses through the steps, with each channel's frequency and pulse width being adjusted accordingly.

The overall flow repeats indefinitely after completing all four phases.

* Phase Duration: The default duration is 60 seconds per phase, adjustable from 10 to 240 seconds via the menu.
* Steps per Phase: Each phase has 100 steps, ensuring smooth transitions in frequencies and pulse widths.
* Phase Repetition: After Phase 4, the process loops back to Phase 1.

### Phase Details
| Phase | Frequency | Pulse Width | Description | Purpose |
| --- | --- | --- | --- | --- |
| Phase 1 | 25 Hz → 20 Hz| 160 ms → 140 ms| Starts with a relatively high frequency of 25 Hz and gradually decreases to 20 Hz. The pulse width narrows slightly, producing a medium-paced, firm stimulation. | Provides a moderate introduction to the stimulation, easing into the session with slightly reducing intensity. |
| Phase 2 | 20 Hz → 5 Hz | 140 ms → 150 ms | Frequency drops significantly, from 20 Hz to 5 Hz, while the pulse width expands slightly. The slow pulses create a deeper, more drawn-out sensation. | Deep and slow sensations, used to build intensity and provide grounding, thudding effects. |
| Phase 3 | 5 Hz → 80 Hz | 150 ms → 100 ms | A rapid increase in frequency, from 5 Hz to 80 Hz, with the pulse width shortening. This creates sharper, faster pulses that feel more intense and buzzing. | Sharp, fast stimulation intended to increase excitement and arousal with quicker pulses. |
| Phase 4 | 80 Hz → 60 Hz | 100 ms → 110 ms | Frequency decreases slightly, from 80 Hz to 60 Hz, while the pulse width broadens a bit. The sensations smooth out but retain a strong, fast pace. | A smoother and more consistent phase, offering a moderate intensity level with steady sensations. |