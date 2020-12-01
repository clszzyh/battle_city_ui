defmodule BattleCity.Compile do
  @moduledoc false

  alias BattleCity.Utils
  require Logger

  @stage_path "priv/stages/*.json"

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
        use BattleCity.Stage.Base,
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
