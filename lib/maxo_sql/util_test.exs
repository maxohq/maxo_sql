defmodule MaxoSql.UtilTest do
  use ExUnit.Case
  use MnemeDefaults
  alias MaxoSql.Util

  describe "url_to_params" do
    test "parses postgres URLs" do
      url = "postgresql://janedoe:mypassword@localhost:5432/mydb?schema=sample"

      auto_assert(
        [
          username: "janedoe",
          password: "mypassword",
          hostname: "localhost",
          database: "mydb",
          port: 5432,
          type: :psql,
          schema: "sample"
        ] <- Util.url_to_params(url)
      )

      url = "postgresql://janedoe:@localhost:5432/mydb?schema=sample"

      auto_assert(
        [
          username: "janedoe",
          password: "",
          hostname: "localhost",
          database: "mydb",
          port: 5432,
          type: :psql,
          schema: "sample"
        ] <- Util.url_to_params(url)
      )

      url = "postgresql://janedoe:@localhost:5555/mydb?schema=public"

      auto_assert(
        [
          username: "janedoe",
          password: "",
          hostname: "localhost",
          database: "mydb",
          port: 5555,
          type: :psql,
          schema: "public"
        ] <- Util.url_to_params(url)
      )

      url = "postgresql://localhost:5555/mydb?schema=sample"

      auto_assert(
        [
          username: "",
          password: "",
          hostname: "localhost",
          database: "mydb",
          port: 5555,
          type: :psql,
          schema: "sample"
        ] <- Util.url_to_params(url)
      )
    end

    test "parses mysql urls" do
      url = "mysql://janedoe:mypassword@localhost:3306/mydb"

      auto_assert(
        [
          username: "janedoe",
          password: "mypassword",
          hostname: "localhost",
          database: "mydb",
          port: 3306,
          type: :mysql
        ] <- Util.url_to_params(url)
      )

      url = "mysql://janedoe:@localhost:3306/mydb"

      auto_assert(
        [
          username: "janedoe",
          password: "",
          hostname: "localhost",
          database: "mydb",
          port: 3306,
          type: :mysql
        ] <- Util.url_to_params(url)
      )

      url = "mysql://janedoe:@localhost:3399/mydb"

      auto_assert(
        [
          username: "janedoe",
          password: "",
          hostname: "localhost",
          database: "mydb",
          port: 3399,
          type: :mysql
        ] <- Util.url_to_params(url)
      )
    end
  end
end
