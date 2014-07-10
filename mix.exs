defmodule Ordos.Mixfile do
  use Mix.Project

  def project do
    [app: :ordos,
     version: "0.0.1",
     elixir: "~> 0.14.3-dev",
     deps: deps]
  end

  def application do
    [applications: [:exlager, :exactor, :locker, :elli],
     mod: {Ordos, []}]
  end

  defp deps do
    [
      {:locker, github: "wooga/locker"},
      {:elli, github: "knutin/elli"},
      {:exactor, github: "sasa1977/exactor"},
      {:lager, github: "quasiconvex/lager", override: true},
      {:exlager, github: "khia/exlager"}
    ]
  end
end
