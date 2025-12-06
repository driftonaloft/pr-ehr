module nudsfml.window.contextsettings;

struct ContextSettings {
    /// Bits of the depth buffer.
    uint depthBits = 0;
    /// Bits of the stencil buffer.
    uint stencilBits = 0;
    /// Level of antialiasing.
    uint antialiasingLevel = 0;
    /// Level of antialiasing.
    uint majorVersion = 2;
    /// Minor number of the context version to create.
    uint minorVersion = 0;

    uint attributeFlags = 0;
    int srgbCapable = 0;
}