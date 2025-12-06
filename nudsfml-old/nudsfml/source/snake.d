module snake;

import gameentity;
import gamemap;
import game;

import nudsfml.graphics;

import std.stdio;

enum Direction{
    Up,
    Down,
    Left,
    Right
}

Vector2f[Direction] dir;
 
class Snake {
    SnakeEntity[] parts;
    int len;
    Direction direction;
    Vector2i headPosition;

    float updateTimer = .25;;
    float updateInterval= .24;

    int head = -1;
    int tail = -1;
    bool doAdd = false;

    Game g;

    this(Game game_){
        dir = [ Direction.Up : Vector2f(0, -1),
                Direction.Down : Vector2f(0, 1),
                Direction.Left : Vector2f(-1, 0),
                Direction.Right : Vector2f(1, 0)];
        g = game_;
    }

    void generate(int length){
        this.len = len;     
        for(int i = 0; i < length; i++){
            auto p = new SnakeEntity(g.map.tex);
            p.mapLocation = Vector2f(headPosition.x - i, headPosition.y);
            parts ~= p;
        }

        foreach(ref part ; parts){
            g.map.addSnake(part);
        }

        writeln(parts.length);

        direction = Direction.Right;
        head = 0;
        tail = length - 1;
    }


    void move(){
        int id = tail;

        foreach(i ,ref part ; parts){
            if(i + 1 < parts.length){
                auto next = parts[i+1];
                part.mapLocation = next.mapLocation;
            } else {
                part.mapLocation = part.mapLocation + dir[direction];
            }
        }
        
        g.map.sortEntities;
    }

    bool canDirection(Direction dir){
        if (direction == Direction.Up && dir == Direction.Down)
            return false;
        if (direction == Direction.Down && dir == Direction.Up)
            return false;
        if (direction == Direction.Left && dir == Direction.Right)
            return false;  
        if (direction == Direction.Right && dir == Direction.Left)
            return false;
        return true;
    }

    void update(float deltaTime){
        updateTimer -= deltaTime;
        if(updateTimer < 0){
            updateTimer = updateInterval;
            if(g.doMove)
                move();
        }
    }


    SnakeEntity addPart(){
        auto part = new SnakeEntity(g.map.tex);
        part.parentID = tail;
        part.mapLocation = parts[parts.length-1].mapLocation;
        part.id = len;
        parts ~= part;
        g.map.addSnake(part);
        len++;
        doAdd = false;
        return part;
    }


}