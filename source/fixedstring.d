/**
* a @safe, @nogc-compatible template string type.
* Authors: Susan
* Date: 2021-11-06
* Licence: AGPL-3.0 or later
* Copyright: Susan, 2021
*/
module fixedstring;

import std.traits: isSomeChar;

/// short syntax.
auto FixedString(string s)()
{
	import std.math.algebraic: nextPow2;
	return FixedString!(nextPow2(s.length))(s);
}

///
@safe @nogc nothrow unittest
{
	enum testString = "dlang is good";
	immutable foo = FixedString!(testString);
	immutable bar = FixedString!16("dlang is good");

	assert(foo == bar);
}

///
struct FixedString(size_t maxSize, CharT = char)
{
	invariant (_length <= data.length);

	enum size = maxSize; ///

	private size_t _length;
	private CharT[maxSize] data = ' ';

	///
	public size_t length() const pure @nogc @safe
	{
		return _length;
	}

	/// ditto
	public void length(in size_t rhs) pure @safe @nogc
	in (rhs <= maxSize)
	{
		if (rhs >= length)
		{
			data[length .. rhs] = CharT.init;
		}
		_length = rhs;
	}

	/// constructor
	public this(in CharT[] rhs) @safe @nogc nothrow pure
	in (rhs.length <= maxSize)
	{
		length = rhs.length;
		data[0 .. length] = rhs[];
	}

	/// assignment
	public void opAssign(in CharT[] rhs) @safe @nogc nothrow pure
	in (rhs.length <= maxSize)
	{
		length = rhs.length;
		data[0 .. length] = rhs[];
	}

	/// ditto
	public void opAssign(T : FixedString!n, size_t n)(in T rhs) @safe @nogc nothrow pure
	in (rhs.length <= maxSize)
	{
		length = rhs.length;
		data[0 .. length] = rhs[];
	}

	/// ditto
	public void opOpAssign(string op)(in CharT[] rhs) @safe @nogc nothrow pure
	if (op == "~")
	in (length + rhs.length <= maxSize)
	{
		immutable oldLength = length;
		length = length + rhs.length;
		data[oldLength .. length] = rhs[];
	}

	/// ditto
	public void opOpAssign(string op)(in CharT rhs) @safe @nogc nothrow pure
	if (op == "~")
	in (length + 1 <= maxSize)
	{
		length = length + 1;
		data[length - 1] = rhs;
	}

	/// ditto
	public void opOpAssign(string op, T: FixedString!n, size_t n)(in T rhs) @safe @nogc nothrow pure
	if (op == "~")
	in (length + rhs.length <= maxSize)
	{
		immutable oldLength = length;
		length = length + rhs.length;
		data[oldLength .. length] = rhs[];
	}

	/// array features...
	public auto opSlice(in size_t first, in size_t last) @safe @nogc nothrow const pure
	{
		auto temp = data[first .. last];
		return temp;
	}

	/// ditto
	public size_t opDollar(size_t pos)() @safe @nogc nothrow const pure
	if (pos == 0)
	{
		return length;
	}

	/// ditto
	public const(CharT)[] opIndex() @safe @nogc nothrow const pure
	{
		return data[0 .. length];
	}

	/// ditto
	public CharT opIndex(in size_t index) @safe @nogc nothrow const pure
	in (index < length)
	{
		return data[index];
	}

	/// ditto
	public void opIndexAssign(in CharT rhs, in size_t index) @safe @nogc nothrow pure
	in (index <= maxSize)
	{
		if (index >= length)
		{
			length = index + 1;
		}
		data[index] = rhs;
	}

	/// equality
	public bool opEquals(T : FixedString!n, size_t n)(in T rhs) @safe @nogc nothrow const pure
	{
		return this[] == rhs[];
	}

	/// ditto
	public bool opEquals(in CharT[] s) @safe @nogc nothrow const pure
	{
		if (length != s.length)
		{
			return false;
		}

		return this[] == s[];
	}

	/// concatenation. note that you should probably use the ~ operator instead - only use this version when you are pressed for ram and aren't making many calls, or you will end up with template bloat.
	public auto concat(size_t s, T: FixedString!n, size_t n)(in T rhs) @safe @nogc nothrow const pure
	in (s >= length + rhs.length)
	{
		FixedString!(s) result;

		result = this[];
		result ~= rhs[];

		return result;
	}

	/// concatenation operator. generally, you should prefer this version.
	public auto opBinary(string op, T: FixedString!n, size_t n)(in T rhs) @safe @nogc nothrow const pure
	if (op == "~")
	{
		import std.math.algebraic: nextPow2;
		return concat!(nextPow2(size + rhs.size))(rhs);
	}

	static if (isSomeChar!CharT)
	{
		///
		public const(CharT)[] toString() @safe nothrow const pure
		{
			return data[0 .. length].idup;
		}
	}

	///
	public size_t toHash() @safe @nogc nothrow const pure
	{
		ulong result = length;
		foreach (CharT c; data[0 .. length])
		{
			result += c;
		}
		return result;
	}

	/// range interface
	public bool empty() @safe @nogc nothrow const pure
	{
		return (length <= 0);
	}

	/// ditto
	public CharT front() @safe @nogc nothrow const pure
	{
		return data[0];
	}

	/// ditto
	public void popFront() @safe @nogc nothrow
	{
		for (auto i = 0; i < length; ++i)
		{
			data[i] = data[i + 1];
		}
		length = length - 1;
	}

	mixin(opApplyWorkaround);
}

/// readme example code
@safe @nogc nothrow unittest
{
	FixedString!14 foo = "clang";
	foo[0] = 'd';
	foo ~= " is cool";
	assert (foo == "dlang is cool");

	foo.length = 9;

	immutable bar = FixedString!"neat";
	assert (foo ~ bar == "dlang is neat");

	// wchars and dchars are also supported
	assert(FixedString!(5, wchar)("áéíóú") == "áéíóú");

	// in fact, any type is:
	immutable int[4] intArray = [1, 2, 3, 4];
	assert(FixedString!(5, int)(intArray) == intArray);
}

private string resultAssign(in int n)
{
	switch (n)
	{
	case 1:
		return "result = dg(temp);";
	case 2:
		return "result = dg(i, temp);";
	default:
		assert(false, "this will never happen.");
	}
}

private string delegateType(in int n, in string attributes)
{
	string params;
	switch (n)
	{
	case 1:
		params = "ref CharT";
		break;
	case 2:
		params = "ref int, ref CharT";
		break;
	default:
		assert(false, "unsupported number of parameters.");
	}

	return "delegate(" ~ params ~ ") " ~ attributes;
}

private string opApplyWorkaround()
{
	// dfmt off
	return paramNumbers("") ~
	paramNumbers("@safe") ~
	paramNumbers("@nogc") ~
	paramNumbers("@safe @nogc") ~
	paramNumbers("nothrow") ~
	paramNumbers("@safe nothrow") ~
	paramNumbers("@nogc nothrow") ~
	paramNumbers("@safe @nogc nothrow") ~
	paramNumbers("pure") ~
	paramNumbers("pure @safe") ~
	paramNumbers("pure @nogc") ~
	paramNumbers("pure @safe @nogc") ~
	paramNumbers("pure nothrow") ~
	paramNumbers("pure @safe nothrow") ~
	paramNumbers("pure @nogc nothrow") ~
	paramNumbers("pure @safe @nogc nothrow");
	// dfmt on
}

private string paramNumbers(in string params)
{
	// dfmt off
	return good(1, params, true) ~
	good(2, params, true) ~
	good(1, params, false) ~
	good(2, params, false);
	// dfmt on
}

private string good(in int n, in string parameters, in bool isConst)
{
	string s;
	if (isConst)
	{
		s = "const";
	}
	else
	{
		s = "";
	}

	string result = "
		public int opApply(scope int " ~ delegateType(n, parameters) ~ " dg) " ~ s ~ "
		{
			int result = 0;

			for (int i = 0; i != length; ++i)
			{
				CharT temp = data[i];
				" ~ resultAssign(n) ~ "
				if (result)
				{
					break;
				}
			}

			return result;
		}";

	return result;
}

@safe @nogc nothrow unittest
{
	immutable string temp = "cool";
	auto a = FixedString!8(temp);
	assert(a[0] == 'c');
	assert(a == "cool");
	assert(a[] == "cool");
	assert(a[0 .. $] == "cool");

	a[2] = 'd';
	assert(a == "codl");
	assert(a != "");

	a[5] = 'd';
	assert(a == "codl\xffd");

	a.length = 4;
	assert(a == "codl");

	a.length = 6;
	assert(a == "codl\xff\xff");

	a.length = 4;
	assert(a == "codl");

	FixedString!10 b;
	b = " is nic";
	b ~= 'e';
	assert(a ~ b == "codl is nice");
	assert(a.concat!16(b) == "codl is nice");
	assert(a ~ b == a.concat!16(b));

	FixedString!10 d;
	d = a;

	foreach (i, char c; a)
	{
		switch (i)
		{
		case 0:
			assert(c == 'c');
			break;

		case 1:
			assert(c == 'o');
			break;

		case 2:
			assert(c == 'd');
			break;

		case 3:
			assert(c == 'l');
			break;

		default:
			assert(false);
		}
	}

	a = "de";
	a ~= "ad";
	assert(a == "dead");
	b = "beef";
	a ~= b;
	assert(a == "deadbeef");

	assert(FixedString!"aéiou" == "aéiou");

	immutable char[4] dead = "dead";
	immutable(char)[4] beef = "beef";

	immutable FixedString!4 deader = dead;
	immutable FixedString!4 beefer = beef;
	assert(deader ~ beefer == "deadbeef");
}

@safe nothrow unittest
{
	immutable a = FixedString!16("bepis");
	assert (a.toString == "bepis");
}

@system unittest
{
	import std.exception;
	import core.exception : AssertError;

	assertThrown!AssertError(FixedString!2("too long"));

	FixedString!2 a = "uh";
	assertThrown!AssertError(a[69] = 'a');
	assertThrown!AssertError(a.concat!1(a));
}
