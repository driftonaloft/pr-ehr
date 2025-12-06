module nudsfml.graphics.renderstates;

import nudsfml.graphics.blendmode;
import nudsfml.graphics.transform;
import nudsfml.graphics.texture;
import nudsfml.graphics.shader;
import std.typecons:Rebindable;

/**
 * Define the states used for drawing to a RenderTarget.
 */
struct RenderStates {
    /// The blending mode.
    BlendMode blendMode;
    /// The transform.
    Transform transform;
    private {
        Rebindable!(const(Texture)) m_texture;
        Rebindable!(const(Shader)) m_shader;
    }

    /**
     * Construct a default set of render states with a custom blend mode.
     *
     * Params:
     *	theBlendMode = Blend mode to use
     */
    this(BlendMode theBlendMode) {
        blendMode = theBlendMode;
        transform = Transform();

        m_texture = null;
        m_shader = null;
    }

    /**
     * Construct a default set of render states with a custom transform.
     *
     * Params:
     *	theTransform = Transform to use
     */
    this(Transform theTransform) {
        transform = theTransform;

        blendMode = BlendMode.Alpha;

        m_texture = null;
        m_shader = null;
    }

    /**
     * Construct a default set of render states with a custom texture
     *
     * Params:
     *	theTexture = Texture to use
     */
    this(const(Texture) theTexture) {
        m_texture = theTexture;

        blendMode = BlendMode.Alpha;

        transform = Transform();
        m_shader = null;
    }

    /**
     * Construct a default set of render states with a custom shader
     *
     * Params:
     * theShader = Shader to use
     */
    this(const(Shader) theShader) {
        m_shader = theShader;
    }

    /**
     * Construct a set of render states with all its attributes
     *
     * Params:
     *	theBlendMode = Blend mode to use
     *	theTransform = Transform to use
     *	theTexture   = Texture to use
     *	theShader    = Shader to use
     */
    this(BlendMode theBlendMode, Transform theTransform, const(Texture) theTexture, const(Shader) theShader) {
        blendMode = theBlendMode;
        transform = theTransform;
        m_texture = theTexture;
        m_shader = theShader;
    }

    @property {
        /// The shader to apply while rendering.
        const(Shader) shader(const(Shader) theShader) {
            m_shader = theShader;
            return theShader;
        }

        /// ditto
        const(Shader) shader() const {
            return m_shader;
        }
    }

    @property {
        /// The texture to apply while rendering.
        const(Texture) texture(const(Texture) theTexture) {
            m_texture = theTexture;
            return theTexture;
        }

        /// ditto
        const(Texture) texture() const{
            return m_texture;
        }
    }
}
