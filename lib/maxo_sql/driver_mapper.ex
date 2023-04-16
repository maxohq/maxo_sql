defmodule MaxoSql.DriverMapper do
  alias MaxoSql.Driver.Psql
  alias MaxoSql.Driver.Mysql
  alias MaxoSql.Driver.Sqlite

  def get_driver(:psql), do: Psql
  def get_driver(:mysql), do: Mysql
  def get_driver(:sqlite), do: Sqlite
  def get_driver(type), do: raise("NOT SUPPORTED DRIVER #{type}!")

  @db_types %{
    "postgresql" => :psql,
    "mysql" => :mysql,
    "file" => :sqlite
  }
  def get_type_for_scheme(url_scheme) do
    Map.get(@db_types, url_scheme)
  end
end
