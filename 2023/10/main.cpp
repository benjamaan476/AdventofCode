#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include <vector>
#include <set>
#include "../../utils/FileParser.h"

constexpr static int8_t right = 1 << 0;
constexpr static int8_t down = 1 << 1;
constexpr static int8_t left = 1 << 2;
constexpr static int8_t up = 1 << 3;

struct pipe
{
	char type{};
	int8_t connections{};
	int32_t distance{};
	bool is_loop{};
	bool is_internal{};

	pipe(char type)
		: type{ type }
	{
		switch (type)
		{
		case '|':
			connections |= up | down;
			break;
		case '-':
			connections |= right | left;
			break;
		case 'L':
			connections |= up | right;
			break;
		case 'J':
			connections |= up | left;
			break;
		case '7':
			connections |= down | left;
			break;
		case 'F':
			connections |= right | down;
			break;
		case '.':
			connections = 0;
			break;
		case 'S':
			connections = up | right | down | left;
			break;
		default:
			break;
		}
	}
};

void clear_map(std::vector<std::vector<pipe>>& map)
{
	for (auto y{ 0 }; y < map.size(); ++y)
	{
		auto& row = map[y];
		std::vector<pipe> row_up{};
		std::vector<pipe> row_down{};
		if (y)
		{
			row_up = map[y - 1];
		}

		if (y < map.size() - 1)
		{
			row_down = map[y + 1];
		}

		for (auto x{ 0 }; x < row.size(); ++x)
		{
			auto& p = row[x];
			pipe pipe_right{ '.' };
			pipe pipe_left{ '.' };

			if (x < row.size() - 1)
			{
				pipe_right = row[x + 1];
			}
			if (x)
			{
				pipe_left = row[x - 1];
			}

			if (p.type != '.')
			{
				bool is_connected_up{};
				bool is_connected_down{};
				bool is_connected_right{};
				bool is_connected_left{};
				if (p.connections & up)
				{
					if (!row_up.empty() && row_up[x].connections & down)
					{
						is_connected_up = true;
					}
				}
				if (p.connections & right)
				{
					if (pipe_right.type != '.' && pipe_right.connections & left)
					{
						is_connected_right = true;
					}
				}
				if (p.connections & down)
				{
					if (!row_down.empty() && row_down[x].connections & up)
					{
						is_connected_down = true;
					}
				}
				if (p.connections & left)
				{
					if (pipe_left.type != '.' && pipe_left.connections & right)
					{
						is_connected_left = true;
					}
				}

				auto connections = { is_connected_up, is_connected_right, is_connected_down, is_connected_left };
				auto connection_count = std::ranges::count_if(connections, [](bool connection) { return connection; });

				if (connection_count == 2)
				{

				}
				else
				{
					p.type = '.';
					p.connections = 0;
				}

				if (p.type == 'S')
				{
					p.connections = 0;
					p.connections |= is_connected_up ? up : 0;
					p.connections |= is_connected_right ? right : 0;
					p.connections |= is_connected_left ? left : 0;
					p.connections |= is_connected_down ? down : 0;
				}
			}
		}
	}
}

void remove_non_loop(std::vector<std::vector<pipe>>& map)
{
	for (auto& row : map)
	{
		for (auto& pipe : row)
		{
			if (!pipe.is_loop)
			{
				pipe.type = '.';
				pipe.connections = 0;
			}
		}
	}
}

void draw_map(const std::vector<std::vector<pipe>>& map)
{
	for (const auto& row : map)
	{
		for (const auto& pipe : row)
		{
			if (pipe.type == '.')
			{
				std::cout << " ";
			}
			else
			{
				std::cout << pipe.type;
			}
		}
		std::cout << std::endl;
	}
	std::cout << std::endl;
}

void draw_map_distance(const std::vector<std::vector<pipe>>& map)
{
	for (const auto& row : map)
	{
		for (const auto& pipe : row)
		{
			if (pipe.type == '.')
			{
				std::cout << '.';
			}
			else
			{
				std::cout << pipe.distance;
			}
		}
		std::cout << std::endl;
	}
	std::cout << std::endl;
}

void draw_map_internal(const std::vector<std::vector<pipe>>& map)
{
	for (const auto& row : map)
	{
		for (const auto& pipe : row)
		{
			if (pipe.is_internal)
			{
				std::cout << '*';
			}
			else
			{
				std::cout << '.';
			}
		}
		std::cout << std::endl;
	}
	std::cout << std::endl;
}

pipe* find_next(std::vector<std::vector<pipe>>& map, int& x, int& y, int8_t& previous_connection)
{
	auto& current_pipe = map[y][x];

	if (current_pipe.connections & up && previous_connection != up)
	{
		previous_connection = down;
		y -= 1;
	}
	else if (current_pipe.connections & right && previous_connection != right)
	{
		previous_connection = left;
		x += 1;
	}
	else if (current_pipe.connections & down && previous_connection != down)
	{
		previous_connection = up;
		y += 1;
	}
	else if (current_pipe.connections & left && previous_connection != left)
	{
		previous_connection = right;
		x -= 1;
	}
	else
	{
		x = x;
	}

	return &map[y][x];
}

int32_t walk_map(std::vector<std::vector<pipe>>& map, int start_x, int start_y)
{
	int first_x = start_x;
	int first_y = start_y;
	int second_x = start_x;
	int second_y = start_y;

	auto* p = &map[start_y][start_x];
	p->is_loop = true;
	int distance{};

	int8_t previous_first{};
	int8_t previous_second{};

	if (p->type == '.')
	{
		std::cout << "Error";
	}

	auto next_first = find_next(map, first_x, first_y, previous_first);
	if (previous_first == up)
	{
		previous_second = down;
	}
	if (previous_first == right)
	{
		previous_second = left;
	}
	if (previous_first == down)
	{
		previous_second = up;
	}
	if (previous_first == left)
	{
		previous_second = right;
	}
	auto next_second = find_next(map, second_x, second_y, previous_second);

	++distance;
	if (next_first->distance == 0)
	{
		next_first->distance = distance;
	}

	if (next_second->distance == 0)
	{
		next_second->distance = distance;
	}

	for (;;)
	{
		next_first = find_next(map, first_x, first_y, previous_first);
		next_second = find_next(map, second_x, second_y, previous_second);
		++distance;
		if (next_first->distance == 0)
		{
			next_first->is_loop = true;
			next_first->distance = distance;
		}
		else
		{
			return distance;
		}

		if (next_second->distance == 0)
		{
			next_second->is_loop = true;
			next_second->distance = distance;
		}
		else
		{
			return distance;
		}

	}

}

int32_t spin_map(std::vector<std::vector<pipe>>& map)
{
	int32_t inner_count{};
	for (auto y{ 0 }; y < map.size(); ++y)
	{
		auto& row = map[y];
		for (auto x{ 0 }; x < row.size(); ++x)
		{
			int xx = x;
			int left_count{};
			int yy = y;
			while (--xx >= 0 && ++yy <= map.size() - 1)
			{
				left_count += (map[yy][xx].type == '-' || map[yy][xx].type == '|' || map[yy][xx].type == '7' || map[yy][xx].type == 'L') ? 1 : 0;
			}
		//	while (--xx >= 0)
			//{
				//left_count += (row[xx].type != '-' && row[xx].type != '.') ? 1 : 0;
			//}

			int right_count{};
			xx = x;
			while (++xx <= row.size() - 1)
			{
				right_count += (row[xx].type != '-' && row[xx].type != '.') ? 1 : 0;

			}

			int up_count{};

			while (--yy >= 0)
			{
				up_count += (map[yy][x].type != '|' && map[yy][x].type != '.') ? 1 : 0;
			}

			yy = y;
			int down_count{};
			while (++yy <= map.size() - 1)
			{
				auto r = map[yy];
				down_count += (r[x].type != '|' && r[x].type != '.') ? 1 : 0;
			}


			auto counts = { up_count , down_count, right_count};
			auto outer = std::ranges::any_of(counts, [](int count) { return count == 0; });
			//outer |= std::ranges::all_of(counts, [](int count) { return (count % 2 == 0) ; });
			//outer |= std::ranges::all_of(counts, [](int count) { return (count % 2 == 0); });
			if (!outer && (left_count % 2 == 1) && !row[x].is_loop)
			{
				row[x].is_internal = true;
				++inner_count;
			}
		}
	}
	return inner_count;
}

void part_1()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	std::vector<std::vector<pipe>> map{};

	int start_x{};
	int start_y{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			map.push_back({});

			auto& row = map.back();
			for (const auto& pipe : *line)
			{
				row.emplace_back(pipe);
				if (pipe == 'S')
				{
					start_x = (int)row.size() - 1;
					start_y = (int)map.size() - 1;
				}
			}
		}
	}

	draw_map(map);
	clear_map(map);
	clear_map(map);
	draw_map(map);
	draw_map_distance(map);

	count = walk_map(map, start_x, start_y);
	//draw_map_distance(map);

	std::cout << count << std::endl;
}

void part_2()
{
	LineParser parser{ "in.txt" };
	int64_t count{};

	std::vector<std::vector<pipe>> map{};

	int start_x{};
	int start_y{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			map.push_back({});

			auto& row = map.back();
			for (const auto& pipe : *line)
			{
				row.emplace_back(pipe);
				if (pipe == 'S')
				{
					start_x = (int)row.size() - 1;
					start_y = (int)map.size() - 1;
				}
			}
		}
	}

	//draw_map(map);
	clear_map(map);
	clear_map(map);
	clear_map(map);
	clear_map(map);
	//clear_map(map);
	draw_map(map);

	count = walk_map(map, start_x, start_y);
	remove_non_loop(map);
	//draw_map_distance(map);

	count = spin_map(map);
	draw_map_internal(map);
	//draw_map_distance(map);

	std::cout << count << std::endl;
}
int main()
{
	part_2();
}