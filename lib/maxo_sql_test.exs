defmodule MaxoSqlTest do
  use ExUnit.Case
  use MnemeDefaults

  doctest MaxoSql

  test "only passing table" do
    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       """, []} <- MaxoSql.from("users")
    )
  end

  test "selecting all columns" do
    auto_assert(
      {"""
       SELECT *
       FROM `users` `u`
       """, []} <- MaxoSql.from("users", %{select: "*"})
    )
  end

  test "selecting all columns of the base resource" do
    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       """, []} <- MaxoSql.from("users", %{select: ".*"})
    )
  end

  test "selecting columns of the base resource (passing a string)" do
    options = %{
      select: "id, first_name, last_name"
    }

    auto_assert(
      {"""
       SELECT `u`.`id`, `u`.`first_name`, `u`.`last_name`
       FROM `users` `u`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "selecting columns of the base resource (passing a list)" do
    options = %{
      select: ["id", "first_name", "last_name"]
    }

    auto_assert(
      {"""
       SELECT `u`.`id`, `u`.`first_name`, `u`.`last_name`
       FROM `users` `u`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "selecting weirdly named columns of the base resource (passing a list)" do
    options = %{
      select: ["id", "first_name", "m2", "a"]
    }

    auto_assert(
      {"""
       SELECT `u`.`id`, `u`.`first_name`, `u`.`m2`, `u`.`a`
       FROM `users` `u`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "selecting weirdly named columns of the base resource (passing a map)" do
    options = %{
      select: ["id", "name", "m2", "a"],
      where: [
        ["name LIKE ? OR name LIKE ?", "%Paul%", "%Engel%"]
      ]
    }

    auto_assert(
      {"""
       SELECT `u`.`id`, `u`.`name`, `u`.`m2`, `u`.`a`
       FROM `users` `u`
       WHERE (`u`.`name` LIKE ? OR `u`.`name` LIKE ?)
       """, ["%Paul%", "%Engel%"]} <- MaxoSql.from("users", options)
    )
  end

  test "interpolating variables" do
    options = %{
      select: ["id", "CONCAT(name, <<postfix>>)"],
      variables: %{postfix: "PostFix!"}
    }

    auto_assert(
      {"""
       SELECT `u`.`id`, CONCAT(`u`.`name`, ?)
       FROM `users` `u`
       """, ["PostFix!"], ["postfix"]} <- MaxoSql.from("users", options)
    )
  end

  test "interpolating variables respects multiple occurrences " do
    options = %{
      select: ["id", "CONCAT(name, <<postfix>>)"],
      where: "foobar LIKE <<postfix>>",
      variables: %{postfix: "PostFix!"}
    }

    auto_assert(
      {"""
       SELECT `u`.`id`, CONCAT(`u`.`name`, ?)
       FROM `users` `u`
       WHERE (`u`.`foobar` LIKE ?)
       """, ["PostFix!", "PostFix!"], ["postfix", "postfix"]} <- MaxoSql.from("users", options)
    )
  end

  test "interpolating variables containing nested maps" do
    options = %{
      select: ["id", "name"],
      where: "first_name LIKE <<user.first_name>>",
      variables: %{user: %{first_name: "Paul"}}
    }

    auto_assert(
      {"""
       SELECT `u`.`id`, `u`.`name`
       FROM `users` `u`
       WHERE (`u`.`first_name` LIKE ?)
       """, ["Paul"], ["user.first_name"]} <- MaxoSql.from("users", options)
    )
  end

  test "resulting variables respects multiple occurrences " do
    options = %{
      select: ["id", "CONCAT(name, <<postfix>>)"],
      where: "foobar LIKE <<postfix>>",
      variables: %{postfix: "PostFix!"}
    }

    auto_assert(
      {"""
       SELECT `u`.`id`, CONCAT(`u`.`name`, ?)
       FROM `users` `u`
       WHERE (`u`.`foobar` LIKE ?)
       """, ["PostFix!", "PostFix!"], ["postfix", "postfix"]} <- MaxoSql.from("users", options)
    )
  end

  test "using functions" do
    options = %{
      select: "COUNT(*)"
    }

    auto_assert(
      {"""
       SELECT COUNT(*)
       FROM `users` `u`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "using quoted arguments" do
    options = %{
      select:
        "id, CONCAT(\"First name: '\", first_name, \"' Last name: '\", last_name, \"'\"), DATE_FORMAT(updated_at, '%d-%m-%Y')"
    }

    auto_assert(
      {"""
       SELECT
         `u`.`id`,
         CONCAT("First name: '", `u`.`first_name`, "' Last name: '", `u`.`last_name`, "'"),
         DATE_FORMAT(`u`.`updated_at`, '%d-%m-%Y')
       FROM `users` `u`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "selecting columns of a 'belongs to' association" do
    options = %{
      select: "id, first_name, user_role.name, department.id, department.name"
    }

    auto_assert(
      {"""
       SELECT
         `u`.`id`,
         `u`.`first_name`,
         `user_role`.`name`,
         `department`.`id`,
         `department`.`name`
       FROM `users` `u`
       LEFT JOIN `user_roles` `user_role` ON `user_role`.`id` = `u`.`user_role_id`
       LEFT JOIN `departments` `department` ON `department`.`id` = `u`.`department_id`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "extreme column and table naming with a belongs_to" do
    options = %{
      select: "id, first_name, user_role.name, department.id, department.name"
    }

    schema = %{
      departments: %{
        table_name: "super department.store"
      },
      users: %{
        department: %{
          foreign_key: "insane weird.stuff"
        }
      }
    }

    auto_assert(
      {"""
       SELECT
         `u`.`id`,
         `u`.`first_name`,
         `user_role`.`name`,
         `department`.`id`,
         `department`.`name`
       FROM `users` `u`
       LEFT JOIN `user_roles` `user_role` ON `user_role`.`id` = `u`.`user_role_id`
       LEFT JOIN `super department.store` `department` ON `department`.`id` = `u`.`insane weird.stuff`
       """, []} <- MaxoSql.from("users", options, schema)
    )
  end

  test "selecting columns of a nested 'belongs to' association" do
    options = %{
      select: "id, first_name, company.category.name"
    }

    auto_assert(
      {"""
       SELECT
         `u`.`id`,
         `u`.`first_name`,
         `company.category`.`name`
       FROM `users` `u`
       LEFT JOIN `companies` `company` ON `company`.`id` = `u`.`company_id`
       LEFT JOIN `categories` `company.category` ON `company.category`.`id` = `company`.`category_id`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "selecting columns of a 'has many' association" do
    options = %{
      select: "id, first_name, last_name, GROUP_CONCAT(orders.id)"
    }

    auto_assert(
      {"""
       SELECT
         `u`.`id`,
         `u`.`first_name`,
         `u`.`last_name`,
         GROUP_CONCAT(`orders`.`id`)
       FROM `users` `u`
       LEFT JOIN `orders` `orders` ON `orders`.`user_id` = `u`.`id`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "selecting columns of a nested 'has many' association" do
    options = %{
      select: "id, first_name, last_name, GROUP_CONCAT(company.orders.id)"
    }

    auto_assert(
      {"""
       SELECT
         `u`.`id`,
         `u`.`first_name`,
         `u`.`last_name`,
         GROUP_CONCAT(`company.orders`.`id`)
       FROM `users` `u`
       LEFT JOIN `companies` `company` ON `company`.`id` = `u`.`company_id`
       LEFT JOIN `orders` `company.orders` ON `company.orders`.`company_id` = `company`.`id`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "selecting columns of a 'has and belongs to many' association" do
    options = %{
      select: "id, first_name, last_name, GROUP_CONCAT(skills.name)"
    }

    schema = %{
      users: %{
        skills: %{
          cardinality: :has_and_belongs_to_many
        }
      }
    }

    auto_assert(
      {"""
       SELECT
         `u`.`id`,
         `u`.`first_name`,
         `u`.`last_name`,
         GROUP_CONCAT(`skills`.`name`)
       FROM `users` `u`
       LEFT JOIN `skills_users` `skills_bridge_table` ON `skills_bridge_table`.`user_id` = `u`.`id`
       LEFT JOIN `skills` `skills` ON `skills`.`id` = `skills_bridge_table`.`skill_id`
       """, []} <- MaxoSql.from("users", options, schema)
    )
  end

  test "selecting columns of a 'has one' association" do
    options = %{
      select: "id, name, current_price.amount",
      group_by: "id"
    }

    schema = %{
      products: %{
        current_price: %{
          cardinality: :has_one,
          resource: "prices"
        }
      }
    }

    auto_assert(
      {"""
       SELECT
         `p`.`id`,
         `p`.`name`,
         `current_price`.`amount`
       FROM `products` `p`
       LEFT JOIN `prices` `current_price` ON `current_price`.`product_id` = `p`.`id`
       GROUP BY `p`.`id`
       """, []} <- MaxoSql.from("products", options, schema)
    )
  end

  test "adding join conditions for paths" do
    options = %{
      select: "id, name, current_price.amount",
      join_on: "current_price.latest = 1"
    }

    schema = %{
      products: %{
        current_price: %{
          cardinality: :has_one,
          resource: "prices"
        }
      }
    }

    auto_assert(
      {"""
       SELECT
         `p`.`id`,
         `p`.`name`,
         `current_price`.`amount`
       FROM `products` `p`
       LEFT JOIN `prices` `current_price` ON `current_price`.`product_id` = `p`.`id` AND `current_price`.`latest` = 1
       """, []} <- MaxoSql.from("products", options, schema)
    )
  end

  test "adding join conditions within the schema" do
    options = %{
      select: "id, name, current_price.amount"
    }

    schema = %{
      products: %{
        current_price: %{
          cardinality: :has_one,
          resource: "prices",
          join_on: "latest = 1"
        }
      }
    }

    auto_assert(
      {"""
       SELECT
         `p`.`id`,
         `p`.`name`,
         `current_price`.`amount`
       FROM `products` `p`
       LEFT JOIN `prices` `current_price` ON `current_price`.`product_id` = `p`.`id` AND `current_price`.`latest` = 1
       """, []} <- MaxoSql.from("products", options, schema)
    )
  end

  test "adding join conditions within the schema using variables" do
    options = %{
      select: "id, name, current_statistic.amount",
      variables: %{
        scope: "awesome_scope"
      }
    }

    schema = %{
      products: %{
        current_statistic: %{
          cardinality: :has_one,
          resource: "statistics",
          join_on: "scope = <<scope>>"
        }
      }
    }

    auto_assert(
      {"""
       SELECT
         `p`.`id`,
         `p`.`name`,
         `current_statistic`.`amount`
       FROM `products` `p`
       LEFT JOIN `statistics` `current_statistic` ON `current_statistic`.`product_id` = `p`.`id` AND `current_statistic`.`scope` = ?
       """, ["awesome_scope"], ["scope"]} <- MaxoSql.from("products", options, schema)
    )
  end

  test "selecting columns of a nested 'has and belongs to many' association" do
    options = %{
      select: "id, first_name, last_name, GROUP_CONCAT(company.tags.name)"
    }

    schema = %{
      companies: %{
        tags: %{
          cardinality: :has_and_belongs_to_many
        }
      }
    }

    auto_assert(
      {"""
       SELECT
         `u`.`id`,
         `u`.`first_name`,
         `u`.`last_name`,
         GROUP_CONCAT(`company.tags`.`name`)
       FROM `users` `u`
       LEFT JOIN `companies` `company` ON `company`.`id` = `u`.`company_id`
       LEFT JOIN `companies_tags` `company.tags_bridge_table` ON `company.tags_bridge_table`.`company_id` = `company`.`id`
       LEFT JOIN `tags` `company.tags` ON `company.tags`.`id` = `company.tags_bridge_table`.`tag_id`
       """, []} <- MaxoSql.from("users", options, schema)
    )
  end

  test "supports ['path = ? OR path = ?', criteria1, criteria2] notation (complexity 1)" do
    options = %{
      select: ["id", "name"],
      where: ["name LIKE ?", "%Engel%"]
    }

    auto_assert(
      {"""
       SELECT `u`.`id`, `u`.`name`
       FROM `users` `u`
       WHERE (`u`.`name` LIKE ?)
       """, ["%Engel%"]} <- MaxoSql.from("users", options)
    )
  end

  test "supports ['path = ? OR path = ?', criteria1, criteria2] notation (complexity 2)" do
    options = %{
      select: ["id", "name"],
      where: ["name LIKE ? OR name LIKE ?", "%Paul%", "%Engel%"]
    }

    auto_assert(
      {"""
       SELECT `u`.`id`, `u`.`name`
       FROM `users` `u`
       WHERE (`u`.`name` LIKE ? OR `u`.`name` LIKE ?)
       """, ["%Paul%", "%Engel%"]} <- MaxoSql.from("users", options)
    )
  end

  test "supports ['path = ? OR path = ?', criteria1, criteria2] notation (complexity 3)" do
    options = %{
      select: ["id", "name"],
      where: [
        ["name LIKE ? OR name LIKE ?", "%Paul%", "%Engel%"],
        ["company_id = 1982"],
        ["address.city = ? AND subscription.active = ?", "Amsterdam", true],
        ["tags.name IN (?)", [1, 8, 1982]]
      ]
    }

    auto_assert(
      {"""
       SELECT `u`.`id`, `u`.`name`
       FROM `users` `u`
       LEFT JOIN `addresses` `address` ON `address`.`id` = `u`.`address_id`
       LEFT JOIN `subscriptions` `subscription` ON `subscription`.`id` = `u`.`subscription_id`
       LEFT JOIN `tags` `tags` ON `tags`.`user_id` = `u`.`id`
       WHERE (`u`.`name` LIKE ? OR `u`.`name` LIKE ?) AND (`u`.`company_id` = 1982) AND (`address`.`city` = ? AND `subscription`.`active` = ?) AND (`tags`.`name` IN (?))
       """,
       ["%Paul%", "%Engel%", "Amsterdam", true, [1, 8, 1982]]} <- MaxoSql.from("users", options)
    )
  end

  test "overriding the resource table name" do
    schema = %{
      resellers: %{
        table_name: "companies"
      }
    }

    auto_assert(
      {"""
       SELECT `r`.*
       FROM `companies` `r`
       """, []} <- MaxoSql.from("resellers", %{}, schema)
    )
  end

  test "overriding the resource of an association" do
    options = %{
      select: ["id", "description", "CONCAT(assignee.first_name, ' ', assignee.last_name)"]
    }

    schema = %{
      issues: %{
        assignee: %{resource: "users"}
      }
    }

    auto_assert(
      {"""
       SELECT
         `i`.`id`,
         `i`.`description`,
         CONCAT(`assignee`.`first_name`, ' ', `assignee`.`last_name`)
       FROM `issues` `i`
       LEFT JOIN `users` `assignee` ON `assignee`.`id` = `i`.`assignee_id`
       """, []} <- MaxoSql.from("issues", options, schema)
    )
  end

  test "overriding the table name of an association" do
    options = %{
      select: ["id", "description", "CONCAT(assignee.first_name, ' ', assignee.last_name)"]
    }

    schema = %{
      issues: %{
        assignee: %{table_name: "users"}
      }
    }

    auto_assert(
      {"""
       SELECT
         `i`.`id`,
         `i`.`description`,
         CONCAT(`assignee`.`first_name`, ' ', `assignee`.`last_name`)
       FROM `issues` `i`
       LEFT JOIN `users` `assignee` ON `assignee`.`id` = `i`.`assignee_id`
       """, []} <- MaxoSql.from("issues", options, schema)
    )
  end

  test "overriding the bridge table of a has and belongs to many association" do
    options = %{
      select: "id, first_name, last_name, GROUP_CONCAT(skills.name)"
    }

    schema = %{
      users: %{
        skills: %{
          cardinality: :has_and_belongs_to_many,
          bridge_table: "skill_set",
          foreign_key: "person_id"
        }
      }
    }

    auto_assert(
      {"""
       SELECT
         `u`.`id`,
         `u`.`first_name`,
         `u`.`last_name`,
         GROUP_CONCAT(`skills`.`name`)
       FROM `users` `u`
       LEFT JOIN `skill_set` `skills_bridge_table` ON `skills_bridge_table`.`person_id` = `u`.`id`
       LEFT JOIN `skills` `skills` ON `skills`.`id` = `skills_bridge_table`.`skill_id`
       """, []} <- MaxoSql.from("users", options, schema)
    )
  end

  test "overriding the bridge table of a has and belongs to many with extreme table names in association" do
    options = %{
      select: "id, first_name, last_name, GROUP_CONCAT(skills.name)"
    }

    schema = %{
      users: %{
        skills: %{
          cardinality: :has_and_belongs_to_many,
          bridge_table: "test skill_set.awesome",
          foreign_key: "strange.person_id"
        }
      }
    }

    auto_assert(
      {"""
       SELECT
         `u`.`id`,
         `u`.`first_name`,
         `u`.`last_name`,
         GROUP_CONCAT(`skills`.`name`)
       FROM `users` `u`
       LEFT JOIN `test skill_set.awesome` `skills_bridge_table` ON `skills_bridge_table`.`strange.person_id` = `u`.`id`
       LEFT JOIN `skills` `skills` ON `skills`.`id` = `skills_bridge_table`.`skill_id`
       """, []} <- MaxoSql.from("users", options, schema)
    )
  end

  test "grouping the query result" do
    options = %{
      select: ["COUNT(*)"],
      group_by: "category.name"
    }

    auto_assert(
      {"""
       SELECT COUNT(*)
       FROM `users` `u`
       LEFT JOIN `categories` `category` ON `category`.`id` = `u`.`category_id`
       GROUP BY `category`.`name`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "ordering the query result (passing a string)" do
    options = %{
      select: ".*",
      order_by: "last_name ASC, first_name"
    }

    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       ORDER BY `u`.`last_name` ASC, `u`.`first_name`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "ordering the query result (passing a list)" do
    options = %{
      select: ".*",
      order_by: ["last_name ASC", "first_name"]
    }

    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       ORDER BY `u`.`last_name` ASC, `u`.`first_name`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "limiting the query result" do
    options = %{
      limit: 20
    }

    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       LIMIT ?
       """, [20]} <- MaxoSql.from("users", options)
    )
  end

  test "limiting the query result by passing the limit in variables[:_options_][:limit]" do
    options = %{
      limit: "?",
      variables: %{
        _options_: %{
          limit: 20
        }
      }
    }

    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       LIMIT ?
       """, [20], ["_options_.limit"]} <- MaxoSql.from("users", options)
    )
  end

  test "adding an offset to the query result" do
    options = %{
      limit: 10,
      offset: 20
    }

    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       LIMIT ?
       OFFSET ?
       """, [10, 20]} <- MaxoSql.from("users", options)
    )
  end

  test "adding an offset to the query result by passing the offset in variables[:_options_][:offset]" do
    options = %{
      limit: 10,
      offset: "?",
      variables: %{
        _options_: %{
          offset: 20
        }
      }
    }

    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       LIMIT ?
       OFFSET ?
       """, [10, 20], [nil, "_options_.offset"]} <- MaxoSql.from("users", options)
    )
  end

  test "quoting SELECT statement aliases" do
    options = %{
      select: "id AS foo.bar"
    }

    auto_assert(
      {"""
       SELECT `u`.`id` AS `foo.bar`
       FROM `users` `u`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "putting quoted SELECT statement aliases either in the WHERE or HAVING statement" do
    options = %{
      select:
        "id AS id, CONCAT(first_name, ' ', last_name) AS name, company.name AS company.name",
      where: ["id <= 1982", "name LIKE '%Engel%'", "company.name LIKE '%Inc%'"]
    }

    auto_assert(
      {"""
       SELECT
         `u`.`id` AS `id`,
         CONCAT(`u`.`first_name`, ' ', `u`.`last_name`) AS `name`,
         `company`.`name` AS `company.name`
       FROM `users` `u`
       LEFT JOIN `companies` `company` ON `company`.`id` = `u`.`company_id`
       WHERE (`u`.`id` <= 1982) AND (`company`.`name` LIKE '%Inc%')
       HAVING (`name` LIKE '%Engel%')
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "respecting preserved word NULL" do
    options = %{
      where: "name IS NOT NULL"
    }

    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       WHERE (`u`.`name` IS NOT NULL)
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "respecting booleans" do
    options = %{
      where: "is_admin = true OR FALSE"
    }

    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       WHERE (`u`.`is_admin` = true OR FALSE)
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "handling '' within WHERE statements" do
    options = %{
      where: "name = ''"
    }

    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       WHERE (`u`.`name` = '')
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "not auto-grouping base records at default" do
    options = %{
      select: "id",
      where: "organization.addresses.street LIKE '%Broad%'"
    }

    auto_assert(
      {"""
       SELECT `u`.`id`
       FROM `users` `u`
       LEFT JOIN `organizations` `organization` ON `organization`.`id` = `u`.`organization_id`
       LEFT JOIN `addresses` `organization.addresses` ON `organization.addresses`.`organization_id` = `organization`.`id`
       WHERE (`organization.addresses`.`street` LIKE '%Broad%')
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "being able to ensuring unique base records for has_many associations" do
    options = %{
      select: "id",
      where: "organization.addresses.street LIKE '%Broad%'",
      unique: true
    }

    auto_assert(
      {"""
       SELECT `u`.`id`
       FROM `users` `u`
       LEFT JOIN `organizations` `organization` ON `organization`.`id` = `u`.`organization_id`
       LEFT JOIN `addresses` `organization.addresses` ON `organization.addresses`.`organization_id` = `organization`.`id`
       WHERE (`organization.addresses`.`street` LIKE '%Broad%')
       GROUP BY `u`.`id`
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "extreme column and table naming with has_many" do
    options = %{
      select: "id",
      where: "organization.addresses.street LIKE '%Broad%'",
      unique: true
    }

    schema = %{
      organizations: %{
        addresses: %{
          foreign_key: "sql dust.is.cool"
        }
      },
      addresses: %{
        table_name: "some address.table"
      }
    }

    auto_assert(
      {"""
       SELECT `u`.`id`
       FROM `users` `u`
       LEFT JOIN `organizations` `organization` ON `organization`.`id` = `u`.`organization_id`
       LEFT JOIN `some address.table` `organization.addresses` ON `organization.addresses`.`sql dust.is.cool` = `organization`.`id`
       WHERE (`organization.addresses`.`street` LIKE '%Broad%')
       GROUP BY `u`.`id`
       """, []} <- MaxoSql.from("users", options, schema)
    )
  end

  test "being able to ensuring unique base records for has_one associations" do
    options = %{
      select: "id",
      where: "organization.name LIKE '%Broad%'",
      unique: true
    }

    schema = %{
      users: %{
        organization: %{
          cardinality: :has_one
        }
      }
    }

    auto_assert(
      {"""
       SELECT `u`.`id`
       FROM `users` `u`
       LEFT JOIN `organizations` `organization` ON `organization`.`user_id` = `u`.`id`
       WHERE (`organization`.`name` LIKE '%Broad%')
       GROUP BY `u`.`id`
       """, []} <- MaxoSql.from("users", options, schema)
    )
  end

  test "extreme column and table naming with a has_one" do
    options = %{
      select: "id",
      where: "organization.name LIKE '%Broad%'",
      unique: true
    }

    schema = %{
      users: %{
        organization: %{
          cardinality: :has_one,
          foreign_key: "user.organization column"
        }
      },
      organizations: %{
        table_name: "organization hallo.test"
      }
    }

    auto_assert(
      {"""
       SELECT `u`.`id`
       FROM `users` `u`
       LEFT JOIN `organization hallo.test` `organization` ON `organization`.`user.organization column` = `u`.`id`
       WHERE (`organization`.`name` LIKE '%Broad%')
       GROUP BY `u`.`id`
       """, []} <- MaxoSql.from("users", options, schema)
    )
  end

  test "being able to ensuring unique base records for has_and_belongs_to_many associations" do
    options = %{
      select: "id",
      where: "skills.name LIKE '%cool%'",
      unique: true
    }

    schema = %{
      users: %{
        skills: %{
          cardinality: :has_and_belongs_to_many
        }
      }
    }

    auto_assert(
      {"""
       SELECT `u`.`id`
       FROM `users` `u`
       LEFT JOIN `skills_users` `skills_bridge_table` ON `skills_bridge_table`.`user_id` = `u`.`id`
       LEFT JOIN `skills` `skills` ON `skills`.`id` = `skills_bridge_table`.`skill_id`
       WHERE (`skills`.`name` LIKE '%cool%')
       GROUP BY `u`.`id`
       """, []} <- MaxoSql.from("users", options, schema)
    )
  end

  test "DirectiveRecord example 1 (with additional WHERE statements)" do
    options = %{
      select:
        "id, name, COUNT(orders.id) AS order.count, GROUP_CONCAT(DISTINCT tags.name) AS tags, foo.tags",
      group_by: "id",
      where: ["name LIKE '%Paul%'", "order.count > 5", "foo.tags = 1"],
      order_by: "COUNT(DISTINCT tags.id) DESC",
      limit: 5
    }

    schema = %{
      customers: %{
        tags: %{
          cardinality: :has_and_belongs_to_many
        }
      }
    }

    auto_assert(
      {"""
       SELECT
         `c`.`id`,
         `c`.`name`,
         COUNT(`orders`.`id`) AS `order.count`,
         GROUP_CONCAT(DISTINCT `tags`.`name`) AS `tags`,
         `foo`.`tags`
       FROM `customers` `c`
       LEFT JOIN `orders` `orders` ON `orders`.`customer_id` = `c`.`id`
       LEFT JOIN `customers_tags` `tags_bridge_table` ON `tags_bridge_table`.`customer_id` = `c`.`id`
       LEFT JOIN `tags` `tags` ON `tags`.`id` = `tags_bridge_table`.`tag_id`
       LEFT JOIN `foos` `foo` ON `foo`.`id` = `c`.`foo_id`
       WHERE (`c`.`name` LIKE '%Paul%') AND (`foo`.`tags` = 1)
       GROUP BY `c`.`id`
       HAVING (`order.count` > 5)
       ORDER BY COUNT(DISTINCT `tags`.`id`) DESC
       LIMIT ?
       """, [5]} <- MaxoSql.from("customers", options, schema)
    )
  end

  test "DirectiveRecord example 3" do
    options = %{
      where: "tags.name LIKE '%gifts%'"
    }

    schema = %{
      customers: %{
        tags: %{
          cardinality: :has_and_belongs_to_many
        }
      }
    }

    auto_assert(
      {"""
       SELECT `c`.*
       FROM `customers` `c`
       LEFT JOIN `customers_tags` `tags_bridge_table` ON `tags_bridge_table`.`customer_id` = `c`.`id`
       LEFT JOIN `tags` `tags` ON `tags`.`id` = `tags_bridge_table`.`tag_id`
       WHERE (`tags`.`name` LIKE '%gifts%')
       """, []} <- MaxoSql.from("customers", options, schema)
    )
  end

  test "DirectiveRecord example 5" do
    options = %{
      select: "tags.*",
      where: "tags.name LIKE '%gifts%'",
      group_by: "tags.id"
    }

    schema = %{
      customers: %{
        tags: %{
          cardinality: :has_and_belongs_to_many
        }
      }
    }

    auto_assert(
      {"""
       SELECT `tags`.*
       FROM `customers` `c`
       LEFT JOIN `customers_tags` `tags_bridge_table` ON `tags_bridge_table`.`customer_id` = `c`.`id`
       LEFT JOIN `tags` `tags` ON `tags`.`id` = `tags_bridge_table`.`tag_id`
       WHERE (`tags`.`name` LIKE '%gifts%')
       GROUP BY `tags`.`id`
       """, []} <- MaxoSql.from("customers", options, schema)
    )
  end

  test "DirectiveRecord example 6" do
    options = %{
      select: ["id", "name", "COUNT(orders.id) AS order_count"],
      where: "order_count > 3",
      group_by: "id"
    }

    auto_assert(
      {"""
       SELECT
         `c`.`id`,
         `c`.`name`,
         COUNT(`orders`.`id`) AS `order_count`
       FROM `customers` `c`
       LEFT JOIN `orders` `orders` ON `orders`.`customer_id` = `c`.`id`
       GROUP BY `c`.`id`
       HAVING (`order_count` > 3)
       """, []} <- MaxoSql.from("customers", options)
    )
  end

  test "prepending path aliases in the HAVING statement while respecting SELECT statement aliases" do
    options = %{
      select: "id AS identifier",
      where: "identifier > 0 AND id != 2",
      order_by: "description desc"
    }

    auto_assert(
      {"""
       SELECT `u`.`id` AS `identifier`
       FROM `users` `u`
       HAVING (`identifier` > 0 AND `u`.`id` != 2)
       ORDER BY `u`.`description` desc
       """, []} <- MaxoSql.from("users", options)
    )
  end

  test "downcasing base table alias" do
    schema = %{
      User: %{
        table_name: "people"
      }
    }

    auto_assert(
      {"""
       SELECT `u`.*
       FROM `people` `u`
       """, []} <- MaxoSql.from("User", %{}, schema)
    )
  end

  test "ignore WHERE with empty statement" do
    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       """, []} <- MaxoSql.from("users", %{where: [""]})
    )

    auto_assert(
      {"""
       SELECT `u`.*
       FROM `users` `u`
       WHERE (`u`.`id` = 1)
       """, []} <- MaxoSql.from("users", %{where: ["", "id = 1", "    "]})
    )
  end
end
