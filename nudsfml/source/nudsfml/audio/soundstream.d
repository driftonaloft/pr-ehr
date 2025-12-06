/*
 * DSFML - The Simple and Fast Multimedia Library for D
 *
 * Copyright (c) 2013 - 2018 Jeremy DeHaan (dehaan.jeremiah@gmail.com)
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from the
 * use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not claim
 * that you wrote the original software. If you use this software in a product,
 * an acknowledgment in the product documentation would be appreciated but is
 * not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source distribution
 *
 *
 * DSFML is based on SFML (Copyright Laurent Gomila)
 */

module nudsfml.audio.soundstream;

import bindbc.sfml.audio;
import bindbc.sfml.system;

import nudsfml.system.vector3;
import nudsfml.system.time;

class SoundStream {
    sfSoundStream * m_soundstream;

    void[] m_data;

    this(sfSoundStreamGetDataCallback onGetData, sfSoundStreamSeekCallback onSeek, uint channelCount, uint sampleRate,void[] data){
        m_data = data.dup;
        m_soundstream = sfSoundStream_create(onGetData, onSeek, channelCount, sampleRate, m_data.ptr);
    }
    
    ~this(){
        if(m_soundstream !is null){
            sfSoundStream_destroy(m_soundstream);
        }
    }

    @property {
        float pitch(){
            return sfSoundStream_getPitch(m_soundstream);
        }
        void pitch(float pitch_){
            sfSoundStream_setPitch(m_soundstream, pitch_);
        }
    }

    @property {
        float volume() {
            return sfSoundStream_getVolume(m_soundstream);
        }
        void volume(float vol) {
            if (vol < 0 ){
                vol = 0;
            } else if (vol > 100){
                vol = 100;
            }
            sfSoundStream_setVolume(m_soundstream, vol);
        }
    } 

    @property {
        Vector3f position(){
            return cast(Vector3f) sfSoundStream_getPosition(m_soundstream);
        }
        void position(Vector3f pos){
            sfSoundStream_setPosition(m_soundstream, cast(sfVector3f) pos);
        }
    }

    @property {
        bool loop(){
            return sfSoundStream_getLoop(m_soundstream) != 0;
        }
        void loop(bool doloop){
            sfSoundStream_setLoop(m_soundstream, doloop ? 1 : 0);
        }
    }

    @property {
        void minDistance(float distance){
            sfSoundStream_setMinDistance(m_soundstream, distance);
        }
        float minDistance(){
            return sfSoundStream_getMinDistance(m_soundstream);
        }
    }

    @property {
        void attenuation(float value){
            sfSoundStream_setAttenuation(m_soundstream, value);
        }
        float attenuation(){
            return sfSoundStream_getAttenuation(m_soundstream);
        }
    }

    @property {
        void relativeToListener(bool value){
            sfSoundStream_setRelativeToListener(m_soundstream, value ? 1 : 0 );
        }
        bool relativeToListener(){
            return sfSoundStream_isRelativeToListener(m_soundstream) != 0;
        }
    }

    @property {
        void playingOffset(Time value){
            sfSoundStream_setPlayingOffset(m_soundstream, cast(sfTime)value);
        }
        Time playingOffset(){
            return cast(Time) sfSoundStream_getPlayingOffset(m_soundstream);
        }
    }

    @property {
        uint sampleRate(){
            return sfSoundStream_getSampleRate(m_soundstream);
        }
    }

    void play(){
        sfSoundStream_play(m_soundstream);
    }
    void pause(){
        sfSoundStream_pause(m_soundstream);
    }
    void stop(){
        sfSoundStream_stop(m_soundstream);
    }
}