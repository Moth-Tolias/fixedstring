module fixedstring.opapplymixin;

package(fixedstring) string opApplyWorkaround() nothrow pure @safe
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

private string paramNumbers(in string params) nothrow pure @safe
{
	// dfmt off
	return good(1, params, true) ~
	good(2, params, true) ~
	good(1, params, false) ~
	good(2, params, false);
	// dfmt on
}

private string delegateType(in int n, in string attributes) nothrow pure @safe
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

private string good(in int n, in string parameters, in bool isConst) nothrow pure @safe
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
		int opApply(scope int " ~ delegateType(n, parameters) ~ " dg) " ~ s ~ "
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

private string resultAssign(in int n) nothrow pure @safe
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
