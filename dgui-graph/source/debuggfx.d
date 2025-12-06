module debuggfx;

import nudsfml.graphics;

import std.stdio;
import std.conv;

struct GraphInfo {
    string name;
    VertexArray points;
    float [] samples;
    float max = 0;
    float min = 20_000;
    Color m_color;
    bool updated = false;
    bool updatedColor = false;
    float avg;

    void push_value(float value) {
        import std.math;
        samples = samples[1..$] ~ value;
        max = std.math.fmax(max, value);
        max *= 0.9999;
        min = std.math.fmin(min, value);
        updated = true;
    }

    @property {
        Color color(Color c){
            updated = true;
            updatedColor = true;
            m_color = c;
            return c;
        };
        Color color(){
            return m_color;
        }
    }
}

class DebugGraph : Drawable, Transformable {
    mixin NormalTransformable;

    Vector2f size;

    float maxDecayRate;
    float minDecayRate;

    GraphInfo [string] graphs;

    int sampleSize;

    RectangleShape backgroundBox;
    RectangleShape gridBox;

    int visibleSamples;

    Text label;
    Font font; 

    this(Vector2f position_, Vector2f size_) {
        position = position_;
        size = size_;

        font = new Font();
        font.loadFromFile ("data/fonts/braciola-ms.regular.ttf");

        label = new Text("Sample Label", font, 12);
        label.fillColor = Color.White;

        backgroundBox = new RectangleShape();
        backgroundBox.position = position;
        backgroundBox.size = size;
        backgroundBox.fillColor = Color(15,15,15);
        backgroundBox.outlineColor = Color(128,128,128);
        backgroundBox.outlineThickness = 1f;

        gridBox = new RectangleShape();
        gridBox.position = position + Vector2f(5,5);
        gridBox.size = size + Vector2f(-10,-10) + Vector2f(-100,0);
        gridBox.fillColor = Color(15,15,15);
        gridBox.outlineColor = Color(200,200,200);
        gridBox.outlineThickness = 1f;

        visibleSamples = gridBox.size.x.to!int;
    }

    void push_value(string name, float value) {
        if (name in graphs) {
            graphs[name].push_value(value);
        }
    }

    void addSampler(string name, Color color ){
        GraphInfo graph;
        graph.name = name;
        graph.points = new VertexArray(PrimitiveType.LineStrip, visibleSamples);
        graph.samples.length = visibleSamples;
        foreach(i, ref f;graph.samples ){
            f = 0;
        }
        graphs[name] = graph;
    }

    void update(float deltaTime){
        //checkForNeededUpdate ie new samples have been pushed onto the array
        foreach(ref graph; graphs) {
            if(graph.updated && !graph.updatedColor) {
                float scale = (size.y - 15 ) / (graph.max == 0 ? 1 : graph.max);
                graph.avg = 0;
                for ( int i = 0; i < graph.samples.length; i++) {
                    float v = graph.samples[i] * scale;
                    graph.avg += graph.samples[i];
                    graph.points[i].position = Vector2f(i, v) + position + Vector2f(-5,-5);
                }
                graph.avg /= graph.samples.length;
                graph.updated = false;
            } else if(graph.updatedColor) {
                                float scale = (size.y - 15 ) / (graph.max == 0 ? 1 : graph.max);
                graph.avg = 0;
                for ( int i = 0; i < graph.samples.length; i++) {
                    float v = graph.samples[i] * scale;
                    graph.avg += graph.samples[i];
                    graph.points[i].position = Vector2f(i, v) + position + Vector2f(-5,-5);
                    graph.points[i].color = graph.m_color; 
                }
                graph.avg /= graph.samples.length;
                graph.updated = false;
                graph.updatedColor = false;
            }
        }
    }

    override void draw(RenderTarget target, RenderStates states) {
        import std.format;
        target.draw(backgroundBox);
        target.draw(gridBox);

        states.transform *= getTransform();
        //states.transform = states.transform.translate(10f,10f);

        foreach(graph; graphs){
            target.draw(graph.points, states);
            label.setString(format("%s: %5.2f %5.2f", graph.name, graph.avg, graph.max));
            label.position = position + size - Vector2f(65, size.y);
            target.draw(label);
        }
    }
}

class DebugDisplay {
    
    
}