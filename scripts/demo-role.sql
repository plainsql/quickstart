-- Read-only login for the public demo database. PlainSQL only reads the
-- catalog and prepares statements, so SELECT is enough to generate code for
-- every query in this example, including the writes. Safe to run again.
--
-- psql supplies :demo_role, :demo_password, :demo_connection_limit, and
-- :demo_statement_timeout.

BEGIN;

SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'demo_role', :'demo_password')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'demo_role')
\gexec

SELECT format('ALTER ROLE %I LOGIN PASSWORD %L CONNECTION LIMIT %s', :'demo_role', :'demo_password', :'demo_connection_limit')
\gexec

SELECT format('ALTER ROLE %I SET statement_timeout = %L', :'demo_role', :'demo_statement_timeout')
\gexec

SELECT format('ALTER ROLE %I SET default_transaction_read_only = on', :'demo_role')
\gexec

SELECT format('GRANT CONNECT ON DATABASE %I TO %I', current_database(), :'demo_role')
\gexec

SELECT format('GRANT USAGE ON SCHEMA public TO %I', :'demo_role')
\gexec

SELECT format('GRANT SELECT ON ALL TABLES IN SCHEMA public TO %I', :'demo_role')
\gexec

SELECT format('ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO %I', :'demo_role')
\gexec

COMMIT;
