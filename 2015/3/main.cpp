#include <iostream>
#include <array>
#include <ranges>
#include "../../utils/FileParser.h"

constexpr static auto up = "^";
constexpr static auto right = ">";
constexpr static auto down = "v";
constexpr static auto left = "<";


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

constexpr static int width = 500;
constexpr static int height = 500;


void part_1()
{
	std::array<bool, width * height> houses{};

	int posX = width / 2;
	int posY = height / 2;


	houses.at(posY * width + posX) = true;

	CharacterParser characterParser{ "in.txt" };
	while (const auto& line = characterParser.next())
	{
		if (line.has_value())
		{
			if (strcmp(line->c_str(), up) == 0)
			{
				++posY;
			}
			if (strcmp(line->c_str(), right) == 0)
			{
				++posX;
			}
			if (strcmp(line->c_str(), down) == 0)
			{
				--posY;
			}
			if (strcmp(line->c_str(), left) == 0)
			{
				--posX;
			}
			houses.at(posY * width + posX) = true;
		}
	}

	auto visited = std::ranges::count_if(houses, [](bool visited) { return visited; });

	std::cout << visited << std::endl;
}

void part_2()
{
	std::array<bool, width* height> houses{};

	int santaPosX = width / 2;
	int santaPosY = height / 2;
	int roboSantaPosX = width / 2;
	int roboSantaPosY = height / 2;

	auto isSantaTurn = true;

	houses.at(santaPosY * width + santaPosX) = true;

	CharacterParser characterParser{ "in.txt" };
	while (const auto& line = characterParser.next())
	{
		if (line.has_value())
		{
			if (strcmp(line->c_str(), up) == 0)
			{
				isSantaTurn ? ++santaPosY : ++roboSantaPosY;
			}
			if (strcmp(line->c_str(), right) == 0)
			{
				isSantaTurn ? ++santaPosX : ++roboSantaPosX;
			}
			if (strcmp(line->c_str(), down) == 0)
			{
				isSantaTurn ? --santaPosY : --roboSantaPosY;
			}
			if (strcmp(line->c_str(), left) == 0)
			{
				isSantaTurn ? --santaPosX : --roboSantaPosX;
			}
			houses.at(santaPosY * width + santaPosX) = true;
			houses.at(roboSantaPosY * width + roboSantaPosX) = true;

			isSantaTurn = !isSantaTurn;
		}
	}

	auto visited = std::ranges::count_if(houses, [](bool visited) { return visited; });

	std::cout << visited << std::endl;

}

int main()
{
	part_2();
}