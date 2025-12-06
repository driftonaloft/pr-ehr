module nudsfml.system.vector3;

import std.traits;

/**
 * Utility template struct for manipulating 3-dimensional vectors.
 */
struct Vector3(T)
	if(isNumeric!(T) || is(T == bool))
{
	/// X coordinate of the vector.
	T x;

	/// Y coordinate of the vector.
	T y;

	/// Z coordinate of the vector.
	T z;

	/**
	 * Construct the vector from its coordinates
	 *
	 * Params:
	 * 		X = X coordinate
	 * 		Y = Y coordinate
	 * 		Z = Z coordinate
	 */
	this(T X,T Y,T Z)
	{

		x = X;
		y = Y;
		z = Z;

	}

	/**
	 * Construct the vector from another type of vector
	 *
	 * Params:
	 * 	otherVector = Vector to convert.
	 */
	this(E)(Vector3!(E) otherVector)
	{
		x = cast(T)(otherVector.x);
		y = cast(T)(otherVector.y);
		z = cast(T)(otherVector.z);
	}

	/// Invert the members of the vector.
	Vector3!(T) opUnary(string s)() const
	if(s == "-")
	{
		return Vector3!(T)(-x,-y,-z);
	}

	/// Add/Subtract between two vector3's.
	Vector3!(T) opBinary(string op,E)(Vector3!(E) otherVector) const
	if(isNumeric!(E) && ((op == "+") || (op == "-")))
	{
		static if (op == "+")
		{
			return Vector3!(T)(cast(T)(x+otherVector.x),cast(T)(y+otherVector.y),cast(T)(z + otherVector.z));
		}
		static if(op == "-")
		{
			return Vector3!(T)(cast(T)(x-otherVector.x),cast(T)(y-otherVector.y),cast(T)(z - otherVector.z));
		}
	}

	/// Multiply/Divide a Vector3 with a numaric value.
	Vector3!(T) opBinary(string op,E)(E num) const
	if(isNumeric!(E) && ((op == "*") || (op == "/")))
	{
		static if (op == "*")
		{
			return Vector3!(T)(cast(T)(x*num),cast(T)(y*num),cast(T)(z*num));
		}
		static if(op == "/")
		{
			return Vector3!(T)(cast(T)(x/num),cast(T)(y/num),cast(T)(z/num));
		}
	}

	/// Assign Add/Subtract with another vector3.
	ref Vector3!(T) opOpAssign(string op, E)(Vector3!(E) otherVector)
	if(isNumeric!(E) && ((op == "+") || (op == "-")))
	{
		static if(op == "+")
		{
			x += otherVector.x;
			y += otherVector.y;
			z += otherVector.z;
			return this;
		}
		static if(op == "-")
		{
			x -= otherVector.x;
			y -= otherVector.y;
			z -= otherVector.z;
			return this;
		}
	}

	// Assign Multiply/Divide a Vector3 with a numaric value.
	ref Vector3!(T) opOpAssign(string op,E)(E num)
	if(isNumeric!(E) && ((op == "*") || (op == "/")))
	{
		static if(op == "*")
		{
			x *= num;
			y *= num;
			z *= num;
			return this;
		}
		static if(op == "/")
		{
			x /= num;
			y /= num;
			z /= num;
			return this;
		}
	}

	/// Assign the value of another vector whose type can be converted to T.
	ref Vector3!(T) opAssign(E)(Vector3!(E) otherVector)
	{
		x = cast(T)(otherVector.x);
		y = cast(T)(otherVector.y);
		z = cast(T)(otherVector.z);
		return this;
	}

	/// Compare two vectors for equality.
	bool opEquals(E)(const Vector3!(E) otherVector) const
	if(isNumeric!(E))
	{
		return ((x == otherVector.x) && (y == otherVector.y)
				&& (z == otherVector.z));
	}

	/// Output the string representation of the Vector3.
	string toString() const
	{
		import std.conv;
		return "X: " ~ text(x) ~ " Y: " ~ text(y) ~ " Z: " ~ text(z);
	}
}

/// Definition of a Vector3 of integers.
alias Vector3i = Vector3!(int);

/// Definition of a Vector3 of floats.
alias Vector3f = Vector3!(float);