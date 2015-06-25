defmodule PhoenixTokenAuth.Mixfile do
  use Mix.Project

  @repo_url "https://github.com/manukall/phoenix_token_auth"

  def project do
    [app: :phoenix_token_auth,
     version: "0.0.14",
     elixir: "~> 1.0.4",
     package: package,
     description: description,
     source_url: @repo_url,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: applications(Mix.env)]
  end

  defp applications(:test), do: applications(:all) ++ [:blacksmith]
  defp applications(_all),  do: [:logger]

  defp package do
    [
        contributors: ["Manuel Kallenbach"],
        licenses: ["MIT"],
        links: %{"GitHub" => @repo_url,
                "Phoenix" => "https://github.com/phoenixframework/phoenix"}
    ]
  end

  defp description do
    """
    Solution for token auth in Phoenix apps. Provides an api for registration, account confirmation
    and logging in.
    """
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
        {:cowboy, "~> 1.0.0"},
        {:phoenix, ">= 0.13.1"},
        {:ecto, "~> 0.12.0"},
        {:comeonin, "~> 1.0"},
        {:postgrex, ">= 0.8.4"},
        {:joken, "~> 0.14.1"},
        {:poison, "~> 1.4.0"},
        {:secure_random, "~> 0.1.1"},
        {:mailgun, "~> 0.1.1"},
        {:timex, "~> 0.14.0"},
        # DEV
        {:earmark, "~> 0.1.8", only: :dev},
        {:ex_doc, "~> 0.7.3", only: :dev},
        # TESTING
        {:mock, "~> 0.1.1", only: :test},
        {:blacksmith, git: "git://github.com/batate/blacksmith.git", only: :test},
    ]
  end
end
