Code.require_file "../test_helper.exs", __FILE__

defmodule TestProjectTest do
  use ExUnit.Case

  test "the truth" do
    IO.puts(Templates.Hello.render name: "Markus")
    assert true
  end
end
