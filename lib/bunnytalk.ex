defmodule Bunnytalk do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = Enum.map(1..(Sweetconfig.get([:bunnytalk, :workers], 4)), fn v ->
      worker(Bunnytalk.Publisher, [], id: :erlang.binary_to_atom("bunnytalk_#{v}", :utf8))
    end)

    opts = [strategy: :one_for_one, name: Bunnytalk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def say(exchange, message) do
    Bunnytalk.Publisher.say(exchange, message)
  end
end

defmodule Bunnytalk.Publisher do
  use ExActor.GenServer
  import Exrabbit.Utils

  def say(exchange, msg), do: say(exchange, msg, 0)

  defp say(_exchange, _msg, attempts) when attempts > 10, do: :failed
  defp say(exchange, msg, attempts) do
    pid = :pg2.get_closest_pid :publishers
    case call_publish(pid, exchange, msg) do
      :ok -> :ok
      _   -> say(exchange, msg, attempts + 1)
    end
  end

  definit do
    :pg2.create :publishers
    :pg2.join :publishers, self
    amqp = connect(Sweetconfig.get([:bunnytalk, :amqp], %{}))
    channel = channel(amqp)
    :erlang.link(amqp)
    :erlang.link(channel)
    initial_state(%{amqp: amqp, channel: channel})
  end

  defcall call_publish(exchange, msg), state: %{amqp: _amqp, channel: channel} do
    publish(channel, exchange, "", Jazz.encode!(msg), :wait_confirmation) |> reply
  end
end