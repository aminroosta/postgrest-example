-- clean up existing db objects
set client_min_messages to warning;
drop schema if exists api cascade;
drop schema if exists basic_auth cascade;
drop schema if exists pgjwt cascade;
drop role if exists todo_user;
drop role if exists web_anon;
drop role if exists authenticator;

-- create pgcrypto extension
create extension if not exists pgcrypto;

-- web_anon & authenticator roles
create role authenticator noinherit login
password 'apple-desk-pen-13';

create role web_anon nologin;
grant web_anon to authenticator;

-- api schema
create schema api;
grant usage on schema api to web_anon;

-- imports
\i sql/api.todos.sql
\i sql/pgjwt.sql
-- \i sql/basic_auth.sql
