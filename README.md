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

	auto bar = FixedString!16("neat");
	assert (foo ~ bar == "dlang is neat");
}
```

# licence
AGPL-3.0 or later
