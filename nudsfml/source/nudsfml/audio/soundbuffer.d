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


module nudsfml.audio.soundbuffer;

import std.string;
import bindbc.sfml.audio;

import nudsfml.system.time;
import nudsfml.system.vector3;

import nudsfml.audio.soundstatus;

class SoundBuffer {
    sfSoundBuffer* m_soundBuffer = null;

    this(const(sfSoundBuffer)* other){
        m_soundBuffer = sfSoundBuffer_copy(other);
    }
    this(SoundBuffer other) {
        m_soundBuffer = sfSoundBuffer_copy(other.m_soundBuffer);
    }
    this(string filename){
        createFromFile(filename);
    }
    this(void[] data){
        createFromMemory(data);
    }
    ~this(){
        if(m_soundBuffer !is null){
            sfSoundBuffer_destroy(m_soundBuffer);
        }
    }

    @property {
        short[] samples() {
            import core.stdc.string;
            short* temp = cast(short*) sfSoundBuffer_getSamples(m_soundBuffer);
            size_t length = sfSoundBuffer_getSampleCount(m_soundBuffer);

            short[] retval;
            retval.length = length;
            memcpy(temp, retval.ptr, length);

            return retval;
        }
        void samples(short [] data) {

        }
    }
    @property {
        uint sampleRate(){
            return sfSoundBuffer_getSampleRate(m_soundBuffer);
        }
    }
    @property {
        uint channelCount(){
            return sfSoundBuffer_getChannelCount(m_soundBuffer);
        }
    }
    @property {
        Time duration(){
            return cast(Time) sfSoundBuffer_getDuration(m_soundBuffer);
        }
    }

    bool createFromFile(string filename){
        if(m_soundBuffer !is null){
            sfSoundBuffer_destroy(m_soundBuffer);
        }
        m_soundBuffer = sfSoundBuffer_createFromFile(filename.toStringz);
        return m_soundBuffer !is null;
    }
    bool createFromMemory(void[] data){
        if(m_soundBuffer !is null){
            sfSoundBuffer_destroy(m_soundBuffer);
        }
        m_soundBuffer = sfSoundBuffer_createFromMemory(data.ptr, data.length);
        return m_soundBuffer !is null;
    }
}