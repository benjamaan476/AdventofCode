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
#include <queue>
#include "../../utils/FileParser.h"

#include <glm/glm.hpp>
struct point
{
	glm::vec3 p{};
	glm::vec3 v{};
};

int intersect(float dist_1, float dist_2, const glm::vec3& p1, const glm::vec3& p2, glm::vec3& hit)
{
	if (dist_1 * dist_2 >= 0.F)
	{
		return 0;
	}
	if (dist_1 == dist_2)
	{
		return 0;
	}

	hit = p1 + (p2 - p1) * (-dist_1 / (dist_2 - dist_1));
	return 1;
}

bool in_box(const glm::vec3& hit, const glm::vec3& b1, const glm::vec3& b2, int axis)
{
	if (axis == 1 && hit.z > b1.z && hit.z < b2.z && hit.y > b1.y && hit.y < b2.y) return true;
	if (axis == 2 && hit.z > b1.z && hit.z < b2.z && hit.x > b1.x && hit.x < b2.x) return true;
	if (axis == 3 && hit.x > b1.x && hit.x < b2.x && hit.y > b1.y && hit.y < b2.y) return true;

	return false;
}

bool check_line(const glm::vec3& b1, const glm::vec3& b2, const glm::vec3& l1, const glm::vec3& l2, glm::vec3 hit)
{
	if (l2.x < b1.x && l1.x < b1.x) return false;
	if (l2.x > b2.x && l1.x > b2.x) return false;
	if (l2.y < b1.y && l1.y < b1.y) return false;
	if (l2.y > b2.y && l1.y > b2.y) return false;
	if (l2.z < b1.z && l1.z < b1.z) return false;
	if (l2.z > b2.z && l1.z > b2.z) return false;

	if (l1.x > b1.x && l1.x < b2.x && l1.y > b1.y && l1.y < b2.y && l1.z > b1.z && l1.z < b2.z)
	{
		hit = l1;
		return true;
	}

	if (intersect(l1.x - b1.x, l2.x - b1.x, l1, l2, hit) && in_box(hit, b1, b2, 1)
		|| intersect(l1.y - b1.y, l2.y - b1.y, l1, l2, hit) && in_box(hit, b1, b2, 2)
		|| intersect(l1.z - b1.z, l2.y - b1.y, l1, l2, hit) && in_box(hit, b1, b2, 3)
		|| intersect(l1.x - b2.x, l2.x - b2.x, l1, l2, hit) && in_box(hit, b1, b2, 1)
		|| intersect(l1.y - b2.y, l2.y - b2.y, l1, l2, hit) && in_box(hit, b1, b2, 2)
		|| intersect(l1.z - b2.z, l2.y - b2.y, l1, l2, hit) && in_box(hit, b1, b2, 3))
	{
		return true;
	}

	return false;
}

void part_1()
{
	LineParser parser{ "in.txt" };
	size_t count{};

	std::vector<point> points{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			point p{};
			sscanf_s(line->c_str(), "%d, %d, %d @ %d, %d, %d", &p.p.x, &p.p.y, &p.p.z, &p.v.x, &p.v.y, &p.v.z);
			points.push_back(p);
		}
	}

	for (const auto& point : points)
	{
		auto other = point.p + point.v * 1000000.F;
		glm::vec3 hit{};
		auto hits = check_line({ 7, 7, 0 }, { 27, 27, 0 }, point.p, other, hit);

		count += hits ? 1 : 0;
	}


	std::cout << count << std::endl;
}


void part_2()
{
	LineParser parser{ "in.txt" };
	size_t count{};
	size_t max_count{};

	std::vector<std::string> lines{};

	while (const auto& line = parser.next())
	{
		if (line.has_value() && !line->empty())
		{
			lines.push_back(*line);
		}
	}


	std::cout << max_count << std::endl;

}

int main()
{
	part_1();
}