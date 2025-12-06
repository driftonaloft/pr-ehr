module nudsfml.audio.soundstatus;

import bindbc.sfml.config;

// Audio/SoundStatus.h
enum SoundStatus {
    sfStopped,
    sfPaused,
    sfPlaying,
}

mixin(expandEnum!SoundStatus);