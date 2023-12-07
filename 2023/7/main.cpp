#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include <vector>
#include <set>
#include "../../utils/FileParser.h"

enum type
{
	high_card,
	one_pair,
	two_pair,
	three_of_a_kind,
	full_house,
	four_of_a_kind,
	five_of_a_kind,
};

int rank_to_number(int rank)
{
	if (std::isdigit(rank))
	{
		// part 1
		//return rank - 2 - '0';
		// part 2
		return rank - 1 - '0';
	}
	else
	{
		switch (rank)
		{
		case 'A':
			return 12;
		case 'K':
			return 11;
		case 'Q':
			return 10;
		case 'J':
			//part 1
			//return 9;
			// part 2
			return 0;
		case 'T':
			return 9;
		default:
			return -1;
		}
	}
}

struct hand
{
	std::string hand_s{};
	std::vector<int> ranks{};
	type type{};

	hand(const std::string& hand) : hand_s{ hand }
	{
		ranks = std::vector<int>(13, 0);
		for (const auto& card : hand)
		{
			auto val = rank_to_number(card);
			ranks[val]++;
		}

		type = get_type();

	}

	/*
	type get_type() const
	{
		if (std::any_of(ranks.begin(), ranks.end(), [](int rank) { return rank == 5; }))
		{
			return type::five_of_a_kind;
		}

		if (std::any_of(ranks.begin(), ranks.end(), [](int rank) { return rank == 4; }))
		{
			return type::four_of_a_kind;
		}

		if (std::ranges::any_of(ranks, [](int rank) { return rank == 3; }) && std::ranges::any_of(ranks, [](int rank) { return rank == 2;}))
		{
			return type::full_house;
		}

		if (std::any_of(ranks.begin(), ranks.end(), [](int rank) { return rank == 3; }))
		{
			return type::three_of_a_kind;
		}

		if(std::ranges::count_if(ranks, [](int rank) { return rank == 2; }) == 2)
		{
			return type::two_pair;
		}

		if (std::any_of(ranks.begin(), ranks.end(), [](int rank) { return rank == 2; }))
		{
			return type::one_pair;
		}

		return type::high_card;
	}
	*/

	::type get_type() const
	{
		if (std::ranges::any_of(ranks, [](int rank) { return rank == 5; }))
		{
			return type::five_of_a_kind;
		}

		if (std::ranges::any_of(ranks, [](int rank) { return rank == 4; }))
		{
			if (ranks[0] == 1)
			{
				return type::five_of_a_kind;
			}
			// missed this case
			else if (ranks[0] == 4)
			{
				return type::five_of_a_kind;
			}
				return type::four_of_a_kind;
		}

		if (std::ranges::any_of(ranks, [](int rank) { return rank == 3; }) && std::ranges::any_of(ranks, [](int rank) { return rank == 2;}))
		{
			if (ranks[0])
			{
				if (ranks[0] == 2)
				{
				return type::five_of_a_kind;
				}
				else if (ranks[0] == 3)
				{
					return type::five_of_a_kind;
				}
			}

			return type::full_house;
		}

		
		if (std::ranges::any_of(ranks, [](int rank) { return rank == 3; }))
		{
			if (ranks[0])
			{
				if (ranks[0] == 1)
				{
					return type::four_of_a_kind;
				}
				else if (ranks[0] == 3)
				{
					return type::four_of_a_kind;
				}
			}

			return type::three_of_a_kind;
		}

		if(std::ranges::count_if(ranks, [](int rank) { return rank == 2; }) == 2)
		{
			if (ranks[0])
			{
				if (ranks[0] == 1)
				{
					return type::full_house;
				}
				else if (ranks[0] == 2)
				{
					return type::four_of_a_kind;
				}
			}
			return type::two_pair;
		}

		if (std::any_of(ranks.begin(), ranks.end(), [](int rank) { return rank == 2; }))
		{
			if (ranks[0])
			{
				if (ranks[0] == 1)
				{
					return type::three_of_a_kind;
				}
				else if(ranks[0] == 2)
				{
					return type::three_of_a_kind;
				}
			}

			return type::one_pair;

		}
		
		if (ranks[0])
		{
			if (ranks[0] == 1)
			{
				return type::one_pair;
			}
		}
		return type::high_card;

	}

	friend	bool operator<(const hand& lhs, const hand& rhs)
	{
		auto lhs_type = lhs.type;
		auto rhs_type = rhs.type;

		if (lhs_type != rhs_type)
		{
			return lhs.type < rhs.type;
		}

		for (auto i{ 0 }; i < lhs.hand_s.size(); ++i)
		{
			auto lhs_val = rank_to_number(lhs.hand_s[i]);
			auto rhs_val = rank_to_number(rhs.hand_s[i]);

			if (lhs_val != rhs_val)
			{
				return lhs_val < rhs_val;
			}
		}

		return false;
	}
};

struct game
{
	hand hand;
	int bid{};

	friend bool operator<(const game& lhs, const game& rhs)
	{
		return lhs.hand < rhs.hand;
	}
};



void part_1()
{
	LineParser parser{ "in.txt" };
	int32_t count{};

	std::vector<game> games{};
	std::set<game> games_set{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			std::istringstream ss{ *line };
			std::string hand{};
			int bid{};
			ss >> hand >> bid;

			games.emplace_back(hand, bid);
			games_set.emplace(hand, bid);

		}
	}

	int game_count = 1;
	for (const auto& game : games_set)
	{
		count += game_count * game.bid;
		game_count++;
	}

	std::cout << count << std::endl;
}

void part_2()
{
	LineParser parser{ "in.txt" };
	int64_t count{};

	std::set<game> games_set{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			std::istringstream ss{ *line };
			std::string hand{};
			int bid{};
			ss >> hand >> bid;

			games_set.emplace(hand, bid);

		}
	}

	int game_count = 1;
	for (const auto& game : games_set)
	{
		count += game_count * game.bid;
		game_count++;
	}

	std::cout << count << std::endl;
}

int main()
{
	part_2();
}