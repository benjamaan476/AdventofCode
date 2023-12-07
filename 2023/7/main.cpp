#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include "../../utils/FileParser.h"


void part_1()
{

	int32_t count{ 1 };

	std::vector<int> times{};
	std::vector<int> distances{};

	FILE* f{};
	fopen_s(&f, "in.txt", "r");
	if (f)
	{
		char buffer[512];
		fgets(buffer, sizeof(buffer), f);

		std::string time_string = buffer;
		time_string = time_string.substr(time_string.find_first_of(':') + 1);

		{
			std::istringstream ss{ time_string };
			int time{};
			while (ss >> time)
			{
				times.push_back(time);
			}
		}

		fgets(buffer, sizeof(buffer), f);

		std::string distance_string = buffer;
		distance_string = distance_string.substr(distance_string.find_first_of(':') + 1);

		{
			std::istringstream ss{ distance_string };
			int distance{};
			while (ss >> distance)
			{
				distances.push_back(distance);
			}
		}

		fclose(f);
	}

	for (auto i{ 0 }; i < times.size(); ++i)
	{
		const auto& race_time = times[i];
		const auto& best_distance = distances[i];

		int time{};
		int winning_times{};

		while (++time < race_time)
		{
			int distance = (race_time - time) * time;
			if (distance > best_distance)
			{
				winning_times++;
			}
		}

		count *= winning_times;
	}
	std::cout << count << std::endl;
}

void part_2()
{

	int64_t count{ 1 };

	std::vector<std::string> times{};
	std::vector<std::string> distances{};

	FILE* f{};
	fopen_s(&f, "in.txt", "r");
	if (f)
	{
		char buffer[512];
		fgets(buffer, sizeof(buffer), f);

		std::string time_string = buffer;
		time_string = time_string.substr(time_string.find_first_of(':') + 1);

		{
			std::istringstream ss{ time_string };
			std::string time{};
			while (ss >> time)
			{
				times.push_back(time);
			}
		}


		fgets(buffer, sizeof(buffer), f);

		std::string distance_string = buffer;
		distance_string = distance_string.substr(distance_string.find_first_of(':') + 1);

		{
			std::istringstream ss{ distance_string };
			std::string distance{};
			while (ss >> distance)
			{
				distances.push_back(distance);
			}
		}

		fclose(f);
	}

		std::string total_time{};

		for (const auto& time : times)
		{
			total_time += time;
		}

		std::string total_distance{};

		for (const auto& distance : distances)
		{
			total_distance += distance;
		}
	//	for (auto i{0}; i < times.size(); ++i)
	{
		//		const auto& race_time = times[i];
		//		const auto& best_distance = distances[i];

		int64_t time{};
		int64_t winning_times{};
		auto race_time = std::stoi(total_time);
		auto best_distance = strtoll(total_distance.c_str(), NULL, 10);
		
		while (++time < race_time)
		{
			int64_t distance = (race_time - time) * time;

			if (distance > best_distance)
			{
				winning_times++;
			}
		}

		count *= winning_times;
	}
	std::cout << count << std::endl;
}

int main()
{
	part_2();
}