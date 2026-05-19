local obs = obslua

-- Default sound file
local audio_file_path = ""

function playsound(filepath)
    if filepath == "" or filepath == nil then
        print("No audio file specified")
        return
    end

    local players = {"aplay", "paplay", "play", "ffplay"}

    for _, player in ipairs(players) do
        local cmd = string.format("which %s >/dev/null 2>&1", player)
        if os.execute(cmd) == 0 then
            if player == "ffplay" then
                os.execute(string.format("%s -nodisp -autoexit '%s' >/dev/null 2>&1 &", player, filepath))
            elseif player == "paplay" then
                os.execute(string.format("%s '%s' &", player, filepath))
            else
                os.execute(string.format("%s '%s' >/dev/null 2>&1 &", player, filepath))
            end
            return
        end
    end

    print("No audio player found. Install alsa-utils, pulseaudio-utils, sox, or ffmpeg")
end

function on_event(event)
    if event == obs.OBS_FRONTEND_EVENT_REPLAY_BUFFER_SAVED then
        playsound(audio_file_path)
    end
end

function script_load(settings)
    obs.obs_frontend_add_event_callback(on_event)
    audio_file_path = obs.obs_data_get_string(settings, "audio_file")
end

function script_save(settings)
    obs.obs_data_set_string(settings, "audio_file", audio_file_path)
end

function script_update(settings)
    audio_file_path = obs.obs_data_get_string(settings, "audio_file")
end

function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_path(props, "audio_file", "Audio File", obs.OBS_PATH_FILE, "Audio Files (*.wav *.mp3 *.ogg)",
        nil)

    return props
end

function script_description()
    return "Plays a sound when replay buffer is saved.\n\nSelect your audio file in the properties below."
end
