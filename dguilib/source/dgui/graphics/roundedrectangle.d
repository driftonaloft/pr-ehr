module dgui.graphics.roundedrectangle;

import nudsfml.graphics.shape;
import nudsfml.graphics;
import std.math;

class RoundedRectangle: Shape {
    Vector2f m_size;
    float m_radius;
    uint m_cornerCount;
    ubyte m_cornerMask;
    bool topRight = true;
    bool topLeft = true;
    bool bottomLeft = true;
    bool bottomRight = true;

    @property { //size 
        Vector2f size(Vector2f s){
            m_size = s;
            update();
            return m_size;
        }
        Vector2f size(){
            return m_size;
        }
    }

    @property { // radius
        float radius(float r){
            m_radius = r;
            update();
            return m_radius;
        }
        float radius(){
            return m_radius;
        }
    }

    @property { // cornerCount
        uint cornerCount(uint cpc){
            m_cornerCount = cpc;
            update();
            return m_cornerCount * 4;
        }
        uint cornerCount(){
            return m_cornerCount * 4;
        }
    }

    @property{
		override uint pointCount() const {
			return getPointCount();
		}
	}

    this(Vector2f size = Vector2f(0, 0), float radius = 5, uint cornerPointCount = 5 ){
        m_size = size;
        m_radius = radius;
        m_cornerCount = cornerPointCount;
        update();
    }

    uint getPointCount() const{
        return m_cornerCount * 4;
    }

    override Vector2f getPoint(uint index) const {
        if(index >= m_cornerCount * 4){
            return Vector2f(0,0);
        }

        float deltaAngle = 90.0f / (m_cornerCount - 1);
        Vector2f center=Vector2f(0, 0);
        uint centerIndex = index / m_cornerCount;
        static const float pi = 3.14159654f;

        float tempRadius = 0;
        final switch(centerIndex){
            case 0: 
                tempRadius = topRight * m_radius;
                center.x = m_size.x - tempRadius; center.y = tempRadius; 
                break;
            case 1: 
                tempRadius = topLeft * m_radius;
                center.x = tempRadius; center.y = tempRadius; 
                break;
            case 2: 
                tempRadius = bottomLeft * m_radius;
                center.x = tempRadius; center.y = m_size.y - tempRadius; 
                break;
            case 3: 
                tempRadius = bottomRight * m_radius;
                center.x = m_size.x - tempRadius; center.y = m_size.y - tempRadius; 
                break;
        }

        return Vector2f(tempRadius * cos(deltaAngle * (index - centerIndex) * pi / 180) + center.x,
                       -tempRadius * sin(deltaAngle * (index - centerIndex) * pi / 180) + center.y);
    }
}