defmodule BattleCity.StructCollect do
  @moduledoc false

  alias BattleCity.Utils

  defmacro __using__(_env) do
    quote do
      import unquote(__MODULE__)

      @callback handle_init(map()) :: map() | {:error, :atom}
      @optional_callbacks handle_init: 1

      defimpl Collectable do
        def into(o), do: {o, &into_callback/2}
        defp into_callback(o, {:cont, {k, v}}), do: Map.put(o, k, v)
        defp into_callback(o, :done), do: o
        defp into_callback(_, :halt), do: :ok
      end
    end
  end

  defmacro init_ast(behaviour_module, current_module, keyword) when is_atom(behaviour_module) do
    has_id? = Map.has_key?(behaviour_module.__struct__(), :id)
    keys = Map.keys(behaviour_module.__struct__())

    ast =
      if has_id? do
        quote do
          defp maybe_add_id(map), do: Map.put(map, :id, Utils.random())
        end
      else
        quote do
          defp maybe_add_id(map), do: map
        end
      end

    quote do
      @obj Map.put(unquote(keyword), :__module__, unquote(current_module))

      @behaviour unquote(behaviour_module)

      @spec maybe_add_id(map()) :: map()
      unquote(ast)

      @spec maybe_handle_init(map()) :: map() | {:error, atom()}
      defp maybe_handle_init(map) do
        if function_exported?(unquote(current_module), :handle_init, 1) do
          apply(unquote(current_module), :handle_init, [map])
        else
          map
        end
      end

      @spec init(map()) :: unquote(behaviour_module).t
      def init(map \\ %{}) do
        map
        |> maybe_add_id()
        |> maybe_handle_init()
        |> case do
          %{} = map ->
            map
            |> Map.take(unquote(keys))
            |> Enum.into(@obj)

          {:error, reason} ->
            raise CompileError, description: "#{inspect(map)} #{reason}"
        end
      end

      # @impl true
      # def handle_init(map), do: map

      defoverridable unquote(behaviour_module)
    end
  end
end
