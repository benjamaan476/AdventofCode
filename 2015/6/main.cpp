#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include "../../utils/FileParser.h"

#include <regex>

const static std::regex doubleMatch {"(.)\\1"};
std::string test{"aacdfjxykl"};

bool has_double(const std::string& name)
{
	auto begin = std::sregex_iterator(name.begin(), name.end(), doubleMatch);
	auto end = std::sregex_iterator();

	if (begin != end)
	{
		return true;
	}

	return false;

}

const static std::regex badMatch{"(?=^(?:(?!ab).)*$)(?=^(?:(?!cd).)*$)(?=^(?:(?!pq).)*$)(?=^(?:(?!xy).)*$).*$"};
bool has_bad_pair(const std::string& name)
{
	auto begin = std::sregex_iterator(name.begin(), name.end(), badMatch);
	auto end = std::sregex_iterator();

	if (begin != end)
	{
		return true;
	}

	return false;

}

const static std::regex vowelMatch{"[aeiou].*[aeiou].*[aeiou]"};
bool has_three_vowels(const std::string& name)
{
	auto begin = std::sregex_iterator(name.begin(), name.end(), vowelMatch);
	auto end = std::sregex_iterator();

	if (begin != end)
	{
		return true;
	}

	return false;

}

bool is_good_name(const std::string& name)
{
	auto good = has_double(name);
	if (!good)
	{
		return false;
	}
	good = has_bad_pair(name);
	if (!good)
	{
		return false;
	}

	good = has_three_vowels(name);
	return good;
}

void part_1()
{
	LineParser parser{ "in.txt" };

	int32_t count{};

	while (const auto& line = parser.next())
	{
		if (line.has_value())
		{
			is_good_name(*line) ? ++count : count;

		}
	}

	std::cout << count << std::endl;
}

static const std::regex xyx{"(.).\\1"};

bool is_xyx(const std::string& name)
{
	auto begin = std::sregex_iterator(name.begin(), name.end(), xyx);
	auto end = std::sregex_iterator();

	if (begin != end)
	{
		return true;
	}

	return false;

}

const static std::regex xxyxx{"(..).*\\1"};
bool is_xxyxx(const std::string& name)
{
	auto begin = std::sregex_iterator(name.begin(), name.end(), xxyxx);
	auto end = std::sregex_iterator();

	if (begin != end)
	{
		return true;
	}

	return false;

}

bool is_good_name_2(const std::string& name)
{
	auto good = is_xyx(name);
	if (!good)
	{
		return false;
	}
	good = is_xxyxx(name);
	return good;
}


void part_2()
{
	LineParser parser{ "in.txt" };

	int32_t count{};

	while (const auto& line = parser.next())
	{
		if (line.has_value())
		{
			is_good_name_2(*line) ? ++count : count;

		}
	}

	std::cout << count << std::endl;

}

int main()
{
	part_2();
}