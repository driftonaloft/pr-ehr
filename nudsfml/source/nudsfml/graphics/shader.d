module nudsfml.graphics.shader;

import bindbc.sfml.graphics;

import nudsfml.graphics.texture;
import nudsfml.graphics.transform;
import nudsfml.graphics.color;
import nudsfml.graphics.glsl;

import std.string;

import nudsfml.system.inputstream;
import nudsfml.system.vector2;
import nudsfml.system.vector3;
//import nudsfml.system.err;


/**
 * Shader class (vertex and fragment).
 */
class Shader {
    /// Types of shaders.
    enum Type{
        Vertex,  /// Vertex shader
        Geometry,/// Geometry shader
        Fragment /// Fragment (pixel) shader.
    }

    package sfShader* sfPtr = null;

    /**
     * Special type/value that can be passed to `setParameter`, and that
     * represents the texture of the object being drawn.
     */
    struct CurrentTextureType {}
    /// ditto
    static CurrentTextureType CurrentTexture;

    /// Default constructor.
    this() {
        //creates an empty shader
        //sfPtr=sfShader_construct();
    }

    package this(sfShader* shader){
        sfPtr = shader;
    }

    /// Destructor.
    ~this(){
        //import nudsfml.system.config;
        //mixin(destructorOutput);
        sfShader_destroy(sfPtr);
    }

    /**
     * Load the vertex, geometry, or fragment shader from a file.
     *
     * This function loads a single shader, vertex, geometry, or fragment,
     * identified by the second argument. The source must be a text file
     * containing a valid shader in GLSL language. GLSL is a C-like language
     * dedicated to OpenGL shaders; you'll probably need to read a good
     * documentation for it before writing your own shaders.
     *
     * Params:
     * 		filename	= Path of the vertex, geometry, or fragment shader file to load
     * 		type		= Type of shader (vertex geometry, or fragment)
     *
     * Returns: true if loading succeeded, false if it failed.
     */
    bool loadFromFile(const(char)[] filename, Type type) {
        import std.string;
        if (sfPtr !is null){
            sfShader_destroy(sfPtr);
        }
        
        if(type == Type.Vertex){
            sfPtr = sfShader_createFromFile(filename.toStringz, null,null);
        }
        else if(type == Type.Geometry){
            sfPtr = sfShader_createFromFile(null,filename.toStringz,null);
        }
        else if(type == Type.Fragment){
            sfPtr = sfShader_createFromFile(null,null, filename.toStringz);
        }
        
        return sfPtr !is null;
    }

    /**
     * Load both the vertex and fragment shaders from files.
     *
     * This function loads both the vertex and the fragment shaders. If one of
     * them fails to load, the shader is left empty (the valid shader is
     * unloaded). The sources must be text files containing valid shaders in
     * GLSL language. GLSL is a C-like language dedicated to OpenGL shaders;
     * you'll probably need to read a good documentation for it before writing
     * your own shaders.
     *
     * Params:
     * 		vertexShaderFilename	= Path of the vertex shader file to load
     * 		fragmentShaderFilename	= Path of the fragment shader file to load
     *
     * Returns: true if loading succeeded, false if it failed.
     */
    bool loadFromFile(const(char)[] vertexShaderFilename, const(char)[] fragmentShaderFilename){
        if(sfPtr !is null){
            sfShader_destroy(sfPtr);
        }
        sfPtr = sfShader_createFromFile(vertexShaderFilename.toStringz, null, fragmentShaderFilename.toStringz);
        return sfPtr !is null;
    }

    /**
     * Load the vertex, geometry, and fragment shaders from files.
     *
     * This function loads the vertex, geometry and the fragment shaders. If one
     * of them fails to load, the shader is left empty (the valid shader is
     * unloaded). The sources must be text files containing valid shaders in
     * GLSL language. GLSL is a C-like language dedicated to OpenGL shaders;
     * you'll probably need to read a good documentation for it before writing
     * your own shaders.
     *
     * Params:
     * 		vertexShaderFilename	= Path of the vertex shader file to load
     * 		geometryShaderFilename	= Path of the geometry shader file to load
     * 		fragmentShaderFilename	= Path of the fragment shader file to load
     *
     * Returns: true if loading succeeded, false if it failed.
     */
    /*bool loadFromFile(const(char)[] vertexShaderFilename, const(char)[] geometryShaderFilename, const(char)[] fragmentShaderFilename)
    {
        return sfShader_loadAllFromFile(sfPtr, vertexShaderFilename.ptr, vertexShaderFilename.length,
                                         geometryShaderFilename.ptr, geometryShaderFilename.length,
                                         fragmentShaderFilename.ptr, fragmentShaderFilename.length);
    }*/

    /**
     * Load the vertex, geometry, or fragment shader from a source code in memory.
     *
     * This function loads a single shader, vertex, geometry, or fragment,
     * identified by the second argument. The source code must be a valid shader
     * in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders;
     * you'll probably need to read a good documentation for it before writing
     * your own shaders.
     *
     * Params:
     * 		shader	= String containing the source code of the shader
     * 		type	= Type of shader (vertex geometry, or fragment)
     *
     * Returns: true if loading succeeded, false if it failed.
     */
    bool loadFromMemory(const(char)[] shader, Type type)
    {
        if(sfPtr !is null){
            sfShader_destroy(sfPtr);
        }

        if(type == Type.Vertex){
            sfPtr = sfShader_createFromMemory(shader.toStringz, null, null);
        }
        else if(type == Type.Geometry){
            sfPtr = sfShader_createFromMemory(null, shader.toStringz, null);
        }
        else if(type == Type.Fragment){
            sfPtr = sfShader_createFromMemory(null, null, shader.toStringz);
        }

        return sfPtr !is null;
    }

    /**
     * Load both the vertex and fragment shaders from source codes in memory.
     *
     * This function loads both the vertex and the fragment shaders. If one of
     * them fails to load, the shader is left empty (the valid shader is
     * unloaded). The sources must be valid shaders in GLSL language. GLSL is a
     * C-like language dedicated to OpenGL shaders; you'll probably need to read
     * a good documentation for it before writing your own shaders.
     *
     * Params:
     * 	vertexShader   = String containing the source code of the vertex shader
     * 	fragmentShader = String containing the source code of the fragment
                         shader
     *
     * Returns: true if loading succeeded, false if it failed.
     */
    bool loadFromMemory(const(char)[] vertexShader, const(char)[] geometryShader, const(char)[] fragmentShader)
    {
        if(sfPtr !is null){
            sfShader_destroy(sfPtr);
        }

        sfPtr = sfShader_createFromMemory(vertexShader.toStringz, geometryShader.toStringz, fragmentShader.toStringz);

        return sfPtr !is null;
    }


}