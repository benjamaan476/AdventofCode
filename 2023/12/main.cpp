#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include <vector>
#include <set>
#include <regex>
#include <numeric>
#include <map>
#include "../../utils/FileParser.h"
#include "../../utils/string_stuff.h"

using memo = std::pair<size_t, size_t>;
using memo_map = std::map<memo, size_t>;

constexpr static const char delim = '.';

struct row
{
	std::string data{};
	std::vector<size_t> groups{};
};

bool matches2(const std::string& input, size_t pos, size_t len)
{
    // Ensure that the preceding character can be a . (need . or ?)
    if ((pos > 0) && (input[pos-1] == '#')) return false;
    // Can't match if the group overruns the input
    if ((pos + len) > input.size()) return false;
    // Ensure that the group items can all be # (need # or ?)
    for (int i = 0; i < len; ++i) if (input[pos+i] == '.') return false;   
    // If we are the end of the input there is no need for a following .
    if ((pos + len) == input.size()) return true;
    // Ensure that the following character can be a . (need . or ?)
    return (input[pos + len] != '#');
}

size_t calculate(const std::string& input, const std::vector<size_t>& groups, size_t pos, size_t grp, memo_map& memo_map)
{
 memo memo = std::make_pair(pos, grp);
    if (memo_map.find(memo) != memo_map.end()) return memo_map[memo];

    if (grp >= groups.size())
    {
        for (auto p: range(pos, input.size())) 
            if (input[p] == '#') return 0;
        return 1;
    }

    size_t result = 0;
    while (pos < input.size())
    {
        if (matches2(input, pos, groups[grp]))
        {
            result += calculate(input, groups, pos + groups[grp] + 1, grp + 1, memo_map);
        }

        if (input[pos] == '#') break;
        ++pos;
    }

    memo_map[memo] = result;
    return result;
}

size_t calculate(const row& row)
{
	std::ostringstream os;
	os << "\\.*";

	for (auto c : row.groups)
	{
		for (auto d : range(c))
		{
			if (d)
			{

			}
			os << '#';
}
		os << "\\.+";
	}

	auto corrupt = row.data + ".";
	
	memo_map map;
	return calculate(corrupt, row.groups, 0, 0, map);
}

size_t process_row(const row& row)
{
	size_t count{};

	count = calculate(row);

	std::cout << count << std::endl;
	return count;
}

void part_1()
{
	LineParser parser{ "in.txt" };
	size_t count{};

	std::vector<row> rows{};
	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			std::string data{};
			std::string group{};
			std::vector<size_t> groups{};

			std::istringstream ss{ *line };
			ss >> data;

			std::string non{};
			ss >> non;

			std::stringstream rr{};
			rr << non << "," << non << "," << non << "," << non << "," << non;
			while (std::getline(rr, group, ','))
			{
				groups.push_back(std::stoi(group));
			}

			data = data + "?" + data + "?" + data + "?" + data + "?" + data;
			rows.emplace_back(data, groups);
		}
	}

	for (const auto& row : rows)
	{
		count += process_row(row);
	}

	std::cout << count << std::endl;
}

void part_2()
{
	LineParser parser{ "in.txt" };
	int64_t count{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
		}
	}

	std::cout << count << std::endl;
}

int main()
{
	part_1();
}