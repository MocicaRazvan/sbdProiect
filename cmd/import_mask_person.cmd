@echo off

impdp bro_import/bro_import@//localhost:1522/orclpdb ^
remap_table=persoana:persoana_mask ^
remap_table=angajat:angajat_mask ^
remap_table=antrenor:antrenor_mask ^
remap_table=receptionist:receptionist_mask ^
remap_table=client:client_mask ^
remap_schema=bro_admin:bro_import ^
directory=MASK_DUMP ^
dumpfile=mask_person.dmp ^
logfile=mask_person_import.log ^
parallel=8 ^
transform=disable_archive_logging:y


echo Done importing mask persoana
exit /b 0