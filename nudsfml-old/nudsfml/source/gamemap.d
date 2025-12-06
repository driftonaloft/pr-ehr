module gamemap;

import nudsfml.graphics;

import std.algorithm;
import std.conv;
import std.string;
import std.format;

import gameentity;

enum TileTypes {
    None = -1,
    Floor = 0,
    Wall = 1,
    WallShadow = 2,
}

struct Tile {
    int id;
    int type = TileTypes.None;
    Vector2f offset;
    Vector2f pos;
}

class GameMap {
    Tile [] tiles;
    IntRect [] tileRects;

    int width; 
    int height;
    int gridWidth;
    int gridHeight;
    int tileWidth;
    int tileHeight;

    float frameChange =  1f / 15f;
    float currentFrame = 0f;
    int currentFrameIndex = 0;
    int currentMaxFrameIndex = 30;

    Entity [] entities;

    Texture tex;

    AppleEntity addApple(int x, int y) {
        AppleEntity apple = new AppleEntity(tex);
        apple.mapLocation = Vector2i(x, y);
        apple.position = Vector2f(x*gridWidth, y*gridHeight);
        entities ~= apple;
        sortEntities();
        return apple;
    }

    void addSnake(ref SnakeEntity snakepart){
        entities ~= snakepart;
        sortEntities();
    }

    void sortEntities() {
        entities.sort!((a,b) => a.position.y < b.position.y);
    }

    void  update(float deltaTime){
        foreach(ref entity; entities) {
            entity.update(deltaTime);
        }
        currentFrame += deltaTime;;
        if(currentFrame > frameChange){
            currentFrame = 0f;
            currentFrameIndex++;
            if(currentFrameIndex > currentMaxFrameIndex){
                currentFrameIndex = 0;
            }

        }
    }



    enum Direction {
        Up = 1,
        Right = 2,
        Down = 4,
        Left = 8
    }



    this(){
        width = 32;
        height = 24;
        gridWidth = 32;
        gridHeight = 32;
        tileWidth = 32;
        tileHeight = 48;

        tiles.length = (width * height *2);

        for (int y = 0; y < 4; y++){
            for (int x = 0; x < 16; x++){
                tileRects ~= IntRect(x * tileWidth, y * tileHeight, tileWidth, tileHeight);
            }
        }

        tex = new Texture;
        tex.loadFromFile("data/snaketiles.png");

        createMap();
    }

    int getIndex(int x, int y, int layer = 0){
        int index = (layer * width * height) + (y * width) + x;

        if ( index < 0 || index > (width * height * 2)){
            return -1;
        }
        return index;
    }

    void createMap(){
        for(int i = 0; i < width; i++){
            for(int j = 0; j < height; j++){
                if(i == 0 || i == width - 1 || j == 0 || j == height - 1){
                    tiles[i + j * width].type = TileTypes.Wall;
                }
                else{
                    tiles[i + j * width].type = TileTypes.Floor;
                }
                getTile(i,j).pos = Vector2f(i * gridWidth,j * gridHeight);
                getTile(i, j).offset = Vector2f(0,-16);
            }
        }

        calcWallIndexes();
        calcWallShadows();


    }

    void calcWallShadows(){
        //calc shadows 
        for(int y = 1 ; y < height; y++){
            for(int x = 0; x < width; x++){
                int index = getIndex(x,y - 1);
                if(tiles[index].type == TileTypes.Wall && tiles[getIndex(x,y)].type == TileTypes.Floor){
                    tiles[getIndex(x,y,1)].id = 16*3+1; // using magic numbers
                    tiles[getIndex(x,y,1)].type = TileTypes.WallShadow;
                } else {
                    tiles[getIndex(x,y,1)].type = TileTypes.None;
                    tiles[getIndex(x,y,1)].offset =  Vector2f(0,-16);
                }
            }
        }
    }



    void calcWallIndexes(){
        //convert forloop to a function to make it easier to read
        for(int y = 0 ; y < height; y++){
            for(int x = 0; x < width; x++){
                int index = getIndex(x,y);
                if(tiles[index].type == TileTypes.Wall){
                    tiles[index].id = 0 + calcTileNeighbors(x,y);
                } else {
                    tiles[index].id = 32; // + random_number(0,3);
                }
            }
        }
    }

    int addToTileset(IntRect rect) {
        int id =  tileRects.length.to!int;
        tileRects ~= rect;

        return id;
    }

    int calcTileNeighbors(int x, int y) {
        int neighbors = 0;
        auto t = getTile(x,y);
        if (x > 0) {
            if (getTile(x - 1, y).type == t.type) {
                neighbors += Direction.Left;
            }
        }
        if (x < width - 1) {
            if (getTile(x + 1, y).type == t.type) {
                neighbors += Direction.Right;
            }
        }
        if (y > 0) {
            if (getTile(x, y - 1).type == t.type) {
                neighbors += Direction.Up;
            }
        }
        if (y < height - 1) {
            if (getTile(x,y + 1).type == t.type)  {
                neighbors += Direction.Down;
            }
        }
        return neighbors;
    }

    ref Tile getTile(int x, int y) {
        return tiles[x + y * width];
    }

    void draw(Vector2f pos, RenderTarget target) {
        import std.stdio;
        RectangleShape rect = new RectangleShape();
        rect.fillColor = Color.White;
        rect.size = Vector2f(tileWidth, tileHeight);
        rect.setTexture(tex);
        int entityIndex = 0;
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                for(int l = 0; l < 2; l++){
                    int index = getIndex(x,y,l);
                    if(tiles[index].type != TileTypes.None){
                        rect.position = pos  + Vector2f(gridWidth * x, gridHeight * y ) + tiles[index].offset;

                        rect.textureRect = tileRects[tiles[index].id];
                        target.draw(rect);
                    }
                }
            }
            //writeln("Y: ", y);
            if (entityIndex < entities.length ) {
                while (entities[entityIndex].position.y < ((y - 1) * gridHeight)) {
                   // writeln(format("%d pos(%f,%f)", entityIndex, entities[entityIndex].position.x, entities[entityIndex].position.y));
                    entities[entityIndex].draw(target);
                    entityIndex++;
                    if(entityIndex >= entities.length){
                        break;
                    }
                }
            }   
        }
    }
}