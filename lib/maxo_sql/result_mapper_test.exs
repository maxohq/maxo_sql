defmodule MaxoSql.ResultMapperTest do
  use ExUnit.Case
  use MnemeDefaults

  alias MaxoSql.ResultMapper

  describe "psql" do
    test "works" do
      res = %Postgrex.Result{
        command: :select,
        columns: ["?column?"],
        rows: [[1]],
        num_rows: 1,
        connection_id: 126,
        messages: []
      }

      auto_assert(
        %MaxoSql.Result{
          columns: ["?column?"],
          command: :select,
          connection_id: 126,
          num_rows: 1,
          rows: [[1]],
          type: :psql
        } <- ResultMapper.map(res)
      )
    end
  end

  describe "mysql" do
    test "works" do
      res = %MyXQL.Result{
        columns: ["1"],
        connection_id: 46,
        last_insert_id: nil,
        num_rows: 1,
        rows: [[1]],
        num_warnings: 0
      }

      auto_assert(
        %MaxoSql.Result{columns: ["1"], connection_id: 46, num_rows: 1, rows: [[1]], type: :mysql} <-
          ResultMapper.map(res)
      )
    end
  end

  describe "sqlite" do
    test "works" do
      res = %Exqlite.Result{command: :execute, columns: ["1"], rows: [[1]], num_rows: 1}

      auto_assert(
        %MaxoSql.Result{
          columns: ["1"],
          command: :execute,
          num_rows: 1,
          rows: [[1]],
          type: :sqlite
        } <- ResultMapper.map(res)
      )
    end
  end
end
