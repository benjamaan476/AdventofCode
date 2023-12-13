#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include <vector>
#include <set>
#include <regex>
#include <numeric>
#include "../../utils/FileParser.h"


constexpr static const char delim = '0';

struct row
{
	std::string data{};
	std::vector<int> groups{};
};

std::string build_match(const row& row, const std::vector<int>& gaps)
{
	std::string match{};
	for (int i{}; i < gaps.size(); ++i)
	{
		int gap = gaps[i];
		int group_size = row.groups[i];

		while (gap--)
		{
			match.push_back(delim);
		}

		while (group_size--)
		{
			match.push_back('#');
		}


	}

	return match;
}

void pad_match(std::string& match, int size)
{
	while (match.size() < size)
	{
		match.push_back(delim);
	}
}

int process_row(const row& row)
{
	int count{};

	auto num_groups = row.groups.size();
	std::vector<int> gaps(num_groups, 1);
	gaps[0] = 0;
	std::string regex_string{"^"};

	for (const char datum : row.data)
	{
		if (datum == '?')
		{
			regex_string.push_back('[');
			regex_string.push_back(delim);
			regex_string.push_back('|');
			regex_string.push_back('#');
			regex_string.push_back(']');
		}
		else
		{
			regex_string.push_back(datum);
		}
	}

	regex_string.push_back('$');

	for (int gap_index{1}; gap_index < gaps.size() - 1; ++gap_index)
	{
		for (;;)
		{
			{
				int group_count = std::accumulate(row.groups.begin(), row.groups.end(), 0);
				int gap_count = std::accumulate(gaps.begin(), gaps.end(), 0);

				if (group_count + gap_count > row.data.size())
				{
					break;
				}
			}
			for (int increment_index = 0; increment_index < gap_index; ++increment_index)
			{
				for (;;)
				{
					int group_count = std::accumulate(row.groups.begin(), row.groups.end(), 0);
					int gap_count = std::accumulate(gaps.begin(), gaps.end(), 0);

					if (group_count + gap_count > row.data.size())
					{
						break;
					}

					do
					{
						std::string match = build_match(row, gaps);


						if (match.size() > row.data.size())
						{
							break;
						}

						pad_match(match, (int)row.data.size());

						std::regex regex{regex_string};
						std::smatch base_match;
						if (std::regex_match(match, base_match, regex))
						{
							count++;
						}
					} while (++gaps[0]);
					gaps[0] = 0;
					gaps[increment_index + 1]++;
					//if (another_index + 1 >= gaps.size())
					//{
					//	break;
					//}
					//gaps[increment_index + 1]++;
				}
				int index = increment_index + 1;
				do
				{
					gaps[index] = 1;
				} while (index--);
				gaps[0] = 0;
				//int index = gap_index + 1;
				//while (index-- >= 1)
				//{
				//	gaps[index] = 1;
				//}
				//gaps[0] = 0;
				//if (gap_index + increment_index + 2 >= gaps.size())
				//{
				//	break;
				//}
				//gaps[gap_index + increment_index + 2]++;

			}
			gaps[gap_index + 1]++;
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
			std::string data{};
			std::string group{};
			std::vector<int> groups{};

			std::istringstream ss{*line};
			ss >> data;
			while (std::getline(ss, group, ','))
			{
				groups.push_back(std::stoi(group));
			}

			std::ranges::replace(data, '.', delim);
			rows.emplace_back(data, groups);
		}
	}

	for (const auto& row : rows)
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