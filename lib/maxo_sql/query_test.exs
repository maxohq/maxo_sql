defmodule MaxoSql.QueryTest do
  use ExUnit.Case
  doctest MaxoSql.Query
  import MaxoSql.Query

  test "select returns MaxoSql containing :select option (passing a string)" do
    query = select("id")

    assert query == %MaxoSql{
             select: ["id"]
           }
  end

  test "select returns MaxoSql containing :select option (passing a list)" do
    query = select(["id"])

    assert query == %MaxoSql{
             select: ["id"]
           }
  end

  test "select appends an argument to existing :select option (passing a string)" do
    query =
      select("id")
      |> select("name")

    assert query == %MaxoSql{
             select: ["id", "name"]
           }
  end

  test "select appends an argument to existing :select option (passing a list)" do
    query =
      select("id")
      |> select(~w(name))

    assert query == %MaxoSql{
             select: ["id", "name"]
           }
  end

  test "passing a string to imply the :from option" do
    query =
      "users"
      |> select("id")

    assert query == %MaxoSql{
             select: ["id"],
             from: "users"
           }
  end

  test "from returns MaxoSql containing :from option" do
    query = from("users")

    assert query == %MaxoSql{
             from: "users"
           }
  end

  test "from sets :from option of passed MaxoSql" do
    query =
      select("id")
      |> from("users")

    assert query == %MaxoSql{
             select: ["id"],
             from: "users"
           }
  end

  test "where returns MaxoSql containing :where option (passing a string)" do
    query = where("company.name LIKE '%Engel%'")

    assert query == %MaxoSql{
             where: ["company.name LIKE '%Engel%'"]
           }
  end

  test "where returns MaxoSql containing :where option (passing a list)" do
    query = where(["company.name LIKE '%Engel%'"])

    assert query == %MaxoSql{
             where: [["company.name LIKE '%Engel%'"]]
           }
  end

  test "where appends an argument to existing :where option (passing a string)" do
    query =
      where("company.name LIKE '%Engel%'")
      |> where("category_id = 1")

    assert query == %MaxoSql{
             where: ["company.name LIKE '%Engel%'", "category_id = 1"]
           }
  end

  test "where appends an argument to existing :where option (passing a list)" do
    query =
      where(["company.name LIKE ?", "%Engel%"])
      |> where(["category_id = ?", 1])

    assert query == %MaxoSql{
             where: [
               ["company.name LIKE ?", "%Engel%"],
               ["category_id = ?", 1]
             ]
           }
  end

  test "variables returns MaxoSql containing :variables option" do
    query = variables(%{id: 1982})

    assert query == %MaxoSql{
             variables: %{id: 1982}
           }
  end

  test "variables merges an argument to existing :variables option" do
    query =
      variables(%{id: 1982})
      |> variables(%{name: "Paul Engel"})

    assert query == %MaxoSql{
             variables: %{id: 1982, name: "Paul Engel"}
           }
  end

  test "group_by returns MaxoSql containing :group_by option (passing a string)" do
    query = group_by("company_id")

    assert query == %MaxoSql{
             group_by: ["company_id"]
           }
  end

  test "group_by returns MaxoSql containing :group_by option (passing a list)" do
    query = group_by(["company_id"])

    assert query == %MaxoSql{
             group_by: ["company_id"]
           }
  end

  test "group_by appends an argument to existing :group_by option (passing a string)" do
    query =
      group_by("company_id")
      |> group_by("category_id")

    assert query == %MaxoSql{
             group_by: ["company_id", "category_id"]
           }
  end

  test "group_by appends an argument to existing :group_by option (passing a list)" do
    query =
      group_by("company_id")
      |> group_by(~w(category_id))

    assert query == %MaxoSql{
             group_by: ["company_id", "category_id"]
           }
  end

  test "order_by returns MaxoSql containing :order_by option (passing a string)" do
    query = order_by("company_id")

    assert query == %MaxoSql{
             order_by: ["company_id"]
           }
  end

  test "order_by returns MaxoSql containing :order_by option (passing a list)" do
    query = order_by(["company_id"])

    assert query == %MaxoSql{
             order_by: ["company_id"]
           }
  end

  test "order_by appends an argument to existing :order_by option (passing a string)" do
    query =
      order_by("company_id")
      |> order_by("category_id")

    assert query == %MaxoSql{
             order_by: ["company_id", "category_id"]
           }
  end

  test "order_by appends an argument to existing :order_by option (passing a list)" do
    query =
      order_by("company_id")
      |> order_by(~w(category_id))

    assert query == %MaxoSql{
             order_by: ["company_id", "category_id"]
           }
  end

  test "limit returns MaxoSql containing :limit option" do
    query = limit(10)

    assert query == %MaxoSql{
             limit: 10
           }
  end

  test "limit sets :limit option of passed MaxoSql" do
    query =
      select("id")
      |> limit(10)

    assert query == %MaxoSql{
             select: ["id"],
             limit: 10
           }
  end

  test "limit defaults to '?'" do
    query =
      select("id")
      |> limit

    assert query == %MaxoSql{
             select: ["id"],
             limit: "?"
           }
  end

  test "limit overwrites :limit option within passed MaxoSql" do
    query =
      select("id")
      |> limit(10)
      |> limit(100)

    assert query == %MaxoSql{
             select: ["id"],
             limit: 100
           }
  end

  test "limit default overwrites :limit option within passed MaxoSql" do
    query =
      select("id")
      |> limit(10)
      |> limit

    assert query == %MaxoSql{
             select: ["id"],
             limit: "?"
           }
  end

  test "offset returns MaxoSql containing :offset option" do
    query = offset(10)

    assert query == %MaxoSql{
             offset: 10
           }
  end

  test "offset sets :offset option of passed MaxoSql" do
    query =
      select("id")
      |> offset(10)

    assert query == %MaxoSql{
             select: ["id"],
             offset: 10
           }
  end

  test "offset overwrites :offset option within passed MaxoSql" do
    query =
      select("id")
      |> offset(10)
      |> offset(100)

    assert query == %MaxoSql{
             select: ["id"],
             offset: 100
           }
  end

  test "offset defaults to '?'" do
    query =
      select("id")
      |> offset

    assert query == %MaxoSql{
             select: ["id"],
             offset: "?"
           }
  end

  test "offset default overwrites :offset option within passed MaxoSql" do
    query =
      select("id")
      |> offset(10)
      |> offset

    assert query == %MaxoSql{
             select: ["id"],
             offset: "?"
           }
  end

  test "unique returns MaxoSql containing :unique option (at default true)" do
    query = unique()

    assert query == %MaxoSql{
             unique: true
           }
  end

  test "unique returns MaxoSql containing :unique option" do
    query = unique(false)

    assert query == %MaxoSql{
             unique: false
           }
  end

  test "unique sets :unique option of passed MaxoSql" do
    query =
      select("id")
      |> unique(true)

    assert query == %MaxoSql{
             select: ["id"],
             unique: true
           }
  end

  test "unique overwrites :unique option within passed MaxoSql" do
    query =
      select("id")
      |> unique(true)
      |> unique(false)

    assert query == %MaxoSql{
             select: ["id"],
             unique: false
           }
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

    assert query == %MaxoSql{
             schema: %{
               users: %{
                 skills: %{
                   cardinality: :has_and_belongs_to_many
                 }
               }
             }
           }
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

    assert query == %MaxoSql{
             schema: %{
               users: %{
                 skills: %{
                   cardinality: :has_and_belongs_to_many,
                   primary_key: "identifier"
                 }
               },
               relations: %{
                 table_name: "users"
               }
             }
           }
  end

  test "throwing an error when generating SQL without having assigned the :from option" do
    assert_raise RuntimeError, "missing :from option in query dust", fn ->
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

    assert sql == """
           SELECT
             `u`.`1st_address` AS `1st_address`,
             `u`.`second_address`
           FROM `users` `u`
           """
  end

  test "it generates the select for columns that ends with a number" do
    {sql, _} =
      select("address1 as address1")
      |> select("second_address")
      |> from("users")
      |> to_sql

    assert sql == """
           SELECT
             `u`.`address1` AS `address1`,
             `u`.`second_address`
           FROM `users` `u`
           """
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

    assert sql == """
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
           """
  end

  test "generating SQL using composed query dust" do
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

    assert sql ==
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
              """, [1, 100, "%Engel%", 20]}
  end
end
