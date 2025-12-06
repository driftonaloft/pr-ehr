module nudsfml.window.windowhandle;

//TODO: Make the Windows Window Handle the right type?
//(ie, a HWND from std.c.windows.windows?
version(Windows) {
	//import std.c.windows.windows;
	struct HWND__;
	alias HWND__* WindowHandle;
}
version(OSX) {
	import core.stdc.config;
	alias c_ulong WindowHandle;
}
version(linux) {
	alias void* WindowHandle;
}