module formeditor;

import std.stdio;

import nudsfml.system.vector2;
import nudsfml.graphics.rendertarget;
import nudsfml.graphics.renderstates;
import nudsfml.window.event;

import gui;

import scene;
import app;

import util.color;


class SectionElement {
    string name;
    string type;
    string id;

    Vector2f size;
    Vector2f position;

    Widget widget; 
}

class SectionRep {
    string name;
    string id;

    Vector2f size;

    Widget section;
    SectionElement [] elements;
}

class FormRep {
    string name;
    string id;
    Widget form;

    Vector2f size;

    SectionRep [] sections;

}

template buttonMixin(string name){
		const char [] buttonMixin = "auto btn" ~ name ~" = new gui.togglebutton.ToggleButton(app.guisystem, btn,buttonPos,Vector2f(90,30));" ~
		"btn" ~ name ~".id = \"btn\" ~ btn;" ~
		"btn" ~ name ~".events[\"click\"] = (Event e){ " ~
			"writeln(btn" ~ name ~".id,\":\",btn" ~ name ~".checked ); " ~
			"foreach(ref child; guiToolbox.children){ " ~
				"writeln(\"\t\",child.id,\":\",child.checked); " ~
				"if(child.id != btn" ~ name ~".id){ " ~
					"child.value = \"false\"; " ~
				"} else {" ~
					"selection = \""~name~"\";"~
				"}" ~
			"} " ~
		"};" ~
		"guiToolbox.addChild(btn" ~ name ~");" ;
}


class FormEditor : Scene {
	Widget formTarget;
	Widget formSelection;
	Widget currentSection;
    Widget toolBox; //drawer
	Widget tglEdit;
	Widget btnExport; 


    Widget propertyBox; //window
	Widget formPropertyPanel;
	Widget lablePropertyPanel;
	Widget togglePropertyPanel;
	Widget checkBoxPropertyPanel;
	Widget listboxPropertyPanel;
	Widget textboxPropertyPanel;
	Widget dropdownPropertyPanel;
	Widget textblockPropertyPanel;

	Window narrativeEditor;

    Widget propertyBoxTarget; //window
	
	Cage formCage;

    string selection;
    string mode;

    this (Application app_){
        super(app_);
        	//buildGui(guisystem);

		mode = "create";
    }

    override void onUpdate(float dt){
        //TODO: update property box this is for testing only 
		if(app.guisystem.hasFocus !is null){
			Widget root = app.guisystem.hasFocus.getRoot();
			if(root.m_type == "form"){
				updatePropertyBox();
			}
		}
		app.text.string = "Selection: " ~ selection ~ " Mode: " ~ mode;
    }

    override void onResize(Vector2i size){
		super.onResize(size);
		propertyBox.position = Vector2f(size.x - propertyBox.size.x - 10, 20);
    }

    override void onDraw(RenderTarget target, RenderStates states){
        //target.draw(toolBox,states);
        //target.draw(propertyBox,states);
        target.draw(app.text);
    }

	override void onCreate(){
		super.onCreate();
		buildToolBox();
		buildPropertyBox();
		buildFormSelection();

		tglEdit = new ToggleButton(app.guisystem, "Edit", Vector2f(205, 0),Vector2f(60,20));
		tglEdit.id = "tglEdit";
		writeln(&tglEdit);
		tglEdit.events["click"] = (Event e){
			version(DEBUG_LOG){ writeln(&tglEdit, &tglEdit.checked);}

			if(tglEdit.checked){
				mode = "edit";

				auto form = formTarget;
				if(form !is null ){
					foreach(ref section ; form.children){
						writeln(section.m_type , " - " , section.id, ": ", section.label);
						if(section.m_type == "section"){
							foreach(ref child ; section.children){
								writeln("\t",child.m_type , " - " ,child.id, ": ", child.label);
								if(child.m_type == "cage"){
									gui.cage.Cage cage = cast(gui.cage.Cage)child;
									cage.edit = true;
								}
							}
						}
					}
				}
			} else {
				mode = "view";
				
				auto form = formTarget;
				if(form !is null ){
					foreach(ref section ; form.children){
						writeln(section.m_type , " - " ,section.id, ": ", section.label);
						if(section.m_type == "section"){
							foreach(ref child ; section.children){
								writeln("\t",child.m_type , " - " ,child.id, ": ", child.label);
								if(child.m_type == "cage"){
									gui.cage.Cage cage = cast(gui.cage.Cage)child;
									cage.edit = false;
								}
							}
						}
					}
				}
			}

			if(mode == "edit"){
				app.guisystem.addChild(toolBox);
			} else {
				app.guisystem.removeChildType(toolBox);
			}
		};

		btnExport = new Button(app.guisystem, "Export", Vector2f(270,0), Vector2f(100,20));
		btnExport.id = "btnExport";
		btnExport.value("Export Form");
		btnExport.events["click"] = (Event e) {
			exportForm(formTarget);	
		};
	}

	void exportForm(Widget form){
		import std.stdio;
		writeln("Export Form");
		if(form !is null){
			FormRep formRep = new FormRep;

			formRep.id = form.id;
			formRep.name = form.label;
			formRep.form = form;

			formRep.size = form.size;

			foreach(child ; form.children){
				if(child.m_type == "section"){
					SectionRep sectionRep = new SectionRep;
					sectionRep.name = child.label;
					sectionRep.id = child.id;

					foreach(sChild; child.children){
						SectionElement element = new SectionElement;
						Widget w = sChild;
						if(w.m_type == "cage"){
							if(w.children.length > 0){
								w = w.children[0]; // needs help if child is supposed to be multiselect toggle
							}
						}
						element.type = w.m_type;
						element.id = w.id;
						element.name = w.label;
						element.widget = w;

						sectionRep.elements ~= element;
					}

					formRep.sections ~= sectionRep;
				}
			}

			writeln(formRep.id ," - ",formRep.name);
			foreach(section ; formRep.sections){
				writeln("\t",section.id ," - ",section.name);
				foreach(element; section.elements){
					writeln("\t\t",element.id ," - ",element.name);	
					writeln("\t\t\tsize: ",element.size);
					writeln("\t\t\tposition: ",element.position);
				}
			}
		}
	}	

	override void onGainFocus(){
		super.onGainFocus();
		app.guisystem.clear();
		app.guisystem.addChild(propertyBox);
		//app.guisystem.addChild(toolBox);
		app.guisystem.addChild(formSelection);
		app.guisystem.addChild(tglEdit);
		app.guisystem.addChild(btnExport);
	}

	override void onLostFocus(){
		super.onLostFocus();
	}

	void updatePropertyBox(){
		import std.format;
		if(propertyBoxTarget !is null && propertyBox !is null){
			gui.widgets.Widget child;
			if(propertyBoxTarget.m_type == "cage" && propertyBoxTarget.children.length > 0){
				child = propertyBoxTarget.children[0];
			} else {
				child = propertyBoxTarget;
			}
			propertyBox.getChild("tbID").value =  		child.id;
			propertyBox.getChild("tbLabel").value = 	child.label;
			propertyBox.getChild("tbValue").value = 	child.value;
			propertyBox.getChild("tbType").value =  	child.m_type;
			propertyBox.getChild("tbChecked").value = 	(child.checked ? "true" : "false");
			if(propertyBoxTarget.m_type == "cage"){
				propertyBox.getChild("tbPosition").value = format("%4.0f,%4.0f",propertyBoxTarget.position.x, propertyBoxTarget.position.y);
			} else {
				propertyBox.getChild("tbPosition").value = format("%4.0f,%4.0f",child.position.x, child.position.y);
			}
			propertyBox.getChild("tbSize").value = 	format("%4.0f,%4.0f",child.size.x, child.size.y);
			propertyBox.getChild("tbColor").value = 	format("#%x%x%x%x", child.color.r, child.color.g, child.color.b, child.color.a);

			propertyBox.removeChild("panelWidget");
			if(child.m_type == "form"){
				if(formPropertyPanel !is null){
					propertyBox.addChild(formPropertyPanel);
					updateFormPropertyPanel(child);
				}
				propertyBox.size = Vector2f(300, 250) + Vector2f(0,200);
			}

		} else {
			propertyBox.getChild("tbID").value = 		"";
			propertyBox.getChild("tbLabel").value = 	"";
			propertyBox.getChild("tbValue").value = 	"";
			propertyBox.getChild("tbType").value =  	"";
			propertyBox.getChild("tbChecked").value = 	"";
			propertyBox.getChild("tbPosition").value = 	"";
			propertyBox.getChild("tbSize").value = 		"";
			propertyBox.getChild("tbColor").value = 	"";
			propertyBox.removeChild("panelWidget");
			propertyBox.size = Vector2f(300,250);
		}
	}

	void updateFormPropertyPanel(Widget child){
		if(formPropertyPanel !is null){
			if(child.m_type == "form"){
				Form form = cast(Form)child;
			
				auto templb = formPropertyPanel.getChild("lbSection");
				if(templb !is null){
					ListBox lbSection = cast(ListBox)templb;
					int tempindex = lbSection.index;
					lbSection.clear();
					foreach(string section; form.sections){
						lbSection.addItem(section, section);					
					}
					lbSection.index = tempindex;
				}
			}
		}
	}

	void applyPropertyBox(){
		import std.conv;

		if(propertyBoxTarget !is null){
			gui.widgets.Widget child;
			if(propertyBoxTarget.m_type == "cage" && propertyBoxTarget.children.length > 0){
				child = propertyBoxTarget.children[0];
			} else {
				child = propertyBoxTarget;
			}
			child.id = propertyBox.getChild("tbID").value;
			child.label = propertyBox.getChild("tbLabel").value;
			child.value = propertyBox.getChild("tbValue").value;
			child.m_type = propertyBox.getChild("tbType").value;
			child.checked = (propertyBox.getChild("tbChecked").value == "true");
	
			if(propertyBoxTarget.m_type == "cage"){
				propertyBoxTarget.position = propertyBox.getChild("tbPosition").value.stringToVector2f;
			} else {
				child.position = propertyBox.getChild("tbPosition").value.stringToVector2f;
			}
			child.size = propertyBox.getChild("tbSize").value.stringToVector2f;
			//child.color = propertyBox.getChild("tbColor").value.getColorHex;
		}
	}

	void buildPropertyBox() {
		auto position = Vector2f(app.win.size.x - 310, 20);
		propertyBox = new gui.window.Window(app.guisystem, "Properties", position, Vector2f(300,250));

		Label lblID =  new Label(app.guisystem, "ID: ", "lblID",  Vector2f(5,20));
		propertyBox.addChild(lblID);
		
		TextBox tbID = new TextBox(app.guisystem, "tbID", Vector2f(100,20),Vector2f(200,20));
		tbID.value = "";
		propertyBox.addChild(tbID, true);

		Label lblLabel = new Label(app.guisystem, "Label: ", "lblLabel", Vector2f(5,40));
		propertyBox.addChild(lblLabel);
		
		TextBox tbLabel = new TextBox(app.guisystem, "tbLabel", Vector2f(100,40),Vector2f(200,20));
		tbLabel.value = "";
		propertyBox.addChild(tbLabel , true);

		Label lblValue = new Label(app.guisystem, "Value: ", "lblValue", Vector2f(5,60));
		propertyBox.addChild(lblValue);
		
		TextBox tbValue = new TextBox(app.guisystem, "tbValue", Vector2f(100,60),Vector2f(200,20));
		tbValue.value = "";
		propertyBox.addChild(tbValue, true);

		Label lblType =new Label(app.guisystem, "Type: ", "lblType", Vector2f(5,80));
		propertyBox.addChild(lblType);
		
		TextBox tbType = new TextBox(app.guisystem, "tbType", Vector2f(100,80),Vector2f(200,20));
		tbType.value = "";
		tbType.locked = true;
		propertyBox.addChild(tbType, true);

		Label lblChecked = new Label(app.guisystem, "Checked: ", "lblChecked", Vector2f(5,100));
		propertyBox.addChild(lblChecked);
		
		TextBox tbChecked = new TextBox(app.guisystem, "tbChecked", Vector2f(100,100),Vector2f(200,20));
		tbChecked.value = "";
		propertyBox.addChild(tbChecked, true);

		Label lblPosition = new Label(app.guisystem, "Position: ", "lblPosition",Vector2f(5,120));
		propertyBox.addChild(lblPosition);
		
		TextBox tbPosition = new TextBox(app.guisystem, "tbPosition", Vector2f(100,120),Vector2f(200,20));
		tbPosition.value = "";
		propertyBox.addChild(tbPosition, true);
		
		Label lblSize =new Label(app.guisystem, "Size: ", "lblSize", Vector2f(5,140));
		propertyBox.addChild(lblSize);
		
		TextBox tbSize = new TextBox(app.guisystem, "tbSize", Vector2f(100,140),Vector2f(200,20));
		tbSize.value = "";
		propertyBox.addChild(tbSize,true);

		Label lblColor =new Label(app.guisystem, "Color: ", "lblColor", Vector2f(5,160));
		propertyBox.addChild(lblColor);
		
		TextBox tbColor = new TextBox(app.guisystem,  "tbColor", Vector2f(100,160),Vector2f(200,20));
		tbColor.value = "";
		propertyBox.addChild(tbColor,true);

		Button btnApply = new Button(app.guisystem, "Apply", Vector2f(5,185));
		btnApply.id = "btnApply";
		btnApply.value = "Apply";
		btnApply.events["click"] = (e){
			applyPropertyBox();
		};
		propertyBox.addChild(btnApply,true);

		buildPropertyBoxForm();

	}

	void buildPropertyBoxForm(){
		formPropertyPanel = new Widget(app.guisystem);
		formPropertyPanel.id = "panelWidget";
		formPropertyPanel.position = Vector2f(5,215);
		formPropertyPanel.size = Vector2f(290,140);

		ListBox lbSection = new ListBox(app.guisystem, "lbSection", Vector2f(5,5), Vector2f(200,200));
		lbSection.id = "lbSection";
		formPropertyPanel.addChild(lbSection);

	}
	

	Widget addWidgetToFormTarget(Widget target, string type, Vector2i location){	
		Widget retval;
		void delegate(Event e) cageClick = (e){
			import std.format;
			auto point = Vector2i(e.mouseButton.x, e.mouseButton.y);
			auto cage = app.guisystem.contains(point);
			if(cage !is null){
				propertyBoxTarget = cage;
				if(cage.children.length > 0){
					auto child = cage.children[0];
					propertyBox.getChild("tbID").value =  		child.id;
					propertyBox.getChild("tbLabel").value = 	child.label;
					propertyBox.getChild("tbValue").value = 	child.value;
					propertyBox.getChild("tbType").value =  	child.m_type;
					propertyBox.getChild("tbChecked").value = 	(child.checked ? "true" : "false");
					propertyBox.getChild("tbPosition").value = 	format("%.0f,%.0f",cage.position.x, cage.position.y);
					propertyBox.getChild("tbSize").value = 		format("%.0f,%.0f",child.size.x, child.size.y);
					propertyBox.getChild("tbColor").value = 	format("#%x%x%x%x", child.color.r, child.color.g, child.color.b, child.color.a);
				}
			}
			writeln("\t cagePoint:" , point);
		};
		if(selection.length > 0){
			Vector2i targetpos = target.getReleativePosition(location);
			Vector2f cagepos = Vector2f(targetpos);
			auto cage = new gui.cage.Cage(app.guisystem,"cage", cagepos, Vector2f(100,30));
			cage.label = "Cage";
			cage.events["click"] = cageClick;
			switch (type) {
				case "Button": 
					auto button = new gui.button.Button(app.guisystem);
					cage.addChild(button);	
					break;
				case "Label":
					auto label = new gui.label.Label(app.guisystem, "Label");
					cage.addChild(label);
					break;
				case "Textbox":
					auto textbox = new gui.textbox.TextBox(app.guisystem, "tbTextbox", Vector2f(0,0), Vector2f(100,20));
					cage.addChild(textbox);
					break;
				case "TextBlock":
					auto textblock = new gui.textblock.TextBlock(app.guisystem, "tbTextblock", "tbTextBlockID", Vector2f(0,0), Vector2f(100,20));
					cage.addChild(textblock);
					break;
				case "Checkbox":
					auto checkbox = new gui.checkbox.CheckBox(app.guisystem);
					cage.addChild(checkbox);
					break;
				case "Listbox":
					auto listbox = new gui.listbox.ListBox(app.guisystem);
					cage.size = Vector2f(100, 100);
					cage.addChild(listbox);
					break;
				case "Spinner":
					auto spinner = new gui.spinner.Spinner(app.guisystem);
					cage.addChild(spinner);
					break;
				case "Slider":
					break;
				case "Toggle":
					auto toggle = new gui.togglebutton.ToggleButton(app.guisystem);
					cage.addChild(toggle);
					break;
				default:
					writeln("attempeted to add empty cage");
					break;
			}

			if(cage.children.length > 0){
				cage.edit = true;
				cage.updateSize();
				retval = cage;
				target.addChild(cage);
			}

			//clears selection and guiToolbox Toggles
			selection = "";
			foreach(ref btn ; toolBox.children){
				btn.value = "false";
			}
		//add widgets based on selection and mode here 
		} else {
			propertyBoxTarget = target;
		}
		return retval;
	}

	void buildToolBox(){
		auto guiToolbox = new gui.window.Window(app.guisystem);
		guiToolbox.label = "Toolbox";
		guiToolbox.size = Vector2f(100, 400);
		guiToolbox.position = Vector2f(0, 0);
		toolBox = guiToolbox;

		Vector2f buttonPos = Vector2f(5, 25);
		static foreach(btn ; ["Label", "Textbox", "Checkbox", "Listbox", "Spinner", "Slider", "Toggle","TextBlock"]){
			mixin(buttonMixin!(btn));
			buttonPos += Vector2f(0, 35);
		}
		//TODO! --- move to seperate buildGuiFunction

		auto form = new Form(app.guisystem,"Form", Vector2f(110,40),Vector2f(640,480));
		formTarget = form;
		form.events["click"] = (Event e){
			Vector2i point = Vector2i(e.mouseButton.x, e.mouseButton.y);
			if(mode == "edit"){
				propertyBoxTarget = addWidgetToFormTarget(form, selection, point);
			} else {
				propertyBoxTarget = formTarget;
			}

		};
		app.guisystem.addChild(form);

		auto editToggle = new gui.togglebutton.ToggleButton(app.guisystem);
		editToggle.id = "editToggle";
		editToggle.label = "Edit";
		editToggle.position = Vector2f(110, 5);
		editToggle.size = Vector2f(50, 30);
		editToggle.events["click"] = (Event e){
			writeln("editToggle: ", editToggle.checked);
			if(!editToggle.checked){
				app.mode = "edit";
				foreach(ref section ; form.children){
					writeln(section.id, ": ", section.label);
					if(section.m_type == "section"){
						foreach(ref child ; form.children){
							writeln("\t",child.id, ": ", child.label);
							if(child.m_type == "cage"){
								gui.cage.Cage cage = cast(gui.cage.Cage)child;
								cage.edit = true;
							}
						}
					}
				}
			} else {
				app.mode = "view";
				foreach(ref section ; form.children){
					writeln(section.id, ": ", section.label);
					if(section.m_type == "section"){
						foreach(ref child ; form.children){
							writeln("\t",child.id, ": ", child.label);
							if(child.m_type == "cage"){
								gui.cage.Cage cage = cast(gui.cage.Cage)child;
								cage.edit = false;
							}
						}
					}
				}
			}	
		};
		app.guisystem.addChild(editToggle);
	}

	void buildFormSelection() {
		formSelection = new gui.window.Window(app.guisystem, "Form Selection", Vector2f(0,0), Vector2f(200,450));

		auto tbFormName = new TextBox(app.guisystem, "tbFormName", Vector2f(5,20), Vector2f(135,20));
		tbFormName.value = "Form Name";
		formSelection.addChild(tbFormName);

		auto btnCreateForm = new Button(app.guisystem, "btnCreateForm", Vector2f(145,20), Vector2f(50,20));
		btnCreateForm.value = "Create";
		formSelection.addChild(btnCreateForm);

		auto lbForms = new ListBox(app.guisystem, "Forms", Vector2f(5,45), Vector2f(190,150));
		formSelection.addChild(lbForms);

		btnCreateForm.events["click"] = (Event e) {
			writeln("create form");
			//finalize and cleanup previous form target
			if(formTarget !is null){
				//TODO: formTarget.cleanup();
				//TODO: validate if a form can be changed yet ie needs to be saved xyz needs to be aproved ect...
			}

			auto form = new Form(app.guisystem, tbFormName.value, Vector2f(210,40), Vector2f(640,480));
			formTarget = form;

			lbForms.addItem(tbFormName.value, "frmDefault");
			form.id = tbFormName.value;
			form.events["click"] = (Event e){
				writeln("form clicked");
				Vector2i point = Vector2i(e.mouseButton.x, e.mouseButton.y);
				if(mode != "edit"){
					propertyBoxTarget = form;
				}
			};

			app.guisystem.addChild(formTarget);
		};

		Label lblSection = new Label(app.guisystem, "Section","lblSection", Vector2f(5,200));
		formSelection.addChild(lblSection);

		auto tbSectionName = new TextBox(app.guisystem, "tbSectionName", Vector2f(5,225), Vector2f(190,20));
		formSelection.addChild(tbSectionName);

		auto lbSections = new ListBox(app.guisystem, "Sections", Vector2f(5,250), Vector2f(190,150));
		formSelection.addChild(lbSections);

		auto btnAddSection = new Button(app.guisystem, "btnAddSection", Vector2f(5,405), Vector2f(50,20));
		btnAddSection.value = "Add";
		formSelection.addChild(btnAddSection);

		btnAddSection.events["click"] = (Event e) {
			writeln("add section");
			if(formTarget !is null){
				auto section = new Section(app.guisystem, tbSectionName.value, Vector2f(5,25), Vector2f(630,300));
				section.id = tbSectionName.value;
				section.events["click"] = (Event e){
					writeln("section clicked");
					Vector2i point = Vector2i(e.mouseButton.x, e.mouseButton.y);
					if(mode == "edit"){
						propertyBoxTarget = addWidgetToFormTarget(section, selection, point);
					} else {
						propertyBoxTarget = section;
					}
				};

				formTarget.addChild(section);
				lbSections.addItem(tbSectionName.value, "secDefault");

				int top = 25;
				int bottom = 0;
				import std.conv;
				foreach(w ; formTarget.children){
					if(w.m_type == "section"){
						w.position = Vector2f(5, top);
						bottom = top +  w.size.y.to!int + 10;
						top = bottom;
					}
				}
				formTarget.size = Vector2f(formTarget.size.x, bottom-5);
			}
		};

		auto btnEditSection = new Button(app.guisystem, "btnEditSection", Vector2f(95,405), Vector2f(100,20));
		btnEditSection.value = "Create/Edit";

		btnEditSection.events["click"] = (Event e) {
			writeln("edit section");
			//create section
		};
		
		formSelection.addChild(btnEditSection);
		
	}

	void buildNarrativeEditor() {
		narrativeEditor = new gui.window.Window(app.guisystem, "Narrative Editor", Vector2f(0,0), Vector2f(200,450));

		auto tbSectionName = new TextBox(app.guisystem, "tbSectionName", Vector2f(5,225), Vector2f(190,20));
		narrativeEditor.addChild(tbSectionName);

		auto lbSections = new ListBox(app.guisystem, "Sections", Vector2f(5,250), Vector2f(190,150));
		narrativeEditor.addChild(lbSections);

		auto btnAddSection = new Button(app.guisystem, "btnAddSection", Vector2f(5,405), Vector2f(50,20));
		btnAddSection.value = "Add";
		narrativeEditor.addChild(btnAddSection);

		auto btnEditSection = new Button(app.guisystem, "btnEditSection", Vector2f(95,405), Vector2f(100,20));
		btnEditSection.value = "Create/Edit";
		btnEditSection.events["click"] = (Event e) {	
			writeln("edit section");
			//create section
		};
		
		narrativeEditor.addChild(btnEditSection);
	}

	

}