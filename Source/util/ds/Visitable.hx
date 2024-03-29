﻿/*
Copyright (c) 2008-2016 Michael Baczynski, http://www.polygonal.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
package util.ds;

/**
	An object that can be visited in a traversal by calling `object.visit()`
**/
interface Visitable
{
	/**
		@param preflight if true, an extra traversal is performed before the actual traversal runs.
		<br/>The first pass visits all elements and calls `element.visit()` with the `preflight` parameter set to true.
		In this pass the return value determines whether the element will be included (true) or excluded (false) from the final traversal,
		which is performed in the second pass (`preflight` parameter set to false).
		@param userData custom data passed to every visited element. Default is null.
	**/
	function visit(preflight:Bool, userData:Dynamic):Bool;
}