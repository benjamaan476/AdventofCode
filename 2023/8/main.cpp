#include <iostream>
#include <array>
#include <ranges>
#include <string>
#include <vector>
#include <set>
#include <map>
#include <numeric>
#include "../../utils/FileParser.h"

struct node
{
	std::string name{};
	node* left{};
	node* right{};

	bool is_star{};
	bool is_end{};
};

void part_1()
{
	int32_t count{};

	std::map<std::string, node> nodes{};

	FILE* f{};
	fopen_s(&f, "in.txt", "r");
	std::string instructions{};

	if (f)
	{
		char buffer[512];
		fgets(buffer, sizeof(buffer), f);
		instructions = std::string{ buffer };

		fgets(buffer, sizeof(buffer), f);

		char node_name[16]{}, left[16]{}, right[16]{};

		while (fgets(buffer, sizeof(buffer), f))
		{
			sscanf_s(buffer, "%s = (%[^,], %[^)])\n", node_name, (uint32_t)sizeof(node_name), left, (uint32_t)sizeof(left), right, (uint32_t)sizeof(right));
			node* node{};
			std::string name{};
			if (!nodes.contains(node_name))
			{
				auto pair = nodes.emplace(node_name, node_name);
				node = &pair.first->second;
			}
			else
			{
				node = &nodes[node_name];
			}

			if (nodes.contains(left))
			{
				node->left = &nodes[left];
			}
			else
			{
				auto pair = nodes.emplace(left, left);
				node->left = &pair.first->second;
			}

			if (nodes.contains(right))
			{
				node->right = &nodes[right];
			}
			else
			{
				auto pair = nodes.emplace(right, right);
				node->right = &pair.first->second;
			}
		}
		fclose(f);
	}

	node start_node = nodes.find("AAA")->second;

	node* next_node = &start_node;
	int steps{};
	bool found{};
	while (!found)
	{
		for (const auto& step : instructions)
		{
			if (step == 'L')
			{
				next_node = next_node->left;
				++steps;
			}
			else if (step == 'R')
			{
				next_node = next_node->right;
				++steps;
			}
			if (next_node->name == "ZZZ")
			{
				found = true;
				break;
			}
		}
	}
	count = steps;
	std::cout << count << std::endl;
}
int64_t gcd(int64_t a, int64_t b)
{
	for (;;)
	{
		if (a == 0) return b;
		b %= a;
		if (b == 0) return a;
		a %= b;
	}
}

int64_t lcm(int64_t a, int64_t b)
{
	int64_t temp = gcd(a, b);

	return temp ? (a / temp * b) : 0;
}
void part_2()
{
	int64_t count{};

	std::map<std::string, node> nodes{};

	FILE* f{};
	fopen_s(&f, "in.txt", "r");
	std::string instructions{};
	std::vector<node*> start_nodes{};

	if (f)
	{
		char buffer[512];
		fgets(buffer, sizeof(buffer), f);
		instructions = std::string{ buffer };

		fgets(buffer, sizeof(buffer), f);

		char node_name[16]{}, left[16]{}, right[16]{};

		while (fgets(buffer, sizeof(buffer), f))
		{
			sscanf_s(buffer, "%s = (%[^,], %[^)])\n", node_name, (uint32_t)sizeof(node_name), left, (uint32_t)sizeof(left), right, (uint32_t)sizeof(right));
			node* node{};
			std::string name{};
			if (!nodes.contains(node_name))
			{
				auto pair = nodes.emplace(node_name, node_name);
				node = &pair.first->second;
			}
			else
			{
				node = &nodes[node_name];
			}

			node->is_star = node_name[2] == 'A';
			node->is_end = node_name[2] == 'Z';


			if (nodes.contains(left))
			{
				node->left = &nodes[left];
			}
			else
			{
				auto pair = nodes.emplace(left, left);
				node->left = &pair.first->second;
			}

			if (nodes.contains(right))
			{
				node->right = &nodes[right];
			}
			else
			{
				auto pair = nodes.emplace(right, right);
				node->right = &pair.first->second;
			}

			if (node->is_star)
			{
				start_nodes.push_back(node);
			}

		}
		fclose(f);
	}

	std::vector<int64_t> founds(start_nodes.size());
	std::vector<node*> next_nodes = start_nodes;
	for (auto i{ 0 }; i < next_nodes.size(); ++i)
	{
		int64_t steps{};
		bool found{};
		while (!found)
		{

			for (const auto& step : instructions)
			{
				if (step == '\n')
				{
					continue;
				}

				++steps;

				next_nodes[i] = (step == 'L') ? next_nodes[i]->left : (step == 'R') ? next_nodes[i]->right : next_nodes[i];
				//std::cout << next_nodes[i]->is_end;

			//std::cout << '\r';
				if (next_nodes[i]->is_end)
				{
					founds[i] = steps;
					found = true;
					break;
				}
			}
		}
	}


	count = (int64_t)std::accumulate(founds.begin(), founds.end(), (int64_t)1, lcm);
	std::cout << count << std::endl;
}

int main()
{
	part_2();
}