#include <iostream>

#include "../../utils/FileParser.h"

constexpr static const char* up = "(";
constexpr static const char* down = ")";

int main()
{
	CharacterParser characterParser{ "in.txt" };

	int64_t floor{};
	int64_t position{ };
	while (const auto& line = characterParser.next())
	{
		++position;
		if (line.has_value())
		{
			auto f = line->c_str();
			
			if (strcmp(f, up) == 0)
			{
				++floor;
			}
			else if (strcmp(f, down) == 0)
			{
				--floor;
			}

			//std::cout << line.value() << std::endl;
		}
		if(floor == -1)
		{
			std::cout << "Basement: " << position;
		}
	}

	std::cout << "Final floor: " << floor << std::endl;
}