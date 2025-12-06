module gameentity;

import nudsfml.graphics;

import std.stdio;

import gamemap;

class Entity {
    Vector2f position;
    Vector2i mapLocation;
    int id;
    bool destroy=false;

    this(){} 
    void update(float dt){}
    void draw(RenderTarget target){}
}


class SnakeEntity : Entity {
    int partsID;
    int parentID;
    int childID;

    RectangleShape shape;

    Texture texture;

    this (Texture t){
        texture=t;
        shape = new RectangleShape();
        shape.size(Vector2f(32,48));
        shape.fillColor(Color.White);
        shape.setTexture(texture);
        shape.textureRect = IntRect(6*32,2*48,32,48);
    }

    override void update(float dt){
        if(destroy){
            return;
        }
    }

    override void draw(RenderTarget target){
        position = Vector2f(mapLocation.x * 32, mapLocation.y * 32);
        shape.position = position;
        target.draw(shape);   
    }
}


class AppleEntity : Entity {
    Vector2f offset = Vector2f(0, -8);

    float floatTime = 0;
    float floatTimeMultiplyer = 1.0;

    Texture texture;
    RectangleShape shape;
    RectangleShape shadow;

    this(Texture t) {
        texture = t;
        shape = new RectangleShape();
        shape.setTexture(t);
        //TODO!!! - load tile texture position and size from file 
        shape.size(Vector2f(32, 48));
        shape.textureRect = IntRect(32 * 4, 48*2, 32, 48);
        shape.fillColor = Color.White;

        shadow = new RectangleShape();
        shadow.setTexture(t);
        //TODO!!! - load tile texture position and size from file 
        shadow.size(Vector2f(32, 48));
        shadow.textureRect = IntRect(32 * 5, 48*2, 32, 48);
        shadow.fillColor = Color.White;

        super();
    }

    override void update(float deltaTime){
        
        floatTime += deltaTime * floatTimeMultiplyer;
        //writeln("deltaTime: ", deltaTime ," floatTime: ", floatTime, " multiplier: ", floatTimeMultiplyer);
        if(floatTime > .75 ){
            floatTime = .75;
            floatTimeMultiplyer = -floatTimeMultiplyer;
        }
        if(floatTime < 0 ){
            floatTime = 0.0;
            floatTimeMultiplyer = -floatTimeMultiplyer;
        }

        super.update(deltaTime);
    }

    override void draw(RenderTarget target){
        shadow.position = position;
        target.draw(shadow);
        
        shape.position = position + offset * (floatTime/0.75);
        target.draw(shape);

        super.draw(target);
    }
}