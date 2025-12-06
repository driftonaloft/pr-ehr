module game;

import nudsfml.graphics;
import nudsfml.system;
import nudsfml.audio;
import nudsfml.network;

import std.stdio;
import std.format;

import gamemap;
import gameentity;
import snake;

class Game {
    string dataDir;
    bool running = true;

    RenderWindow win;
     
    GameMap map;
    AppleEntity [] apples;
    //SceneManager
    //scriptingEngine
    //

    Snake snake;
    bool doMove = true;

    Font systemFont;
    Text debugText;

    bool doDrawDebug = false;

    Clock gameTick;

    Clock elementTimer;

    this(string dataDir_ = "data/"){
        dataDir = dataDir_;

        win = new RenderWindow(VideoMode(1024, 768), "NudSFML");
        //win.setVerticalSyncEnabled(true); // higher accuracy but more cpu time
        //win.setFramerateLimit(60); // 60 fps max // TODO: make this configurable

        systemFont = new Font();
        systemFont.loadFromFile(dataDir ~ "CamingoCode-Regular.ttf");

        debugText = new Text("Test", systemFont, 16);
        doDrawDebug = true;
        //create initial resources

        map = new GameMap();
        apples ~= map.addApple(5,4);

        snake = new Snake(this);
        snake.headPosition = Vector2i(map.width / 2, map.height / 2);
        snake.direction = Direction.Up;
        snake.generate(3);

        gameTick = new Clock();
        elementTimer = new Clock();
    } 


    void startup() {
        win.setTitle("素晴らしい ！"d);

    }

    float dt, drawtime, eventTimer, updateTimer;

    void run(){
        while(running){
            dt = gameTick.restart().asSeconds();
            drawtime = elementTimer.restart().asSeconds();
            handleEvents();
            eventTimer= elementTimer.getElapsedTime.asSeconds();
            update(dt);
            updateTimer = elementTimer.getElapsedTime.asSeconds();
            draw();
        }
    }

    void update(float dt){
        if(Keyboard.isKeyPressed(Keyboard.Key.Up)){
            if(snake.canDirection(Direction.Up)){
                snake.direction = Direction.Up;
            }
        } else if(Keyboard.isKeyPressed(Keyboard.Key.Right)){
            if(snake.canDirection(Direction.Right)){
                snake.direction = Direction.Right;
            }
        } else if(Keyboard.isKeyPressed(Keyboard.Key.Down)){
            if(snake.canDirection(Direction.Down)){
                snake.direction = Direction.Down;
            }
        } else if(Keyboard.isKeyPressed(Keyboard.Key.Left)){
            if(snake.canDirection(Direction.Left)){
                snake.direction = Direction.Left;
            }
        }
        map.update(dt); 
        snake.update(dt);
    }

    void draw(){
        win.clear();

        //draw stuff here 
        map.draw(Vector2f(0,16), win);
        
        drawDebug();
        win.display();
    }

    void drawDebug(){
        if(doDrawDebug){
            debugText.position = Vector2f(32,32);
            string text = format("FPS: %0.f , drawTime: %f , eventTime: %f , updateTime: %f", 1/dt, drawtime, eventTimer, updateTimer);
            debugText.setString = text;
            win.draw(debugText);
        }
    }

    void handleEvents(){
        Event e;
        while(win.pollEvent(e)){
            switch(e.type){
                case Event.Type.Closed:
                    running = false;
                    break;
                case Event.Type.KeyPressed:
                    switch(e.key.code) { 
                        case Keyboard.Key.Escape:  
                            running = false;
                            break;
                        case Keyboard.Key.F9:
                            snake.addPart();
                            break;
                        case Keyboard.Key.F10:
                            snake.move();
                            break;
                        case Keyboard.Key.F12:
                            doDrawDebug = !doDrawDebug;
                            break;
                        case Keyboard.Key.P:
                            auto screenShot = win.capture();
                            writeln("Saved screenshot to screenShot.png");
                            screenShot.saveToFile("screenshot.png");
                            break;
                        case Keyboard.Key.Space:
                            doMove = !doMove;
                            break;
                        default: break;
                    }
                    break;
                default: break;
            }
        }
    }



    void shutdown(){
        //clean up resources 

    }
}