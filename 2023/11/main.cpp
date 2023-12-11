#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include <vector>
#include <set>
#include "../../utils/FileParser.h"

template<typename Iter, typename Func>
void combine_pairwise(Iter first, Iter last, Func func)
{
	for (; first != last; ++first)
		for (Iter next = std::next(first); next != last; ++next)
			func(*first, *next);
}

using space = std::vector<std::vector<char>>;

void expand(space& space, std::set<int>& blank_colums)
{
	for (auto x{ 0 }; x < space.front().size(); ++x)
	{
		std::vector<char> column{};
		for (auto y{ 0 }; y < space.size(); ++y)
		{
			column.push_back(space[y][x]);
		}

		bool is_empty = std::ranges::all_of(column, [](char datum) { return datum == '.'; });
		if (is_empty)
		{
			blank_colums.insert(x);
		}
	}
}

std::vector<std::pair<int, int>> find_galaxies(const space& space)
{
	std::vector<std::pair<int, int>> galaxies{};
	for (auto y{ 0 }; y < space.size(); ++y)
	{
		auto& row = space[y];
		for (auto x{ 0 }; x < row.size(); ++x)
		{
			char datum = row[x];

			if (datum == '#')
			{
				galaxies.emplace_back(x, y);
			}
		}
	}
	return galaxies;
}

void part_1()
{
	LineParser parser{ "in.txt" };
	int64_t count{};

	std::set<int> blank_rows{};
	std::set<int> blank_colums{};
	space space{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			space.push_back({});
			std::string val = *line;
			for (const auto& datum : val)
			{
				space.back().push_back(datum);
			}

			bool is_empty = std::ranges::all_of(space.back(), [](char datum) { return datum == '.'; });
			if (is_empty)
			{
				blank_rows.insert((int)space.size() - 1);
			}

		}
	}

	expand(space, blank_colums);
	auto galaxies = find_galaxies(space);

	combine_pairwise(galaxies.begin(), galaxies.end(), [&](auto& lhs, auto rhs)
		{
			int x_dist = std::abs(lhs.first - rhs.first);
			int y_dist = std::abs(lhs.second - rhs.second);

			for (const auto column : blank_colums)
			{
				if ((lhs.first < column && column < rhs.first) || (rhs.first < column && column < lhs.first))
				{
					count += 999999;
				}
			}
			for (const auto row : blank_rows)
			{
				if ((lhs.second < row && row < rhs.second) || (rhs.second < row && row < lhs.second))
				{
					count += 999999;
				}
			}
			count += x_dist + y_dist;
					}
	);
				std::cout << count << std::endl;
}

void part_2()
{
	LineParser parser{ "in.txt" };
	int64_t count{};

	space space{};
	std::set<int> blank_rows{};
	std::set<int> blank_columns{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			space.push_back({});
			std::string val = *line;
			for (const auto& datum : val)
			{
				space.back().push_back(datum);
			}

			bool is_empty = std::ranges::all_of(space.back(), [](char datum) { return datum == '.'; });
			if (is_empty)
			{
				blank_rows.insert((int)space.size());
			}

		}
	}

	expand(space, blank_columns);
	auto galaxies = find_galaxies(space);

	combine_pairwise(galaxies.begin(), galaxies.end(), [&](auto& lhs, auto rhs)
		{
			int x_dist = std::abs(lhs.first - rhs.first);
			int y_dist = std::abs(lhs.second - rhs.second);
			count += x_dist + y_dist;
		}
	);
	std::cout << count << std::endl;
}

int main()
{
	part_1();
}