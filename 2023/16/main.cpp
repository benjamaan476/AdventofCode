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
#include "../../utils/FileParser.h"

constexpr const static char space = '.';
constexpr const static char energy = '#';
enum class direction
{
	up,
	right,
	down,
	left
};

struct beam
{
	int x{};
	int y{};
	direction dir{direction::right};
};

void part_1()
{
	LineParser parser{ "in.txt" };
	size_t count{};

	std::vector<std::string> lines{};
	std::vector<std::string> energized{};
	std::vector<std::string> sources_grid{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			lines.push_back(*line);
		}
	}

	sources_grid = lines;
	energized = lines;
	beam dir{};

	std::vector<beam> sources{dir};

	for (size_t i{}; i < sources.size(); ++i)
	{
		for (;;)
		{
			bool has_left{};
			auto& beam = sources[i];

			energized[beam.y][beam.x] = energy;

			auto next_cell = lines[beam.y][beam.x];

			switch (next_cell)
			{
			case '-':
				if (beam.dir == direction::up || beam.dir == direction::down)
				{
					beam.dir = direction::right;
					if (sources_grid[beam.y][beam.x] != '&')
					{
						sources_grid[beam.y][beam.x] = '&';
						sources.emplace_back(beam.x, beam.y, direction::left);
					}
				} break;
			case '|':
				if (beam.dir == direction::right || beam.dir == direction::left)
				{
					beam.dir = direction::down;
					if (sources_grid[beam.y][beam.x] != '&')
					{
						sources_grid[beam.y][beam.x] = '&';

						sources.emplace_back(beam.x, beam.y, direction::up);
					}
				} break;
			case '/':
				switch (beam.dir)
				{
				case direction::up:
					beam.dir = direction::right;
					break;
				case direction::right:
					beam.dir = direction::up;
					break;
				case direction::down:
					beam.dir = direction::left;
					break;
				case direction::left:
					beam.dir = direction::down;
					break;
				default:
					break;
				} break;
			case '\\':
				switch (beam.dir)
				{
				case direction::up:
					beam.dir = direction::left;
					break;
				case direction::right:
					beam.dir = direction::down;
					break;
				case direction::down:
					beam.dir = direction::right;
					break;
				case direction::left:
					beam.dir = direction::up;
					break;
				default:
					break;
				} break;

			case '.':
			default:
				break;
			}

			switch (beam.dir)
			{
			case direction::up:
				if (beam.y == 0)
				{
					has_left = true;
					break;
				}
				--beam.y;
				break;
			case direction::right:
				if (beam.x == lines.front().size() - 1)
				{
					has_left = true;
					break;
				}
				++beam.x;
				break;
			case direction::down:
				if (beam.y == lines.size() - 1)
				{
					has_left = true;
					break;
				}
				++beam.y;
				break;
			case direction::left:
				if (beam.x == 0)
				{
					has_left = true;
					break;
				}
				--beam.x;
				break;
			default:
				break;
			}

			if (has_left)
			{
				break;
			}
		}
	}

	for (const auto& line : energized)
	{
		count += std::ranges::count_if(line, [](char datum) { return datum == '#'; });
	}
	std::cout << count << std::endl;
}


void part_2()
{
	LineParser parser{ "in.txt" };
	size_t count{};
	size_t max_count{};

	std::vector<std::string> lines{};
	std::vector<std::string> energized{};
	std::vector<std::string> sources_grid{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			lines.push_back(*line);
		}
	}

	for (int x{}; x < lines.front().size(); ++x)
	{
		count = 0;
		beam b{ x, 0, direction::down };
		sources_grid = lines;
		energized = lines;

		std::vector<beam> sources{b};

		for (size_t i{}; i < sources.size(); ++i)
		{
			for (;;)
			{
				bool has_left{};
				auto& beam = sources[i];

				energized[beam.y][beam.x] = energy;

				auto next_cell = lines[beam.y][beam.x];

				switch (next_cell)
				{
				case '-':
					if (beam.dir == direction::up || beam.dir == direction::down)
					{
						beam.dir = direction::right;
						if (sources_grid[beam.y][beam.x] != '&')
						{
							sources_grid[beam.y][beam.x] = '&';
							sources.emplace_back(beam.x, beam.y, direction::left);
						}
					} break;
				case '|':
					if (beam.dir == direction::right || beam.dir == direction::left)
					{
						beam.dir = direction::down;
						if (sources_grid[beam.y][beam.x] != '&')
						{
							sources_grid[beam.y][beam.x] = '&';

							sources.emplace_back(beam.x, beam.y, direction::up);
						}
					} break;
				case '/':
					switch (beam.dir)
					{
					case direction::up:
						beam.dir = direction::right;
						break;
					case direction::right:
						beam.dir = direction::up;
						break;
					case direction::down:
						beam.dir = direction::left;
						break;
					case direction::left:
						beam.dir = direction::down;
						break;
					default:
						break;
					} break;
				case '\\':
					switch (beam.dir)
					{
					case direction::up:
						beam.dir = direction::left;
						break;
					case direction::right:
						beam.dir = direction::down;
						break;
					case direction::down:
						beam.dir = direction::right;
						break;
					case direction::left:
						beam.dir = direction::up;
						break;
					default:
						break;
					} break;

				case '.':
				default:
					break;
				}

				switch (beam.dir)
				{
				case direction::up:
					if (beam.y == 0)
					{
						has_left = true;
						break;
					}
					--beam.y;
					break;
				case direction::right:
					if (beam.x == lines.front().size() - 1)
					{
						has_left = true;
						break;
					}
					++beam.x;
					break;
				case direction::down:
					if (beam.y == lines.size() - 1)
					{
						has_left = true;
						break;
					}
					++beam.y;
					break;
				case direction::left:
					if (beam.x == 0)
					{
						has_left = true;
						break;
					}
					--beam.x;
					break;
				default:
					break;
				}

				if (has_left)
				{
					break;
				}
			}
		}

		for (const auto& line : energized)
		{
			count += std::ranges::count_if(line, [](char datum) { return datum == '#'; });
		}
		max_count = std::max(count, max_count);
	}

	for (int x{}; x < lines.front().size(); ++x)
	{
		count = 0;

		beam b{ x, (int)lines.size() - 1, direction::up};
		sources_grid = lines;
		energized = lines;

		std::vector<beam> sources{b};

		for (size_t i{}; i < sources.size(); ++i)
		{
			for (;;)
			{
				bool has_left{};
				auto& beam = sources[i];

				energized[beam.y][beam.x] = energy;

				auto next_cell = lines[beam.y][beam.x];

				switch (next_cell)
				{
				case '-':
					if (beam.dir == direction::up || beam.dir == direction::down)
					{
						beam.dir = direction::right;
						if (sources_grid[beam.y][beam.x] != '&')
						{
							sources_grid[beam.y][beam.x] = '&';
							sources.emplace_back(beam.x, beam.y, direction::left);
						}
					} break;
				case '|':
					if (beam.dir == direction::right || beam.dir == direction::left)
					{
						beam.dir = direction::down;
						if (sources_grid[beam.y][beam.x] != '&')
						{
							sources_grid[beam.y][beam.x] = '&';

							sources.emplace_back(beam.x, beam.y, direction::up);
						}
					} break;
				case '/':
					switch (beam.dir)
					{
					case direction::up:
						beam.dir = direction::right;
						break;
					case direction::right:
						beam.dir = direction::up;
						break;
					case direction::down:
						beam.dir = direction::left;
						break;
					case direction::left:
						beam.dir = direction::down;
						break;
					default:
						break;
					} break;
				case '\\':
					switch (beam.dir)
					{
					case direction::up:
						beam.dir = direction::left;
						break;
					case direction::right:
						beam.dir = direction::down;
						break;
					case direction::down:
						beam.dir = direction::right;
						break;
					case direction::left:
						beam.dir = direction::up;
						break;
					default:
						break;
					} break;

				case '.':
				default:
					break;
				}

				switch (beam.dir)
				{
				case direction::up:
					if (beam.y == 0)
					{
						has_left = true;
						break;
					}
					--beam.y;
					break;
				case direction::right:
					if (beam.x == lines.front().size() - 1)
					{
						has_left = true;
						break;
					}
					++beam.x;
					break;
				case direction::down:
					if (beam.y == lines.size() - 1)
					{
						has_left = true;
						break;
					}
					++beam.y;
					break;
				case direction::left:
					if (beam.x == 0)
					{
						has_left = true;
						break;
					}
					--beam.x;
					break;
				default:
					break;
				}

				if (has_left)
				{
					break;
				}
			}
		}

		for (const auto& line : energized)
		{
			count += std::ranges::count_if(line, [](char datum) { return datum == '#'; });
		}
		max_count = std::max(count, max_count);
	}

	for (int y{}; y < lines.size(); ++y)
	{
		count = 0;

		beam b{ 0, y, direction::right };
		sources_grid = lines;
		energized = lines;

		std::vector<beam> sources{b};

		for (size_t i{}; i < sources.size(); ++i)
		{
			for (;;)
			{
				bool has_left{};
				auto& beam = sources[i];

				energized[beam.y][beam.x] = energy;

				auto next_cell = lines[beam.y][beam.x];

				switch (next_cell)
				{
				case '-':
					if (beam.dir == direction::up || beam.dir == direction::down)
					{
						beam.dir = direction::right;
						if (sources_grid[beam.y][beam.x] != '&')
						{
							sources_grid[beam.y][beam.x] = '&';
							sources.emplace_back(beam.x, beam.y, direction::left);
						}
					} break;
				case '|':
					if (beam.dir == direction::right || beam.dir == direction::left)
					{
						beam.dir = direction::down;
						if (sources_grid[beam.y][beam.x] != '&')
						{
							sources_grid[beam.y][beam.x] = '&';

							sources.emplace_back(beam.x, beam.y, direction::up);
						}
					} break;
				case '/':
					switch (beam.dir)
					{
					case direction::up:
						beam.dir = direction::right;
						break;
					case direction::right:
						beam.dir = direction::up;
						break;
					case direction::down:
						beam.dir = direction::left;
						break;
					case direction::left:
						beam.dir = direction::down;
						break;
					default:
						break;
					} break;
				case '\\':
					switch (beam.dir)
					{
					case direction::up:
						beam.dir = direction::left;
						break;
					case direction::right:
						beam.dir = direction::down;
						break;
					case direction::down:
						beam.dir = direction::right;
						break;
					case direction::left:
						beam.dir = direction::up;
						break;
					default:
						break;
					} break;

				case '.':
				default:
					break;
				}

				switch (beam.dir)
				{
				case direction::up:
					if (beam.y == 0)
					{
						has_left = true;
						break;
					}
					--beam.y;
					break;
				case direction::right:
					if (beam.x == lines.front().size() - 1)
					{
						has_left = true;
						break;
					}
					++beam.x;
					break;
				case direction::down:
					if (beam.y == lines.size() - 1)
					{
						has_left = true;
						break;
					}
					++beam.y;
					break;
				case direction::left:
					if (beam.x == 0)
					{
						has_left = true;
						break;
					}
					--beam.x;
					break;
				default:
					break;
				}

				if (has_left)
				{
					break;
				}
			}
		}

		for (const auto& line : energized)
		{
			count += std::ranges::count_if(line, [](char datum) { return datum == '#'; });
		}
		max_count = std::max(count, max_count);
	}

	for (int y{}; y < lines.size(); ++y)
	{
		count = 0;

		beam b{ (int)lines.size() - 1, y, direction::left};
		sources_grid = lines;
		energized = lines;

		std::vector<beam> sources{b};

		for (size_t i{}; i < sources.size(); ++i)
		{
			for (;;)
			{
				bool has_left{};
				auto& beam = sources[i];

				energized[beam.y][beam.x] = energy;

				auto next_cell = lines[beam.y][beam.x];

				switch (next_cell)
				{
				case '-':
					if (beam.dir == direction::up || beam.dir == direction::down)
					{
						beam.dir = direction::right;
						if (sources_grid[beam.y][beam.x] != '&')
						{
							sources_grid[beam.y][beam.x] = '&';
							sources.emplace_back(beam.x, beam.y, direction::left);
						}
					} break;
				case '|':
					if (beam.dir == direction::right || beam.dir == direction::left)
					{
						beam.dir = direction::down;
						if (sources_grid[beam.y][beam.x] != '&')
						{
							sources_grid[beam.y][beam.x] = '&';

							sources.emplace_back(beam.x, beam.y, direction::up);
						}
					} break;
				case '/':
					switch (beam.dir)
					{
					case direction::up:
						beam.dir = direction::right;
						break;
					case direction::right:
						beam.dir = direction::up;
						break;
					case direction::down:
						beam.dir = direction::left;
						break;
					case direction::left:
						beam.dir = direction::down;
						break;
					default:
						break;
					} break;
				case '\\':
					switch (beam.dir)
					{
					case direction::up:
						beam.dir = direction::left;
						break;
					case direction::right:
						beam.dir = direction::down;
						break;
					case direction::down:
						beam.dir = direction::right;
						break;
					case direction::left:
						beam.dir = direction::up;
						break;
					default:
						break;
					} break;

				case '.':
				default:
					break;
				}

				switch (beam.dir)
				{
				case direction::up:
					if (beam.y == 0)
					{
						has_left = true;
						break;
					}
					--beam.y;
					break;
				case direction::right:
					if (beam.x == lines.front().size() - 1)
					{
						has_left = true;
						break;
					}
					++beam.x;
					break;
				case direction::down:
					if (beam.y == lines.size() - 1)
					{
						has_left = true;
						break;
					}
					++beam.y;
					break;
				case direction::left:
					if (beam.x == 0)
					{
						has_left = true;
						break;
					}
					--beam.x;
					break;
				default:
					break;
				}

				if (has_left)
				{
					break;
				}
			}
		}

		for (const auto& line : energized)
		{
			count += std::ranges::count_if(line, [](char datum) { return datum == '#'; });
		}
		max_count = std::max(count, max_count);
	}

	std::cout << max_count << std::endl;

}

int main()
{
	part_2();
}