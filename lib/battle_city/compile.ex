defmodule BattleCity.Compile do
  @moduledoc false

  alias BattleCity.Environment
  alias BattleCity.Tank
  alias BattleCity.Utils
  require Logger

  @stage_path "priv/stages/*.json"

  @bot_map %{
    "fast" => Tank.Fast,
    "power" => Tank.Power,
    "armor" => Tank.Armor,
    "basic" => Tank.Basic
  }

  @environment_map %{
    "X" => Environment.Blank,
    "B" => Environment.BrickWall,
    "T" => Environment.SteelWall,
    "F" => Environment.Tree,
    "R" => Environment.Water,
    "S" => Environment.Ice,
    "E" => Environment.Home
  }

  @suffix_map %{
    nil => nil,
    "3" => "3",
    "4" => "4",
    "5" => "5",
    "8" => "8",
    "a" => "a",
    "c" => "c",
    "f" => "f",
    "A" => "a",
    "C" => "c",
    "E" => "e",
    "F" => "f"
  }

  paths = Path.wildcard(@stage_path)
  paths_hash = :erlang.md5(paths)

  for path <- paths do
    @external_resource path
  end

  def __mix_recompile__? do
    :erlang.md5(Path.wildcard(@stage_path)) != unquote(paths_hash)
  end

  @after_compile __MODULE__
  def __after_compile__(_env, _bytecode) do
    compile_stage!(@stage_path)
  end

  def validate_stage!(%{map: map, bots: bots} = o) do
    %{o | map: Enum.map(map, &parse_map/1), bots: Enum.map(bots, &parse_bot/1)}
  end

  defp parse_map(o) when is_binary(o) do
    result = o |> String.split(" ", trim: true)
    unless Enum.count(result) == 13, do: raise("#{o}'s length should be 13.")
    result |> Enum.map(&parse_map_1/1)
  end

  defp parse_map_1(o) when is_binary(o) do
    {prefix, suffix} = parse_map_2(o)
    Map.fetch!(@environment_map, prefix).init(%{stage: Map.fetch!(@suffix_map, suffix)})
  end

  defp parse_map_2(<<prefix::binary-size(1), suffix::binary-size(1)>>), do: {prefix, suffix}
  defp parse_map_2(<<prefix::binary-size(1)>>), do: {prefix, nil}

  defp parse_bot(o) when is_binary(o) do
    [num, kind] = o |> String.split("*")
    num = String.to_integer(num)
    if num <= 0, do: raise("#{o} should > 0.")
    {Map.fetch!(@bot_map, kind), num}
  end

  def compile_stage!(path) do
    path
    |> Path.wildcard()
    |> Enum.each(fn f ->
      f |> File.read!() |> Jason.decode!() |> compile_stage_1()
    end)
  end

  defp compile_stage_1(%{"name" => name, "bots" => bots, "difficulty" => difficulty, "map" => map}) do
    module_name = Module.concat(BattleCity.Stage, "S#{name}")

    if Utils.defined?(module_name) do
      Logger.debug("Delete module: #{module_name}")
      :code.purge(module_name)
      :code.delete(module_name)
    end

    ast =
      quote location: :keep do
        use BattleCity.Stage,
          name: unquote(name),
          difficulty: unquote(difficulty),
          map: unquote(map),
          bots: unquote(bots)
      end

    {:module, final_module, _byte_code, _} =
      Module.create(module_name, ast, Macro.Env.location(__ENV__))

    Logger.debug("Create module: #{final_module}")

    final_module
  end
end
