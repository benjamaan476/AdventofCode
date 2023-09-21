#include <iostream>

#include "../../utils/FileParser.h"

constexpr static auto delimiter = 'x';

std::vector<int32_t> split(const std::string& string)
{
	std::vector<int32_t> values;
	std::string token{};
	std::stringstream ss(string);
	while (std::getline(ss, token, delimiter))
	{
		values.push_back(stoi(token));
	}
	return values;
}

void part_1()
{
	int32_t totalAmount{};
	LineParser characterParser{ "in.txt" };
	while (const auto& line = characterParser.next())
	{
		if (line.has_value())
		{
			auto tokens = split(*line);
			if (tokens.size() != 3)
			{
				continue;
			}
			auto w = tokens[0];
			auto l = tokens[1];
			auto h = tokens[2];

			auto surface = 2 * w * l + 2 * l * h + 2 * w * h;
			int32_t extra{};

			auto max_side = std::max({ w, l, h });

			if (max_side == w)
			{
				extra = l * h;
			}

			if (max_side == l)
			{
				extra = w * h;
			}

			if (max_side == h)
			{
				extra = l * w;
			}

			auto total = surface + extra;

			totalAmount += total;
		}

	}

	std::cout << "Final floor: " << totalAmount << std::endl;

}

void part_2()
{
	int32_t totalAmount{};
	LineParser characterParser{ "in.txt" };
	while (const auto& line = characterParser.next())
	{
		if (line.has_value())
		{
			auto tokens = split(*line);
			if (tokens.size() != 3)
			{
				continue;
			}
			auto w = tokens[0];
			auto l = tokens[1];
			auto h = tokens[2];

			auto perim1 = 2 * w + 2 * h;
			auto perim2 = 2 * w + 2 * l;
			auto perim3 = 2 * l + 2 * h;

			auto minPerim = std::min({ perim1, perim2, perim3 });
			totalAmount += minPerim;
			totalAmount += w * l * h;

		}
	}

	std::cout << totalAmount << std::endl;
}

int main()
{
	part_2();
}