#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include <vector>
#include <set>
#include <numeric>
#include "../../utils/FileParser.h"

struct row
{
	std::string springs{};
	std::vector<int> groups{};
};

int count_possibilities(const std::vector<char>& springs, const std::vector<int>& groups)
{
	int count{};

	if (std::ranges::all_of(springs, [](char spring) { return spring == '#'; }))
	{
		return 0;
	}

	const auto group_sum = std::accumulate(groups.begin(), groups.end(), 0);
	

	if (springs.size() == groups.size())
	{
		return 1;
	}


	if (springs.size() == group_sum)
	{
		return 1;
	}

	if (groups.size() == 1)
	{
		return (int)springs.size();
	}

	if (springs.size() == group_sum + 1 && groups.size() == 1)
	{
		return 2;
	}
	 
	if (springs.size() == group_sum + 1)
	{
		return 1;
	}

	if (springs.size() == group_sum + groups.size() - 1)
	{
		return 1;
	}

	return count;
}

int process_row(row& row)
{
	if (row.springs.find_first_of('?') == std::string::npos)
	{
		return 0;
	}

	int count{};
	std::vector<std::vector<char>> damaged_springs(1);
	for (const char datum : row.springs)
	{
		if (datum == '.')
		{
			damaged_springs.push_back({});
		}
		else
		{
			damaged_springs.back().push_back(datum);
		}

	}
	std::erase_if(damaged_springs, [](auto spring) { return spring.empty(); });

	for (auto damaged_spring_iterator = damaged_springs.begin(); damaged_spring_iterator != damaged_springs.end();)
	{
		auto spring_group = *damaged_spring_iterator;
		std::vector<int> groups{};
		int total{};
		int group_size = (int)spring_group.size();
		bool erased{};
		for (auto group_iterator = row.groups.begin(); group_iterator != row.groups.end();)
		{
			auto group = *group_iterator;
			if (total + group <= group_size)
			{
				groups.push_back(group);
				total += group + 1;
				++group_iterator;
			}
			else
			{
				count += count_possibilities(spring_group, groups);
				group_iterator = row.groups.erase(row.groups.begin(), row.groups.begin() + groups.size());
				damaged_spring_iterator = damaged_springs.erase(damaged_springs.begin());
				erased = true;
				break;
			}
		}
		 
		if (!erased)
		{
			++damaged_spring_iterator;
		}
	}

	std::cout << count << std::endl;
	return count;
}

void part_1()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	std::vector<row> rows{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			const std::string val = *line;

			std::vector<int> groups{};
			std::string row{};
			std::string group{};

			{
				std::istringstream ss{ val };
				ss >> row;

				while (std::getline(ss, group, ','))
				{
					groups.push_back(std::stoi(group));
				}
			}
			rows.emplace_back(row, groups);
		}
	}

	for (auto& row : rows)
	{
		count += process_row(row);
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