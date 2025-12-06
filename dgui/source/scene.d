module scene;

import nudsfml.graphics;
import app;

class Scene {
    Application app;
    string sceneId;


    this (Application app_) {
        app = app_;
    }

    void onDraw(RenderTarget target, RenderStates states){};
    void onResize(Vector2i size){};
    void onUpdate(float dt){};
    void onGainFocus(){};
    void onLostFocus(){};
    void onCreate(){};
    void onDestroy(){};

}

class SceneManager : Drawable{
    Scene[] scenes;
    Scene currentScene;
    Vector2i size;
    Application app;

    
    this (Application app_) {
        app = app_;
        size = app.win.size;
    }

    void switchScene(string id_){
        foreach (ref scene ; scenes) {
            if (scene.sceneId == id_) {
                auto temp = currentScene;
                currentScene = scene;
                currentScene.onGainFocus();
                currentScene.onResize(size);

                if(temp !is null){
                    temp.onLostFocus();
                }
                break; //return ? 
            }
        }
    }

    void registerScene(T : Scene)(string id_, ref T scene)
    {
        scene.sceneId = id_;
        scene.onCreate();
        scenes ~= scene;
    }

    void removeScene(string id_){
        import std.algorithm;
        for (int i = 0; i < scenes.length; i++) {
            if (scenes[i].sceneId == id_) {
                scenes[i].onDestroy();
                break;
            }
        }
        scenes  = scenes.remove!(a => a.sceneId == id_);
    }

    void update(float dt){
        if(currentScene !is null){
            currentScene.onUpdate(dt);
        }
    }

    override void draw(RenderTarget target, RenderStates states){
        if(currentScene !is null){
            currentScene.onDraw(target, states);
        }
    }

    void resize(Vector2i size_){
        size = size_;
        if(currentScene !is null){
            currentScene.onResize(size);
        }
    }
}