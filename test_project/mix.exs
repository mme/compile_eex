defmodule TestProject.Mixfile do
  use Mix.Project

  def project do
    [ app: :test_project,
      version: "0.0.1",
      deps: deps,
      compilers: [:eex]]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [ {:compile_eex, github: "mme/compile_eex"} ]
  end
end
