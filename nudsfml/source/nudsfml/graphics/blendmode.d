module nudsfml.graphics.blendmode;

struct BlendMode {
    /**
     * Enumeration of the blending factors.
     *
     * The factors are mapped directly to their OpenGL equivalents,
     * specified by `glBlendFunc()` or `glBlendFuncSeparate()`.
     */
    enum Factor {
        /// (0, 0, 0, 0)
        Zero,
        /// (1, 1, 1, 1)
        One,
        /// (src.r, src.g, src.b, src.a)
        SrcColor,
        /// (1, 1, 1, 1) - (src.r, src.g, src.b, src.a)
        OneMinunSrcColor,
        /// (dst.r, dst.g, dst.b, dst.a)
        DstColor,
        /// (1, 1, 1, 1) - (dst.r, dst.g, dst.b, dst.a)
        OneMinusDstColor,
        /// (src.a, src.a, src.a, src.a)
        SrcAlpha,
        /// (1, 1, 1, 1) - (src.a, src.a, src.a, src.a)
        OneMinusSrcAlpha,
        /// (dst.a, dst.a, dst.a, dst.a)
        DstAlpha,
        /// (1, 1, 1, 1) - (dst.a, dst.a, dst.a, dst.a)
        OneMinusDstAlpha
    }

    /**
     * Enumeration of the blending equations
     *
     * The equations are mapped directly to their OpenGL equivalents,
     * specified by glBlendEquation() or glBlendEquationSeparate().
     */
    enum Equation {
        /// Pixel = Src * SrcFactor + Dst * DstFactor
        Add,
        /// Pixel = Src * SrcFactor - Dst * DstFactor
        Subtract,
        /// Pixel = Dst * DstFactor - Src * SrcFactor
        ReverseSubtract
    }

    /// Blend source and dest according to dest alpha.
    enum Alpha = BlendMode(Factor.SrcAlpha, Factor.OneMinusSrcAlpha, Equation.Add, Factor.One, Factor.OneMinusSrcAlpha, Equation.Add);
    /// Add source to dest.
    enum Add = BlendMode(Factor.SrcAlpha, Factor.One, Equation.Add, Factor.One, Factor.One, Equation.Add);
    /// Multiply source and dest.
    enum Multiply = BlendMode(Factor.DstColor, Factor.Zero, Equation.Add, Factor.DstColor, Factor.Zero, Equation.Add);
    /// Overwrite dest with source.
    enum None = BlendMode(Factor.One, Factor.Zero, Equation.Add, Factor.One, Factor.Zero, Equation.Add);

    /// Source blending factor for the color channels.
    Factor colorSrcFactor = Factor.SrcAlpha;
    /// Destination blending factor for the color channels.
    Factor colorDstFactor = Factor.OneMinusSrcAlpha;
    /// Blending equation for the color channels.
    Equation colorEquation = Equation.Add;
    /// Source blending factor for the alpha channel.
    Factor alphaSrcFactor = Factor.One;
    /// Destination blending factor for the alpha channel.
    Factor alphaDstFactor = Factor.OneMinusSrcAlpha;
    /// Blending equation for the alpha channel.
    Equation alphaEquation = Equation.Add;

    /**
     * Construct the blend mode given the factors and equation.
     *
     * This constructor uses the same factors and equation for both
     * color and alpha components. It also defaults to the Add equation.
     *
     * Params:
     * sourceFactor      = Specifies how to compute the source factor for the
                           color and alpha channels
     * destinationFactor = Specifies how to compute the destination factor for
                           the color and alpha channels
     * blendEquation     = Specifies how to combine the source and destination
                           colors and alpha
     */
    this(Factor sourceFactor, Factor destinationFactor, Equation blendEquation = Equation.Add) {
        colorSrcFactor = sourceFactor;
        colorDstFactor = destinationFactor;
        colorEquation = blendEquation;

        alphaSrcFactor = sourceFactor;
        alphaDstFactor = destinationFactor;
        alphaEquation = blendEquation;
    }

    /**
     * Construct the blend mode given the factors and equation.
     *
     * Params:
     * colorSourceFactor      = Specifies how to compute the source factor for
                                the color channels
     * colorDestinationFactor = Specifies how to compute the destination factor
                                for the color channels
     * colorBlendEquation     = Specifies how to combine the source and
                                destination colors
     * alphaSourceFactor      = Specifies how to compute the source factor
     * alphaDestinationFactor = Specifies how to compute the destination factor
     * alphaBlendEquation     = Specifies how to combine the source and
                                destination alphas
     */
    this(Factor colorSourceFactor, Factor colorDestinationFactor, Equation colorBlendEquation, Factor alphaSourceFactor, Factor alphaDestinationFactor, Equation alphaBlendEquation) {
        colorSrcFactor = colorSourceFactor;
        colorDstFactor = colorDestinationFactor;
        colorEquation = colorBlendEquation;

        alphaSrcFactor = alphaSourceFactor;
        alphaDstFactor = alphaDestinationFactor;
        alphaEquation = alphaBlendEquation;
    }

    bool opEquals(BlendMode rhs) const {
		return (colorSrcFactor == rhs.colorSrcFactor &&
                colorDstFactor == rhs.colorDstFactor &&
                colorEquation == rhs.colorEquation   &&
                alphaSrcFactor == rhs.alphaSrcFactor &&
                alphaDstFactor == rhs.alphaDstFactor &&
                alphaEquation == rhs.alphaEquation );
	}
}