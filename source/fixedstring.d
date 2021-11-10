module fixedstring;

/**
* a @safe, @nogc-compatible template string type.
* Authors: Susan
* Date: 2021-11-06
* Licence: AGPL-3.0 or later
* Copyright: Susan, 2021
*/

struct FixedString(size_t maxSize)
{
	invariant (length <= data.length);

	enum size = maxSize; ///

	size_t length = 0; ///
	private char[maxSize] data = ' ';

	/// constructor
	this(in char[] rhs) @safe @nogc nothrow pure
	in (rhs.length <= maxSize)
	{
		length = rhs.length;
		foreach (i, char c; rhs)
		{
			data[i] = c;
		}
	}

	/// assignment
	public void opAssign(in char[] rhs) @safe @nogc nothrow pure
	in (rhs.length <= maxSize)
	{
		length = rhs.length;
		foreach (i, char c; rhs)
		{
			data[i] = c;
		}
	}

	/// ditto
	public void opAssign(T : FixedString!n, size_t n)(in T rhs) @safe @nogc nothrow pure
	in (rhs.length <= maxSize)
	{
		length = rhs.length;
		foreach (i, char c; rhs)
		{
			data[i] = c;
		}
	}

	/// ditto
	public void opOpAssign(string op)(in char[] rhs) @safe @nogc nothrow pure if (op == "~")
	in (length + rhs.length <= maxSize)
	{
		foreach (i, char c; rhs)
		{
			data[length + i] = c;
		}
		length += rhs.length;
	}

	/// ditto
	public void opOpAssign(string op, T:
			FixedString!n, size_t n)(in T rhs) @safe @nogc nothrow pure if (op == "~")
	in (length + rhs.length <= maxSize)
	{
		foreach (i, char c; rhs)
		{
			data[length + i] = c;
		}
		length += rhs.length;
	}

	/// array features...
	public auto opSlice(in size_t first, in size_t last) @safe @nogc nothrow const pure
	{
		auto temp = data[first .. last];
		return temp;
	}

	/// ditto
	public size_t opDollar(size_t pos)() @safe @nogc nothrow const pure if (pos == 0)
	{
		return length;
	}

	/// ditto
	public const(char)[] opIndex() @safe @nogc nothrow const pure
	{
		return data[0 .. length];
	}

	/// ditto
	public char opIndex(in size_t index) @safe @nogc nothrow const pure
	in (index < length)
	{
		return data[index];
	}

	/// ditto
	public void opIndexAssign(in char value, in size_t index) @safe @nogc nothrow pure
	in(index <= maxSize)
	{
		if (index >= length)
		{
			length = index + 1;
		}
		data[index] = value;
	}

	/// equality
	public bool opEquals(T : FixedString!n, size_t n)(in T rhs) @safe @nogc nothrow const pure
	{
		return data[0 .. length] == rhs.data[0 .. rhs.length];
	}

	/// ditto
	public bool opEquals(in char[] s) @safe @nogc nothrow const pure
	{
		if (length != s.length)
		{
			return false;
		}
		foreach (i, char c; data[0 .. length])
		{
			if (s[i] != c)
			{
				return false;
			}
		}

		return true;
	}

	/// concatenation. prefer this over the ~ operator whenever you know what size the result will be ahead of time - the operator version always uses the size of the maximum possible result.
	public auto concat(size_t s, T:
			FixedString!n, size_t n)(in T rhs) @safe @nogc nothrow const pure
	in(s >= length + rhs.length)
	{
		FixedString!(s) result;

		result.length = length + rhs.length;
		foreach (i, char c; data[0 .. length])
		{
			result.data[i] = c;
		}

		foreach (i, char c; rhs.data[0 .. rhs.length])
		{
			result.data[length + i] = c;
		}

		return result;
	}

	/// concatenation operator
	public auto opBinary(string op, T:
			FixedString!n, size_t n)(in T rhs) @safe @nogc nothrow const pure 
			if (op == "~")
	{
		return concat!(size + rhs.size)(rhs);
	}

	///
	public string toString() @safe nothrow const pure
	{
		return data[0 .. length].idup;
	}

	///
	public size_t toHash() @safe @nogc nothrow const pure
	{
		ulong result = length;
		foreach(char c; data[0 .. length])
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
	public char front() @safe @nogc nothrow const pure
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
		--length;
	}

	mixin(opApplyWorkaround);
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
		assert(false);
	}
}

private string delegateType(in int n, in string attributes)
{
	string params;
	switch (n)
	{
	case 1:
		params = "ref char";
		break;
	case 2:
		params = "ref int, ref char";
		break;
	default:
		assert(false);
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
				char temp = data[i];
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
	assert (a[] == "cool");
	assert(a[0 .. $] == "cool");

	a[2] = 'd';
	assert(a == "codl");

	a[5] = 'd';
	assert(a == "codl d");

	a.length = 4;
	assert(a == "codl");

	FixedString!10 b;
	b = " is nice";
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
}

unittest
{
	import std.exception;
	import core.exception : AssertError;
	assertThrown!AssertError(FixedString!2("too long"));

	FixedString!2 a = "uh";
	assertThrown!AssertError(a[69] = 'a');
	assertThrown!AssertError(a.concat!1(a));
}
