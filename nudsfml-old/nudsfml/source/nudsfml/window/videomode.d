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
			const(sfVideoMode) * modes = sfVideoMode_getFullscreenModes(&counts);;

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