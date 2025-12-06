module logon;

import nudsfml.graphics;

import scene;

import gui;
import app;

class Logon : Scene {
    Application app;

    gui.window.Window loginWindow;
    Label userNameLabel;
    Label passwordLabel;
    TextBox userNameTextBox;
    TextBox passwordTextBox;
    Button loginButton;
    Button cancelButton;
    Button configureButton;

    this (Application app_) {
        super(app_);
        app = app_;
    }

    override void onResize (Vector2i size){
        super.onResize(size);
        if (loginWindow !is null) {
            loginWindow.position = (Vector2f(size) - loginWindow.size ) / 2;
        }
    }

    override void onGainFocus(){
        super.onGainFocus();
        app.guisystem.clear();
        app.guisystem.addChild(loginWindow);
    }

    override void onLostFocus(){
        super.onLostFocus();
    }

    override void onCreate(){
        loginWindow = new gui.window.Window(app.guisystem, "Login",Vector2f(0,0), Vector2f(300,200));

        userNameLabel = new Label(app.guisystem, "User Name:","lblUserName", Vector2f(5,20));
        loginWindow.addChild(userNameLabel);
        userNameTextBox = new TextBox(app.guisystem, "", Vector2f(90,20), Vector2f(loginWindow.size.x-95,20));
        loginWindow.addChild(userNameTextBox,true);

        passwordLabel = new Label(app.guisystem, "Password:","lblPassword", Vector2f(5,40));
        loginWindow.addChild(passwordLabel);
        passwordTextBox = new TextBox(app.guisystem, "", Vector2f(90,40), Vector2f(loginWindow.size.x-95,20));
        passwordTextBox.password = true;
        loginWindow.addChild(passwordTextBox,true);

        loginButton = new Button(app.guisystem, "btnLogin", Vector2f(5,90), Vector2f(loginWindow.size.x-10,20));
        loginButton.value = "Login";
        loginWindow.addChild(loginButton,true);
        loginButton.events["click"] = (Event e) {
            auto retval = app.logon(userNameTextBox.value, passwordTextBox.value); //TODO: provide password as a hash
            //TODO: do a reall login using cleint/server exchange
            if(true){
                app.sceneManager.switchScene("editor");
            } else {
                //TODO: show error message
                //app.guisystem.popup("Login failed","Continue");
                //app.log("Login failed: " + userNameTextBox.value + " " + passwordTextBox.value);
            }
        };
    }
}