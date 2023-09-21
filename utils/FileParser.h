#pragma once

#include <filesystem>
#include <fstream>
#include <string_view>
#include <coroutine>
#include <optional>


class StringViewCoro
{
public:
	StringViewCoro(StringViewCoro&& other) noexcept : m_cohandle{ other.release() }
	{
	}
	StringViewCoro& operator=(StringViewCoro&& other) noexcept
	{
		if (this != &other)
		{
			if (m_cohandle)
			{
				m_cohandle.destroy();
			}
			m_cohandle = other.release();
		}
		return *this;
	}
	~StringViewCoro()
	{
		if (m_cohandle)
		{
			m_cohandle.destroy();
		}
	}

	class promise_type
	{
	public:
		StringViewCoro get_return_object()
		{
			return StringViewCoro(std::coroutine_handle<promise_type>::from_promise(*this));
		}

		std::suspend_always initial_suspend() noexcept
		{
			return {};
		}
		std::suspend_always final_suspend() noexcept
		{
			return {};
		}
		std::suspend_always yield_value(const std::string& value) noexcept
		{
			m_value = value;
			return {};
		}

		void return_void()
		{
		}
		void unhandled_exception() noexcept
		{
		}

		std::string m_value{};
	};

	std::optional<std::string> next() noexcept
	{
		if (!m_cohandle || m_cohandle.done())
		{
			return std::nullopt;
		}
		m_cohandle.resume();

		if (m_cohandle.done())
		{
			return std::nullopt;
		}

		return m_cohandle.promise().m_value;
	}

private:
	explicit StringViewCoro(const std::coroutine_handle<promise_type> cohandle) noexcept : m_cohandle{ cohandle }
	{
	}

	std::coroutine_handle<promise_type> m_cohandle{};

private:
	std::coroutine_handle<promise_type> release() noexcept
	{
		return std::exchange(m_cohandle, nullptr);
	}
};

class Parser
{
public:
	explicit Parser(std::filesystem::path file)
		: filename{ file }
	{
		ifs.open(file.string(), std::ios::in);
	}

	virtual std::optional<std::string> next() = 0;

	virtual ~Parser()
	{
		if (ifs.is_open())
		{
			ifs.close();
		}
	}

protected:
	std::ifstream ifs{};
	std::filesystem::path filename{};
};

class LineParser : public Parser
{
public:
	explicit LineParser(std::filesystem::path file) : Parser(file)
	{
	}

	std::optional<std::string> next() final
	{
		return get().next();
	}

	StringViewCoro get()
	{
		while (!ifs.eof())
		{
			std::string line{};
			std::getline(ifs, line);

			co_yield line;
		}
	}

	~LineParser() final = default;
};

class DelimitedParser : public Parser
{
public:
	DelimitedParser(std::filesystem::path file, char delim) : Parser(file), delim{ delim }
	{
	}

	std::optional<std::string> next() final
	{
		return get().next();
	}

	StringViewCoro get()
	{
		while (!ifs.eof())
		{
			std::string line{};
			std::getline(ifs, line, delim);

			co_yield line;
		}
	}

	~DelimitedParser() final = default;

private:
	char delim{};
};

class CharacterParser : public Parser
{
public:
	explicit CharacterParser(std::filesystem::path file) : Parser(file)
	{
	}

	std::optional<std::string> next() final
	{
		return get().next();
	}

	StringViewCoro get()
	{
		char buff;
		while (ifs >> buff)
		{
			co_yield{ buff };
		}
	}

	~CharacterParser() final = default;
};