module fixedstring.fixedstringrange;

package(fixedstring):

struct FixedStringRange(DataType)
{
	private const(DataType)[] source;
	private size_t startIndex;
	private size_t length_;
	size_t length()
	{
		return length_;
	}

	@disable this();

	package this(in DataType[] source)
	{
		this.source = source;
		this.length_ = source.length;
	}

	bool empty() const
	{
		return length_ == 0;
	}

	DataType front()
	in (!empty)
	{
		return source[startIndex];
	}

	void popFront()
	in (!empty)
	{
		++startIndex;
		--length_;
	}

	typeof(this) save()
	{
		return this;
	}

	DataType back()
	in (!empty)
	{
		return source[startIndex + (length_ - 1)];
	}

	void popBack()
	in (!empty)
	{
		--length_;
	}

	DataType opIndex(in size_t index)
	in (index < length_)
	{
		return source[startIndex + index];
	}

	auto opSlice(in size_t first, in size_t last)
	in (first <= length_ && last <= length_)
	{
		return typeof(this)(source[(startIndex + first) .. (startIndex + last)]);
	}
}
