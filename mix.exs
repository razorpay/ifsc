defmodule IFSC.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ifsc,
      version: "1.4.5",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases(),
      source_url: "https://github.com/razorpay/ifsc",
      homepage_url: "https://ifsc.razorpay.com/",
      elixirc_paths: ["src/elixir"],
      test_paths: ["tests/elixir"],
    ]
  end

  def application do
    [
      extra_applications: [:logger],
    ]
  end

  defp description do
    "A simple package by @razorpay to help you validate your IFSC codes. "
    <> "IFSC codes are bank codes within India"
  end

  defp package do
    [
      maintainers: [
        "Nihal Gonsalves <nihal@gonsalves.com>",
        "Abhay Rana <contact@razorpay.com>",
      ],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/razorpay/ifsc",
        "Website" => "https://ifsc.razorpay.com/",
      },
      files: files(),
    ]
  end

  defp files do
    [
      "src/elixir/config/**",
      "src/elixir/lib/**",
      "src/elixir/*.md",
      "tests/elixir/**",
      "tests/*.json",
      "priv/*",
      "src/*.json",
      "*.md",
      "mix.exs",
    ]
  end

  defp deps do
    [
      {:poison, "~> 4.0"},
      {:httpoison, "~> 1.2"},
      {:memoize, "~> 1.2"},
      {:exvcr, "~> 0.10", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp aliases do
    [
      test: ["ifsc.copy_json", "test"],
      "hex.publish": ["ifsc.copy_json", "hex.publish"],
    ]
  end
end
