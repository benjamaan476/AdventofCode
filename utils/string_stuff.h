

static inline void ltrim(std::string& s)
{
	s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char ch) {
		return !std::isspace(ch);
									}));
}

// trim from end (in place)
static inline void rtrim(std::string& s)
{
	s.erase(std::find_if(s.rbegin(), s.rend(), [](unsigned char ch) {
		return !std::isspace(ch);
						 }).base(), s.end());
}

// trim from both ends (in place)
static inline void trim(std::string& s)
{
	rtrim(s);
	ltrim(s);
}

bool is_number(const std::string& s)
{
	std::string::const_iterator it = s.begin();
	while (it != s.end() && std::isdigit(*it)) ++it;
	return !s.empty() && it == s.end();
}

int32_t string_to_num(const std::string& str)
{
	if (str == "1" || str == "one")
	{
		return 1;
	}
	else if (str == "2" || str == "two")
	{
		return  2;
	}
	else if (str == "3" || str == "three")
	{
		return  3;
	}
	else if (str == "4" || str == "four")
	{
		return  4;
	}
	else if (str == "5" || str == "five")
	{
		return  5;
	}
	else if (str == "6" || str == "six")
	{
		return  6;
	}
	else if (str == "7" || str == "seven")
	{
		return  7;
	}
	else if (str == "8" || str == "eight")
	{
		return  8;
	}
	else if (str == "9" || str == "nine")
	{
		return  9;
	}

	try
	{
		return std::stoi(str);
	}
	catch (std::exception e)
	{
		return -1;
	}
}

template <typename T, typename U = T, typename V = T>
class range
{
    using value_type = decltype(T{} + U{} + V{});
    //static_assert( (is_signed_v<T> && is_signed_v<U> && is_signed_v<U>) ||
    //               (is_unsigned_v<T> && is_unsigned_v<U> && is_unsigned_v<U>),
    //               "Range types should be all signed or all unsigned" );

    public:
        range(T from, U to, V step = 1)
        : m_from{from}
        , m_to{to}
        , m_step{step}
        {
        }

        range(T to)
        : range{T{}, to}
        {
        }

        class iter
        {
            public:
                iter(value_type pos, value_type step)
                : m_pos{pos}
                , m_step{step}
                {
                }

                iter& operator++()                 { m_pos += m_step; return *this; }
                value_type operator*()             { return m_pos; }
                bool operator!=(const iter& other) { return m_pos*m_step < other.m_pos*m_step; }
                //bool operator==(const Iter& other) { return !(other == *this); }

            private:
                value_type m_pos;
                value_type m_step;
        };

        iter begin() { return iter{m_from, m_step}; }
        iter end()   { return iter{m_to, m_step}; }

    private:
        value_type m_from;
        value_type m_to;
        value_type m_step;
};
