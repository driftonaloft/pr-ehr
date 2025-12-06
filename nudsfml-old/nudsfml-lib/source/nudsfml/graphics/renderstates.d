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
