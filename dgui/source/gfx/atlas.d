module gfx.atlas;

import nudsfml.graphics;

import std.math;
import std.algorithm;
import std.stdio;

struct AtlasRef {
    IntRect rect;
    Image image;
    Texture tex;
    string id;

    @property {
        Vector2f size() {
            return Vector2f(image.getSize().x, image.getSize().y);
        }
    }

    IntRect getSubRect(IntRect sub) {
        sub.left += rect.left;
        sub.top += rect.top;
        IntRect inter;
        if (rect.intersects(sub, inter)) {
            return sub;
        }
        return inter;
    }
}

class Atlas {
    Vector2f size;
    Image atlasImage;
    Texture atlasTexture;

    AtlasRef[string] atlas;
    AtlasRef[] references;

    int maxWidth = 0;

    this(int _size = 8196) {
        atlasTexture = new Texture();
        auto s = atlasTexture.getMaximumSize();

        s = min(s, _size);
        size = Vector2f(s, s);

        atlasImage = new Image();
        atlasImage.create(cast(uint)(size.x), cast(uint)(size.y), Color.Black);

        atlasTexture.loadFromImage(atlasImage);
    }

    string loadImageFile(string filename) {
        Image image = new Image();
        image.loadFromFile(filename);

        import std.digest.crc, std.digest.md, std.digest.sha;
        import std.stdio;

        auto file = File(filename);
        auto result = digest!CRC32(file.byChunk(4096 * 1024));
        string stringHash = toHexString(result).dup;

        AtlasRef reference;
        reference.image = image;
        reference.id = filename ~ stringHash;

        references ~= reference;
        return stringHash;
    }

    void loadImageMemory(string file, Vector2i size, ubyte[] data) {
    }

    string loadImage(string id, Image img){
        AtlasRef reference;
        reference.image = img;
        reference.id = id;
        references ~= reference;
        return id;
    }

    //finds a free place to load the current file into gpu memory
    int calcArea() {
        int area = 0;
        maxWidth = 0;

        foreach (img; references) {
            area += (img.image.getSize.x * img.image.getSize.y);
            maxWidth = max(maxWidth, img.image.getSize.x);
        }
        return area;
    }

    void pack(bool buildTex = true) {
        references.sort!("a.size.y > b.size.y");

        int area = calcArea();
        const int startWidth = cast(int) size.x;

        IntRect[] spaces = [IntRect(0, 0, startWidth, startWidth)];
        AtlasRef[string] packed; // should be atlas ref?

        foreach (i, ref img; references) {
            bool placed = false;
            Vector2i s = img.size;
            foreach (ref space; spaces) {
                if (s.x < space.width && s.y < space.height && !placed) {
                    img.rect = IntRect(space.left, space.top, s.x, s.y);
                    packed[img.id] = img;
                    placed = true;

                    if (space.width == s.x && space.height == s.y) {
                        space.height = 0;
                    } else if (s.y == space.height) {
                        space.left = space.left + s.x;
                        space.width = space.width - s.x;
                    } else if (s.x == space.width) {
                        space.top = space.top + s.y;
                        space.height = space.height - s.y;
                    } else {
                        auto temp = IntRect(space.left + s.x, space.top, space.width - s.x, s.y);

                        space.top = space.top + s.y;
                        space.height = space.height - s.y;
                        spaces ~= temp;
                    }
                    break;
                }
            }
            spaces.remove!("a.height == 0");
        }
        atlas = packed;

        if (buildTex)
            buildTexture(true);
    }

    IntRect[] mergeSpaces(IntRect[] s) {
        s.sort!("a.width > b.width");

        foreach (i ; s) {
            if (i.height != 0) {
                foreach (j; s) {
                    if (i != j) {
                        if (j.top == i.top + i.height && i.width == j.width && i.left == j.left) {
                            writeln("!!! --> merged space");
                            i.height += j.height;
                            j.height = 0;
                        }
                        if (j.left == i.left && j.top == i.top) {
                            writeln("!!! --> same location space");
                            j.height = 0;
                        }
                        if (j.intersects(i)) {
                            writeln("!!! --> intersects space");
                            j.height = 0;
                        }
                    }
                }
            }
        }

        s.remove!("a.height == 0");
        s.sort!("a.height * a.width > b.height * b.width && a.top < b.top");

        return s;
    }

    void buildTexture(bool saveAtlas = false) {
        foreach (v; atlas) {
            atlasImage.copyImage(v.image, cast(int)(v.rect.left), cast(int)(v.rect.top));
            writeln(v.rect.toString);
        }

        if (saveAtlas) {
            writeln("saving image to : atlas.png");
            atlasImage.saveToFile("atlas.png");
            writeln("done saving");
        }
        atlasTexture.updateFromImage(atlasImage, 0, 0);
    }

    void drawRect(IntRect rect, Color outlineColor, Color fillColor) {
        IntRect drawRect = IntRect(cast(int) rect.left, cast(int) rect.top,
                cast(int) rect.width, cast(int) rect.height);
        for (int y = 0; y < drawRect.height; y++) {
            for (int x = 0; x < drawRect.width; x++) {
                int mx = x + drawRect.left;
                int my = y + drawRect.top;
                if (x == 0 || y == 0 || x == drawRect.width - 1 || y == drawRect.height - 1) {
                    atlasImage.setPixel(mx, my, outlineColor);
                } else {
                    if (fillColor != Color.Black) {
                        atlasImage.setPixel(mx, my, fillColor);
                    }
                }
            }
        }
    }
}

unittest {
    import std.stdio;
    import std.file;

    auto atlas = new Atlas();

    foreach (f; dirEntries("data/atlastest", "*.png", SpanMode.depth)) {
        writeln(f.name);
        atlas.loadImageFile(f.name);
    }
    atlas.pack();
}
