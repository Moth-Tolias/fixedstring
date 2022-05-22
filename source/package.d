/**
* a @safe, @nogc-compatible template string type.
* Authors: Susan
* Date: 2021-11-06
* Licence: AGPL-3.0 or later
* Copyright: Susan, 2021
*/
module fixedstring;

import fixedstring.fixedstringrange;
import fixedstring.opapplymixin;
import std.traits: isSomeChar;

/// short syntax.
auto fixedString(string s)()
{
	import std.math.algebraic: nextPow2;
	return FixedString!(nextPow2(s.length))(s);
}

///
@safe @nogc nothrow unittest
{
	enum testString = "dlang is good";
	immutable foo = fixedString!(testString);
	immutable bar = FixedString!16(testString);

	assert(foo == bar);
}

///
struct FixedString(size_t maxSize, CharT = char)
{
	invariant (length_ <= data.length);

	enum size = maxSize; ///

	private size_t length_;
	private CharT[maxSize] data = ' ';

	///
	size_t length() const @nogc nothrow pure @safe
	{
		return length_;
	}

	/// ditto
	void length(in size_t rhs) @nogc nothrow pure @safe
	in (rhs <= maxSize)
	{
		if (rhs >= length)
		{
			data[length .. rhs] = CharT.init;
		}
		length_ = rhs;
	}

	/// constructor
	this(in CharT[] rhs)
	in (rhs.length <= maxSize)
	{
		length = rhs.length;
		data[0 .. length] = rhs[];
	}

	/// assignment
	void opAssign(in CharT[] rhs)
	in (rhs.length <= maxSize)
	{
		length = rhs.length;
		data[0 .. length] = rhs[];
	}

	/// ditto
	void opAssign(T: CharT, size_t n)(in FixedString!(n, T) rhs)
	in (rhs.length <= maxSize)
	{
		length = rhs.length;
		data[0 .. length] = rhs[0 .. length];
	}

	/// ditto
	void opOpAssign(string op)(in CharT[] rhs)
	if (op == "~")
	in (length + rhs.length <= maxSize)
	{
		immutable oldLength = length;
		length = length + rhs.length;
		data[oldLength .. length] = rhs[];
	}

	/// ditto
	void opOpAssign(string op)(in CharT rhs)
	if (op == "~")
	in (length + 1 <= maxSize)
	{
		length = length + 1;
		data[length - 1] = rhs;
	}

	/// ditto
	void opOpAssign(string op, T: CharT, size_t n)(in FixedString!(n, T) rhs)
	if (op == "~")
	in (length + rhs.length <= maxSize)
	{
		immutable oldLength = length;
		length = length + rhs.length;
		data[oldLength .. length] = rhs[0 .. rhs.length];
	}

	/// array features...
	auto opSlice(in size_t first, in size_t last) const @nogc nothrow pure @safe
	in (first <= length && last <= length)
	{
		return data[first .. last];
	}

	/// ditto
	size_t opDollar(size_t pos)() const @nogc nothrow pure @safe
	if (pos == 0)
	{
		return length;
	}

	/// ditto
	auto opIndex() const
	{
		return FixedStringRange!CharT(data[0 .. length]);
	}

	/// ditto
	CharT opIndex(in size_t index) const @nogc nothrow pure @safe
	in (index < length)
	{
		return data[index];
	}

	/// ditto
	void opIndexAssign(in CharT rhs, in size_t index)
	in (index < length)
	{
		data[index] = rhs;
	}

	/// equality
	bool opEquals(T : CharT, size_t n)(in FixedString!(n, T) rhs) const
	{
		import std.algorithm.comparison: equal;
		return this[].equal(rhs[]);
	}

	/// ditto
	bool opEquals(in CharT[] s) const
	{
		if (length != s.length)
		{
			return false;
		}

		import std.algorithm.comparison: equal;
		return this[].equal(s[]);
	}

	/// concatenation. note that you should probably use the ~ operator instead - only use this version when you are pressed for ram and aren't making many calls, or you will end up with template bloat.
	auto concat(size_t s, T: CharT, size_t n)(in FixedString!(n, T) rhs) const
	in (s >= length + rhs.length)
	{
		FixedString!(s) result;

		result = this;
		result ~= rhs;

		return result;
	}

	/// concatenation operator. generally, you should prefer this version.
	auto opBinary(string op, T: CharT, size_t n)(in FixedString!(n, T) rhs) const
	if (op == "~")
	{
		import std.math.algebraic: nextPow2;
		return concat!(nextPow2(size + rhs.size))(rhs);
	}

	static if (isSomeChar!CharT)
	{
		///
		const(CharT)[] toString() const nothrow pure @safe
		{
			return data[0 .. length].idup;
		}
	}

	///
	size_t toHash() const @nogc nothrow pure @safe
	{
		ulong result = length;
		foreach (CharT c; data[0 .. length])
		{
			result += c;
		}
		return result;
	}

	mixin(opApplyWorkaround);
}

///
@safe @nogc nothrow pure unittest
{
	immutable string temp = "cool";
	auto foo = FixedString!8(temp);
	assert(foo[0] == 'c');
	assert(foo == "cool");

	import std.algorithm.comparison: equal;
	assert(foo[].equal("cool"));
	assert(foo[0 .. $] == "cool");

	foo[2] = 'd';
	assert(foo == "codl");
	assert(foo != "");

	foo ~= "d";
	foo.length = 4;
	assert(foo == "codl");

	foo.length = 6;
	assert(foo == "codl\xff\xff");

	foo.length = 4;
	assert(foo == "codl");

	import std.range: retro;
	assert(equal(retro(foo[]), "ldoc"));

	import std.range: radial;
	assert(equal(radial(foo[]), "odcl"));

	import std.range: cycle;
	assert(foo[].cycle[4 .. 8].equal(foo[]));

	assert(foo[].save == foo[]);

	FixedString!10 bar;
	bar = " is nic";
	bar ~= 'e';

	immutable truth = fixedString!"codl is nice";

	assert(foo ~ bar == truth);
	assert(foo.concat!16(bar) == truth);
	assert(foo ~ bar == foo.concat!16(bar));

	FixedString!10 d;
	d = foo;
	d.length = 4;

	foreach (i, char c; d)
	{
		assert(c == foo[i]);
	}

	foo = "de";
	foo ~= "ad";
	assert(foo == "dead");
	bar = "beef";
	foo ~= bar;
	assert(foo == "deadbeef");

	assert(fixedString!"aéiou" == "aéiou");

	immutable char[4] dead = "dead";
	immutable(char)[4] beef = "beef";

	immutable FixedString!4 deader = dead;
	immutable FixedString!4 beefer = beef;
	assert(deader ~ beefer == "deadbeef");
}

///
pure @safe nothrow unittest
{
	immutable a = FixedString!16("bepis");
	assert(a.toString == "bepis");

	int[FixedString!16] table;
	table[a] = 1;

	immutable b = FixedString!16("conk");
	table[b] = 2;

	assert(table[a] == 1);
	assert(table[b] == 2);
}

/// readme example code
@safe @nogc nothrow pure unittest
{
	FixedString!14 foo = "clang";
	foo[0] = 'd';
	foo ~= " is cool";
	assert(foo == "dlang is cool");

	foo.length = 9;

	immutable bar = fixedString!"neat";
	assert(foo ~ bar == "dlang is neat");

	// wchars and dchars are also supported
	assert(FixedString!(5, wchar)("áéíóú") == "áéíóú");

	// in fact, any type is:
	immutable int[4] intArray = [1, 2, 3, 4];
	assert(FixedString!(5, int)(intArray) == intArray);
}

@system unittest
{
	import std.exception: assertThrown;
	import core.exception: AssertError;

	assertThrown!AssertError(FixedString!2("too long"));

	FixedString!2 a = "uh";
	assertThrown!AssertError(a[69] = 'a');
	assertThrown!AssertError(a.concat!1(a));
}
