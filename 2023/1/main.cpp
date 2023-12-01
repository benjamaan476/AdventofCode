#include <iostream>
#include <regex>

#include "../../utils/FileParser.h"
std::string test{"1twone"};
void part_1()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	while (const auto& line = parser.next())
	{
		if (line.has_value())
		{
			auto& val = *line;
			const char* digits = "0123456789";
			const std::size_t first = val.find_first_of(digits);
			const std::size_t last = val.find_last_of(digits);

			if (first != std::string::npos && last != std::string::npos)
			{

				auto number = 10* (val[first] - '0');
				number += (val[last] - '0');

				count += number;
			}
		}
	}

	std::cout << count << std::endl;

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

	return -1;
}

const static std::regex number_match{"([0-9]|one|two|three|four|five|six|seven|eight|nine)"};
void part_2()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	while (const auto& line = parser.next())
	{
		if (line.has_value())
		{
			const auto& val = *line;

			std::smatch pieces_match;

			std::vector<std::string> matches{};
			auto iter = val.cbegin();
			while (std::regex_search(iter, val.end(), pieces_match, number_match))
			{
				matches.push_back(pieces_match[1].str());
				iter++;// = pieces_match[0].second;
			}

			if (!matches.empty())
			{
				auto first = matches.front();
				auto number = 10 * string_to_num(first);

				std::string last = matches.back();
				number += string_to_num(last);

				count += number;
				std::cout << first << " + " << last << " = " << number << ", " << count << std::endl;
			}
		}
	}

	std::cout << count << std::endl;
}

int main()
{
	part_2();

}