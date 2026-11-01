\getenv exporter_password POSTGRES_EXPORTER_PASSWORD

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'postgres_exporter') THEN
        CREATE ROLE postgres_exporter LOGIN;
    END IF;
END
$$;

ALTER ROLE postgres_exporter WITH LOGIN PASSWORD :'exporter_password';
GRANT pg_monitor TO postgres_exporter;
