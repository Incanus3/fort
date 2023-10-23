defmodule Fort.Ticker do
  def start_link(period, receiver) do
    spawn_link(fn ->
      loop(period, receiver)
    end)
  end

  defp loop(period, receiver) do
    Process.sleep(period)
    send(receiver, :tick)
    loop(period, receiver)
  end
end
