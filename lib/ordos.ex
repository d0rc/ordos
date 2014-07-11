defmodule Ordos do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(:locker, [1]),
      worker(:elli, [[port: 3000, callback: Ordos.HTTP]]),
      worker(Ordos.Worker, [])
    ]

    opts = [strategy: :one_for_one, name: Ordos.Supervisor]
    Supervisor.start_link(children, opts)
  end
end