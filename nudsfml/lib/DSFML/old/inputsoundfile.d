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
 * $(U InputSoundFile) decodes audio samples from a sound file. It is used
 * internally by higher-level classes such as $(SOUNDBUFFER_LINK) and
 * $(MUSIC_LINK), but can also be useful if you want to process or analyze audio
 * files without playing them, or if you want to implement your own version of
 * $(MUSIC_LINK) with more specific features.
 *
 * Example:
 * ---
 * // Open a sound file
 * auto file = new InputSoundFile();
 * if (!file.openFromFile("music.ogg"))
 * {
 *      //error
 * }
 *
 * // Print the sound attributes
 * writeln("duration: ", file.getDuration().total!"seconds");
 * writeln("channels: ", file.getChannelCount());
 * writeln("sample rate: ", file.getSampleRate());
 * writeln("sample count: ", file.getSampleCount());
 *
 * // Read and process batches of samples until the end of file is reached
 * short samples[1024];
 * long count;
 * do
 * {
 *     count = file.read(samples, 1024);
 *
 *     // process, analyze, play, convert, or whatever
 *     // you want to do with the samples...
 * }
 * while (count > 0);
 * ---
 *
 * See_Also:
 * $(OUTPUTSOUNDFILE_LINK)
 */
module nudsfml.audio.old.inputsoundfile;

import std.string;
import nudsfml.system.inputstream;
import nudsfml.system.err;

import bindbc.sfml.audio;

public import nudsfml.system.time;

