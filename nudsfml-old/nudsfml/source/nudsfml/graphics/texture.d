module nudsfml.graphics.texture;

import std.string;

import bindbc.sfml.graphics;
import bindbc.sfml.system;

import nudsfml.graphics.rect;
import nudsfml.graphics.image;
import nudsfml.graphics.renderwindow;

import nudsfml.window.window;

import nudsfml.system.inputstream;
import nudsfml.system.vector2;
//import nudsfml.system.err;

/**
 * Image living on the graphics card that can be used for drawing.
 */
class Texture
{
    package sfTexture* sfPtr;
    bool managed = false;

    /**
     * Default constructor
     *
     * Creates an empty texture.
     */
    this() {
        //sfPtr = sfTexture_construct();
    }

    package this(sfTexture * texturePointer)
    {
        sfPtr = texturePointer;
        managed = true;
    }

    /// Destructor.
    ~this() {
        //import nudsfml.system.config;
//        mixin(destructorOutput);
        if(!managed && sfPtr !is null) {
            sfTexture_destroy(sfPtr);
            sfPtr = null;
        }
    }

    /**
     * Load the texture from a file on disk.
     *
     * The area argument can be used to load only a sub-rectangle of the whole
     * image. If you want the entire image then leave the default value (which
     * is an empty IntRect). If the area rectangle crosses the bounds of the
     * image, it is adjusted to fit the image size.
     *
     * The maximum size for a texture depends on the graphics driver and can be
     * retrieved with the getMaximumSize function.
     *
     * If this function fails, the texture is left unchanged.
     *
     * Params:
     * 		filename	= Path of the image file to load
     * 		area		= Area of the image to load
     *
     * Returns: true if loading was successful, false otherwise.
     */
    bool loadFromFile(const(char)[] filename, IntRect area = IntRect() )
    {
        if(sfPtr !is null){
            sfTexture_destroy( sfPtr);
        }

        sfIntRect *sfArea = new sfIntRect;
        sfArea.left = area.left;
        sfArea.top = area.top;
        sfArea.width = area.width;
        sfArea.height = area.height;

        sfPtr = sfTexture_createFromFile( filename.toStringz ,sfArea); 
        return sfPtr !is null;
    }

    /**
     * Load the texture from a file in memory.
     *
     * The area argument can be used to load only a sub-rectangle of the whole
     * image. If you want the entire image then leave the default value (which
     * is an empty IntRect). If the area rectangle crosses the bounds of the
     * image, it is adjusted to fit the image size.
     *
     * The maximum size for a texture depends on the graphics driver and can be
     * retrieved with the getMaximumSize function.
     *
     * If this function fails, the texture is left unchanged.
     *
     * Params:
     * 		data	= Image in memory
     * 		area	= Area of the image to load
     *
     * Returns: true if loading was successful, false otherwise.
     */
    bool loadFromMemory(const(void)[] data, IntRect area = IntRect())
    {
        if(sfPtr !is null){
            sfTexture_destroy( sfPtr);
        }
        
        sfIntRect *sfArea = new sfIntRect;
        sfArea.left = area.left;
        sfArea.top = area.top;
        sfArea.width = area.width;
        sfArea.height = area.height;

        sfPtr = sfTexture_createFromMemory(data.ptr, data.length,sfArea); 
        return sfPtr !is null;

    }
    /**
     * Load the texture from an image.
     *
     * The area argument can be used to load only a sub-rectangle of the whole
     * image. If you want the entire image then leave the default value (which
     * is an empty IntRect). If the area rectangle crosses the bounds of the
     * image, it is adjusted to fit the image size.
     *
     * The maximum size for a texture depends on the graphics driver and can be
     * retrieved with the getMaximumSize function.
     *
     * If this function fails, the texture is left unchanged.
     *
     * Params:
     * 		image	= Image to load into the texture
     * 		area	= Area of the image to load
     *
     * Returns: true if loading was successful, false otherwise.
     */
    bool loadFromImage(Image image, IntRect area = IntRect())
    {

        if(sfPtr !is null){
            sfTexture_destroy( sfPtr);
        }
        
        sfIntRect *sfArea = new sfIntRect;
        sfArea.left = area.left;
        sfArea.top = area.top;
        sfArea.width = area.width;
        sfArea.height = area.height;

        sfPtr = sfTexture_createFromImage(image.sfPtr,sfArea); 
        return sfPtr !is null;
    }

    /**
     * Get the maximum texture size allowed.
     *
     * This Maximum size is defined by the graphics driver. You can expect a
     * value of 512 pixels for low-end graphics card, and up to 8192 pixels or
     * more for newer hardware.
     *
     * Returns: Maximum size allowed for textures, in pixels.
     */
    static uint getMaximumSize()
    {
        return sfTexture_getMaximumSize();
    }

    /**
     * Return the size of the texture.
     *
     * Returns: Size in pixels.
     */
    Vector2u getSize() const
    {
        sfVector2u temp = sfTexture_getSize( sfPtr);
        Vector2u retval = Vector2u(temp.x,temp.y);
        return retval;
    }

    /**
     * Enable or disable the smooth filter.
     *
     * When the filter is activated, the texture appears smoother so that pixels
     * are less noticeable. However if you want the texture to look exactly the
     * same as its source file, you should leave it disabled. The smooth filter
     * is disabled by default.
     *
     * Params:
     * 		smooth	= true to enable smoothing, false to disable it
     */
    void setSmooth(bool smooth)
    {
        sfTexture_setSmooth(sfPtr, smooth);
    }

    /**
     * Enable or disable repeating.
     *
     * Repeating is involved when using texture coordinates outside the texture
     * rectangle [0, 0, width, height]. In this case, if repeat mode is enabled,
     * the whole texture will be repeated as many times as needed to reach the
     * coordinate (for example, if the X texture coordinate is 3 * width, the
     * texture will be repeated 3 times).
     *
     * If repeat mode is disabled, the "extra space" will instead be filled with
     * border pixels. Warning: on very old graphics cards, white pixels may
     * appear when the texture is repeated. With such cards, repeat mode can be
     * used reliably only if the texture has power-of-two dimensions
     * (such as 256x128). Repeating is disabled by default.
     *
     * Params:
     * 		repeated	= true to repeat the texture, false to disable repeating
     */
    void setRepeated(bool repeated)
    {
        sfTexture_setRepeated(sfPtr, repeated);
    }

    /**
     * Bind a texture for rendering.
     *
     * This function is not part of the graphics API, it mustn't be used when
     * drawing DSFML entities. It must be used only if you mix Texture with
     * OpenGL code.
     *
     * Params:
     * 		texture	= The texture to bind. Can be null to use no texture
     */
    static void bind(Texture texture)
    {
        (texture is null)?sfTexture_bind(null):sfTexture_bind(texture.sfPtr);
    }

    /**
     * Create the texture.
     *
     * If this function fails, the texture is left unchanged.
     *
     * Params:
     * 		width	= Width of the texture
     * 		height	= Height of the texture
     *
     * Returns: true if creation was successful, false otherwise.
     */
    bool create(uint width, uint height)
    {
        if(sfPtr !is null){
            sfTexture_destroy( sfPtr);
        }
        sfPtr = sfTexture_create(width,height);
        return sfPtr !is null;
    }

    /**
     * Copy the texture pixels to an image.
     *
     * This function performs a slow operation that downloads the texture's
     * pixels from the graphics card and copies them to a new image, potentially
     * applying transformations to pixels if necessary (texture may be padded or
     * flipped).
     *
     * Returns: Image containing the texture's pixels.
     */
    Image copyToImage() const
    {
        return new Image(sfTexture_copyToImage(sfPtr));
    }

    /**
     * Creates a new texture from the same data (this means copying the entire
     * set of pixels).
     */
    @property Texture dup() const
    {
        return new Texture(sfTexture_copy(sfPtr));
    }

    /**
     * Tell whether the texture is repeated or not.
     *
     * Returns: true if repeat mode is enabled, false if it is disabled.
     */
    bool isRepeated() const
    {
        return (sfTexture_isRepeated(sfPtr)) > 0;
    }

    /**
     * Tell whether the smooth filter is enabled or not.
     *
     * Returns: true if something is enabled, false if it is disabled.
     */
    bool isSmooth() const
    {
        return (sfTexture_isSmooth(sfPtr)) > 0;
    }

    /**
     * Update the whole texture from an array of pixels.
     *
     * The pixel array is assumed to have the same size as
     * the area rectangle, and to contain 32-bits RGBA pixels.
     *
     * No additional check is performed on the size of the pixel
     * array, passing invalid arguments will lead to an undefined
     * behavior.
     *
     * This function does nothing if pixels is empty or if the
     * texture was not previously created.
     *
     * Params:
     * 		pixels	= Array of pixels to copy to the texture.
     */
    void update(const(ubyte)[] pixels)
    {
        Vector2u size = getSize();

        sfTexture_updateFromPixels(sfPtr,pixels.ptr,size.x, size.y, 0,0);
    }

    /**
     * Update part of the texture from an array of pixels.
     *
     * The size of the pixel array must match the width and height arguments,
     * and it must contain 32-bits RGBA pixels.
     *
     * No additional check is performed on the size of the pixel array or the
     * bounds of the area to update, passing invalid arguments will lead to an
     * undefined behaviour.
     *
     * This function does nothing if pixels is empty or if the texture was not
     * previously created.
     *
     * Params:
     * 		pixels	= Array of pixels to copy to the texture.
     * 		width	= Width of the pixel region contained in pixels
     * 		height	= Height of the pixel region contained in pixels
     * 		x		= X offset in the texture where to copy the source pixels
     * 		y		= Y offset in the texture where to copy the source pixels
     */
    void update(const(ubyte)[] pixels, uint width, uint height, uint x, uint y)
    {
        sfTexture_updateFromPixels(sfPtr,pixels.ptr,width, height, x,y);
    }

    /**
     * Update the texture from an image.
     *
     * Although the source image can be smaller than the texture, this function
     * is usually used for updating the whole texture. The other overload, which
     * has (x, y) additional arguments, is more convenient for updating a
     * sub-area of the texture.
     *
     * No additional check is performed on the size of the image, passing an
     * image bigger than the texture will lead to an undefined behaviour.
     *
     * This function does nothing if the texture was not previously created.
     *
     * Params:
     * 		image	= Image to copy to the texture.
     */
    void update(const(Image) image)
    {
        sfTexture_updateFromImage(sfPtr, image.sfPtr, 0, 0);
    }

    /**
     * Update the texture from an image.
     *
     * No additional check is performed on the size of the image, passing an
     * invalid combination of image size and offset will lead to an undefined
     * behavior.
     *
     * This function does nothing if the texture was not previously created.
     *
     * Params:
     * 		image = Image to copy to the texture.
     *		y     = Y offset in the texture where to copy the source image.
     *		x     = X offset in the texture where to copy the source image.
     */
    void update(const(Image) image, uint x, uint y)
    {
        sfTexture_updateFromImage(sfPtr, image.sfPtr, x, y);
    }

    /**
     * Update the texture from the contents of a window
     *
     * Although the source window can be smaller than the texture, this function
     * is usually used for updating the whole texture. The other overload, which
     * has (x, y) additional arguments, is more convenient for updating a
     * sub-area of the texture.
     *
     * No additional check is performed on the size of the window, passing a
     * window bigger than the texture will lead to an undefined behavior.
     *
     * This function does nothing if either the texture or the window
     * was not previously created.
     *
     * Params:
     *		window = Window to copy to the texture
     */
    void update(T)(const(T) window)
        if(is(T == Window) || is(T == RenderWindow))
    {
        update(window, 0, 0);
    }

    /**
     * Update a part of the texture from the contents of a window.
     *
     * No additional check is performed on the size of the window, passing an
     * invalid combination of window size and offset will lead to an undefined
     * behavior.
     *
     * This function does nothing if either the texture or the window was not
     * previously created.
     *
     * Params:
     *		window = Window to copy to the texture
     *		x      = X offset in the texture where to copy the source window
     *		y      = Y offset in the texture where to copy the source window
     *
     */
    void update(T)(const(T) window, uint x, uint y)
        if(is(T == Window) || is(T == RenderWindow))
    {
        static if(is(T == RenderWindow))
        {
            sfTexture_updateFromRenderWindow(sfPtr, T.sfPtr, x, y);
        }
        else
        {
            sfTexture_updateFromWindow(sfPtr, RenderWindow.windowPointer(T),
                                        x, y);
        }
    }

    /**
     * Update the texture from an image.
     *
     * Although the source image can be smaller than the texture, this function
     * is usually used for updating the whole texture. The other overload, which
     * has (x, y) additional arguments, is more convenient for updating a
     * sub-area of the texture.
     *
     * No additional check is performed on the size of the image, passing an
     * image bigger than the texture will lead to an undefined behaviour.
     *
     * This function does nothing if the texture was not previously created.
     *
     * Params:
     * 		image	= Image to copy to the texture.
     *		y     = Y offset in the texture where to copy the source image.
     *		x     = X offset in the texture where to copy the source image.
     */
    //deprecated("Use update function.")
    void updateFromImage(Image image, uint x, uint y)
    {
        sfTexture_updateFromImage(sfPtr, image.sfPtr, x, y);
    }

    /**
     * Update part of the texture from an array of pixels.
     *
     * The size of the pixel array must match the width and height arguments,
     * and it must contain 32-bits RGBA pixels.
     *
     * No additional check is performed on the size of the pixel array or the
     * bounds of the area to update, passing invalid arguments will lead to an
     * undefined behaviour.
     *
     * This function does nothing if pixels is null or if the texture was not
     * previously created.
     *
     * Params:
     * 		pixels	= Array of pixels to copy to the texture.
     * 		width	= Width of the pixel region contained in pixels
     * 		height	= Height of the pixel region contained in pixels
     * 		x		= X offset in the texture where to copy the source pixels
     * 		y		= Y offset in the texture where to copy the source pixels
     */
    //deprecated("Use update function.")
    void updateFromPixels(const(ubyte)[] pixels, uint width, uint height, uint x, uint y)
    {
        sfTexture_updateFromPixels(sfPtr,pixels.ptr,width, height, x,y);
    }

    //TODO: Get this working via inheritance?(so custom window classes can do it too)
    /**
     * Update a part of the texture from the contents of a window.
     *
     * No additional check is performed on the size of the window, passing an
     * invalid combination of window size and offset will lead to an undefined
     * behaviour.
     *
     * This function does nothing if either the texture or the window was not
     * previously created.
     *
     * Params:
     * 		window	= Window to copy to the texture
     * 		x		= X offset in the texture where to copy the source window
     * 		y		= Y offset in the texture where to copy the source window
     */
    //deprecated("Use update function.")
    void updateFromWindow(Window window, uint x, uint y)
    {
       // sfTexture_updateFromWindow(sfPtr, RenderWindow.windowPointer(window), x, y);
    }

    //Is this even safe? RenderWindow inherits from Window, so what happens? Is this bottom used or the top?
    /**
     * Update a part of the texture from the contents of a window.
     *
     * No additional check is performed on the size of the window, passing an
     * invalid combination of window size and offset will lead to an undefined
     * behaviour.
     *
     * This function does nothing if either the texture or the window was not
     * previously created.
     *
     * Params:
     * 		window	= Window to copy to the texture
     * 		x		= X offset in the texture where to copy the source window
     * 		y		= Y offset in the texture where to copy the source window
     */
    //deprecated("Use update function.")
    void updateFromWindow(RenderWindow window, uint x, uint y)
    {
       // sfTexture_updateFromRenderWindow(sfPtr, window.sfPtr, x, y);
    }
}