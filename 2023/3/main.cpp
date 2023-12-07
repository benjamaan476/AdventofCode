#include <iostream>

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

bool is_number(const std::string& s)
{
	std::string::const_iterator it = s.begin();
	while (it != s.end() && std::isdigit(*it)) ++it;
	return !s.empty() && it == s.end();
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

struct info
{
	uint32_t row{};
	int32_t start_index{};
	size_t end_index{};
	uint32_t number{};
};

struct symbol
{
	int32_t row{};
	int32_t column{};
};

void part_1()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	std::vector<std::vector<info>> infos{150};
	std::vector<symbol> symbols{};

	const char* digits = "0123456789";
	uint32_t row{};

	while (const auto& line = parser.next())
	{
		if (line.has_value())
		{
			auto val = *line;
			size_t current_index{};
			std::string substr{};
			size_t next_index{};

			do
			{
				next_index = val.find_first_not_of('.');
				current_index += next_index;
				if (next_index == std::string::npos)
				{
					break;
				}

				substr = val.substr(next_index);

				if (is_number(substr.substr(0, 1)))
				{
					auto num_end = substr.find_first_not_of(digits);

					int num{};
					if (num_end == std::string::npos)
					{
						num = std::stoi(substr);
						infos[row].emplace_back(row, (int32_t)current_index, current_index + 10, num);
						val = "";
						next_index = std::string::npos;
					}
					else
					{
						num = std::stoi(substr.substr(0, num_end));
						infos[row].emplace_back(row, (int32_t)current_index, current_index + num_end - 1, num);

						substr = substr.substr(num_end);
						current_index += num_end;
					}
				}
				else
				{
					symbols.emplace_back(row, (int32_t)current_index);
					substr = substr.substr(1);
					current_index++;
				}
				val = substr;
			} while (next_index != std::string::npos);
			++row;

		}
	}

	for (const auto& [symbol_row, column] : symbols)
	{
		auto& prev_row = infos[symbol_row - 1];
		auto& current_row = infos[symbol_row];
		auto& next_row = infos[symbol_row + 1];

		for (auto& info : prev_row)
		{
			if (info.start_index - 1 <= column && info.end_index + 1 >= column)
			{
				count += info.number;
				info = {};
			}
		}
		for (auto& info : current_row)
		{
			if (info.start_index - 1 <= column && info.end_index + 1 >= column)
			{
				count += info.number;
				info = {};
			}
		}
		for (auto& info : next_row)
		{
			if (info.start_index - 1 <= column && info.end_index + 1 >= column)
			{
				count += info.number;
				info = {};
			}
		}
	}


	std::cout << count << std::endl;

}


void part_2()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	std::vector<std::vector<info>> infos{150};
	std::vector<symbol> symbols{};

	const char* digits = "0123456789";
	uint32_t row{};

	while (const auto& line = parser.next())
	{
		if (line.has_value())
		{
			auto val = *line;
			size_t current_index{};
			std::string substr{};
			size_t next_index{};

			do
			{
				next_index = val.find_first_not_of('.');
				current_index += next_index;
				if (next_index == std::string::npos)
				{
					break;
				}

				substr = val.substr(next_index);

				if (is_number(substr.substr(0, 1)))
				{
					auto num_end = substr.find_first_not_of(digits);

					int num{};
					if (num_end == std::string::npos)
					{
						num = std::stoi(substr);
						infos[row].emplace_back(row, (int32_t)current_index, current_index + 10, num);
						val = "";
						next_index = std::string::npos;
					}
					else
					{
						num = std::stoi(substr.substr(0, num_end));
						infos[row].emplace_back(row, (int32_t)current_index, current_index + num_end - 1, num);

						substr = substr.substr(num_end);
						current_index += num_end;
					}
				}
				else
				{
					if (substr[0] == '*')
					{
						symbols.emplace_back(row, (int32_t)current_index);
					}
						substr = substr.substr(1);
						current_index++;
				}
				val = substr;
			} while (next_index != std::string::npos);
			++row;

		}
	}

	for (const auto& [symbol_row, column] : symbols)
	{
		auto& prev_row = infos[symbol_row - 1];
		auto& current_row = infos[symbol_row];
		auto& next_row = infos[symbol_row + 1];

		std::vector<int32_t> numbers{};

		for (auto& info : prev_row)
		{
			if (info.start_index - 1 <= column && info.end_index + 1 >= column)
			{
				//count += info.number;
				//info = {};
				numbers.push_back(info.number);
			}
		}
		for (auto& info : current_row)
		{
			if (info.start_index - 1 <= column && info.end_index + 1 >= column)
			{
				//count += info.number;
				//info = {};
				numbers.push_back(info.number);
			}
		}
		for (auto& info : next_row)
		{
			if (info.start_index - 1 <= column && info.end_index + 1 >= column)
			{
				//count += info.number;
				//info = {};
				numbers.push_back(info.number);
			}
		}

		if (numbers.size() == 2)
		{
			count += numbers[0] * numbers[1];
		}
	}


	std::cout << count << std::endl;
}

int main()
{
	part_2();

}