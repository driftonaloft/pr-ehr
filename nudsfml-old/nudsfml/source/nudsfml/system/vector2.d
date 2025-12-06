module nudsfml.system.vector2;

import std.traits;

/**
 * Utility template struct for manipulating 2-dimensional vectors.
 */
struct Vector2(T)
	if(isNumeric!(T) || is(T == bool))
{
	/// X coordinate of the vector.
	T x = 0;

	/// Y coordinate of the vector.
	T y = 0;

	/**
	 * Construct the vector from its coordinates.
	 *
	 * Params:
	 * 		X = X coordinate
	 * 		Y = Y coordinate
	 */
	this(T X,T Y)
	{
		x = X;
		y = Y;
	}

	/**
	 * Construct the vector from another type of vector.
	 *
	 * Params:
	 * 	otherVector = Vector to convert
	 */
	this(E)(Vector2!(E) otherVector)
	{
		x = cast(T)(otherVector.x);
		y = cast(T)(otherVector.y);
	}

	/// Invert the members of the vector.
	Vector2!(T) opUnary(string s)() const
	if (s == "-")
	{
		return Vector2!(T)(-x, -y);
	}

	/// Add/Subtract between two vector2's.
	Vector2!(T) opBinary(string op, E)(Vector2!(E) otherVector) const
	if(isNumeric!(E) && ((op == "+") || (op == "-")))
	{
		static if (op == "+")
		{
			return Vector2!(T)(cast(T)(x+otherVector.x),cast(T)(y+otherVector.y));
		}
		static if(op == "-")
		{
			return Vector2!(T)(cast(T)(x-otherVector.x),cast(T)(y-otherVector.y));
		}
	}

	/// Multiply/Divide a vector with a numaric value.
	Vector2!(T) opBinary (string op, E)(E num) const
	if(isNumeric!(E) && ((op == "*") || (op == "/")))
	{
		static if (op == "*")
		{
			return Vector2!(T)(cast(T)(x*num),cast(T)(y*num));
		}
		static if(op == "/")
		{
			return Vector2!(T)(cast(T)(x/num),cast(T)(y/num));
		}
	}

	/// Assign Add/Subtract with another vector2.
	ref Vector2!(T) opOpAssign(string op, E)(Vector2!(E) otherVector)
	if(isNumeric!(E) && ((op == "+") || (op == "-")))
	{
		static if(op == "+")
		{
			x = cast(T)(x + otherVector.x);
			y = cast(T)(y + otherVector.y);
			return this;
		}
		static if(op == "-")
		{
			x = cast(T)(x - otherVector.x);
			y = cast(T)(y - otherVector.y);
			return this;
		}
	}

	/// Assign Multiply/Divide with a numaric value.
	ref Vector2!(T) opOpAssign(string op,E)(E num)
	if(isNumeric!(E) && ((op == "*") || (op == "/")))
	{
		static if(op == "*")
		{
			x *= num;
			y *= num;
			return this;
		}
		static if(op == "/")
		{
			x /= num;
			y /= num;
			return this;
		}
	}

	/// Assign the value of another vector whose type can be converted to T.
	ref Vector2!(T) opAssign(E)(Vector2!(E) otherVector)
	{
		x = cast(T)(otherVector.x);
		y = cast(T)(otherVector.y);
		return this;
	}

	/// Compare two vectors for equality.
	bool opEquals(E)(const Vector2!(E) otherVector) const
	if(isNumeric!(E))
	{
		return ((x == otherVector.x) && (y == otherVector.y));
	}

	/// Output the string representation of the Vector2.
	string toString() const
	{
		import std.conv;
		return "X: " ~ text(x) ~ " Y: " ~ text(y);
	}
}

/// Definition of a Vector2 of integers.
alias Vector2i = Vector2!(int);

/// Definition of a Vector2 of floats.
alias Vector2f = Vector2!(float);

/// Definition of a Vector2 of unsigned integers.
alias Vector2u = Vector2!(uint);