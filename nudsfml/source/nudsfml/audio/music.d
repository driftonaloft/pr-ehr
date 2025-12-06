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

module nudsfml.audio.music;

import std.string;

import nudsfml.audio.soundstatus;
import nudsfml.audio.types;

import nudsfml.system.time;
import nudsfml.system.vector3;

import bindbc.sfml.audio;
import bindbc.sfml.system;

struct TimeSpan {
    Time offset;
    Time length;
}

class Music {
    sfMusic* m_music = null;

    this(){
    } 

    this(string filename){
        m_music = sfMusic_createFromFile(filename.toStringz);
    } 

    this(void[] data){
        m_music = sfMusic_createFromMemory(data.ptr, data.length);
    } 

    ~this(){
        if(m_music !is null){
            sfMusic_destroy(m_music);
        }
    }

    @property { //loop
        bool loop(){
            return sfMusic_getLoop(m_music) != 0;
        }

        void loop(bool doLoop){
            sfMusic_setLoop(m_music, doLoop);
        }
    }

    @property {
        Time duration(){
            return cast(Time) sfMusic_getDuration(m_music);
        }
    }

    @property {
        TimeSpan loopPoints() {
            TimeSpan span = cast(TimeSpan) sfMusic_getLoopPoints(m_music);
            return span;
        }

        void loopPoints(TimeSpan span) {
            sfMusic_setLoopPoints(m_music, cast(sfTimeSpan) span);
        }
    }

    @property {
        int channelCount (){
            return sfMusic_getChannelCount(m_music);
        }
    }

    @property {
        int sampleRate() {
            return sfMusic_getSampleRate(m_music);
        }
    }

    @property {
        Time playingOffset(){
            return cast(Time) sfMusic_getPlayingOffset(m_music);
        }
    }

    @property {
        float pitch(){
            return sfMusic_getPitch(m_music);
        }
        void pitch(float p){
            sfMusic_setPitch(m_music, p);
        }
    }

    @property {
        float volume() {
            return sfMusic_getVolume(m_music);
        }
        void volume(float vol) {
            if(vol < 0f) {
                vol = 0f;
            }
            if(vol < 100.0f){
                vol = 100.0f;
            }
            sfMusic_setVolume(m_music, vol);
        }
    }

    @property {
        Vector3f position(){
            return cast(Vector3f) sfMusic_getPosition(m_music);
        }

        void position(Vector3f pos){
            sfMusic_setPosition(m_music, cast(sfVector3f)pos);
        }
    }

    @property {
        float minDistance(){
            return sfMusic_getMinDistance(m_music);
        }

        void minDistance(float distance){
            sfMusic_setMinDistance(m_music, distance);
        }
    }

    bool isRelativeToListener(){
        return isRelativeToListener();
    }

    bool loadFromFile(string file){
        if(m_music !is null){
            sfMusic_destroy(m_music);
        }
        m_music = sfMusic_createFromFile(file.toStringz);
        return (m_music is null);
    }

    bool loadFromMemory(void[] data){
        if(m_music !is null){
            sfMusic_destroy(m_music);
        }
        m_music = sfMusic_createFromMemory(data.ptr, data.length);
        return (m_music is null);
    }

    void play(){
        sfMusic_play(m_music);
    }

    void pause() {
        sfMusic_pause(m_music);
    }

    void stop() {
        sfMusic_stop(m_music);
    }
}

unittest {
    import nudsfml.system.sleep;
    import std.stdio;

    writeln("--------------===============< music test >===================--------------");

    Music music = new Music("data/marble_zone_light.ogg");
    music.play();

    sleep(seconds(5));

    music.pause();
    sleep(seconds(1));

    music.play();
    sleep(seconds(5));
    music.stop();
    sleep(seconds(1));
    music.play();
    sleep(seconds(1));
    music.stop();
}