defmodule MaxoSql.Result do
  @moduledoc """
  Common result struct
  """
  @type t :: %__MODULE__{}
  defstruct columns: nil,
            type: nil,
            rows: nil,
            num_rows: 0,
            connection_id: nil,
            # psql
            command: nil,
            messages: [],
            ## mysql
            last_insert_id: nil,
            num_warnings: 0
end
