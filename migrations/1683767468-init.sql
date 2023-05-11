-- Migration: init
-- Created at: 2023-05-11 01:11:08
-- ====  UP  ====
BEGIN;

create schema api;

create table api.todos (
  id serial primary key,
  done boolean not null default false,
  task text not null,
  due timestamptz
);

insert into api.todos (task)
values
  ('finish tutorial 0'),
  ('pat self on back');

create role web_anon nologin;
grant usage on schema api to web_anon;
grant select on api.todos to web_anon;

create role authenticator noinherit login password 'apple-desk-pen-13';
grant web_anon to authenticator;

COMMIT;

-- ==== DOWN ====
BEGIN;

revoke web_anon from authenticator;
drop role authenticator;

revoke select on api.todos from web_anon;
revoke usage on schema api from web_anon;
drop role web_anon;

drop table api.todos;

drop schema api;

COMMIT;
