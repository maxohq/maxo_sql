defmodule PerformanceTest do
  @moduledoc false
  import Ecto.MaxoSql

  @test %MaxoSql{
    adapter: nil,
    from: "Address",
    group_by: nil,
    join_on: nil,
    limit: 1,
    offset: nil,
    order_by: ["id ASC"],
    schema: %{
      Address: %{table_name: "addresses"},
      AwesomeModel: %{table_name: "awesome_models"},
      Role: %{
        :table_name => "roles",
        "users" => %{
          association_foreign_key: "user_id",
          association_primary_key: "id",
          bridge_table: "roles_users",
          cardinality: :has_and_belongs_to_many,
          foreign_key: "role_id",
          primary_key: "id",
          resource: "User"
        }
      },
      User: %{
        :table_name => "users",
        "locale" => %{
          cardinality: :belongs_to,
          foreign_key: "locale_id",
          table_name: "user_locale_list"
        },
        "roles" => %{
          association_foreign_key: "role_id",
          association_primary_key: "id",
          bridge_table: "roles_users",
          cardinality: :has_and_belongs_to_many,
          foreign_key: "user_id",
          primary_key: "id",
          resource: "Role"
        }
      }
    },
    select: [],
    unique: true,
    variables: %{scope: "NULL", scope_value: "NULL", var3: "1"},
    where: ["(id = <<var3>>)"]
  }

  def run do
    gen_fn = fn query -> fn -> to_sql(query) end end

    Benchee.run(%{
      "big select (hardcoded)" => gen_fn.(selects(120)),
      "big select (hardcoded) v2" => gen_fn.(gen_query()),
      "small query" => gen_fn.(selects(2)),
      "big joins via select field" => gen_fn.(join_selects(60)),
      "med joins via select field" => gen_fn.(join_selects(20)),
      "big joins via schema & select" => gen_fn.(schema_joins(60)),
      "med joins via schema & select" => gen_fn.(schema_joins(20))
    })
  end

  def schema_joins(i) do
    address = %{table_name: "addresses"}

    {address, select} =
      Enum.reduce(1..i, {address, []}, fn index, {address, select} ->
        index = to_string(index)

        data = %{
          cardinality: :belongs_to,
          foreign_key: "address_id",
          table_name: "table" <> index <> "s"
        }

        {Map.put(address, index <> "a", data), [index <> "a.item as field" <> index | select]}
      end)

    %{@test | schema: %{:Address => address}, select: select}
  end

  def join_selects(i) do
    select = Enum.map(1..i, fn index -> "#{index}table.param as #{index}p" end)
    %{@test | select: select}
  end

  def selects(i) do
    %{@test | select: select_list(i)}
  end

  defp select_list(i) do
    Enum.map(1..i, fn index -> "test#{index} AS test#{index}" end)
  end

  def gen_query() do
    %{@test | from: "User", join_on: [["users.role_id = ?", "1"]], select: select_list(120)}
  end
end

PerformanceTest.run()
