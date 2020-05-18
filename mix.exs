defmodule Metatorrent.MixProject do
  use Mix.Project

  def project do
    [
      app: :metatorrent,
      version: "1.0.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A BitTorrent metainfo decoder.",
      source_url: "https://github.com/cantido/metatorrent",
      homepage_url: "https://github.com/cantido/metatorrent",
      package: [
        maintainers: ["Rosa Richter"],
        licenses: ["GPL-3.0-or-later"],
        links: %{"GitHub" => "https://github.com/cantido/metatorrent"},
      ],
      docs: [
        main: "Metatorrent",
        source_url: "https://github.com/cantido/metatorrent",
        extras: [
          "README.md"
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_bencode, "~> 2.0"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
    ]
  end
end
