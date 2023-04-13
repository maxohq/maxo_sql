defmodule MaxoSql.Result do
  @moduledoc """
  Common result struct
  """
  @type t :: %__MODULE__{}
  defstruct command: nil,
            columns: nil,
            type: nil,
            rows: nil,
            num_rows: 0,
            last_insert_id: nil,
            connection_id: nil,
            messages: []
end
