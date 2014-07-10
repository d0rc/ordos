defmodule Ordos.Worker do
  use ExActor.GenServer
  require Lager

  @timeout :timer.seconds(1)

  definit do: {:ok, [], @timeout}
  definfo :timeout, state: state do
    case :locker.get_meta do
      {[], [], _} -> 
        Lager.warning "Setting locker nodes...!"
        :locker.set_nodes([:erlang.node | :erlang.nodes], [:erlang.node], :erlang.nodes)
      _ -> 
        :ok
    end
    {:noreply, state, @timeout}
  end
end