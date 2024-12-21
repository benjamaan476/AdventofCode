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
#include <queue>
#include "../../utils/FileParser.h"

constexpr const static char path = '.';
constexpr const static char forest = '#';

struct point
{
	int x{};
	int y{};
};

auto reverse_djikstra(std::vector<std::string>& grid, int start_x, int start_y)
{
	std::vector<std::vector<bool>> visited(grid.size());

	for (auto& row : visited)
	{
		row = std::vector<bool>(grid.front().size());
	}

	auto djikstra_map = grid;

	for (auto& row : djikstra_map)
	{
		std::ranges::replace(row, forest, '0');
		std::ranges::replace(row, '>', path);
		std::ranges::replace(row, '<', path);
		std::ranges::replace(row, 'v', path);
		std::ranges::replace(row, '^', path);
	}

	std::queue<point> queue{};
	queue.emplace(start_x, start_y);

	while (!queue.empty())
	{
		const auto [x, y] = queue.front();
		queue.pop();

		if (x <= 0 || x >= grid.front().size() - 1 || y <= 0 || y >= grid.size() - 1)
		{
			continue;
		}

		if (visited[y][x])
		{
			//continue;
		}

		char type = grid[y][x];
		if (type != path && type != '<' && type != 'v' && type != '>' && type != '^')
		{
			continue;
		}


		auto neighbours = { djikstra_map[y + 1][x], djikstra_map[y - 1][x], djikstra_map[y][x + 1], djikstra_map[y][x - 1] };
		auto max = std::ranges::max(neighbours);

		if (djikstra_map[y][x] < max - 1)
		{
			continue;
		}


		djikstra_map[y][x] = max + 1;
		visited[y][x] = true;

		queue.emplace(x + 1, y);
		queue.emplace(x - 1, y);
		queue.emplace(x, y + 1);
		queue.emplace(x, y - 1);
	}

	return djikstra_map;
}

void part_1()
{
	LineParser parser{ "in.txt" };
	size_t count{};

	std::vector<std::string> lines{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			lines.push_back(*line);
		}
	}

	int start_x{ 1 };
	int start_y{ 1 };

	auto djikstra = reverse_djikstra(lines, start_x, start_y);

	for (const auto& row : djikstra)
	{
		std::cout << row << std::endl;
	}
	std::cout << djikstra[21][21] - '0' << std::endl;
	std::cout << count << std::endl;
}


void part_2()
{
	LineParser parser{ "in.txt" };
	size_t count{};
	size_t max_count{};

	std::vector<std::string> lines{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			lines.push_back(*line);
		}
	}


	std::cout << max_count << std::endl;

}

int main()
{
	part_1();
}