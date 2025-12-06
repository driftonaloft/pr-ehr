module nudsfml.graphics.transform;

import bindbc.sfml.graphics;
import bindbc.sfml.system;

import nudsfml.system.vector2;
import nudsfml.graphics.rect;


/**
 * Define a 3x3 transform matrix.
 */
struct Transform {
	/// 4x4 matrix defining the transformation.
	package float[16] m_matrix = [1.0f, 0.0f, 0.0f, 0.0f,
						  		  0.0f, 1.0f, 0.0f, 0.0f,
						  		  0.0f, 0.0f, 1.0f, 0.0f,
						  		  0.0f, 0.0f, 0.0f, 1.0f];

	/**
	 * Construct a transform from a 3x3 matrix.
	 *
	 * Params:
	 * 		a00	= Element (0, 0) of the matrix
	 * 		a01	= Element (0, 1) of the matrix
	 * 		a02	= Element (0, 2) of the matrix
	 * 		a10	= Element (1, 0) of the matrix
	 * 		a11	= Element (1, 1) of the matrix
	 * 		a12	= Element (1, 2) of the matrix
	 * 		a20	= Element (2, 0) of the matrix
	 * 		a21	= Element (2, 1) of the matrix
	 * 		a22	= Element (2, 2) of the matrix
	 */
	this(float a00, float a01, float a02, float a10, float a11, float a12, float a20, float a21, float a22) {
		m_matrix = [ a00,  a10, 0.0f,  a20,
    			     a01,  a11, 0.0f,  a21,
    				0.0f, 0.0f, 1.0f, 0.0f,
    				 a02,  a12, 0.0f,  a22];
	}

	/// Construct a transform from a float array describing a 3x3 matrix.
	this(float[9] matrix) {
		m_matrix = [matrix[0], matrix[3], 0.0f, matrix[6],
    			    matrix[1], matrix[4], 0.0f, matrix[7],
    				     0.0f,      0.0f, 1.0f,      0.0f,
    				matrix[2], matrix[5], 0.0f, matrix[8]];
	}

	/**
	 * Return the inverse of the transform.
	 *
	 * If the inverse cannot be computed, an identity transform is returned.
	 *
	 * Returns: A new transform which is the inverse of self.
	 */
	Transform getInverse() const {
		sfTransform matrix ;
		matrix.matrix = [m_matrix[0], m_matrix[1], m_matrix[3],
								m_matrix[4], m_matrix[5], m_matrix[7],
								m_matrix[12], m_matrix[13], m_matrix[15]];
		auto temp = sfTransform_getInverse(&matrix );
		return Transform(temp.matrix);
	}

	/**
	 * Return the transform as a 4x4 matrix.
	 *
	 * This function returns a pointer to an array of 16 floats containing the
	 * transform elements as a 4x4 matrix, which is directly compatible with
	 * OpenGL functions.
	 *
	 * Returns: A 4x4 matrix.
	 */
	const(float)[] getMatrix() const {
		return m_matrix;
	}

	/**
	 * Combine the current transform with another one.
	 *
	 * The result is a transform that is equivalent to applying this followed by
	 * transform. Mathematically, it is equivalent to a matrix multiplication.
	 *
	 * Params:
	 * 		otherTransform	= Transform to combine with this one
	 *
	 * Returns: Reference to this.
	 */
	ref Transform combine(Transform otherTransform) {
		sfTransform thisTransform = getFromTransform(this);
		sfTransform other = getFromTransform(otherTransform);

		sfTransform_combine(&thisTransform, &other);
		m_matrix = get4x4FromTransform(thisTransform);
		return this;
	}

	/**
	 * Transform a 2D point.
	 *
	 * Params:
	 *		x 	= X coordinate of the point to transform
	 * 		y	= Y coordinate of the point to transform
	 *
	 * Returns: Transformed point.
	 */
	Vector2f transformPoint(float x, float y) const {
		Vector2f temp;
		sfVector2f p;
		p.x = x;
		p.y = y;
		auto m = getFromTransform(this);
		auto point = sfTransform_transformPoint(&m, p);
		temp.x = point.x;
		temp.y = point.y;
		return temp;
	}

	/**
	 * Transform a 2D point.
	 *
	 * Params:
	 *		point 	= the point to transform
	 *
	 * Returns: Transformed point.
	 */
	Vector2f transformPoint(Vector2f point) const {
		return transformPoint(point.x, point.y);
	}

	/**
	 * Transform a rectangle.
	 *
	 * Since SFML doesn't provide support for oriented rectangles, the result of
	 * this function is always an axis-aligned rectangle. Which means that if
	 * the transform contains a rotation, the bounding rectangle of the
	 * transformed rectangle is returned.
	 *
	 * Params:
	 * 		rect	= Rectangle to transform
	 *
	 * Returns: Transformed rectangle.
	 */
	FloatRect transformRect(const(FloatRect) rect)const {
		FloatRect temp;
		sfFloatRect sent;
		sent.height = rect.height;
		sent.left = rect.left;
		sent.top = rect.top;
		sent.width = rect.width;
		auto m = getFromTransform(this);
		auto retval = sfTransform_transformRect(&m,sent);
		temp.height = retval.height;
		temp.left = retval.left;
		temp.top = retval.top;
		temp.width = retval.width;
		return temp;
	}

	/**
	 * Combine the current transform with a translation.
	 *
	 * This function returns a reference to this, so that calls can be chained.
	 *
	 * Params:
	 * 		offset	= Translation offset to apply
	 *
	 * Returns: this
	 */
	ref Transform translate(Vector2f offset) {

		sfTransform m = getFromTransform(this);
		sfTransform_translate(&m, offset.x, offset.y);
		m_matrix = get4x4FromTransform(m);

		return this;
	}

	/**
	 * Combine the current transform with a translation.
	 *
	 * This function returns a reference to this, so that calls can be chained.
	 *
	 * Params:
	 * 		x	= Offset to apply on X axis
	 *		y	= Offset to apply on Y axis
	 *
	 * Returns: this
	 */
	ref Transform translate(float x, float y) {
		sfTransform m = getFromTransform(this);
		sfTransform_translate(&m, x, y);
		m_matrix = get4x4FromTransform(m);

		return this;
	}

	/**
	 * Combine the current transform with a rotation.
	 *
	 * This function returns a reference to this, so that calls can be chained.
	 *
	 * Params:
	 * 		angle	= Rotation angle, in degrees
	 *
	 * Returns: this
	 */
	ref Transform rotate(float angle) {

		sfTransform m = getFromTransform(this);
		sfTransform_rotate(&m, angle);
		m_matrix = get4x4FromTransform(m);
		return this;
	}

	/**
	 * Combine the current transform with a rotation.
	 *
	 * The center of rotation is provided for convenience as a second argument,
	 * so that you can build rotations around arbitrary points more easily (and
	 * efficiently) than the usual
	 * translate(-center).rotate(angle).translate(center).
	 *
	 * This function returns a reference to this, so that calls can be chained.
	 *
	 * Params:
	 * 		angle	= Rotation angle, in degrees
	 * 		centerX	= X coordinate of the center of rotation
	 *		centerY = Y coordinate of the center of rotation
	 *
	 * Returns: this
	 */
	ref Transform rotate(float angle, float centerX, float centerY) {
		sfTransform m = getFromTransform(this);
		sfTransform_rotateWithCenter(&m, angle, centerX, centerY);
		m_matrix = get4x4FromTransform(m);
		return this;
	}

	/**
	 * Combine the current transform with a rotation.
	 *
	 * The center of rotation is provided for convenience as a second argument,
	 * so that you can build rotations around arbitrary points more easily (and
	 * efficiently) than the usual
	 * translate(-center).rotate(angle).translate(center).
	 *
	 * This function returns a reference to this, so that calls can be chained.
	 *
	 * Params:
	 * 		angle	= Rotation angle, in degrees
	 * 		center	= Center of rotation
	 *
	 * Returns: this
	 */
	ref Transform rotate(float angle, Vector2f center) {
		sfTransform m = getFromTransform(this);
		sfTransform_rotateWithCenter(&m, angle, center.x, center.y);
		m_matrix = get4x4FromTransform(m);
		return this;
	}

	/**
	 * Combine the current transform with a scaling.
	 *
	 * This function returns a reference to this, so that calls can be chained.
	 *
	 * Params:
	 * 		scaleX	= Scaling factor on the X-axis.
	 * 		scaleY	= Scaling factor on the Y-axis.
	 *
	 * Returns: this
	 */
	ref Transform scale(float scaleX, float scaleY) {
		sfTransform m = getFromTransform(this);
		sfTransform_scale(&m, scaleX, scaleY);
		m_matrix = get4x4FromTransform(m);

		return this;
	}

	/**
	 * Combine the current transform with a scaling.
	 *
	 * This function returns a reference to this, so that calls can be chained.
	 *
	 * Params:
	 * 		factors	= Scaling factors
	 *
	 * Returns: this
	 */
	ref Transform scale(Vector2f factors) {
		sfTransform m = getFromTransform(this);
		sfTransform_scale(&m, factors.x, factors.y);
		m_matrix = get4x4FromTransform(m);

		return this;
	}

	/**
	 * Combine the current transform with a scaling.
	 *
	 * The center of scaling is provided for convenience as a second argument,
	 * so that you can build scaling around arbitrary points more easily
	 * (and efficiently) than the usual
	 * translate(-center).scale(factors).translate(center).
	 *
	 * This function returns a reference to this, so that calls can be chained.
	 *
	 * Params:
	 * 		scaleX	= Scaling factor on the X-axis
	 * 		scaleY	= Scaling factor on the Y-axis
	 * 		centerX	= X coordinate of the center of scaling
	 * 		centerY	= Y coordinate of the center of scaling
	 *
	 * Returns: this
	 */
	ref Transform scale(float scaleX, float scaleY, float centerX, float centerY) {

		sfTransform m = getFromTransform(this);
		sfTransform_scaleWithCenter(&m, scaleX, scaleY, centerX, centerY);
		m_matrix = get4x4FromTransform(m);

		return this;
	}

	/**
	 * Combine the current transform with a scaling.
	 *
	 * The center of scaling is provided for convenience as a second argument,
	 * so that you can build scaling around arbitrary points more easily
	 * (and efficiently) than the usual
	 * translate(-center).scale(factors).translate(center).
	 *
	 * This function returns a reference to this, so that calls can be chained.
	 *
	 * Params:
	 * 		factors	= Scaling factors
	 * 		center	= Center of scaling
	 *
	 * Returns: this
	 */
	ref Transform scale(Vector2f factors, Vector2f center) {
		sfTransform m = getFromTransform(this);
		sfTransform_scaleWithCenter(&m, factors.x, factors.y, center.x, center.y);		
		m_matrix = get4x4FromTransform(m);

		return this;
	}

	string toString() const {
		return "";//text(InternalsfTransform.matrix);
	}

	/**
	 * Overload of binary operator `*` to combine two transforms.
	 *
	 * This call is equivalent to:
	 * ---
	 * Transform combined = transform;
	 * combined.combine(rhs);
	 * ---
	 *
	 * Params:
	 * rhs = the second transform to be combined with the first
	 *
	 * Returns: New combined transform.
	 */
	Transform opBinary(string op)(Transform rhs)
		if(op == "*")
	{
		Transform temp = this;
		return temp.combine(rhs);
	}

	/**
	 * Overload of assignment operator `*=` to combine two transforms.
	 *
	 * This call is equivalent to calling `transform.combine(rhs)`.
	 *
	 * Params:
	 * rhs = the second transform to be combined with the first
	 *
	 * Returns: The combined transform.
	 */
	ref Transform opOpAssign(string op)(Transform rhs)
		if(op == "*")
	{
		return this.combine(rhs);
	}

	/**
	* Overload of binary operator * to transform a point
	*
	* This call is equivalent to calling `transform.transformPoint(vector)`.
	*
	* Params:
	* vector = the point to transform
	*
	* Returns: New transformed point.
	*/
	Vextor2f opBinary(string op)(Vector2f vector)
		if(op == "*")
	{
		return transformPoint(vector);
	}

	/// Indentity transform (does nothing).
	static const(Transform) Identity;
}




sfTransform getFromTransform ( Transform t ) {
	sfTransform matrix ;
	matrix.matrix = [t.m_matrix[0], t.m_matrix[1], t.m_matrix[3],
					t.m_matrix[4], t.m_matrix[5], t.m_matrix[7],
					t.m_matrix[12], t.m_matrix[13], t.m_matrix[15]];
	
	return matrix;
}

float [16] get4x4FromTransform ( sfTransform t ) {

	return  [t.matrix[0], t.matrix[3], 0.0f, t.matrix[6],
        	t.matrix[1], t.matrix[4], 0.0f, t.matrix[7],
         	0.0f,      0.0f, 1.0f,      0.0f,
    		t.matrix[2], t.matrix[5], 0.0f, t.matrix[8]];
}