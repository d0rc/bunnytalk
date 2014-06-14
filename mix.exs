defmodule Bunnytalk.Mixfile do
  use Mix.Project

  def project do
    [app: :bunnytalk,
     version: "0.0.1",
     deps: deps]
  end

  def application do
    [applications: [:exrabbit, :exactor],
     mod: {Bunnytalk, []}]
  end

  defp deps do
    [
      {:exrabbit, github: "d0rc/exrabbit"},
      {:jazz, github: "d0rc/jazz", override: true, branch: "v0.14.1"},
      {:sweetconfig, github: "d0rc/sweetconfig"},
      {:exactor, github: "sasa1977/exactor"}
    ]
  end
end
