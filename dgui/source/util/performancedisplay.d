module util.performancedisplay;

import std.stdio;

import nudsfml.graphics;

struct PerformanceData {
    int current;
    int min;
    int max;
    bool minset = false;
}

class PerformanceDisplay {
    //clock
    PerformanceData [string] graphs;

    Font font;
    Text graphLabel;

    RectangleShape min;
    RectangleShape max;
    RectangleShape current;

    this(){
        font = new Font;
        if(!font.loadFromFile("data/font/hack/Hack-Regular.ttf")){
            writeln("failed to load Font");
        }
        graphLabel = new Text("text", font);
        graphLabel.setCharacterSize(12);
        graphLabel.fillColor = (Color.White);

        min = new RectangleShape;
        min.fillColor = Color.Blue;
        min.size = Vector2f (0,8);

        max = new RectangleShape;
        max.fillColor = Color.Red;
        max.size = Vector2f (0,8);

        current = new RectangleShape;
        current.fillColor = Color.Green;
        current.size = Vector2f (0,8);
    }

    void update(string key, int value){
        if(!graphs[key].minset){
            graphs[key].minset = true;
            graphs[key].min = value;
        }
        if(graphs[key].min > value) { graphs[key].min = value; }
        if(graphs[key].max < value) { graphs[key].max = value; }

        graphs[key].current = value;
    }

    void reset(){
        foreach(key, ref value; graphs ){
            value = PerformanceData();
        }
    }

    void draw(RenderTarget target){
        Vector2f position = Vector2f(5,5);
        Vector2f fieldWidth = Vector2f(128 , 0);
        foreach( key, graph ; graphs ){
            graphLabel.position = position;
            graphLabel.string = key;
            target.draw (graphLabel);

            max.position = position + fieldWidth;
            max.size = Vector2f(graph.max, 8);
            target.draw(max);
            
            current.position = position + fieldWidth;
            current.size = Vector2f(graph.current, 8);
            target.draw(current);

            min.position = position + fieldWidth;
            min.size = Vector2f(graph.min, 8);
            target.draw(min);

            position += Vector2f(0, 10);
        }
    }
}