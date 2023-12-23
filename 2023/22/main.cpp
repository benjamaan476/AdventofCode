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

struct block
{
	int32_t x_0{};
	int32_t y_0{};
	int32_t z_0{};
	int32_t x_1{};
	int32_t y_1{};
	int32_t z_1{};

	bool intersects(const block& other)
	{
		if (z_1 < other.z_0 || z_0 > other.z_1)
		{
			return false;
		}

		if (y_1 < other.y_0 || y_0 > other.y_1)
		{
			return false;
		}

		if (x_1 < other.x_0 || x_0 > other.x_1)
		{
			return false;
		}

		return true;
	}

	bool operator==(const block& other) const = default;
};

void settle(std::vector<block>& blocks)
{
	for (int i{}; i < blocks.size(); ++i)
	{
		bool intersects{};
		while (!intersects)
		{
			auto& block = blocks[i];
			if (block.z_0 <= 1)
			{
				break;
			}
			block.z_0--;
			block.z_1--;
			for (int j{}; j < blocks.size(); ++j)
			{
				if (j == i)
				{
					continue;
				}

				if (blocks[j].z_0 > block.z_1)
				{
				//	break;
				}

				intersects |= block.intersects(blocks[j]);
			}

			if (intersects)
			{
				block.z_0++;
				block.z_1++;
			}
		}
	}
}

void part_1()
{
	LineParser parser{ "in.txt" };
	size_t count{};
	std::vector<block> blocks{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			block b{};

			sscanf_s(line->c_str(), "%d,%d,%d~%d,%d,%d", &b.x_0, &b.y_0, &b.z_0, &b.x_1, &b.y_1, &b.z_1);

			blocks.push_back(b);
		}
	}

	std::ranges::sort(blocks, [](auto& b_0, auto& b_1) { return b_0.z_0 < b_1.z_0; });

	settle(blocks);

	std::ranges::sort(blocks, [](auto& b_0, auto& b_1) { return b_0.z_0 < b_1.z_0; });

	settle(blocks);
	for (int i{}; i < blocks.size(); ++i)
	{
		auto& block = blocks[i];
		auto orig_block = block;
		block.z_0 = block.z_1 = 0;

		auto temp_blocks = blocks;
		settle(temp_blocks);

		block = orig_block;

		bool moved{};

		for (int j{ i + 1 }; j < blocks.size(); ++j)
		{
			if (temp_blocks[j] != blocks[j])
			{
				moved = true;
				break;
			}
		}
		count += moved ? 0 : 1;

	}

	std::cout << count << std::endl;
}

void part_2()
{
	LineParser parser{ "in.txt" };
	size_t count{};
	std::vector<block> blocks{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			block b{};

			sscanf_s(line->c_str(), "%d,%d,%d~%d,%d,%d", &b.x_0, &b.y_0, &b.z_0, &b.x_1, &b.y_1, &b.z_1);

			blocks.push_back(b);
		}
	}

	std::ranges::sort(blocks, [](auto& b_0, auto& b_1) { return b_0.z_0 < b_1.z_0; });

	settle(blocks);

	std::ranges::sort(blocks, [](auto& b_0, auto& b_1) { return b_0.z_0 < b_1.z_0; });

	settle(blocks);
	for (int i{}; i < blocks.size(); ++i)
	{
		auto& block = blocks[i];
		auto orig_block = block;
		block.z_0 = block.z_1 = 0;

		auto temp_blocks = blocks;
		settle(temp_blocks);

		block = orig_block;

		for (int j{ i + 1 }; j < blocks.size(); ++j)
		{
			if (temp_blocks[j] != blocks[j])
			{
				count += 1;
			}
		}

	}

	std::cout << count << std::endl;
}

int main()
{
	part_2();
}