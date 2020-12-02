defprotocol Display do
  @fallback_to_any true
  def text(struct)
end

defimpl Display, for: Any do
  require Logger

  def text(o) when is_struct(o) do
    Logger.error("Not implement: #{o.__struct__}")
    "?"
  end

  def text(o) do
    Logger.error("Not implement: #{inspect(o)}")
    "?"
  end
end
