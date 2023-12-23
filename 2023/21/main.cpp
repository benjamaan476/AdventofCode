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

constexpr const static char mark = 'O';
constexpr const static char space = '.';
constexpr const static char rock = '#';

struct flood_state
{
	int x;
	int y;
	char new_colour;
};

void find_colour(std::vector<std::string>& grid, int xx, int yy, char new_colour)
{

	std::queue<flood_state> queue{};
	std::queue<flood_state> next_queue{};

	queue.push({ xx, yy, new_colour });
	for (int i{}; i < 6; ++i)
	{
		while (!queue.empty())
		{
			auto state = queue.front();
			queue.pop();

			if (state.x < 0 || state.x >= grid.front().size() || state.y < 0 || state.y >= grid.size())
			{
				continue;
			}
			if (grid[state.y][state.x] == rock)
			{
				continue;
			}
			if (grid[state.y][state.x] == state.new_colour)
			{
				continue;
			}

			if(grid[state.y - 1][state.x] != rock)
				next_queue.emplace(state.x, state.y - 1, new_colour);
			if (grid[state.y + 1][state.x] != rock)
				next_queue.emplace(state.x, state.y + 1, new_colour);	
			if (grid[state.y][state.x - 1] != rock)
			next_queue.emplace(state.x - 1, state.y, new_colour);
			if (grid[state.y][state.x + 1] != rock)
				next_queue.emplace(state.x + 1, state.y, new_colour);
		}

		std::swap(queue, next_queue);
	}

	while (!queue.empty())
	{
		auto state = queue.front();
		queue.pop();

		if (grid[state.y][state.x] == rock)
		{
			continue;
		}
		grid[state.y][state.x] = mark;
	}
}

void calculate(std::vector<std::string>& grid, int64_t start_x, int64_t start_y, int64_t steps)
{
	int64_t distance{};
	for (auto j{ -steps }; j <= steps; ++j)
	{
		int64_t yy = start_y + j;
		if (yy < 0 || yy >= (int64_t)grid.size())
		{
			continue;
		}
		distance = std::abs(j);
		for (auto i{ -steps + distance }; i <= steps - distance; ++i)
		{
			int64_t xx = start_x + i;
			if (xx < 0 || xx >= (int64_t)grid.front().size())
			{
				continue;
			}

			if (grid[yy][xx] != rock)
			{
				if (distance % 2 == 0)
				{
					if (i % 2 == 0 && steps % 2 == 0)
					{
						grid[yy][xx] = mark;
					}
					else if (std::abs(i) % 2 == 1 && steps % 2 == 1)
					{
						grid[yy][xx] = mark;
					}
				}
				else
				{
					if (std::abs(i) % 2 == 1 && steps % 2 == 0)
					{
						grid[yy][xx] = mark;
					}
					else if (std::abs(i) % 2 == 0 && steps % 2 == 1)
					{
						grid[yy][xx] = mark;
					}
				}
			}
		}
	}
}

void part_1()
{
	LineParser parser{ "in.txt" };
	size_t count{};
	std::vector<std::string> lines{};

	int start_x{};
	int start_y{};
	int y{};
	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			lines.push_back(*line);
			if (line->find_first_of('S') != std::string::npos)
			{
				start_x = (int)line->find_first_of('S');
				start_y = y;
			}
			++y;
		}
	}

	const int steps{ 131 };
	calculate(lines, start_x, start_y, steps);

	for (const auto& line : lines)
	{
		std::cout << line << std::endl;
		count += std::ranges::count(line, mark);
	}

	std::cout << count << std::endl;
}

void part_2()
{
	LineParser parser{ "in.txt" };
	int64_t count{};
	std::vector<std::string> lines{};

	int start_x{};
	int start_y{};
	int y{};
	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			lines.push_back(*line);
			if (line->find_first_of('S') != std::string::npos)
			{
				start_x = (int)line->find_first_of('S');
				start_y = y;
			}
			++y;
		}
	}
	const int steps{ 26501365 };

	const int64_t width = lines.front().size();
	const int64_t half_width{ (width - 1) / 2 };

	auto repeats = (float)(steps - half_width) / width;

	auto full_grid = lines;
	calculate(full_grid, half_width, half_width, 65);

	int64_t full_grid_count{};
	for (const auto& line : full_grid)
	{
		std::cout << line << std::endl;
		full_grid_count += std::ranges::count(line, mark);
	}
	auto left_grid = lines;
	calculate(left_grid, width, start_y, half_width);
	
	int64_t left_grid_count{};
	for (const auto& line : left_grid)
	{
		left_grid_count += std::ranges::count(line, mark);
	}

	auto right_grid = lines;
	calculate(right_grid, 0, half_width, half_width);

	int64_t right_grid_count{};
	for (const auto& line : right_grid)
	{
		right_grid_count += std::ranges::count(line, mark);
	}

	auto top_grid = lines;
	calculate(top_grid, half_width, width - 1, half_width);

	int64_t top_grid_count{};
	for (const auto& line : top_grid)
	{
		top_grid_count += std::ranges::count(line, mark);
	}

	auto bottom_grid = lines;
	calculate(bottom_grid, half_width, 0, half_width);

	int64_t bottom_grid_count{};
	for (const auto& line : bottom_grid)
	{
		bottom_grid_count += std::ranges::count(line, mark);
	}

	auto bottom_left_grid = lines;
	calculate(bottom_left_grid, width - 1, 0, width - 1);

	int64_t bottom_left_grid_count{};
	for (const auto& line : bottom_left_grid)
	{
		bottom_left_grid_count += std::ranges::count(line, mark);
	}

	auto bottom_right_grid = lines;
	calculate(bottom_right_grid, 0, 0, width - 1);

	int64_t bottom_right_grid_count{};
	for (const auto& line : bottom_right_grid)
	{
		bottom_right_grid_count += std::ranges::count(line, mark);
	}

	auto top_right_grid = lines;
	calculate(top_right_grid, 0, width - 1, width - 1);

	int64_t top_right_grid_count{};
	for (const auto& line : top_right_grid)
	{
		top_right_grid_count += std::ranges::count(line, mark);
	}

	auto top_left_grid = lines;
	calculate(top_left_grid, width - 1, width - 1, width - 1);

	int64_t top_left_grid_count{};
	for (const auto& line : top_left_grid)
	{
		top_left_grid_count += std::ranges::count(line, mark);
	}

	int row{1};

	count += top_grid_count + left_grid_count + right_grid_count + bottom_grid_count;
	while (row <= repeats * 2 + 1)
	{
		count += top_left_grid_count + top_right_grid_count + full_grid_count * row;
		row += 2;
	}

	while (row > 1)
	{
		count += bottom_left_grid_count + bottom_right_grid_count + full_grid_count * row;
		row -= 2;
	}

	std::cout << count << std::endl;
}

int main()
{
	part_2();
}