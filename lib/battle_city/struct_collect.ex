defmodule BattleCity.StructCollect do
  @moduledoc false

  defmacro __using__(_env) do
    quote do
      import unquote(__MODULE__)

      @callback init :: t()
      @callback init(keyword) :: t()

      defimpl Collectable do
        def into(o), do: {o, &into_callback/2}
        defp into_callback(o, {:cont, {k, v}}), do: Map.put(o, k, v)
        defp into_callback(o, :done), do: o
        defp into_callback(_, :halt), do: :ok
      end
    end
  end

  defmacro init_ast(module, o) do
    quote do
      @behaviour unquote(module)

      @impl true
      def init, do: unquote(o)

      @impl true
      def init(keyword), do: Enum.into(keyword, unquote(o))

      defoverridable unquote(module)
    end
  end
end
