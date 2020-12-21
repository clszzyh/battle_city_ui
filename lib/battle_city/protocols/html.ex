defprotocol Html do
  def grid(struct)
end

defimpl Html, for: BattleCity.Environment do
  def grid(%{position: p, __module__: module}) do
    %{type: "e", kind: module.__name__(), x: p.x, y: p.y}
  end
end

defimpl Html, for: BattleCity.Tank do
  def grid(%{position: p, __module__: module}) do
    %{type: "t", kind: module.__name__(), x: p.x, y: p.y, d: p.direction}
  end
end

defimpl Html, for: BattleCity.Bullet do
  def grid(%{position: p}) do
    %{type: "b", x: p.x, y: p.y, d: p.direction}
  end
end
