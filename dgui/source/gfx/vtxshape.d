module gfx.vtxshape;

import nudsfml.graphics;

import std.file;
import std.conv;
import std.string;
import std.algorithm;
import std.math;

class VertexShape : Transformable, Drawable {
    mixin NormalTransformable;

    Color m_color;

    VertexArray va;
    Vector2f [] vertices;
    uint [] vertIndex;

    @property { //Color
        Color color(Color c){
            setColor(c);
            return c;
        }

        Color color(){
            return m_color;
        }
    }

    this(){
        va = new VertexArray(PrimitiveType.Triangles,0);
    }

    void loadFromFile(string filename){
        //if(exists(filename)){load(read(filename))};
        string input = to!string(read(filename));
        load(input);
    }

    void saveToFile(string filename){
       write(filename,save()); 
    }

    void clear(){
        vertices.length = 0;
        vertIndex.length = 0;
        va.clear();
    }

    void load(string input){
        clear();

        int lineIndex = 0;
        const int vertsPerFace = 3;
        string [] lines = splitLines(input);

        string readLine(){
            if(lineIndex < lines.length){
                return lines[lineIndex++];
            }
            return "";
        }

        string line = readLine();
        int numberOfVertices = to!int(line);
        for(int i = 0; i < numberOfVertices; i++){
            float x = 0, y = 0;
            line = readLine();
            auto vars = split(line,","); //NOTE! may need to trim white space on each
            if(vars.length == 2){
                x = to!float(strip(vars[0])) * -1;
                y = to!float(strip(vars[1])) * -1;
                vertices ~= Vector2f(x,y);
            }
        }

        line = readLine();
        int numberOfFaces = to!int(line);
        va.resize(numberOfFaces * vertsPerFace);
        for(int i = 0; i < numberOfFaces; i++){
            int index = 0;
            int offset = 0;
            int indexValue = 0;
            
            line = readLine();
            auto vars = split(line, ","); //NOTE! may need to trim white space on each
            if(vars.length == 3){
                foreach(value; vars){
                    index = to!int(strip(value));
                    indexValue = (i * vertsPerFace) + offset++;
                    vertIndex ~= index;
                    va[indexValue].position = vertices[index];
                    va[indexValue].color = Color.Black;
                }
            }
        }
    }

    string save(){
        string output = format("%d\n\r",vertices.length);
        foreach(vert; vertices){
            output ~= format("%f, %f\n\r", vert.x, vert.y);
        }
        output ~= format("%d\n\r", vertIndex.length/3);
        for(int i = 0; i < vertIndex.length; i += 3){
            output ~= format("%d, %d, %d\n\r",
                vertIndex[i],
                vertIndex[i+1],
                vertIndex[i+2]);
        }
        return output;
    }

    void realign(){
        Vector2f smallest = Vector2f(0,0);

        foreach(vert; vertices){
            smallest.x = min(vert.x, smallest.x);
            smallest.y = min(vert.y, smallest.y);
        }
        
        //should be inverse instead of abs?
        smallest.x = abs(smallest.x);
        smallest.y = abs(smallest.y);

        foreach(ref vert; vertices){
            vert += smallest;
        }
    }

    void normalize(float target, bool vertical=true){
        Vector2f largest = Vector2f(0,0);
        float ratio = 1.0;
        
        foreach(vert ; vertices){
            largest.x = max(vert.x , largest.x);
            largest.y = max(vert.y , largest.y);
        }

        if(vertical){
            ratio = target / largest.y;
        } else {
            ratio = target / largest.x;
        }

        foreach(ref vert ; vertices){
            vert *= ratio;
        }

    }

    void setColor(Color color){
        for(int i = 0; i < va.getVertexCount(); i++){
            va[i].color = color;
        }
        m_color = color;
    }

    void draw(RenderTarget target, RenderStates states){
        states.transform *= getTransform();
        target.draw(va, states);
    }
}