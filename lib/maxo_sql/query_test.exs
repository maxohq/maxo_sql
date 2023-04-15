defmodule MaxoSql.QueryTest do
  use ExUnit.Case
  use MnemeDefaults
  doctest MaxoSql.Query
  import MaxoSql.Query

  test "select returns MaxoSql containing :select option (passing a string)" do
    query = select("id")

    auto_assert(%MaxoSql{select: ["id"]} <- query)
  end

  test "select returns MaxoSql containing :select option (passing a list)" do
    query = select(["id"])

    auto_assert(%MaxoSql{select: ["id"]} <- query)
  end

  test "select appends an argument to existing :select option (passing a string)" do
    query =
      select("id")
      |> select("name")

    auto_assert(%MaxoSql{select: ["id", "name"]} <- query)
  end

  test "select appends an argument to existing :select option (passing a list)" do
    query =
      select("id")
      |> select(~w(name))

    auto_assert(%MaxoSql{select: ["id", "name"]} <- query)
  end

  test "passing a string to imply the :from option" do
    query =
      "users"
      |> select("id")

    auto_assert(%MaxoSql{from: "users", select: ["id"]} <- query)
  end

  test "from returns MaxoSql containing :from option" do
    query = from("users")

    auto_assert(%MaxoSql{from: "users"} <- query)
  end

  test "from sets :from option of passed MaxoSql" do
    query =
      select("id")
      |> from("users")

    auto_assert(%MaxoSql{from: "users", select: ["id"]} <- query)
  end

  test "from converts atoms to strings" do
    query =
      select("id")
      |> from(:users)

    auto_assert(%MaxoSql{from: "users", select: ["id"]} <- query)
  end

  test "where returns MaxoSql containing :where option (passing a string)" do
    query = where("company.name LIKE '%Engel%'")

    auto_assert(%MaxoSql{where: ["company.name LIKE '%Engel%'"]} <- query)
  end

  test "where returns MaxoSql containing :where option (passing a list)" do
    query = where(["company.name LIKE '%Engel%'"])

    auto_assert(%MaxoSql{where: [["company.name LIKE '%Engel%'"]]} <- query)
  end

  test "where appends an argument to existing :where option (passing a string)" do
    query =
      where("company.name LIKE '%Engel%'")
      |> where("category_id = 1")

    auto_assert(%MaxoSql{where: ["company.name LIKE '%Engel%'", "category_id = 1"]} <- query)
  end

  test "where appends an argument to existing :where option (passing a list)" do
    query =
      where(["company.name LIKE ?", "%Engel%"])
      |> where(["category_id = ?", 1])

    auto_assert(
      %MaxoSql{where: [["company.name LIKE ?", "%Engel%"], ["category_id = ?", 1]]} <- query
    )
  end

  test "variables returns MaxoSql containing :variables option" do
    query = variables(%{id: 1982})

    auto_assert(%MaxoSql{variables: %{id: 1982}} <- query)
  end

  test "variables merges an argument to existing :variables option" do
    query =
      variables(%{id: 1982})
      |> variables(%{name: "Paul Engel"})

    auto_assert(%MaxoSql{variables: %{id: 1982, name: "Paul Engel"}} <- query)
  end

  test "group_by returns MaxoSql containing :group_by option (passing a string)" do
    query = group_by("company_id")

    auto_assert(%MaxoSql{group_by: ["company_id"]} <- query)
  end

  test "group_by returns MaxoSql containing :group_by option (passing a list)" do
    query = group_by(["company_id"])

    auto_assert(%MaxoSql{group_by: ["company_id"]} <- query)
  end

  test "group_by appends an argument to existing :group_by option (passing a string)" do
    query =
      group_by("company_id")
      |> group_by("category_id")

    auto_assert(%MaxoSql{group_by: ["company_id", "category_id"]} <- query)
  end

  test "group_by appends an argument to existing :group_by option (passing a list)" do
    query =
      group_by("company_id")
      |> group_by(~w(category_id))

    auto_assert(%MaxoSql{group_by: ["company_id", "category_id"]} <- query)
  end

  test "order_by returns MaxoSql containing :order_by option (passing a string)" do
    query = order_by("company_id")

    auto_assert(%MaxoSql{order_by: ["company_id"]} <- query)
  end

  test "order_by returns MaxoSql containing :order_by option (passing a list)" do
    query = order_by(["company_id"])

    auto_assert(%MaxoSql{order_by: ["company_id"]} <- query)
  end

  test "order_by appends an argument to existing :order_by option (passing a string)" do
    query =
      order_by("company_id")
      |> order_by("category_id")

    auto_assert(%MaxoSql{order_by: ["company_id", "category_id"]} <- query)
  end

  test "order_by appends an argument to existing :order_by option (passing a list)" do
    query =
      order_by("company_id")
      |> order_by(~w(category_id))

    auto_assert(%MaxoSql{order_by: ["company_id", "category_id"]} <- query)
  end

  test "limit returns MaxoSql containing :limit option" do
    query = limit(10)

    auto_assert(%MaxoSql{limit: 10} <- query)
  end

  test "limit sets :limit option of passed MaxoSql" do
    query =
      select("id")
      |> limit(10)

    auto_assert(%MaxoSql{limit: 10, select: ["id"]} <- query)
  end

  test "limit defaults to '?'" do
    query =
      select("id")
      |> limit

    auto_assert(%MaxoSql{limit: "?", select: ["id"]} <- query)
  end

  test "limit overwrites :limit option within passed MaxoSql" do
    query =
      select("id")
      |> limit(10)
      |> limit(100)

    auto_assert(%MaxoSql{limit: 100, select: ["id"]} <- query)
  end

  test "limit default overwrites :limit option within passed MaxoSql" do
    query =
      select("id")
      |> limit(10)
      |> limit

    auto_assert(%MaxoSql{limit: "?", select: ["id"]} <- query)
  end

  test "offset returns MaxoSql containing :offset option" do
    query = offset(10)

    auto_assert(%MaxoSql{offset: 10} <- query)
  end

  test "offset sets :offset option of passed MaxoSql" do
    query =
      select("id")
      |> offset(10)

    auto_assert(%MaxoSql{offset: 10, select: ["id"]} <- query)
  end

  test "offset overwrites :offset option within passed MaxoSql" do
    query =
      select("id")
      |> offset(10)
      |> offset(100)

    auto_assert(%MaxoSql{offset: 100, select: ["id"]} <- query)
  end

  test "offset defaults to '?'" do
    query =
      select("id")
      |> offset

    auto_assert(%MaxoSql{offset: "?", select: ["id"]} <- query)
  end

  test "offset default overwrites :offset option within passed MaxoSql" do
    query =
      select("id")
      |> offset(10)
      |> offset

    auto_assert(%MaxoSql{offset: "?", select: ["id"]} <- query)
  end

  test "unique returns MaxoSql containing :unique option (at default true)" do
    query = unique()

    auto_assert(%MaxoSql{unique: true} <- query)
  end

  test "unique returns MaxoSql containing :unique option" do
    query = unique(false)

    auto_assert(%MaxoSql{unique: false} <- query)
  end

  test "unique sets :unique option of passed MaxoSql" do
    query =
      select("id")
      |> unique(true)

    auto_assert(%MaxoSql{select: ["id"], unique: true} <- query)
  end

  test "unique overwrites :unique option within passed MaxoSql" do
    query =
      select("id")
      |> unique(true)
      |> unique(false)

    auto_assert(%MaxoSql{select: ["id"], unique: false} <- query)
  end

  test "schema returns MaxoSql containing :schema option" do
    query =
      schema(%{
        users: %{
          skills: %{
            cardinality: :has_and_belongs_to_many
          }
        }
      })

    auto_assert(
      %MaxoSql{schema: %{users: %{skills: %{cardinality: :has_and_belongs_to_many}}}} <- query
    )
  end

  test "schema merges argument to existing :schema option" do
    query =
      schema(%{
        users: %{
          skills: %{
            cardinality: :has_and_belongs_to_many
          }
        }
      })
      |> schema(%{
        users: %{
          skills: %{
            primary_key: "identifier"
          }
        },
        relations: %{
          table_name: "users"
        }
      })

    auto_assert(
      %MaxoSql{
        schema: %{
          relations: %{table_name: "users"},
          users: %{skills: %{cardinality: :has_and_belongs_to_many, primary_key: "identifier"}}
        }
      } <- query
    )
  end

  test "throwing an error when generating SQL without having assigned the :from option" do
    assert_raise RuntimeError, "missing :from option in query maxo_sql", fn ->
      select("id")
      |> to_sql
    end
  end

  test "it generates the select for columns that start with a number" do
    {sql, _} =
      select("1st_address as 1st_address")
      |> select("second_address")
      |> from("users")
      |> to_sql

    auto_assert(
      """
      SELECT
        `u`.`1st_address` AS `1st_address`,
        `u`.`second_address`
      FROM `users` `u`
      """ <- sql
    )
  end

  test "it generates the select for columns that ends with a number" do
    {sql, _} =
      select("address1 as address1")
      |> select("second_address")
      |> from("users")
      |> to_sql

    auto_assert(
      """
      SELECT
        `u`.`address1` AS `address1`,
        `u`.`second_address`
      FROM `users` `u`
      """ <- sql
    )
  end

  test "escapes fields with same name as function" do
    {sql, _} =
      select("[regexp] as regexp")
      |> select("[id]")
      |> select("[key.in.value]")
      |> select("'a' REGEXP '^[a-d]'")
      |> select("'Ewout!' REGEXP '.*' as test2")
      |> from("users")
      |> where("[like] = 'ewout'")
      |> to_sql

    auto_assert(
      """
      SELECT
        `u`.`regexp` AS `regexp`,
        `u`.`id`,
        `key.in`.`value`,
        'a' REGEXP '^[a-d]',
        'Ewout!' REGEXP '.*' AS `test2`
      FROM `users` `u`
      LEFT JOIN `keys` `key` ON `key`.`id` = `u`.`key_id`
      LEFT JOIN `ins` `key.in` ON `key.in`.`id` = `key`.`in_id`
      WHERE (`u`.`like` = 'ewout')
      """ <- sql
    )
  end

  test "generating SQL using composed query MaxoSql" do
    sql =
      select("id, name")
      |> select("company.name")
      |> select("company.address.city")
      |> select("company.1st_address")
      |> from("users")
      |> where(["id > ?", 100])
      |> where(["company.name LIKE ?", "%Engel%"])
      |> join_on(["company.address.is_current = ?", 1])
      |> order_by("name, company.name")
      |> limit(20)
      |> schema(%{
        users: %{table_name: "people"},
        companies: %{address: %{cardinality: :has_one}}
      })
      |> unique
      |> to_sql

    auto_assert(
      {"""
       SELECT
         `u`.`id`,
         `u`.`name`,
         `company`.`name`,
         `company.address`.`city`,
         `company`.`1st_address`
       FROM `people` `u`
       LEFT JOIN `companies` `company` ON `company`.`id` = `u`.`company_id`
       LEFT JOIN `addresses` `company.address` ON `company.address`.`company_id` = `company`.`id` AND `company.address`.`is_current` = ?
       WHERE (`u`.`id` > ?) AND (`company`.`name` LIKE ?)
       GROUP BY `u`.`id`
       ORDER BY `u`.`name`, `company`.`name`
       LIMIT ?
       """, [1, 100, "%Engel%", 20]} <- sql
    )
  end
end
