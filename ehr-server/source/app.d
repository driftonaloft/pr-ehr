import std.stdio;

import ehr : Ehr;

void main() {
	Ehr ehr = new Ehr;
	ehr.startup();
	ehr.run();
	ehr.shutdown();
}
