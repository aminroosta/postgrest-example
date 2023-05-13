--
-- pgquarrel 0.7.0
-- quarrel between 15.3 (Debian 15.3-1.pgdg110+1) and 15.3 (Debian 15.3-1.pgdg110+1)
--

CREATE SCHEMA pgjwt;

ALTER SCHEMA pgjwt OWNER TO app_user;

CREATE FUNCTION pgjwt.url_decode(data text) RETURNS bytea
    LANGUAGE sql IMMUTABLE
AS $$
WITH t AS (SELECT translate(data, '-_', '+/') AS trans),
     rem AS (SELECT length(t.trans) % 4 AS remainder FROM t) -- compute padding size
    SELECT decode(
        t.trans ||
        CASE WHEN rem.remainder > 0
           THEN repeat('=', (4 - rem.remainder))
           ELSE '' END,
    'base64') FROM t, rem;
$$;

ALTER FUNCTION pgjwt.url_decode(data text) OWNER TO app_user;

CREATE FUNCTION pgjwt.url_encode(data bytea) RETURNS text
    LANGUAGE sql IMMUTABLE
AS $$
    SELECT translate(encode(data, 'base64'), E'+/=\n', '-_');
$$;

ALTER FUNCTION pgjwt.url_encode(data bytea) OWNER TO app_user;

CREATE FUNCTION pgjwt.algorithm_sign(signables text, secret text, algorithm text) RETURNS text
    LANGUAGE sql IMMUTABLE
AS $$
WITH
  alg AS (
    SELECT CASE
      WHEN algorithm = 'HS256' THEN 'sha256'
      WHEN algorithm = 'HS384' THEN 'sha384'
      WHEN algorithm = 'HS512' THEN 'sha512'
      ELSE '' END AS id)  -- hmac throws error
SELECT pgjwt.url_encode(hmac(signables, secret, alg.id)::bytea) FROM alg;
$$;

ALTER FUNCTION pgjwt.algorithm_sign(signables text, secret text, algorithm text) OWNER TO app_user;

CREATE FUNCTION pgjwt.sign(payload json, secret text, algorithm text DEFAULT 'HS256'::text) RETURNS text
    LANGUAGE sql IMMUTABLE
AS $$
WITH
  header AS (
    SELECT pgjwt.url_encode(convert_to('{"alg":"' || algorithm || '","typ":"JWT"}', 'utf8')) AS data
    ),
  payload AS (
    SELECT pgjwt.url_encode(convert_to(payload::text, 'utf8')) AS data
    ),
  signables AS (
    SELECT header.data || '.' || payload.data AS data FROM header, payload
    )
SELECT
    signables.data || '.' ||
    pgjwt.algorithm_sign(signables.data, secret, algorithm) FROM signables;
$$;

ALTER FUNCTION pgjwt.sign(payload json, secret text, algorithm text) OWNER TO app_user;

CREATE FUNCTION pgjwt.verify(token text, secret text, algorithm text DEFAULT 'HS256'::text) RETURNS TABLE(header json, payload json, valid boolean)
    LANGUAGE sql IMMUTABLE ROWS 1000
AS $$
  SELECT
    convert_from(pgjwt.url_decode(r[1]), 'utf8')::json AS header,
    convert_from(pgjwt.url_decode(r[2]), 'utf8')::json AS payload,
    r[3] = pgjwt.algorithm_sign(r[1] || '.' || r[2], secret, algorithm) AS valid
  FROM regexp_split_to_array(token, '\.') r;
$$;

ALTER FUNCTION pgjwt.verify(token text, secret text, algorithm text) OWNER TO app_user;
