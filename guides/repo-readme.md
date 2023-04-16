```elixir
defmodule MyRepo do
  use MaxoSql.Repo
end

MyRepo.run(query)
MyRepo.stop()
MyRepo.stop()

MyRepo.start_link(1)
psql_url = "postgresql://postgres:postgres@127.0.0.1:5551/maxo_sql"
MyRepo.connect(psql_url)
MyRepo.query!("select 1 + 1")




mysql_url = "mysql://root:mysql@127.0.0.1:5552/maxo_sql"
MyRepo.start_link(mysql_url)

# MyRepo.connect(mysql_url)
MyRepo.query!("select 1 + 1")

MyRepo.query!("drop table if exists comments")
MyRepo.query!("create table comments(id integer, name varchar(1000))")
MyRepo.query!("insert into comments(id, name) values (1, 'joe'), (2, 'mike')")
MyRepo.query!("insert into comments(id, name) values (1, 'joe'), (2, 'mike')")
MyRepo.query!("select * from comments")
import MaxoSql.Query
q = from(:comments) |> select(["id", "name"]) |> where(["id = ? or id = ?", 1, 2])

q = from(:comments) |> select("count(id)")
MyRepo.run(q)

from("comments") |> select("count(id)") |> MyRepo.run()

sqlite_url = "file:./check.db?mode=memory&cache=shared"
MyRepo.start_link(sqlite_url)
MyRepo.query!("select 1 + 1")
MyRepo.query!("create table comments(id, name)")
MyRepo.query!("insert into comments(id, name) values (1, 'joe'), (2, 'mike')")
MyRepo.query!("select * from comments")

MyRepo.query!("select * from comments where id = 1 or id = 2")

import MaxoSql.Query
q = from(:comments) |> select(["id", "name"]) |> where(["id = ? or id = ?", 1, 2])

MyRepo.run(q)

from("comments") |> select("count(id)") |> MyRepo.run()
MyRepo.stop()


MyRepo.dynamic_repo()
```
