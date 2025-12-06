/*--+{ NuDSFML 2.5.1 }+------------------------------------------------------*\
| NuDSFML 2.5.1 (new DSFML) is a refactor of DSFML 2.4 by Jeremy Dahaan       |
| it has been refactored to be based on CSFML 2.5.1 via the bindbc.sfml       |
| library by Drifton Aloft                                                    |
|                                                                             |
| Caution not all current DSFML features have been replicated / implimented   |
| yet. use at your own risk this software probably contains bugs, clever      |
| fixes and other programmer hijinks                                          |
\*---------------------------------------------------------------------------*/

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

module nudsfml.window.videomode;

import bindbc.sfml.window;

struct VideoMode {
	///Video mode width, in pixels.
	uint width;
	///Video mode height, in pixels.
	uint height;

	///Video mode pixel depth, in bits per pixels.
	uint bitsPerPixel;

	/**
	 * Construct the video mode with its attributes.
	 *
	 * Params:
     * 		modeWidth = Width in pixels
     * 		modeHeight = Height in pixels
     * 		modeBitsPerPixel = Pixel depths in bits per pixel
	 */
	this(uint modeWidth, uint modeHeight, uint modeBitsPerPixel= 32) {
		width = modeWidth;
		height = modeHeight;
		bitsPerPixel = modeBitsPerPixel;
	}

	/**
	 * Get the current desktop video mode.
	 *
	 * Returns: Current desktop video mode.
	 */
	static VideoMode getDesktopMode() {
		VideoMode temp = cast(VideoMode) sfVideoMode_getDesktopMode();
		return temp;
	}

	/**
	 * Retrieve all the video modes supported in fullscreen mode.
	 *
	 * When creating a fullscreen window, the video mode is restricted to be
	 * compatible with what the graphics driver and monitor support. This
	 * function returns the complete list of all video modes that can be used in
	 * fullscreen mode. The returned array is sorted from best to worst, so that
	 * the first element will always give the best mode (higher width, height
	 * and bits-per-pixel).
	 *
	 * Returns: Array containing all the supported fullscreen modes.
	 */
	static VideoMode[] getFullscreenModes() {
		//stores all video modes after the first call
		static VideoMode[] videoModes;

		//if getFullscreenModes hasn't been called yet
		if(videoModes.length == 0) {
			size_t counts;
			const(sfVideoMode) * modes = sfVideoMode_getFullscreenModes(&counts);

			//calculate real length
			videoModes.length = counts/3;

			//populate videoModes
			int videoModeIndex = 0;
			for(uint i = 0; i < counts; i+=3) {
				VideoMode temp = VideoMode(modes[i].width, modes[i].height, modes[i].bitsPerPixel);

				videoModes[videoModeIndex] = temp;
				++videoModeIndex;
			}
		}

		return videoModes;
	}

	/**
	 * Tell whether or not the video mode is valid.
	 *
	 * The validity of video modes is only relevant when using fullscreen
	 * windows; otherwise any video mode can be used with no restriction.
	 *
	 * Returns: true if the video mode is valid for fullscreen mode.
	 */
	bool isValid() const {
		sfVideoMode mode = cast(sfVideoMode) this;
		return sfVideoMode_isValid(mode)>0;
	}

	///Returns a string representation of the video mode.
	string toString() const {
		import std.conv: text;
		return "Width: " ~ text(width) ~ " Height: " ~ text(height) ~ " Bits per pixel: " ~ text(bitsPerPixel);
	}
}