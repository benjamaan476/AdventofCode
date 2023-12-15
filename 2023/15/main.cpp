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

constexpr const static char block = '#';
constexpr const static char space = '.';
constexpr const static char rock = 'O';

size_t HASH(size_t value, const char input)
{
	if (input == '\n')
	{
		return value;
	}
	value += input;
	value *= 17;
	value = value % 256;
	 
	return value;
}

size_t do_hash(const std::string& input)
{
	size_t start{};
	return std::accumulate(input.begin(), input.end(), start, HASH);
}

void part_1()
{
	DelimitedParser parser{ "in.txt", ','};
	size_t count{};

	std::vector<std::string> lines{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			lines.push_back(*line);
		}
	}

	size_t start{};
	for (const auto& line : lines)
	{
		start = 0;
		auto has = std::accumulate(line.begin(), line.end(),start, HASH);
		count += has;

	}
	std::cout << count << std::endl;
}

struct lens
{
	std::string label{};
	int slot{};

	bool operator==(const lens& other) const
	{
		return label == other.label;
	}
};


void part_2()
{
	DelimitedParser parser{ "in.txt", ','};
	size_t count{};

	std::vector<std::string> lines{};
	

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			lines.push_back(*line);
		}
	}

	std::vector<std::vector<lens>> boxes(256);

	for (const auto& line : lines)
	{
		if (auto split = line.find_first_of('='); split != std::string::npos)
		{
			std::string h = line.substr(0, split);
			auto hash_value = do_hash(h);

			std::string focal_length = line.substr(split + 1);

			lens l{ h, std::stoi(focal_length) };
			
			if (auto pos = std::ranges::find(boxes[hash_value], l); pos != boxes[hash_value].end())
			{
				*pos = l;
			}
			else
			{
				boxes[hash_value].push_back(l);
			}
		}
		else if (split = line.find_first_of('-'); split != std::string::npos)
		{

			std::string h = line.substr(0, split);
			auto hash_value = do_hash(h);


			lens l{ h, 0 };

			if (auto pos = std::ranges::find(boxes[hash_value], l); pos != boxes[hash_value].end())
			{
				boxes[hash_value].erase(pos);
			}
		}
	}
	
	int box_num{ 1 };
	for (const auto& box : boxes)
	{
		for (auto lens_iter = box.begin(); lens_iter != box.end(); lens_iter++)
		{
			auto index = std::distance(box.begin(), lens_iter);
			count += box_num * (index + 1) * lens_iter->slot;
		}
		++box_num;
	}

	std::cout << count << std::endl;
}

int main()
{
	part_2();
}