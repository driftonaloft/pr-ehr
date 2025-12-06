module gui.widgets;

import std.stdio;

import nudsfml.graphics;

import gui.cage : Cage;
import gui.system : Gui;

class Widget {
	Gui gui;

	string m_id = "widget_default";
	string m_label = "default";
	string m_value = "";
	string m_type = "widget";
	bool m_enabled = true;

	Widget[] children;
	string[] tabstops;
	Widget parent;
	int tabStopIndex = 0;
	bool willTabstop = true;
	bool checked = false;

	Vector2f m_size;
	Vector2f m_position;
	Color m_color;

	bool hasFocus = false;
	bool enterClick = false;
	bool locked = false;
	int cursor = 0;
	
	IntRect m_handle;

	void delegate(Event)[string] events;

	@property { //enabled
		bool enabled(bool v) {
			m_enabled = v;
			return m_enabled;
		}

		bool enabled() {
			return m_enabled;
		}
	}

	@property { //id
		string id(string v) {
			m_id = v;
			return m_id;
		}

		string id() {
			return m_id;
		}
	}

	@property { //value
		string value(string v) {
			m_value = v;
			return m_value;
		}

		string value() {
			return m_value;
		}
	}

	@property { //size
		Vector2f size(Vector2f s) {
			m_size = s;
			return m_size;
		}

		Vector2f size() {
			return m_size;
		}
	}

	@property { //color
		Color color(Color c) {
			m_color = c;
			return m_color;
		}

		Color color() {
			return m_color;
		}
	}

	@property { //label
		string label(string v) {
			m_label = v;
			return m_label;
		}

		string label() {
			return m_label;
		}
	}

	@property { //position
		Vector2f position(Vector2f v) {
			m_position = v;
			return m_position;
		}

		Vector2f position() {
			return m_position;
		}
	}

	this(Gui gui_) {
		gui = gui_;
		m_type = "widget";
		m_size = Vector2f(1000, 600);
		m_color = Color(80, 80, 80, 255);
		m_position = Vector2f(10, 30);
	}

	//Event Handlers
	void onClick(Event e) {
		//do widget specific click event
		//pass event to widget deleagate
		if (("click" in events) !is null) {
			events["click"](e);
		}
	}

	void onScrollWheel(Event e) {
		if (("scrollwheel" in events) !is null) {
			events["scrollwheel"](e);
		}
	}

	void onCursor() {
	}

	void onDrop() {
	}

	void onDrag(Vector2i curr, Vector2i offset) {
	}

	void onPickup() {
	}

	void onResize(Event e) {
		if (("resize" in events) !is null) {
			events["resize"](e);
		}
	}

	void onText(Event e) {
		if (("text" in events) !is null) {
			events["text"](e);
		}
	}

	void onKeyReleased(Event e) {
		if (("keyreleased" in events) !is null) {
			events["keyreleased"](e);
		}
	}

	Widget contains(Vector2i point) {
		if (enabled) {
			point -= position;
			foreach_reverse (ref child; children) {
				auto c = child.contains(point);
				if (c !is null)
					return c;
			}
			if (point.x < m_size.x && point.x >= 0 && point.y < m_size.y && point.y >= 0) {
				return this;
			}
		}
		return null;
	}

	Widget [] getSiblings() {
		Widget [] retval;
		if (parent !is null) {
			retval = parent.children;
		} else {
			retval = gui.children;
		}
		return retval;
	}

	void addChild(T : Widget)(ref T child, bool tabstop = false) {
		child.parent = this;
		children ~= child;
		if (tabstop) {
			tabstops ~= child.id;
		}
	}

	Widget getChild(string id) {
		foreach (ref child; children) {
			if (child.id == id) {
				return child;
			}
		}
		return null;
	}

	void removeChild(string id) {
		import std.algorithm;
		children = children.remove!(c => c.id == id)();
	}

	Widget getRoot() {
		Widget retval = this;
		while (retval.parent !is null) {
			retval = retval.parent;
		}
		return retval;
	}

	void update(float dt) {
		foreach (ref child; children) {
			child.update(dt);
		}
	}

	void onGainFocus() {
	}

	void onLostFocus() {
	}

	Vector2i getReleativePosition(Vector2i point) {
		point = point - Vector2i(position);
		if (parent !is null) {
			point = parent.getReleativePosition(point);
		}
		return point;
	}

	void onDraw(RenderTarget target, Vector2f offset) {
	}

	void onEnd(){
	}

	void onHome(){
	}


	void draw(RenderTarget target, Vector2f offset) {
		if (enabled) {
			onDraw(target, offset);
			foreach (ref child; children) {
				child.draw(target, Vector2f(position) + offset);
			}
		}
	}

	bool grabable (Vector2i point) { // return a widget that is grabbled or a holdable objects ie dragging selected text to another text field or with in the widget
		auto p = getReleativePosition(point);
		return m_handle.contains(p);
	}
}


struct Padding{
	int top;
	int bottom;
	int left;
	int right;
}

enum Alignment {
	None, // default no adjusted alignment targets
	Left, // places the widget to the left of the anchor widget
	Right, // places the widget to the right of the anchor widget
	Top, // places the widget below the anchor widget
	Bottom, // places the widget above the anchor widget
	Center 
}

enum Placement{
	Left, // default places the widget to the left of the anchor widget
	Right, // places the widget to the right of the anchor widget
	Below, // places the widget below the anchor widget
	Above // places the widget above the anchor widget
}



FloatRect spaceTo(Widget anchor, Widget child, Placement place, Alignment alignment = Alignment.None, Padding padding = Padding(5,5,5,5)){
	FloatRect retval;
	auto parent = anchor.parent; //used to adjust the position of the child widget tobe with in parent widget

	switch(place){
		case Placement.Left:
			retval.left   = anchor.position.x - child.size.x - padding.right;
			retval.top    = anchor.position.y;
			retval.width  = child.size.x;
			retval.height = child.size.y;

			if( retval.left < padding.left){
				float maxWidth = anchor.position.x - (padding.left + padding.right);
				retval.left = padding.left;
				retval.width = maxWidth;
			}
			break;
		case Placement.Right:
			retval.left   = anchor.position.x + anchor.size.x + padding.left;
			retval.top 	  = anchor.position.y;
			retval.width  = child.size.x;
			retval.height = anchor.size.y;

			float maxWidth = parent.size.x - retval.left - (padding.right + padding.left);
			if(retval.width > maxWidth){
				retval.width = maxWidth;
			}
			break;
		case Placement.Below:
			retval.left	  = anchor.position.x;
			retval.top	  = anchor.position.y + anchor.size.y + padding.top;
			retval.width  = child.size.x;
			retval.height = child.size.y;

			float maxHeight = parent.size.y - (anchor.position.y + anchor.size.y) - (padding.bottom + padding.top);
			if(retval.height > maxHeight){
				retval.height = maxHeight;
			}
			break;
		case Placement.Above:
			retval.left   = anchor.position.x;
			retval.top    = anchor.position.y - child.size.y - padding.bottom;
			retval.width  = child.size.x;
			retval.height = child.size.y;

			if(retval.top < padding.top){
				retval.top = padding.top;
			}
			float maxHeight = anchor.position.y - (padding.bottom + padding.top);
			if(retval.height > maxHeight){
				retval.height = maxHeight;
			}

			break;
		default:
			break;
	}
	return retval;
}

enum Arrangment {
	Horizontal,
	Vertical,
	Packed,
	BestFit,
	Grid,
	EqualSize,
	Free
}

FloatRect getTargetArea(FloatRect parentArea, Widget anchor, Placement place, Padding padding = Padding(5,5,5,5), Alignment alignment = Alignment.Left){
	FloatRect targetArea;
	switch (place){
		case Placement.Left:
			targetArea.left = 0;
			targetArea.top = anchor.position.y;
			targetArea.width = anchor.position.x - padding.right;
			targetArea.height = anchor.size.y;
			break;
		case Placement.Right:
			targetArea.left = anchor.position.x + anchor.size.x + padding.left;
			targetArea.top = anchor.position.y;
			targetArea.width = anchor.size.x;
			targetArea.height = anchor.size.y;
			break;
		case Placement.Below:
			targetArea.left = anchor.position.x;
			targetArea.top = anchor.position.y + anchor.size.y + padding.top;
			targetArea.width = anchor.size.x;
			targetArea.height = parentArea.height - (anchor.position.y + anchor.size.y + padding.top + padding.bottom);
			break;
		case Placement.Above:
			targetArea.left = anchor.position.x;
			targetArea.top =  anchor.position.y - padding.top;
			targetArea.width = anchor.size.x;
			targetArea.height = parentArea.height - (anchor.position.y - padding.bottom);
			break;
		default:
			break;
	}
	return targetArea;
}

FloatRect[] spaceTo(Widget anchor, ref Widget[] children, Placement place, Alignment alignment = Alignment.Left, Padding padding = Padding(5,5,5,5), Arrangment arrangment = Arrangment.Horizontal ){
	import std.conv;
	FloatRect[] retval;
	Vector2f anchorPos = anchor.position;
	Vector2f anchorSize = anchor.size;

	FloatRect parentArea;
	if(anchor.parent is null){
		parentArea.left = 0;
		parentArea.top = 0;
		parentArea.width = anchor.gui.size.x;
		parentArea.height = anchor.gui.size.y;
	} else {
		parentArea.left = anchor.parent.position.x;
		parentArea.top = anchor.parent.position.y;
		parentArea.width = anchor.parent.size.x;
		parentArea.height = anchor.parent.size.y;
	}

	FloatRect targetArea = getTargetArea(parentArea, anchor, place, padding, alignment);

	
	switch(arrangment){
		case Arrangment.Horizontal:
			retval.length = children.length;
			int targetWidth = (targetArea.width / children.length).to!int - (padding.left > padding.right ? padding.left : padding.right);
			for(uint i = 0; i < children.length; i++){
				retval[i].left   = anchorPos.x + anchorSize.x + padding.left;
				retval[i].top    = anchorPos.y;
				retval[i].width  = targetWidth;
				retval[i].height = anchorSize.y;
				anchorPos.x += children[i].size.x + padding.left + padding.right;
			}
			break;
		case Arrangment.Vertical:
			retval.length = children.length;
			int targetWidth = (targetArea.height / children.length).to!int - (padding.top > padding.bottom ? padding.top : padding.bottom);
			for(uint i = 0; i < children.length; i++){
				retval[i].left   = anchorPos.x;
				retval[i].top    = anchorPos.y + anchorSize.y + padding.top;
				retval[i].width  = anchorSize.x;
				retval[i].height = children[i].size.y;
				anchorPos.y += children[i].size.y + padding.top + padding.bottom;
			}
			break;
		case Arrangment.Packed:
			retval.length = children.length;
			for(uint i = 0; i < children.length; i++){
				retval[i].left   = anchorPos.x;
				retval[i].top    = anchorPos.y;
				retval[i].width  = children[i].size.x;
				retval[i].height = children[i].size.y;
				anchorPos.x += children[i].size.x + padding.left + padding.right;
				anchorPos.y += children[i].size.y + padding.top + padding.bottom;
			}
			break;
		case Arrangment.BestFit:
			break;
		case Arrangment.Grid:
			break;
		case Arrangment.EqualSize:
			break;
		case Arrangment.Free:
			break;
		default:
			break;
	}



	return retval;
}