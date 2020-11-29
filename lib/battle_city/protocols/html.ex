defprotocol Html do
  def grid(struct)
  def title(struct)
  def color(struct)
end

defimpl Html, for: BattleCity.Environment do
  alias BattleCity.Position

  def color(%{__module__: BattleCity.Environment.Blank}), do: "#21262D"
  def color(%{__module__: BattleCity.Environment.BrickWall}), do: "#BB1300"
  def color(%{__module__: BattleCity.Environment.SteelWall}), do: "#FFFFFF"
  def color(%{__module__: BattleCity.Environment.Home}), do: "#7F7F7F"
  def color(%{__module__: BattleCity.Environment.Ice}), do: "#BDBEBD"
  def color(%{__module__: BattleCity.Environment.Tree}), do: "#9CEB02"
  def color(%{__module__: BattleCity.Environment.Water}), do: "#4242FF"

  @width 0.97 * Position.real_width()

  # def grid(%{position: p, __module__: BattleCity.Environment.Home}) do
  # end

  def grid(%{position: p} = o) do
    """
    <rect x="#{p.rx}" y="#{p.ry}" width="#{@width}" height="#{@width}" fill="#{color(o)}">
      <title>#{title(o)}</title>
    </rect>
    """
  end

  def title(%{position: p, health: health}) do
    "#{health} {#{p.x}, #{p.y}}"
  end
end

defimpl Html, for: BattleCity.Tank do
  alias BattleCity.Position

  def color(%{__module__: BattleCity.Tank.Armor}), do: "#333333"
  def color(%{__module__: BattleCity.Tank.Basic}), do: "#E58600"
  def color(%{__module__: BattleCity.Tank.Fast}), do: "#E58600"
  def color(%{__module__: BattleCity.Tank.Power}), do: "#E58600"
  def color(%{__module__: BattleCity.Tank.Level1}), do: "#E58600"
  def color(%{__module__: BattleCity.Tank.Level2}), do: "#E58600"
  def color(%{__module__: BattleCity.Tank.Level3}), do: "#E58600"
  def color(%{__module__: BattleCity.Tank.Level4}), do: "#E58600"

  @width 0.80 * Position.real_width()
  @rx 0.15 * Position.real_width()
  @tank_diff Float.round((0.97 - 0.8) * 0.5 * Position.real_width())

  def grid(%{position: p, hidden?: hidden?} = o) do
    hidden_str = if hidden?, do: "display=\"none\"", else: ""

    """
    <rect x="#{p.rx + @tank_diff}" y="#{p.ry + @tank_diff}"
    width="#{@width}" height="#{@width}" fill="#{color(o)}" rx="#{@rx}" #{hidden_str}>
    <title>#{title(o)}</title>
    </rect>
    """
  end

  def title(%{position: p, id: id, shootable?: shootable?}) do
    "#{id} - #{p.rx} #{p.ry}, #{shootable?}"
  end
end

defimpl Html, for: BattleCity.Bullet do
  alias BattleCity.Position

  @width 0.05 * Position.real_width()
  @tank_diff Float.round((0.97 - 0.8) * 0.5 * Position.real_width())
  @bullet_diff Float.round((0.8 - 0.05) * 0.5 * Position.real_width())

  def grid(%{position: p, hidden?: hidden?} = o) do
    hidden_str = if hidden?, do: "display=\"none\"", else: ""

    """
    <rect x="#{p.rx + @tank_diff + @bullet_diff}" y="#{p.ry + @tank_diff + @bullet_diff}"
    width="#{@width}" height="#{@width}" fill="#{color(o)}" #{hidden_str}>
    <title>#{title(o)}</title>
    </rect>
    """
  end

  def title(%{id: id}) do
    "#{id}"
  end

  def color(_), do: "#E58600"
end
