/*--+{ NuDSFML 2.5.1 }+------------------------------------------------------*\
| NuDSFML 2.5.1 (new DSFML) is a refactor of DSFML 2.4 by Jeremy Dahaan       |
| it has been refactored to be based on CSFML 2.5.1 via the bindbc.sfml       |
| library by Drifton Aloft                                                    |
|                                                                             |
| Caution not all current DSFML features have been replicated / implimented   |
| yet. use at your own risk this software probably contains bugs, clever      |
| fixes and other programmer hijinks                                          |
\*---------------------------------------------------------------------------*/

/*
 * DSFML - The Simple and Fast Multimedia Library for D
 *
 * Copyright (c) 2013 - 2018 Jeremy DeHaan (dehaan.jeremiah@gmail.com)
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from the
 * use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not claim
 * that you wrote the original software. If you use this software in a product,
 * an acknowledgment in the product documentation would be appreciated but is
 * not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source distribution
 *
 *
 * DSFML is based on SFML (Copyright Laurent Gomila)
 */

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