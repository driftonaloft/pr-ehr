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

/**
 * Musics are sounds that are streamed rather than completely loaded in memory.
 *
 * This is especially useful for compressed musics that usually take hundreds of
 * MB when they are uncompressed: by streaming it instead of loading it
 * entirely, you avoid saturating the memory and have almost no loading delay.
 *
 * Apart from that, a $(U Music) has almost the same features as the
 * $(SOUNDBUFFER_LINK)/$(SOUND_LINK) pair: you can play/pause/stop it, request
 * its parameters (channels, sample rate), change the way it is played (pitch,
 * volume, 3D position, ...), etc.
 *
 * As a sound stream, a music is played in its own thread in order not to block
 * the rest of the program. This means that you can leave the music alone after
 * calling `play()`, it will manage itself very well.
 *
 * Example:
 * ---
 * // Declare a new music
 * auto music = new Music();
 *
 * // Open it from an audio file
 * if (!music.openFromFile("music.ogg"))
 * {
 *     // error...
 * }
 *
 * // change its 3D position
 * music.position = Vector3f(0, 1, 10);
 *
 * // increase the pitch
 * music.pitch = 2;
 *
 * // reduce the volume
 * music.volume = 50;
 *
 * // make it loop
 * music.loop = true;
 *
 * // Play it
 * music.play();
 * ---
 *
 * See_Also:
 * $(SOUND_LINK), $(SOUNDSTREAM_LINK)
 */
module nudsfml.audio.music;

public import nudsfml.system.time;

import nudsfml.system.mutex;
import nudsfml.system.inputstream;

import nudsfml.audio.soundstream;

import bindbc.sfml.audio;


/**
 * Streamed music played from an audio file.
 */
class Music //: SoundStream
{
    //import nudsfml.audio.inputsoundfile;
    sfMusic * sfPtr;

    private {
        //InputSoundFile m_file;
        Time m_duration;
        short[] m_samples;
        Mutex m_mutex;
    }

    /// Default constructor.
    this() {
        //m_file = new InputSoundFile();
        m_mutex = new Mutex();
        //super();
    }

    /// Destructor
    ~this() {
        import nudsfml.system.config;
        mixin(destructorOutput);

        if(sfPtr != null){
            sfMusic_destroy(sfPtr);
            sfPtr = null;
        }

        /*
         * Calling stop() causes a segmentation fault when m_mutex is
         * destroyed before this destructor has run (which is what happens
         * during a GC collection).
         *
         * It is probably OK to not call it here since it only resets the seek
         * position on top of what the SoundStream destructor already does.
         */

        //stop();
    }

    /**
     * Open a music from an audio file.
     *
     * This function doesn't start playing the music (call `play()` to do so).
     *
     * The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The
     * supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.
     *
     * Params:
     * 		filename =	Path of the music file to open
     *
     * Returns: true if loading succeeded, false if it failed.
     */
    bool openFromFile(string filename) {
        //stop music if already playing
        stop();

        import std.string;
        if(sfPtr != null){
            sfMusic_destroy(sfPtr);
        }
        sfPtr = sfMusic_createFromFile(filename.toStringz);

        initialize();

        return sfPtr != null;
    }

    /**
     * Open a music from an audio file in memory.
     *
     * This function doesn't start playing the music (call `play()` to do so).
     *
     * The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The
     * supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.
     *
     * Since the music is not loaded completely but rather streamed
     * continuously, the data must remain available as long as the music is
     * playing (ie. you can't deallocate it right after calling this function).
     *
     * Params:
     * 		data =	The array of data
     *
     * Returns: true if loading succeeded, false if it failed.
     */
    bool openFromMemory(const(void)[] data) {
        stop();

        if(sfPtr != null){
            sfMusic_destroy(sfPtr);
        }

        initialize();

        sfPtr = sfMusic_createFromMemory(data.ptr, data.length);
        return  sfPtr != null;
    }

    void play() {
        if(sfPtr != null){
            sfMusic_play(sfPtr);
        }
    }

    void pause() {
        if(sfPtr != null){
            sfMusic_pause(sfPtr);
        }
    }

    void stop() {
        if(sfPtr != null){
            sfMusic_stop(sfPtr);
        }
    }

    /**
     * Open a music from an audio file in memory.
     *
     * This function doesn't start playing the music (call `play()` to do so).
     *
     * The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The
     * supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.
     *
     * Since the music is not loaded completely but rather streamed
     * continuously, the stream must remain available as long as the music is
     * playing (ie. you can't deallocate it right after calling this function).
     *
     * Params:
     * 		stream =	Source stream to read from
     *
     * Returns: true if loading succeeded, false if it failed.
     */

    /* 
    bool openFromStream(InputStream stream)
    {
        stop();

        if(!m_file.openFromStream(stream))
        {
            return false;
        }

        initialize();

        return true;
    }
    */

    /**
     * Get the total duration of the music.
     *
     * Returns: Music duration
     */
    Time getDuration() const {
        return m_duration;
    }

    protected
    {
        /**
         * Request a new chunk of audio samples from the stream source.
         *
         * This function fills the chunk from the next samples to read from the
         * audio file.
         *
         * Params:
         * 		samples =	Array of samples to fill
         *
         * Returns: true to continue playback, false to stop.
         */
        /*override bool onGetData(ref const(short)[] samples)
        {
            import nudsfml.system.lock;

            Lock lock = Lock(m_mutex);

            auto length = cast(size_t)m_file.read(m_samples);
            samples = m_samples[0..length];

            return (samples.length == m_samples.length);
        }*/

        /**
         * Change the current playing position in the stream source.
         *
         * Params:
         * 		timeOffset =   New playing position, from the start of the music
         *
         */
        /*override void onSeek(Time timeOffset)
        {
            import nudsfml.system.lock: Lock;

            auto lock = Lock(m_mutex);

            m_file.seek(timeOffset.asMicroseconds());
        }*
    }

    private
    {
        /**
         * Define the audio stream parameters.
         *
         * This function must be called by derived classes as soon as they know
         * the audio settings of the stream to play. Any attempt to manipulate
         * the stream (play(), ...) before calling this function will fail.
         *
         * It can be called multiple times if the settings of the audio stream
         * change, but only when the stream is stopped.
         *
         * Params:
         * 		channelCount =	Number of channels of the stream
         * 		sampleRate =	Sample rate, in samples per second
         */
        void initialize()
        {
            size_t sampleCount = 1_000_000;//cast(size_t)m_file.getSampleCount();

            uint channelCount = sfMusic_getChannelCount(sfPtr);

            uint sampleRate = sfMusic_getSampleRate(sfPtr);

            // Compute the music duration
            m_duration = cast(Time) sfMusic_getDuration(sfPtr);
            
            microseconds(sampleCount * 1_000_000 / sampleRate /
                                channelCount);

            // Resize the internal buffer so that it can contain 1 second of audio samples
            m_samples.length = sampleRate * channelCount;

            // Initialize the stream
           // super.initialize(channelCount, sampleRate);
        }
    }
}

unittest
{
    version(DSFML_Unittest_Audio)
    {
        import std.stdio;
        import nudsfml.system.clock;

        writeln("Unit test for Music Class");

        auto music = new Music();

        //TODO: update this for a real unit test users can run themselves.
        if(!music.openFromFile("res/TestMusic.ogg"))
        {
            return;
        }

        auto clock = new Clock();

        writeln("Playing music for 5 seconds");

        music.play();
        while(clock.getElapsedTime().asSeconds() < 5)
        {
            //playing music in seoarate thread while main thread is stuck here
        }

        music.stop();

        writeln();
    }
}
