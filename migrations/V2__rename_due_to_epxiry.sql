ALTER TABLE ONLY api.todos ADD COLUMN due timestamp with time zone;

ALTER TABLE ONLY api.todos DROP COLUMN expiry;
