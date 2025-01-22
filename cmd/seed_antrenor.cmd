@echo off

set "SQL_SCRIPT_PATH=C:\Master\An2\sem1\securitateaBD\proiect\sql\bro_admin_antrenor_seed.sql"

sqlplus bro_admin/bro_admin@//localhost:1522/orclpdb @%SQL_SCRIPT_PATH%  

echo Done seeding antrenor table
exit /b 0
