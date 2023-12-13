#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include <vector>
#include <set>
#include <regex>
#include <numeric>
#include "../../utils/FileParser.h"

struct field
{
std::vector<std::vector<char>> rows{};
	std::vector<std::vector<char>> columns{};

	void process()
	{
		for (int x{}; x < rows.front().size(); ++x)
		{
			columns.push_back({});
			for (int y{}; y < rows.size(); ++y)
			{
				columns.back().push_back(rows[y][x]);
			}
		}
	}

	auto find_symmetry() -> std::pair<bool, int>
	{
		for (int y{}; y < rows.size() - 1; ++y)
		{
			const auto& row = rows[y];
			if (row == rows[y + 1])
			{
				bool match{ true };
				int r = y;
				int rr = y + 1;
				while (r-- && ++rr < rows.size())
				{
					match &= rows[r] == rows[rr];
				}
				
				if (match)
				{
					return { true, y + 1 };
				}
			}
		}

		for (int x{}; x < columns.size() - 1; ++x)
		{
			const auto& column = columns[x];
			if (column == columns[x + 1])
			{
				bool match{ true };
				int r = x;
				int rr = x + 1;
				while (r-- && ++rr < columns.size())
				{
					match &= columns[r] == columns[rr];
				}
				
				if (match)
				{
					return { false, x + 1 };
				}
			}
		}

		return { false, -1 };
	}

	auto find_symmetry(std::pair<bool,int> old_symmetry) -> std::pair<bool, int>
	{
		for (int y{}; y < rows.size() - 1; ++y)
		{
			const auto& row = rows[y];
			if (row == rows[y + 1])
			{
				bool match{ true };
				int r = y;
				int rr = y + 1;
				while (r-- && ++rr < rows.size())
				{
					match &= rows[r] == rows[rr];
				}
				
				if (match)
				{
					auto new_symmetry = std::pair(true, y + 1);
					if (new_symmetry != old_symmetry)
					{
						return { true, y + 1 };
					}
				}
			}
		}

		for (int x{}; x < columns.size() - 1; ++x)
		{
			const auto& column = columns[x];
			if (column == columns[x + 1])
			{
				bool match{ true };
				int r = x;
				int rr = x + 1;
				while (r-- && ++rr < columns.size())
				{
					match &= columns[r] == columns[rr];
				}
				
				if (match)
				{
					auto new_symmetry = std::pair(false, x + 1);

					if (new_symmetry != old_symmetry)
					{
						return { false, x + 1 };
					}
				}
			}
		}

		return { false, -1 };
	}

	auto find_smudge_symmetry() -> std::pair<bool, int>
	{
		std::pair<bool, int> old_symmetry = find_symmetry();

		for (auto& row : rows)
		{
			for (auto& datum : row)
			{
				if (datum == '.')
				{
					datum = '#';
				}
				else
				{
					datum = '.';
				}
				field new_field{ rows };
				new_field.process();

				auto new_symmetry = new_field.find_symmetry(old_symmetry);
				if (new_symmetry != old_symmetry && (new_symmetry != std::pair(false, -1)))
				{
					return new_symmetry;
				}
				if (datum == '.')
				{
					datum = '#';
				}
				else
				{
					datum = '.';
				}
			}
		}

		return { false, 0 };
	}
};
void part_1()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	std::vector<field> fields{1};
	
	while (const auto& line = parser.next())
	{
		if (line.has_value())
		{
			if (*line == "")
			{
				fields.push_back({});
			}
			else
			{
				fields.back().rows.push_back({});
				for (char datum : *line)
				{
					fields.back().rows.back().push_back(datum);
				}
			}
		}
	}

	fields.pop_back();

	for (auto& field : fields)
	{
		field.process();
		auto [is_row, value] = field.find_symmetry();
		count += is_row ? value * 100 : value;
	}


	std::cout << count << std::endl;
}

void part_2()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	std::vector<field> fields{1};
	
	while (const auto& line = parser.next())
	{
		if (line.has_value())
		{
			if (*line == "")
			{
				fields.push_back({});
			}
			else
			{
				fields.back().rows.push_back({});
				for (char datum : *line)
				{
					fields.back().rows.back().push_back(datum);
				}
			}
		}
	}

	fields.pop_back();

	for (auto& field : fields)
	{
		field.process();
		auto [is_row, value] = field.find_smudge_symmetry();
		count += is_row ? value * 100 : value;
	}


	std::cout << count << std::endl;
}

int main()
{
	part_2();
}