defmodule BattleCity.Ai.Basic do
  @moduledoc false

  use BattleCity.Ai

  @limit 10
  @diretions [:up, :down, :left, :right]

  @impl true
  def name, do: "basic"

  @impl true
  def handle_shoot(ctx, tank, _) do
    %Event{name: :shoot, counter: ctx.__counters__.loop, id: tank.id}
  end

  @impl true
  def handle_move(ctx, %Tank{id: id, position: %{direction: direction, x: x, y: y}}, nil) do
    %Event{
      name: :move,
      value: direction,
      id: id,
      counter: ctx.__counters__.loop,
      args: %{x: x, y: y}
    }
  end

  def handle_move(
        ctx,
        %Tank{position: %{direction: direction, x: x, y: y}},
        %Event{
          value: direction,
          args: %{x: ex, y: ey} = args
        } = event
      )
      when {x, y} != {ex, ey} do
    %{event | counter: ctx.__counters__.loop, args: %{args | x: x, y: y}}
  end

  def handle_move(
        %Context{__counters__: %{loop: counter}},
        _,
        %Event{counter: event_counter} = event
      )
      when counter - event_counter < @limit do
    event
  end

  @less_up List.duplicate(:up, 5)

  def handle_move(
        %Context{__counters__: %{loop: counter}},
        %Tank{position: %{x: _x, y: _y}},
        %Event{value: direction} = event
      ) do
    directions =
      @diretions
      |> Kernel.--([direction])
      |> List.duplicate(10)
      |> List.flatten()
      |> Kernel.--(@less_up)

    %{event | counter: counter, value: Enum.random(directions)}
  end
end
