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

module nudsfml.system.inputstream;

/**
* Interface for custom file input streams.
*/
interface InputStream
{
	/**
	 * Read data from the stream.
	 *
	 * Params:
 	 * 	data =	Buffer where to copy the read data
 	 * 			and sized to the amount of bytes to be read
 	 *
 	 * Returns: The number of bytes actually read, or -1 on error.
	 */
	long read(void[] data);

	/**
	 * Change the current reading position.
	 * Params:
     * 		position = The position to seek to, from the beginning
     *
	 * Returns: The position actually sought to, or -1 on error.
	 */
	long seek(long position);

	/**
	 * Get the current reading position in the stream.
	 *
	 * Returns: The current position, or -1 on error.
	 */
	long tell();

	/**
	 * Return the size of the stream.
	 *
	 * Returns: Total number of bytes available in the stream, or -1 on error.
	 */
	long getSize();
}

unittest
{
	//version(DSFML_Unittest_System)
	version(none) //temporarily not doing this test
	{
		import nudsfml.graphics.texture;
		import std.stdio;

		//File Stream ported from Laurent's example here:
		//http://www.sfml-dev.org/tutorials/2.0/system-stream.php

		class FileStream:InputStream
		{
			File m_file;

			this()
			{
				// Constructor code
			}
			bool open(string fileName)
			{
				try
				{
					m_file.open(fileName);
				}
				catch(Exception e)
				{
					writeln(e.msg);
				}

				return m_file.isOpen;
			}

			long read(void[] data)
			{

				if(m_file.isOpen)
				{
					return m_file.rawRead(data).length;
				}
				else
				{
					return -1;
				}
			}

			long seek(long position)
			{
				if(m_file.isOpen)
				{
					m_file.seek(position);
					return tell();
				}
				else
				{
					return -1;
				}
			}

			long tell()
			{

				if(m_file.isOpen)
				{
					return m_file.tell;
				}
				else
				{
					return -1;
				}
			}

			long getSize()
			{
				if(m_file.isOpen)
				{
					long position = m_file.tell;

					m_file.seek(0,SEEK_END);

					long size = tell();

					seek(position);

					return size;
				}
				else
				{
					return -1;
				}
			}
		}

		writeln("Unit test for InputStream");

		auto streamTexture = new Texture();

		writeln();
		writeln("Using a basic file stream to load a non existant texture to confirm correct errors are found.");

		auto failStream = new FileStream();
		failStream.open("nonexistantTexture.png");//doesn't open the stream, but you should be checking if open returns true
		streamTexture.loadFromStream(failStream);//prints errors to err

		writeln();
		writeln("Using a basic file stream to load a texture that exists.");
		auto successStream = new FileStream();
		successStream.open("res/TestImage.png");//using a png of Crono for now. Will replace with something that won't get me in trouble
		assert(streamTexture.loadFromStream(successStream));

		writeln("Texture loaded!");

		writeln();
	}
}
