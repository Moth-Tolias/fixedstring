# fixedstring
a templated fixed-length array of `char`s, compatible with `@safe`, `@nogc`, and `nothrow` code.

# example
```d
void main() @safe @nogc nothrow
{
	FixedString!14 foo = "clang";
	foo[0] = 'd';
	foo ~= " is cool";
	assert (foo == "dlang is cool");

	foo.length = 9;

	auto bar = FixedString!"neat";
	assert (foo ~ bar == "dlang is neat");

	// wchars and dchars are also supported
	assert(FixedString!(5, wchar)("áéíóú") == "áéíóú");

	// in fact, any type is:
	immutable int[4] intArray = [1, 2, 3, 4];
	assert(FixedString!(5, int)(intArray) == intArray);
}
```

# licence
AGPL-3.0 or later
