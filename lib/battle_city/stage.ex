defmodule BattleCity.Stage do
  @moduledoc false

  @path "priv/stages/*.json"

  paths = Path.wildcard(@path)
  paths_hash = :erlang.md5(paths)

  for path <- paths do
    @external_resource path
  end

  def __mix_recompile__?() do
    Path.wildcard(@path) |> :erlang.md5() != unquote(paths_hash)
  end

  @type map_data :: [term()]
  @type bot :: term()

  @type t :: %__MODULE__{
          name: binary(),
          difficulty: integer(),
          map: map_data,
          bots: [bot]
        }

  defstruct [
    :name,
    :difficulty,
    :map,
    :bots
  ]

  def load(path) do
    path |> File.read!() |> Jason.decode!()
  end
end
