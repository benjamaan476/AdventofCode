#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include <vector>
#include <set>
#include <regex>
#include <map>
#include <numeric>
#include "../../utils/FileParser.h"

constexpr const static char block = '#';
constexpr const static char space = '.';
constexpr const static char rock = 'O';

std::hash<std::string> hasher{};

size_t hash(const std::vector<std::string>& lines)
{
	size_t seed = lines.size();
	for (auto& i : lines)
	{
		seed ^= hasher(i) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
	}
	return seed;
}

void tilt_north(std::vector<std::string>& lines)
{
	for (int y{}; y < lines.size(); ++y)
	{
		auto& line = lines[y];
		for (int x{}; x < line.size(); ++x)
		{
			int yy = y;
			if (line[x] != rock)
			{
				continue;
			}
			while (--yy >= 0)
			{
				auto& next_line = lines[yy][x];

				if (next_line == space)
				{
					next_line = rock;
					lines[yy + 1][x] = space;
				}
				else break;
			}
		}
	}
}

void tilt_south(std::vector<std::string>& lines)
{
	for (auto& line : lines | std::views::reverse)
	{
		int y =(int)(& line - &lines[0]);
		for (int x{}; x < line.size(); ++x)
		{
			int yy = y;
			if (line[x] != rock)
			{
				continue;
			}
			while (++yy < lines.size())
			{
				auto& next_line = lines[yy][x];

				if (next_line == space)
				{
					next_line = rock;
					lines[yy - 1][x] = space;
				}
				else break;
			}
		}
	}
}

void tilt_east(std::vector<std::string>& lines)
{
	for (int y{}; y < lines.size(); ++y)
	{
		auto& line = lines[y];
		for (auto& datum : line | std::views::reverse)
		{
			size_t x = &datum - &line[0];
			auto xx = x;
			if (line[x] != rock)
			{
				continue;
			}
			while (++xx < line.size())
			{
				auto& next_line = line[xx];

				if (next_line == space)
				{
					next_line = rock;
					line[xx - 1] = space;
				}
				else break;
			}
		}
	}
}

void tilt_west(std::vector<std::string>& lines)
{
	for (int y{}; y < lines.size(); ++y)
	{
		auto& line = lines[y];
		for (int x{}; x < line.size(); ++x)
		{
			int xx = x;
			if (line[x] != rock)
			{
				continue;
			}
			while (--xx >= 0)
			{
				auto& next_line = line[xx];

				if (next_line == space)
				{
					next_line = rock;
					line[xx + 1] = space;
				}
				else break;
			}
		}
	}
}

void spin(std::vector<std::string> &lines)
{
	tilt_north(lines);
	tilt_west(lines);
	tilt_south(lines);
	tilt_east(lines);
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

	tilt_north(lines);

	for (auto num_lines = lines.size(); num_lines > 0; --num_lines)
	{
		count += num_lines * std::ranges::count(lines[lines.size() - num_lines], 'O');
	}


	std::cout << count << std::endl;
}

void part_2()
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

	std::map<size_t, std::vector<std::string>> memo{};

	for (int64_t i{}; i < 1000000000; ++i)
	{
		size_t current_hash = hash(lines);
		if (memo.contains(current_hash))
		{
			lines = memo[current_hash];
			continue;
		}
		spin(lines);

		memo.emplace(current_hash, lines);
	}

	for (auto num_lines = lines.size(); num_lines > 0; --num_lines)
	{
		count += num_lines * std::ranges::count(lines[lines.size() - num_lines], 'O');
	}


	std::cout << count << std::endl;
}

int main()
{
	part_2();
}