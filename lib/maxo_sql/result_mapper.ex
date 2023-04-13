defprotocol MaxoSql.ResultMapper do
  @spec map(t) :: MaxoSql.Result.t()
  def map(value)
end

defimpl MaxoSql.ResultMapper, for: Postgrex.Result do
  # %Postgrex.Result{
  #   command: :select,
  #   columns: ["?column?"],
  #   rows: [[1]],
  #   num_rows: 1,
  #   connection_id: 126,
  #   messages: []
  # }
  def map(%Postgrex.Result{} = res) do
    %MaxoSql.Result{
      type: :psql,
      command: res.command,
      columns: res.columns,
      rows: res.rows,
      num_rows: res.num_rows,
      connection_id: res.connection_id,
      messages: res.messages
    }
  end
end

defimpl MaxoSql.ResultMapper, for: MyXQL.Result do
  # %MyXQL.Result{
  #   columns: ["1"],
  #   connection_id: 46,
  #   last_insert_id: nil,
  #   num_rows: 1,
  #   rows: [[1]],
  #   num_warnings: 0
  # }
  def map(%MyXQL.Result{} = res) do
    %MaxoSql.Result{
      type: :mysql,
      columns: res.columns,
      connection_id: res.connection_id,
      last_insert_id: res.last_insert_id,
      num_rows: res.num_rows,
      rows: res.rows,
      num_warnings: res.num_warnings
    }
  end
end

defimpl MaxoSql.ResultMapper, for: Exqlite.Result do
  # %Exqlite.Result{command: :execute, columns: ["1"], rows: [[1]], num_rows: 1}
  def map(%Exqlite.Result{} = res) do
    %MaxoSql.Result{
      type: :sqlite,
      command: res.command,
      columns: res.columns,
      num_rows: res.num_rows,
      rows: res.rows
    }
  end
end
