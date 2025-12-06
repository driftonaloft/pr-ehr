import std.stdio;

import nudsfml.graphics;
import nudsfml.system;

import application;
import util;
import gfx.hsv;

void main() {
	writeln("d gui editor");

	Image img = new Image();
	
	img.create(256, 256,Color.Black);

	float target_angle = 235;

	Clock clock = new Clock();
	for(int y = 0 ; y < 256; y++){
		for(int x = 0; x < 256; x++){
			float d = distance(x,y,128,128);
			float angle = lineToAngle(x,y,128,128);

			if(d < 130 && d > 120){ 
				Color c = HSVtoRGB(angle,1,1);
				if(angle < target_angle + 1 && angle > target_angle - 1){
					c = Color.White;
				}
				img.setPixel(x,y,c);
			} else if (d > 105 && d < 115){
				Color c = HSVtoRGB(target_angle,angle/360,1);
				img.setPixel(x,y,c);
			} else if (d > 90 && d < 100){
				Color c = HSVtoRGB(target_angle,1,angle/360);
				img.setPixel(x,y,c);
			} else if (d < 60 ){
				Color c = HSVtoRGB(target_angle,.6,1);
				img.setPixel(x,y,c);
			}
		}
	}
	auto d = clock.getElapsedTime();
	writeln(d.asSeconds);
	//writeln("Time as Seconds :",d.asSeconds());

	img.saveToFile("test.png");

	Application app = new Application;
	app.run();
	app.shutdown();

}
