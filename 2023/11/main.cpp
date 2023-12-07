#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include <vector>
#include <set>
#include "../../utils/FileParser.h"

void part_1()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{

		}
	}

	std::cout << count << std::endl;
}

void part_2()
{
	LineParser parser{ "in.txt" };
	int64_t count{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
		}
	}

	std::cout << count << std::endl;
}

int main()
{
	part_1();
}