#include <iostream>
#include <set>

#include "../../utils/FileParser.h"

static inline void ltrim(std::string& s)
{
	s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char ch) {
		return !std::isspace(ch);
									}));
}

// trim from end (in place)
static inline void rtrim(std::string& s)
{
	s.erase(std::find_if(s.rbegin(), s.rend(), [](unsigned char ch) {
		return !std::isspace(ch);
						 }).base(), s.end());
}

// trim from both ends (in place)
static inline void trim(std::string& s)
{
	rtrim(s);
	ltrim(s);
}

int32_t string_to_num(const std::string& str)
{
	if (str == "1" || str == "one")
	{
		return 1;
	}
	else if (str == "2" || str == "two")
	{
		return  2;
	}
	else if (str == "3" || str == "three")
	{
		return  3;
	}
	else if (str == "4" || str == "four")
	{
		return  4;
	}
	else if (str == "5" || str == "five")
	{
		return  5;
	}
	else if (str == "6" || str == "six")
	{
		return  6;
	}
	else if (str == "7" || str == "seven")
	{
		return  7;
	}
	else if (str == "8" || str == "eight")
	{
		return  8;
	}
	else if (str == "9" || str == "nine")
	{
		return  9;
	}

	try
	{
		return std::stoi(str);
	}
	catch (std::exception e)
	{
		return -1;
	}
}

void part_1()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	while (const auto& line = parser.next())
	{
		if (line.has_value())
		{
			std::set<int> red{};
			std::set<int> green{};
			std::set<int> blue{};

			auto& val = *line;

			auto invalid_game = false;
			auto split = val.find_first_of(':');
			if (split != std::string::npos)
			{
				std::cout << val << '\n';

				auto game_id = val.substr(0, split);
				auto games = val.substr(split + 2);

				std::istringstream ss(games);
				std::string game;

				while (std::getline(ss, game, ';'))
				{
					if (invalid_game)
					{
						break;
					}

					std::istringstream game_stream(game);
					std::string cube;

					while (std::getline(game_stream, cube, ','))
					{
						trim(cube);
						auto space = cube.find_first_of(' ');
						if (space != std::string::npos)
						{
							auto var = cube.substr(0, space);
							trim(var);
							auto number = string_to_num(var);
							auto colour = cube.substr(space + 1);

							if (colour == "red")
							{
								red.insert(number);
							}
							else if (colour == "green")
							{
								green.insert(number);
							}
							else
							{
								blue.insert(number);
							}

						}
					}
				}

				count += *red.rbegin() * *green.rbegin() * *blue.rbegin();
				
			}
		}
	}

	std::cout << count << std::endl;

}


void part_2()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	while (const auto& line = parser.next())
	{
		if (line.has_value())
		{
			//const auto& val = *line;


		}
	}

	std::cout << count << std::endl;
}

int main()
{
	part_1();

}