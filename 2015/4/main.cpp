#include <iostream>
#include <array>
#include <ranges>
#include "../../utils/FileParser.h"

#include <bitset>

#include <cryptopp/cryptlib.h>
#include <cryptopp/hex.h>
#include <cryptopp/files.h>
#define CRYPTOPP_ENABLE_NAMESPACE_WEAK 1
#include <cryptopp/md5.h>


constexpr static auto key = "yzbqklnj";

using namespace CryptoPP;

void part_1()
{
	Weak::MD5 hash{};


	for (auto value{ 0 }; ; ++value)
	{
		std::string digest{};
		auto message = key + std::to_string(value);

		hash.Update((const byte*)message.data(), message.size());
		digest.resize(hash.DigestSize());
		hash.Final((byte*)&digest[0]);

		CryptoPP::HexEncoder encoder;
		std::string output;
		encoder.Attach(new CryptoPP::StringSink(output));
		encoder.Put((byte*)digest.data(), sizeof(digest));
		encoder.MessageEnd();

		//std::cout << output << std::endl;

		auto start = output.substr(0, 6);
		if (strcmp(start.c_str(), "000000") == 0)
		{
			std::cout << value << std::endl;
			break;
		}
	}
}

void part_2()
{

}

int main()
{
	part_1();
}