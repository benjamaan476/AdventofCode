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

struct xmas
{
	int x{};
	int m{};
	int a{};
	int s{};
};

bool process(const std::map<std::string, std::string>& instructions, const std::string& instruction, const xmas& xmas)
{
	if (instruction == "R")
	{
		return false;
	}
	
	if (instruction == "A")
	{
		return true;
	}

	auto inst = instructions.at(instruction);
	std::istringstream ss{ inst };
	std::string instr{};
	while (std::getline(ss, instr, ','))
	{
		if (instr.find_first_of(':') == std::string::npos)
		{
			return process(instructions, instr, xmas);
		}
		char arg{};
		char op{};
		int num{};
		char waste{};
		std::string next_instruction{};
		std::istringstream sss{ instr };
		sss >> arg >> op >> num >> waste >> next_instruction;

		int arguement = xmas.x;

		if (arg == 'x')
		{
			arguement = xmas.x;
		}
		else if (arg == 'm')
		{
			arguement = xmas.m;
		}
		else if (arg == 'a')
		{
			arguement = xmas.a;
		}
		else if (arg == 's')
		{
			arguement = xmas.s;
		}
		else
		{
			return false;
		}

		if (op == '<')
		{
			if (arguement < num)
			{
				return process(instructions, next_instruction, xmas);
			}
		}

		if (op == '>')
		{
			if (arguement > num)
			{
				return process(instructions, next_instruction, xmas);
			}
		}
	}
	
	return false;
}

void part_1()
{
	size_t count{};
	FILE* f{};

	std::map<std::string, std::string> instructions{};
	std::vector<xmas> xmass{};

	fopen_s(&f, "in.txt", "r");
	if (f)
	{
		char buffer[1024];
		fgets(buffer, sizeof(buffer), f);
		while (buffer[0] != '\n')
		{
			std::string input{ buffer };
			auto name = input.substr(0, input.find_first_of('{'));
			auto instruction = input.substr(input.find_first_of('{') + 1, input.find_last_of('}') - input.find_first_of('{') - 1);

			instructions.emplace(name, instruction);
			fgets(buffer, sizeof(buffer), f);
		}

		while (fgets(buffer, sizeof(buffer), f))
		{
			xmas x{};

			sscanf_s(buffer, "{x=%d,m=%d,a=%d,s=%d", &x.x, &x.m, &x.a, &x.s);
			xmass.push_back(x);
		}
		fclose(f);
	}

	std::vector<xmas> accepted{};

	for (const auto& x : xmass)
	{
		if (process(instructions, "in", x))
		{
			accepted.push_back(x);
}
	}

	for (const auto& x : accepted)
	{
		count += x.x + x.m + x.a + x.s;
	}

	std::cout << count << std::endl;
}

struct point
{
	uint64_t x{};
	uint64_t y{};

	uint64_t operator+(const point& other) const
	{
		return x * other.y - y * other.x;
	}
};

void part_2()
{
	size_t count{};
	FILE* f{};

	std::map<std::string, std::string> instructions{};
	std::vector<xmas> xmass{};

	fopen_s(&f, "in.txt", "r");
	if (f)
	{
		char buffer[1024];
		fgets(buffer, sizeof(buffer), f);
		while (buffer[0] != '\n')
		{
			std::string input{ buffer };
			auto name = input.substr(0, input.find_first_of('{'));
			auto instruction = input.substr(input.find_first_of('{') + 1, input.find_last_of('}') - input.find_first_of('{') - 1);

			instructions.emplace(name, instruction);
			fgets(buffer, sizeof(buffer), f);
		}

		while (fgets(buffer, sizeof(buffer), f))
		{
			xmas x{};

			sscanf_s(buffer, "{x=%d,m=%d,a=%d,s=%d", &x.x, &x.m, &x.a, &x.s);
			xmass.push_back(x);
		}
		fclose(f);
	}

	std::vector<xmas> accepted{};

	for (int x{ 1 }; x <= 4000; ++x)
	{
		for (int m{ 1 }; m <= 4000; ++m)
		{
			for (int a{ 1 }; a <= 4000; ++a)
			{
				for (int s{ 1 }; s <= 4000; ++s)
				{
					xmas xx{ x, m,a, s };
					if (process(instructions, "in", xx))
					{
						accepted.push_back(xx);
					}
				}
			}
		}
	}

	for (const auto& x : accepted)
	{
		count += x.x + x.m + x.a + x.s;
	}

	std::cout << count << std::endl;
}

int main()
{
	part_2();
}