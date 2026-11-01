\getenv exporter_password POSTGRES_EXPORTER_PASSWORD
\getenv database_name POSTGRES_DB

SELECT format(
    'CREATE ROLE postgres_exporter LOGIN PASSWORD %L',
    :'exporter_password'
)
WHERE NOT EXISTS (
    SELECT 1
    FROM pg_roles
    WHERE rolname = 'postgres_exporter'
)
\gexec

ALTER ROLE postgres_exporter
WITH LOGIN PASSWORD :'exporter_password';

GRANT CONNECT ON DATABASE :"database_name"
TO postgres_exporter;

GRANT pg_monitor TO postgres_exporter;
