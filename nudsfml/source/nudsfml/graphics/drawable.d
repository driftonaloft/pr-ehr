module nudsfml.graphics.drawable;

import nudsfml.graphics.rendertarget;
import nudsfml.graphics.renderstates;

interface Drawable {
    void draw(RenderTarget renderTarget, RenderStates renderstates);
}

