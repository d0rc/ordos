defmodule Ordos do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Ordos.Worker, [arg1, arg2, arg3])
      worker(:locker, [1])
    ]
    :locker.set_nodes([:erlang.node | :erlang.nodes], [:erlang.node], :erlang.nodes)

    opts = [strategy: :one_for_one, name: Ordos.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
