-- Migration: todo_user
-- Created at: 2023-05-12 15:11:35
-- ====  UP  ====

BEGIN;

create role todo_user nologin;
grant todo_user to authenticator;

grant usage on schema api to todo_user;
grant all on api.todos to todo_user;
grant usage, select on sequence api.todos_id_seq to todo_user;

COMMIT;

-- ==== DOWN ====

BEGIN;

drop role todo_user;

COMMIT;
