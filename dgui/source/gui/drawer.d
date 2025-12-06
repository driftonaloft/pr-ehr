module gui.drawer;

import gui;
import gfx;

import std.stdio;
import nudsfml.graphics;

class Drawer : Widget {
	enum Docked {
		Left,
		Top,
		Right,
		Bottom,
	}

	Docked m_docked;

	enum DrawerState {
		Opened,
		Opening,
		Closed,
		Closing,
	}

	DrawerState m_state;

	RectangleShape base;
	RoundedRectangle internal;
	Text label;
	Vector2i area_offset;

	@property { //docked
		Docked docked(Docked d) {
			m_docked = d;
			update_size();
			return m_docked;
		}

		Docked docked() {
			return m_docked;
		}
	}

	@property { //state
		DrawerState state(DrawerState ds) {
			m_state = ds;
			if (gui.win !is null) {
				auto wsize = gui.win.getSize();
				auto d = docked;
				final switch (d) {
				case d.Left:
					switch (ds) {
					case ds.Opened:
						m_position.x = 0;
						break;
					case ds.Closed:
						m_position.x = 0 - m_size.x + 16;
						break;
					default:
						break;
					}
					break;
				case d.Right:
					switch (ds) {
					case ds.Opened:
						m_position.x = wsize.x - m_size.x;
						break;
					case ds.Closed:
						m_position.x = wsize.x - 16;
						break;
					default:
						break;
					}
					break;
				case d.Top:
					switch (ds) {
					case ds.Opened:
						m_position.y = 0;
						break;
					case ds.Closed:
						m_position.y = 0 - m_size.y + 16;
						break;
					default:
						break;
					}
					break;
				case d.Bottom:
					switch (ds) {
					case ds.Opened:
						m_position.y = wsize.y - m_size.y;
						break;
					case ds.Closed:
						m_position.y = wsize.y - m_size.y + 16;
						break;
					default:
						break;
					}
					break;
				}
			}
			return m_state;
		}

		DrawerState state() {
			return m_state;
		}
	}

	@property { //size 
		override Vector2f size(Vector2f s){
			m_size = s;
			update_size();
			return m_size;
		}

		override Vector2f size (){
			return m_size;
		}
	}

	this(Gui gui_, DrawerState state_ = DrawerState.Opened, Docked docked_ = Docked.Left, Vector2f pos_ = Vector2f(0,0), Vector2f size_ = Vector2f(200,200)) {
		super(gui_ );
		m_type = "drawer";

		base = new RectangleShape();
		base.fillColor = Color(100, 100, 100);
		base.outlineColor = Color(80, 80, 80);
		base.outlineThickness = 1;

		internal = new RoundedRectangle();
		internal.fillColor = Color(80, 80, 80);
		internal.radius = 5;
		internal.cornerCount = 4;
		docked = Docked.Right;

		area_offset = Vector2i(16, 4);

		state = state_;
		docked = docked_;
		position = pos_;
		size = size_;
	}

	void update_size() {
		version(DEBUG){ writeln("m_size: ", size.y);}
		base.size = m_size;
		if (docked == Docked.Left || docked == Docked.Right) {
			internal.size = base.size - Vector2f(16, 8);
		} else {
			internal.size = base.size - Vector2f(8, 16);
		}
		if (docked == Docked.Left) {
			area_offset = Vector2f(0, 4);
		} else if (docked == Docked.Right) {
			area_offset = Vector2f(16, 4);
		} else if (docked == Docked.Top) {
			area_offset = Vector2f(4, 0);
		} else if (docked == Docked.Bottom) {
			area_offset = Vector2f(4, -16);
		}
	}

	override Vector2i getReleativePosition(Vector2i point) {
		point -= area_offset;
		return super.getReleativePosition(point);
	}

	override void onClick(Event e) {
		writeln("drawer clicked");
		auto p = Vector2i(e.mouseButton.x, e.mouseButton.y);
		auto r = super.getReleativePosition(p);
		writefln("drawer click (%s)", r.toString);

		if (docked == Docked.Right && r.x >= 0 && r.x < 16) {
			if (state == DrawerState.Opened) {
				state = DrawerState.Closing;
			} else if (state == DrawerState.Closed) {
				state = DrawerState.Opening;
			}
		} else {
			super.onClick(e);
		}
		if (docked == Docked.Left && r.x >= m_size.x - 16 && r.x < m_size.x) {
			if (state == DrawerState.Opened) {
				state = DrawerState.Closing;
			} else if (state == DrawerState.Closed) {
				state = DrawerState.Opening;
			}
		} else {
			super.onClick(e);
		}
		if (docked == Docked.Bottom && r.y >= 0 && r.y < 16) {
			if (state == DrawerState.Opened) {
				state = DrawerState.Closing;
			} else if (state == DrawerState.Closed) {
				state = DrawerState.Opening;
			}
		} else {
			super.onClick(e);
		}
		if (docked == Docked.Top && r.y >= size.y - 16 && r.y < size.y) {
			if (state == DrawerState.Opened) {
				state = DrawerState.Closing;
			} else if (state == DrawerState.Closed) {
				state = DrawerState.Opening;
			}
		} else {
			super.onClick(e);
		}

	}

	override Widget contains(Vector2i point) {
		if (enabled) {
			point -= Vector2i(position);
			point -= area_offset;
			foreach_reverse (ref child; children) {
				auto c = child.contains(point);
				if (c) {
					return c;
				}
			}
			point += area_offset;
			if (point.x < m_size.x && point.x >= 0 && point.y < m_size.y && point.y >= 0) {
				return this;
			}
		}
		return null;
	}

	override void onDraw(RenderTarget target, Vector2f offset) {
		
		Vector2f drawpos = Vector2f(position) + offset;
		base.position = drawpos;

		if (docked == Docked.Right) {
			internal.position = base.position + Vector2f(16, 4);
		} else if (docked == Docked.Left) {
			internal.position = base.position + Vector2f(0, 4);
		} else if (docked == Docked.Top) {
			internal.position = base.position + Vector2f(4, 0);
		} else {
			internal.position = base.position + Vector2f(4, 16);
		}

		target.draw(base);
		target.draw(internal);
	}

	override void update(float dt) {
		float speed = 2000.0f;
		auto wsize = gui.win.getSize();
		if (state == DrawerState.Opening) {
			final switch (docked) {
			case Docked.Left:
				m_position.x += (speed * dt);
				if (m_position.x > m_size.x) {
					state = DrawerState.Opened;
				}
				break;
			case Docked.Right:
				m_position.x -= (speed * dt);
				if (m_position.x < wsize.x - m_size.x) {
					state = DrawerState.Opened;
				}
				break;
			case Docked.Top:
				m_position.y += (speed * dt);
				if (m_position.y > 0) {
					state = DrawerState.Opened;
				}
				break;
			case Docked.Bottom:
				m_position.y -= (speed * dt);
				if (m_position.y < wsize.y - m_size.y) {
					state = DrawerState.Opened;
				}
				break;
			}
		} else if (state == DrawerState.Closing) {
			final switch (docked) {
			case Docked.Left:
				m_position.x -= (speed * dt);
				if (m_position.x < 16) {
					state = DrawerState.Closed;
				}
				break;
			case Docked.Right:
				m_position.x += (speed * dt);
				if (m_position.x > wsize.x - 16) {
					state = DrawerState.Closed;
				}
				break;
			case Docked.Top:
				m_position.y -= (speed * dt);
				if (m_position.y < 0 - m_size.y + 16) {
					state = DrawerState.Closed;
				}
				break;
			case Docked.Bottom:
				m_position.y += (speed * dt);
				if (m_position.y > wsize.y - 16) {
					state = DrawerState.Closed;
				}
				break;
			}
		}

		super.update(dt);
	}

	override void draw(RenderTarget target, Vector2f offset) {
		onDraw(target, offset);

		Vector2f internalOffset;
		if (docked == Docked.Right) {
			internalOffset = Vector2f(16, 4);
		} else if (docked == Docked.Left) {
			internalOffset = Vector2f(-16, 4);
		} else if (docked == Docked.Top) {
			internalOffset = Vector2f(4, -16);
		} else {
			internalOffset = Vector2f(4, 16);
		}

		foreach (ref child; children) {
			child.draw(target, m_position + offset + internalOffset);
		}
	}
}
