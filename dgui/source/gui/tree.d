module gui.tree;

import gui;
import gfx.roundedrectangle;
import std.stdio;
import nudsfml.graphics;

class TreeNode {
    string id;
    string label;
    string value;
    string indicator;
    bool selected;
    bool open;
    //parent 

	Tree parentTree;

    TreeNode[] children;
    this(){}

    this(Tree parentTree, string id, string label, string value, string idicator, bool selected = false, bool open = false){
		this.parentTree = parentTree;
        this.id = id;
        this.label = label;
        this.value = value;
        this.indicator = indicator;
        this.selected = selected;
        this.open = open;
    }

    TreeNode addNode(string id, string label, string value, string idicator, bool selected = false, bool open = false, bool rebuildTreeIndex = true){
        TreeNode child = new TreeNode(parentTree, id, label,value,indicator, selected, open);
        children ~= child;

        if(rebuildTreeIndex){ 
            parentTree.buildTreeIndex(parentTree.treeIndex, children); 
        }

        //child.parent = this;
        return child;
    }

    int getChildCountOpen(){
        
        //parentTree.buildTreeIndex(parentTree.treeIndex, children);
        int count;
        foreach(c; children){
            count ++;
            count += c.getChildCountOpen();
        }
        return count;
    } 
}

class Tree : Widget {
    TreeNode [] nodes;
    TreeNode selected;

    int offset;
    int index;
	bool multiSelect = false;
     int maxVisibleIndexes;

    Text labelText;
    Text nodeText;

    RoundedRectangle base;
    RoundedRectangle scrollCursor;
    RoundedRectangle scrollBar;

	TreeNode [] treeIndex;


    @property { 
        override string label(string l){
            m_label = l;
            labelText.string =  (l);
            return m_label;
        }
        override string label() {
            return m_label;
        }
    } alias label = Widget.label;

    @property {
        override Vector2f size(Vector2f s){
            m_size = s;
            updateSize();
            return m_size;
        }

        override Vector2f size(){
            return m_size;
        }
    } alias size = Widget.size;

    this(Gui gui_,string label_ = "TreeBox", Vector2f pos_ = Vector2f(0,0), Vector2f size_ = Vector2f(100,200)) {
        super(gui_);
        m_type = "tree";

        labelText = new Text();
        labelText.setFont(gui.fonts["default"]);
        labelText.setCharacterSize(16);
        labelText.fillColor = (gui.theme["text"]);

        nodeText = new Text();
        nodeText.setFont(gui.fonts["default"]);
        nodeText.setCharacterSize(13);
        nodeText.fillColor = (gui.theme["text"]);

        base = new RoundedRectangle();
        base.fillColor = Color(60,60,60); // replace with gui.themeColors["fieldBackground"];
        base.outlineColor = Color(140,140,140); // replace with gui.themeColors["fieldOutline"];
        base.outlineThickness = 1;

        scrollCursor = new RoundedRectangle();
        scrollCursor.fillColor = Color(128,128,255); // gui.themeColors["scrollCursor"];
        scrollCursor.outlineColor = Color(100,100,200); //gui.themeColors["scrollCursorOutline"];
        scrollCursor.outlineThickness = 1;

        scrollBar = new RoundedRectangle();
        scrollBar.fillColor = Color(100,100,100); //gui.themeColors["scrollBar"];

        label  = label_;
        position = pos_;
        size = size_;

        index = -1;
    }

    void updateSize() {
        base.size = Vector2f(m_size.x, m_size.y - 20);
        scrollBar.size = Vector2f(12, m_size.y-26);
        maxVisibleIndexes = (cast(int)base.size.y) / 14;
    }

    TreeNode addNode(string id, string label, string value, string indicator, bool selected = false, bool open = false, bool rebuildTreeIndex = true){
        TreeNode child = new TreeNode(this, id, label,value,indicator, selected, open);
        nodes ~= child;

        if(rebuildTreeIndex){
            buildTreeIndex(treeIndex, nodes);
        }
        
        return child;
    }

    //TreeNode getChildIndex(int index);

    int getChildCountOpen(){
        int count;
        foreach(c; nodes){
            count ++;
            count += c.getChildCountOpen();
        }
        return count;
    } 

    override void onScrollWheel(Event e) {
        int delta = e.mouseWheel.delta;
        offset += delta;

        auto childCount = getChildCountOpen();
        if( offset > childCount){
            offset = childCount;
        } 
        if( offset < 0){
            offset = 0;
        }

        super.onScrollWheel(e);
    }



	int buildTreeIndex(ref TreeNode[] dest, TreeNode[] src, int count = 0 ){
		foreach(ref node ; src){
			dest ~= node;
			count++;
			if(node.open && node.children.length > 0){
				count = buildTreeIndex(dest, node.children, count);
			}
		}
		return count;
	}

	TreeNode getNodeIndex(int index){
		if(index >= 0 && index < treeIndex.length){
			return treeIndex[index];
		}
		return null;
	}

	void clearSelected(){
		foreach(node; nodes){
			node.selected = false;
		}
	}

    override void onClick(Event e){
        Vector2i mousePosition = Vector2i(e.mouseButton.x, e.mouseButton.y);
        auto relativePosition = getReleativePosition(mousePosition);

        Vector2i sizeInt = Vector2i(size);
        int nodeCount = getChildCountOpen();

        int indexHeight = 14;

        IntRect labelRect = IntRect(0, 0, sizeInt.x, 20);
        IntRect treeRect = IntRect(0, 20, sizeInt.x, sizeInt.y - 20);
        IntRect scrollBar = IntRect(sizeInt.x - 16, 20, 16, sizeInt.y-20);

        int scrollBarRatio = 32; // maxVisibleIndexes / getChildCountOpen()
        int scrollBarSize = 0;
        if(nodeCount > maxVisibleIndexes){ 
            scrollBarSize = ((sizeInt.y - 20) * maxVisibleIndexes ) / nodeCount;
        }
        
        IntRect scrollCursor = IntRect(sizeInt.x - 16, 20, 16, scrollBarSize < 16 ? 16 : scrollBarSize );

        if(labelRect.contains(relativePosition)) {
            index = -1;
        }

        if(treeRect.contains(relativePosition)){
            if (nodeCount <= maxVisibleIndexes){
                if(scrollBar.contains(relativePosition)){             
		            if(relativePosition.y < scrollBar.top + scrollBar.height/2){
                        if(offset--  < 0) offset = 0;
                    } else if (relativePosition.y >= scrollBar.top + scrollBar.height/2){
                        if(offset++ > nodeCount - maxVisibleIndexes ) offset = nodeCount - maxVisibleIndexes;
                    }
                } else {
					int y = relativePosition.y - treeRect.top;
					int visableIndex = y / indexHeight; 

					int tempIndex = visableIndex + offset;
                    writeln("Tree : tempIndex ", tempIndex);

					if( tempIndex >= 0 && tempIndex < treeIndex.length) {
						auto node = getNodeIndex(tempIndex);
                        writeln("\tnode{id: ", node.id , ", label: ", node.label, ", value: ", node.value, " }");

						if(!multiSelect) clearSelected();
						
                        node.selected = true;
						node.open = !node.open; // ? false : true ;
						if(node.children.length > 0) {
							buildTreeIndex(treeIndex, nodes);
						}
					}
				}
            }
        }
    }

    int drawNodes(RenderTarget target, Vector2f drawpos, TreeNode [] dnodes,int indexOffset = 0, int depth = 0, int count = 0) {
        Vector2f offset = Vector2f(16,14);
        foreach ( n ; dnodes) {
            if(count - indexOffset > maxVisibleIndexes) {
                break;
            }
            auto currentDrawPos = drawpos + Vector2f(offset.x * depth , offset.y * count);
            count++;

            nodeText.string = (n.label);
            nodeText.position = currentDrawPos;
            target.draw(nodeText);
            
            if(n.open && n.children.length > 0) {
                count = drawNodes(target, drawpos, n.children, indexOffset, depth + 1, count);
            }
        }
        return count;
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        Vector2f drawpos  = position + offset;

        labelText.position = drawpos;
        base.position = drawpos + Vector2f(0,20);

        target.draw(labelText);
        target.draw(base);

        int count = drawNodes(target, drawpos + Vector2f(0,20), nodes);

    }
}
