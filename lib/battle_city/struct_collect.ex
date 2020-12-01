defmodule BattleCity.StructCollect do
  @moduledoc false

  defmacro __using__(_env) do
    quote do
      import unquote(__MODULE__)

      @callback handle_init(map()) :: map() | {:error, :atom}

      defimpl Collectable do
        def into(o), do: {o, &into_callback/2}
        defp into_callback(o, {:cont, {k, v}}), do: Map.put(o, k, v)
        defp into_callback(o, :done), do: o
        defp into_callback(_, :halt), do: :ok
      end
    end
  end

  defmacro init_ast(behaviour_module, current_module, keyword) do
    quote do
      @obj Map.put(unquote(keyword), :__module__, unquote(current_module))

      @behaviour unquote(behaviour_module)

      @spec init(map()) :: unquote(behaviour_module).t
      def init(map \\ %{}) do
        map
        |> handle_init
        |> case do
          %{} = map -> Enum.into(map, @obj)
          {:error, reason} -> raise CompileError, description: "#{inspect(map)} #{reason}"
        end
      end

      @impl true
      def handle_init(map), do: map

      defoverridable unquote(behaviour_module)
    end
  end
end
