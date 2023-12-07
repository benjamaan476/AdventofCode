#include <iostream>
#include <set>
#include <map>

#include "../../utils/FileParser.h"
#include "../../utils/string_stuff.h"

struct thing
{
	struct line
	{
		int64_t source{};
		int64_t dest{};
		int64_t range{};
	};

	std::vector<line> lines{};

	bool contains(int64_t other_thing)
	{
		for (const auto& [source, dest, amount] : lines)
		{
			if (other_thing >= source && other_thing <= source + amount)
			{
				return true;
			}
		}

		return false;
	}

	int64_t operator[](int64_t other_thing)
	{
		for (const auto& [source, dest, amount] : lines)
		{
			if (other_thing >= source && other_thing <= source + amount)
			{
				auto diff = other_thing - source;
				return dest + diff;
			}
		}

		return -1;
	}
};

void populate_map(thing& map, FILE* f)
{
	char buffer[128]{};

	fgets(buffer, sizeof(buffer), f);

	while (strncmp(buffer, "\n", 2) != 0)
	{
		std::istringstream ss{buffer};
		int64_t source{}, dest{}, amount{};
		ss >> dest >> source >> amount;

		//for (auto i{ 0 }; i < amount; ++i)
		{
			map.lines.emplace_back(source, dest, amount);
		}
		auto count = fgets(buffer, sizeof(buffer), f);
		if (!count)
		{
			break;
		}
	}
}

void part_1()
{
//	int32_t count{};
	FILE* f;
	fopen_s(&f, "in.txt", "r");

	std::vector<int> seeds{};
	thing seed_to_soil{};
	thing soil_to_fertilizer{};
	thing fertilizer_to_water{};
	thing water_to_light{};
	thing light_to_temperature{};
	thing temperature_to_humidity{};
	thing humidity_to_location{};

	if (f)
	{
		char buffer[128]{};
		fgets(buffer, sizeof(buffer), f);

		std::string seeds_string = buffer;
		auto index = seeds_string.find_first_of(':');
		seeds_string = seeds_string.substr(index + 1);
		{
			std::istringstream ss(seeds_string);
			while (ss.good())
			{
				int seed{};
				ss >> seed;
				if (!seed)
				{
					continue;
				}
				seeds.push_back(seed);
			}
		}
		fgets(buffer, sizeof(buffer), f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(seed_to_soil, f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(soil_to_fertilizer, f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(fertilizer_to_water, f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(water_to_light, f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(light_to_temperature, f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(temperature_to_humidity, f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(humidity_to_location, f);

		fclose(f);
	}

	int64_t location = std::numeric_limits<int64_t>::max();
	for (const auto& seed : seeds)
	{
		int64_t soil{};
		if (seed_to_soil.contains(seed))
		{
			soil = seed_to_soil[seed];
		}
		else
		{
			soil = seed;
		}

		int64_t fertilizer{};
		if (soil_to_fertilizer.contains(soil))
		{
			fertilizer = soil_to_fertilizer[soil];
		}
		else
		{
			fertilizer = soil;
		}

		int64_t water{};
		if (fertilizer_to_water.contains(fertilizer))
		{
			water = fertilizer_to_water[fertilizer];
		}
		else
		{
			water = fertilizer;
		}

		int64_t light = water_to_light.contains(water) ? water_to_light[water] : water;
		int64_t temperature = light_to_temperature.contains(light) ? light_to_temperature[light] : light;
		int64_t humidity = temperature_to_humidity.contains(temperature) ? temperature_to_humidity[temperature] : temperature;
		int64_t loc = humidity_to_location.contains(humidity) ? humidity_to_location[humidity] : humidity;

		if (loc < location)
		{
			location = loc;
		}
	}

	std::cout << location << std::endl;

}

struct thing_2
{
	int64_t value{};
	int64_t range{};
};

void part_2()
{
	FILE* f;
	fopen_s(&f, "in.txt", "r");

	std::vector<thing_2> seeds{};
	thing seed_to_soil{};
	thing soil_to_fertilizer{};
	thing fertilizer_to_water{};
	thing water_to_light{};
	thing light_to_temperature{};
	thing temperature_to_humidity{};
	thing humidity_to_location{};

	if (f)
	{
		char buffer[512]{};
		fgets(buffer, sizeof(buffer), f);

		std::string seeds_string = buffer;
		auto index = seeds_string.find_first_of(':');
		seeds_string = seeds_string.substr(index + 1);
		{
			std::istringstream ss(seeds_string);
			while (ss.good())
			{
				int64_t seed{}, range{};
				ss >> seed >> range;
				if (!seed)
				{
					continue;
				}
				//for (auto i{ 0 }; i < range; ++i)
				{
					seeds.emplace_back(seed, range);
				}
			}
		}
		fgets(buffer, sizeof(buffer), f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(seed_to_soil, f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(soil_to_fertilizer, f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(fertilizer_to_water, f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(water_to_light, f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(light_to_temperature, f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(temperature_to_humidity, f);

		fgets(buffer, sizeof(buffer), f);
		populate_map(humidity_to_location, f);

		fclose(f);
	}

	int64_t location = std::numeric_limits<int64_t>::max();

	for (const auto& [start, range] : seeds)
	{
		for (auto i{ start }; i < start + range; ++i)
		{
			int64_t soil = seed_to_soil.contains(i) ? seed_to_soil[i] : i;
			int64_t fertilizer = soil_to_fertilizer.contains(soil) ? soil_to_fertilizer[soil] : soil;
			int64_t water = fertilizer_to_water.contains(fertilizer) ? fertilizer_to_water[fertilizer] : fertilizer;
			int64_t light = water_to_light.contains(water) ? water_to_light[water] : water;
			int64_t temperature = light_to_temperature.contains(light) ? light_to_temperature[light] : light;
			int64_t humidity = temperature_to_humidity.contains(temperature) ? temperature_to_humidity[temperature] : temperature;
			int64_t loc = humidity_to_location.contains(humidity) ? humidity_to_location[humidity] : humidity;

			if (loc < location)
			{
				location = loc;
			}
		}
	}
	std::cout << location << std::endl;
}

int main()
{
	part_2();
}