defmodule BaseConvert do
  def main(args) do
    {opts, positional, _} =
      OptionParser.parse(args,
        strict: [from: :integer, to: :integer, help: :boolean],
        aliases: [f: :from, t: :to, h: :help]
      )

    if opts[:help] do
      IO.puts("Usage: base_convert <number> [--from BASE] [--to BASE]")
      IO.puts("  Bases: 2, 8, 10, 16. Default: from 10, to 16")
      System.halt(0)
    end

    if positional == [] do
      IO.puts(:stderr, "Error: provide a number")
      System.halt(1)
    end

    from = opts[:from] || 10
    to = opts[:to] || 16
    input = hd(positional)

    value =
      case from do
        10 -> String.to_integer(input)
        _ -> String.to_integer(input, from)
      end

    result =
      case to do
        16 -> Integer.to_string(value, 16) |> String.upcase()
        _ -> Integer.to_string(value, to)
      end

    IO.puts("#{input} (base #{from}) = #{result} (base #{to})")
  end
end

BaseConvert.main(System.argv())
