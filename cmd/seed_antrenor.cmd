@echo off


:: vars
set "SQL_SCRIPT_PATH=C:\Master\An2\sem1\securitateaBD\proiect\sql\bro_admin_antrenor_seed.sql"

:: conn bro_admin
sqlplus bro_admin/bro_admin@//localhost:1522/orclpdb @%SQL_SCRIPT_PATH%  
@REM sqlplus sys/1234@//localhost:1522/orclpdb as sysdba @%SQL_SCRIPT_PATH%


echo Done seeding antrenor table
exit /b 0
