BEGIN;

-- App user (used by FastAPI)
CREATE ROLE app_user
WITH LOGIN PASSWORD 'AppUser123!'
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
NOINHERIT;

-- Grant connection
GRANT CONNECT ON DATABASE law_db TO app_user;

-- Schema usage
GRANT USAGE ON SCHEMA public TO app_user;

COMMIT;
