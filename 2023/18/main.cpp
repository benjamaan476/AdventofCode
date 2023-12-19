#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include <vector>
#include <set>
#include <regex>
#include <map>
#include <numeric>
#include <unordered_map>
#include <array>
#include <queue>
#include "../../utils/FileParser.h"
#include "../../utils/string_stuff.h"

constexpr const static char block = '#';
constexpr const static char space = '_';
constexpr const static char rock = 'O';

void flood(std::vector<std::vector<char>>& grid, int x, int y, char current, char new_colour)
{
	if (x < 0 || x >= grid.front().size() || y < 0 || y >= grid.size())
	{
		return;
	}
	if (grid[y][x] != current)
	{
		return;
	}
	if (grid[y][x] == new_colour)
	{
		return;
	}

	grid[y][x] = new_colour;

	flood(grid, x + 1, y, current, new_colour);
	flood(grid, x - 1, y, current, new_colour);
	flood(grid, x, y + 1, current, new_colour);
	flood(grid, x, y - 1, current, new_colour);
}

struct flood_state
{
	int x;
	int y;
	char current;
	char new_colour;
};

void find_colour(std::vector<std::vector<char>>& grid, int xx, int yy, char new_colour)
{
	char current = grid[yy][xx];

	std::queue<flood_state> queue{};
	queue.push({ xx, yy, current, new_colour });

	while (!queue.empty())
	{
		auto state = queue.front();
		queue.pop();

		if (state.x < 0 || state.x >= grid.front().size() || state.y < 0 || state.y >= grid.size())
		{
			continue;
		}
		if (grid[state.y][state.x] != state.current)
		{
			continue;
		}
		if (grid[state.y][state.x] == state.new_colour)
		{
			continue;
		}

		grid[state.y][state.x] = state.new_colour;

		queue.emplace(state.x , state.y  - 1, current, new_colour);
		queue.emplace(state.x , state.y  + 1, current, new_colour);
		queue.emplace(state.x - 1, state.y , current, new_colour);
		queue.emplace(state.x + 1, state.y , current, new_colour);
	}
}

void part_1()
{
	LineParser parser{ "in.txt" };
	size_t count{};

	std::array<std::array<char,600>, 600> lines{};
	for (auto& row : lines)
	{
		std::ranges::fill(row, ' ');
	}

	int x_location{250};
	int y_location{250};
	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			std::istringstream ss{ *line };
			char direction{};
			int length{};
			std::string colour{};
			ss >> direction >> length >> colour;

			switch (direction)
			{
			case 'R':
					for (int i{}; i < length; ++i)
					{
						++x_location;
						lines[y_location][x_location] = block;
					}
				break;
			case 'U':
				for (int i{}; i < length; ++i)
				{
					--y_location;
						lines[y_location][x_location] = block;
				}
				break;
			case 'D':
				for (int i{}; i < length; ++i)
				{
					++y_location;
					lines[y_location][x_location] = block;
				}
				break;
			case 'L':
				for (int i{}; i < length; ++i)
				{
					--x_location;
					lines[y_location][x_location] = block;
				}
				break;
			default:
				break;
			}
		}
	}

	
	std::vector<std::vector<char>> grid{};

	for (const auto& row : lines)
	{
		if (std::ranges::any_of(row, [](char datum) { return datum == block; }))
		{
			grid.push_back(std::vector<char>(row.size()));
			std::copy(row.begin(), row.end(), grid.back().begin());
		}
	}

	size_t min_index = 10000;
	size_t max_index{};

	for (const auto& row : grid)
	{
		std::string string(row.data(), row.data() + row.size());
		auto iter = string.find_first_of('#');

		if (iter != std::string::npos)
		{
			if (iter < min_index)
			{
				min_index = iter;
			}
		}
		
		iter = string.find_last_of(block);

		if (iter != std::string::npos)
		{
			if (iter > max_index)
			{
				max_index = iter;
			}
		}
	}

	std::vector<std::vector<char>> trimmed_grid{};

	for (auto& row : grid)
	{
		trimmed_grid.push_back({});
		std::copy(row.begin() + min_index - 1, row.begin() + max_index + 1, std::back_inserter(trimmed_grid.back()));
	}
	
	grid.push_back(std::vector<char>(grid.front().size()));
	std::ranges::fill(grid.back(), ' ');
	size_t boundary_size{};

	for (const auto& row : grid)
	{
		boundary_size += std::ranges::count_if(row, [](char datum) { return datum == block; });
	}

	std::string string = trimmed_grid[1].data();
	x_location = (int)string.find_first_of(block) + 1;
	find_colour(trimmed_grid, x_location, 1, block);

	for (const auto& row : trimmed_grid)
	{
		count += std::ranges::count_if(row, [](char datum) { return datum == block; });
	}

	std::cout << count << std::endl;
}

void part_2()
{
	LineParser parser{ "in.txt" };
	size_t count{};
	std::vector<std::pair<int, int>> coords{};
	int boundary_length{};

	int x_location{0};
	int y_location{0};

	coords.emplace_back(x_location, y_location);

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			std::istringstream ss{ *line };
			char direction{};
			int length{};
			std::string colour{};
			ss >> direction >> length >> colour;

			std::string hex_string(colour.data() + 2, colour.data() + 7);
			std::istringstream sss{ hex_string };
			sss >> std::hex >> length;

			direction = colour[colour.size() - 2];

			switch (direction)
			{
			case '0':
				x_location += length;
				break;
			case '3':
				y_location -= length;
				break;
			case '1':
				y_location += length;
				break;
			case '2':
				x_location -= length;
				break;
			default:
				break;
			}

			boundary_length += length;
			coords.emplace_back(x_location, y_location);
		}
	}

	size_t area{};
	std::vector<int> partial_sum(coords.size() + 1);

	std::adjacent_difference(coords.begin(), coords.end(), partial_sum.begin(), [](auto pair_one, auto pair_two) -> int { return pair_one.first * pair_two.second - pair_one.second * pair_two.first; });
	int last = coords.front().first * coords.back().second - coords.front().second * coords.back().first;
	partial_sum.push_back(last);
	area = std::ranges::count(partial_sum, 0);
	area /= 2;
	std::cout << count << std::endl;
}

int main()
{
	part_2();
}