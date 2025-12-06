import std.stdio;
import std.random;

import nudsfml.graphics;

import debuggfx;

void main() {

	RenderWindow win = new RenderWindow(VideoMode(1024, 768), "NudSFML", Window.Style.DefaultStyle , ContextSettings(0, 0, 0, 0, 0, 0));
	//win.setFramerateLimit(60);

	auto graph = new DebugGraph(Vector2f(10,10), Vector2f(500, 110));
	graph.addSampler("FPS", Color.White);

	auto rnd = Random(42);

	Clock frameTime = new Clock;
	float dt = 1/60f;
	while (win.isOpen()) {
		graph.push_value("FPS",1/dt);
		graph.update(dt);

		Event e;
		while (win.pollEvent(e)) {
			if (e.type == Event.Type.Closed) {
				win.close();
			}
			if(e.type == Event.Type.KeyPressed) {
				if(e.key.code == Keyboard.Key.Escape) {
					win.close();
				}
			}
		}

		win.clear(Color.Black);
		win.draw(graph);
		win.display();

		dt = frameTime.restart.asSeconds();
	}

}
