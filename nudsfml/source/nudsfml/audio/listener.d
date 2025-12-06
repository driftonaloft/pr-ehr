module nudsfml.audio.listener;

import bindbc.sfml.audio;
import bindbc.sfml.system;

import nudsfml.system.vector3;

//////////////////////////////////////////////////////////////////////////
/// \breif Class for controling global audio state
//////////////////////////////////////////////////////////////////////////

class Listener {
    this(){

    }

    @property { // globalVolume
        void globalVolume(float volume){
            return sfListener_setGlobalVolume(volume);
        }
        float globalVolume(){
            return sfListener_getGlobalVolume();
        }
    }

    @property { // position
        void position(Vector3f pos) {
            sfListener_setPosition(cast(sfVector3f)pos);
        }
        Vector3f position() {
            Vector3f pos = cast(Vector3f) sfListener_getPosition();
            return pos;
        }
    }

    @property { //direction
        void direction(Vector3f dir){
            sfListener_setDirection(cast(sfVector3f) dir);
        }
        Vector3f direction(){
            Vector3f dir = cast(Vector3f) sfListener_getDirection();
            return dir;
        }
    }

    @property { //upVector
        void upVector(Vector3f vec){
            sfListener_setUpVector(cast(sfVector3f) vec);
        }
        Vector3f upVector() {
            return cast(Vector3f) sfListener_getUpVector();
        }
    }
}
