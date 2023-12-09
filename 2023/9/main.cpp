#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include <vector>
#include <set>
#include <numeric>
#include <ranges>
#include "../../utils/FileParser.h"

int calculate_next_input(const std::vector<int>& inputs)
{
	std::vector<std::vector<int>> new_inputs;
	new_inputs.push_back(inputs);
	while (std::ranges::any_of(new_inputs.back(), [](int input) { return input != 0; }))
	{
		std::vector<int> new_ins{};
		std::adjacent_difference(new_inputs.back().begin(), new_inputs.back().end(), std::back_inserter(new_ins));
		new_ins.erase(new_ins.begin());

		new_inputs.push_back(new_ins);
	}

	int input{};

	for (auto& next_input : new_inputs | std::views::reverse)
	{
		input += next_input.back();
	}

	return input;
}

int calculate_first_input(const std::vector<int>& inputs)
{
	std::vector<std::vector<int>> new_inputs;
	new_inputs.push_back(inputs);
	while (std::ranges::any_of(new_inputs.back(), [](int input) { return input != 0; }))
	{
		std::vector<int> new_ins{};
		std::adjacent_difference(new_inputs.back().begin(), new_inputs.back().end(), std::back_inserter(new_ins));
		new_ins.erase(new_ins.begin());

		new_inputs.push_back(new_ins);
	}

	int input{};

	for (auto& next_input : new_inputs | std::views::reverse)
	{
		input = next_input.front() - input;
	}

	return input;
}
void part_1()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			auto val = *line;

			std::vector<int> inputs{};
			int input{};
			std::istringstream ss{val};
			while (ss >> input)
			{
				inputs.push_back(input);
			}

			count += calculate_next_input(inputs);
		}
	}

	std::cout << count << std::endl;
}

void part_2()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			auto val = *line;

			std::vector<int> inputs{};
			int input{};
			std::istringstream ss{val};
			while (ss >> input)
			{
				inputs.push_back(input);
			}

			count += calculate_first_input(inputs);
		}
	}

	std::cout << count << std::endl;
}

int main()
{
	part_2();
}