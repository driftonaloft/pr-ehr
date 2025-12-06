/*---------------------------------------------------------------------------*\
|   a quick example of working with nudsfml                                   |
\*---------------------------------------------------------------------------*/

unittest {
	import nudsfml.graphics;
	import std.format;

	RenderWindow win = new RenderWindow(VideoMode(1024,768), "Example Window");
	//win.setFramerateLimit(60);
	//win.setVerticalSyncEnabled(true);

	RectangleShape shape = new RectangleShape(Vector2f(50,50));
	shape.fillColor = Color.Red;

	Vector2f winSize = Vector2f(win.size.x, win.size.y);

	Vector2f position = Vector2f(0,0);
	Vector2f speed = Vector2f(150f,80f);

	Font f = new Font();
	f.loadFromFile("data/CamingoCode-Regular.ttf");

	Text t = new Text("Fps:0123456789.", f);

	Clock frameTime = new Clock();
	float deltaA = 1f/60f;
	float fps = 0f;
	float min = 10_000f;
	float max = 0f;

	while(win.isOpen){
		float delta = frameTime.restart.asSeconds;
		deltaA = (delta + deltaA )/ 2f;
		fps = 1f/deltaA;
		if(min > fps) min = fps;
		if(max < fps) max = fps;

		t.setString( format("Fps: %7.2f min: %7.2f max: %7.2f", fps, min, max) );

		Event e;
		while(win.pollEvent(e)){
			if(e.type == Event.Type.Closed)
				win.close();
			if(e.type == Event.Type.KeyPressed){
				if(e.key.code == Keyboard.Key.Escape){
					win.close();
				}
			}

		}

		position = position + speed * delta;
		if(position.x < 0 ){
			position.x = 0;
			speed.x = -speed.x;
		} else if (position.x + shape.size.x > winSize.x ){
			position.x = winSize.x - shape.size.x;
			speed.x = -speed.x;
		}
		if(position.y < 0 ){
			position.y = 0;
			speed.y = -speed.y;
		} else if (position.y + shape.size.y > winSize.y ){
			position.y = winSize.y - shape.size.y;
			speed.y = -speed.y;
		}
		shape.position = position;

		win.clear();

		win.draw(shape);
		win.draw(t);

		win.display();
	}

}
