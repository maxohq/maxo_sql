defmodule MaxoSqlTest do
  use ExUnit.Case
  use MnemeDefaults

  test "greeting" do
    auto_assert("Welcome to Maxo!" <- MaxoSql.greeting())
  end
end
