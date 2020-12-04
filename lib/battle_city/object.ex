defprotocol Object do
  def fingerprint(struct)
end

defimpl Object, for: BattleCity.Tank do
  def fingerprint(tank) do
    {:t, tank.id, tank.enemy?}
  end
end

defimpl Object, for: BattleCity.Bullet do
  def fingerprint(bullet) do
    {:b, bullet.id, bullet.enemy?}
  end
end

defimpl Object, for: BattleCity.PowerUp do
  def fingerprint(powerup) do
    {:p, powerup.id, false}
  end
end
