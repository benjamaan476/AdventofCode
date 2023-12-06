#include <iostream>
#include <set>
#include "../../utils/FileParser.h"
#include "../../utils/string_stuff.h"


void part_1()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	while (const auto& line = parser.next())
	{
		if (line.has_value())
		{
			auto val = *line;
			std::set<int32_t> winning_numbers{};
			std::vector<int32_t> numbers{};
			//Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
			int32_t line_number{};
			const char winning_numbers_string[256]{};
			const char numbers_string[256]{};
			const char* format = "Card %d: %[^\t\n|] | %[^\t\n]";
			sscanf_s(val.c_str(), format, &line_number, winning_numbers_string, sizeof(winning_numbers_string), numbers_string, sizeof(numbers_string));

			{
				std::istringstream ss(winning_numbers_string);
				while (!ss.eof())
				{
					int32_t number{};
					ss >> number;
					winning_numbers.insert(number);

				}
			}
			{
				std::istringstream ss(numbers_string);
				while (!ss.eof())
				{
					int32_t number{};
					ss >> number;
					numbers.push_back(number);

				}
			}
			int32_t score{};

			for (const auto& number : numbers)
			{
				if (winning_numbers.contains(number))
				{
					if (score == 0)
					{
						score++;
					}
					else
					{
						score *= 2;
					}
}

			}
			count += score;
		}
	}

	std::cout << count << std::endl;

}


void part_2()
{
	LineParser parser{ "in.txt" };
	int32_t count{};
	std::vector<int32_t> cards(213);
	std::fill(cards.begin(), cards.end(), 1);

	while (const auto& line = parser.next())
	{
		if (line.has_value())
		{
			auto val = *line;
			std::set<int32_t> winning_numbers{};
			std::vector<int32_t> numbers{};
			//Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
			int32_t line_number{};
			const char winning_numbers_string[256]{};
			const char numbers_string[256]{};
			const char* format = "Card %d: %[^\t\n|] | %[^\t\n]";
			sscanf_s(val.c_str(), format, &line_number, winning_numbers_string, sizeof(winning_numbers_string), numbers_string, sizeof(numbers_string));

			{
				std::istringstream ss(winning_numbers_string);
				while (!ss.eof())
				{
					int32_t number{};
					ss >> number;
					winning_numbers.insert(number);

				}
			}
			{
				std::istringstream ss(numbers_string);
				while (!ss.eof())
				{
					int32_t number{};
					ss >> number;
					numbers.push_back(number);

				}
			}
			int32_t score{};

			for (const auto& number : numbers)
			{
				if (winning_numbers.contains(number))
				{
					++score;
					cards[line_number + score - 1] += cards[line_number - 1];
				}

			}
			//count += score;
		}
	}

	for (auto f : cards)
	{
		count += f;
	}
	std::cout << count << std::endl;
}

int main()
{
	part_2();

}