module nudsfml.window.clipboard;

import bindbc.sfml.window;

import std.string;
import std.conv;

/** 
 *  Class For setting a retriving text from the clipboard
 */
class Clipboard {
    /**
    * Retrieves the current string from the systems clipboard
    * Params:
    * Returns: a string containings the current contents of the the systems clipboard
    *       
    */
    static string getString(){
        char* value = cast(char*)sfClipboard_getString();
        string retval = value.fromStringz().to!string();
        return retval;
    }

    /**
    * sets the provided string to the systems clipboard
    * Params:
    *   value       = the value being copied to the systems clipboard
    * Returns: 
    *       
    */
    static void setString(string value){
        sfClipboard_setString(value.toStringz);
    }
}