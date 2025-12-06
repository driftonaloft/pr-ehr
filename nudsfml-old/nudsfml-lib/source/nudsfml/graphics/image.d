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

module nudsfml.graphics.image;

import bindbc.sfml.graphics;

import nudsfml.graphics.color;
import nudsfml.graphics.rect;
import nudsfml.system.vector2;
import nudsfml.system.inputstream;

class Image {
    sfImage* sfPtr = null;
    /// Default constructor.
    this() {
        sfPtr = sfImage_create(0,0);
    }

    package this(sfImage* image){
        sfPtr = image;
    }

    /// Destructor.
    ~this() {
        if(sfPtr != null){
            sfImage_destroy(sfPtr);
        }
    }

    /**
     * Create the image and fill it with a unique color.
     *
     * Params:
     * 		width	= Width of the image
     * 		height	= Height of the image
     * 		color	= Fill color
     *
     */
    void create(uint width, uint height, Color color) {
        sfColor c = fromColor(color);
        if(sfPtr !is null) {
            sfImage_destroy(sfPtr);
        }
        sfPtr = sfImage_createFromColor(width, height,c);
    }

    /**
     * Create the image from an array of pixels.
     *
     * The pixel array is assumed to contain 32-bits RGBA pixels, and have the
     * given width and height. If not, this is an undefined behaviour. If pixels
     * is null, an empty image is created.
     *
     * Params:
     * 		width	= Width of the image
     * 		height	= Height of the image
     * 		pixels	= Array of pixels to copy to the image
     *
     */
    void create(uint width, uint height, const(ubyte)[] pixels) {
        if (sfPtr !is null)
            sfImage_destroy(sfPtr);
        sfPtr = sfImage_createFromPixels(width, height,pixels.ptr);
    }

    /**
     * Load the image from a file on disk.
     *
     * The supported image formats are bmp, png, tga, jpg, gif, psd, hdr and
     * pic. Some format options are not supported, like progressive jpeg. If
     * this function fails, the image is left unchanged.
     *
     * Params:
     * 		filename	= Path of the image file to load
     *
     * Returns: true if loading succeeded, false if it failed
     */
    bool loadFromFile(const(char)[] filename) {
        import std.string;
        if(sfPtr !is null){
            sfImage_destroy(sfPtr);
        }
        sfPtr = sfImage_createFromFile(filename.toStringz);
        return sfPtr !is null;
    }

    /**
     * Load the image from a file in memory.
     *
     * The supported image formats are bmp, png, tga, jpg, gif, psd, hdr and
     * pic. Some format options are not supported, like progressive jpeg. If
     * this function fails, the image is left unchanged.
     *
     * Params:
     * 		data	= Data file in memory to load
     *
     * Returns: true if loading succeeded, false if it failed
     */
    bool loadFromMemory(const(void)[] data) {
        if(sfPtr !is null){
            sfImage_destroy(sfPtr);
        }
        sfPtr = sfImage_createFromMemory(data.ptr, data.length);
        return sfPtr !is null;
    }

    /**
     * Get the color of a pixel
     *
     * This function doesn't check the validity of the pixel coordinates; using
     * out-of-range values will result in an undefined behaviour.
     *
     * Params:
     * 		x	= X coordinate of the pixel to get
     * 		y	= Y coordinate of the pixel to get
     *
     * Returns: Color of the pixel at coordinates (x, y)
     */
    Color getPixel(uint x, uint y) const {
        import std.conv;
        sfColor c = sfImage_getPixel(sfPtr, x,y);
        Color temp;
        temp.r = c.r.to!ubyte;
        temp.g = c.g.to!ubyte;
        temp.b = c.b.to!ubyte;
        temp.a = c.a.to!ubyte;
        return temp;
    }

    /**
     * Get the read-only array of pixels that make up the image.
     *
     * The returned value points to an array of RGBA pixels made of 8 bits
     * integers components. The size of the array is:
     * `width * height * 4 (getSize().x * getSize().y * 4)`.
     *
     * Warning: the returned slice may become invalid if you modify the image,
     * so you should never store it for too long.
     *
     * Returns: Read-only array of pixels that make up the image.
     */
    const(ubyte)[] getPixelArray() const {
        import std.stdio;
        Vector2u size = getSize();
        int length = size.x * size.y * 4;

        if(length!=0) {
            return sfImage_getPixelsPtr(sfPtr)[0..length];
        } else {
            writeln("Trying to access the pixels of an empty image");
            return [];
        }
    }

    /**
     * Return the size (width and height) of the image.
     *
     * Returns: Size of the image, in pixels.
     */
    Vector2u getSize() const {
       auto v = sfImage_getSize(sfPtr);
        Vector2u temp = Vector2u(v.x,v.y);
        return temp;
    }

    /**
     * Change the color of a pixel.
     *
     * This function doesn't check the validity of the pixel coordinates, using
     * out-of-range values will result in an undefined behaviour.
     *
     * Params:
     * 		x		= X coordinate of pixel to change
     * 		y		= Y coordinate of pixel to change
     * 		color	= New color of the pixel
     */
    void setPixel(uint x, uint y, Color color) {
        sfColor c = fromColor(color);
        sfImage_setPixel(sfPtr, x,y,c);
    }

    /**
     * Copy pixels from another image onto this one.
     *
     * This function does a slow pixel copy and should not be used intensively.
     * It can be used to prepare a complex static image from several others, but
     * if you need this kind of feature in real-time you'd better use
     * RenderTexture.
     *
     * If sourceRect is empty, the whole image is copied. If applyAlpha is set
     * to true, the transparency of source pixels is applied. If it is false,
     * the pixels are copied unchanged with their alpha value.
     *
     * Params:
     * 	source		= Source image to copy
     * 	destX		= X coordinate of the destination position
     * 	destY		= Y coordinate of the destination position
     * 	sourceRect	= Sub-rectangle of the source image to copy
     * 	applyAlpha	= Should the copy take the source transparency into account?
     */
    void copyImage(const(Image) source, uint destX, uint destY, IntRect sourceRect = IntRect(0,0,0,0), bool applyAlpha = false){
        sfIntRect sourcerect;
        
        sourcerect.left = sourceRect.left;
        sourcerect.top = sourceRect.top;
        sourcerect.width = sourceRect.width;
        sourcerect.height = sourceRect.height;

        sfImage_copyImage(sfPtr, source.sfPtr, destX, destY,sourcerect, applyAlpha);
    }

    /**
     * Create a transparency mask from a specified color-key.
     *
     * This function sets the alpha value of every pixel matching the given
     * color to alpha (0 by default) so that they become transparent.
     *
     * Params:
     * 		maskColor   = Color to make transparent
     * 		alpha	    = Alpha value to assign to transparent pixels
     */
    void createMaskFromColor(Color maskColor, ubyte alpha = 0) {
        sfColor c = fromColor(maskColor);
        sfImage_createMaskFromColor(sfPtr,c, alpha);
    }

    /// Create a copy of the Image.
    @property Image dup() const {
        return new Image(sfImage_copy(sfPtr));
    }

    /// Flip the image horizontally (left <-> right)
    void flipHorizontally(){
        sfImage_flipHorizontally(sfPtr);
    }

    /// Flip the image vertically (top <-> bottom)
    void flipVertically() {
        sfImage_flipVertically(sfPtr);
    }

    /**
     * Save the image to a file on disk.
     *
     * The format of the image is automatically deduced from the extension. The
     * supported image formats are bmp, png, tga and jpg. The destination file
     * is overwritten if it already exists. This function fails if the image is
     * empty.
     *
     * Params:
     * 		filename	= Path of the file to save
     *
     * Returns: true if saving was successful
     */
    bool saveToFile(const(char)[] filename) const{
        import std.string;
        auto f  = filename.toStringz;
        return sfImage_saveToFile(sfPtr, f)!=0;
    }
}