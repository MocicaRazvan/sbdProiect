@echo off


expdp bro_admin/bro_admin@//localhost:1522/orclpdb ^
tables=BRO_ADMIN.PERSOANA, BRO_ADMIN.ANGAJAT, BRO_ADMIN.ANTRENOR, BRO_ADMIN.RECEPTIONIST, BRO_ADMIN.CLIENT ^
remap_data=persoana.id_persoana:mask_person.mask_person_id ^
remap_data=persoana.nume:mask_person.mask_item ^
remap_data=persoana.prenume:mask_person.mask_item ^
remap_data=persoana.email:mask_person.mask_item ^
remap_data=persoana.varsta:mask_person.mask_item ^
remap_data=angajat.id_angajat:mask_person.mask_person_fk ^
remap_data=angajat.salariu:mask_person.mask_item ^
remap_data=angajat.id_meneger:mask_person.mask_person_fk ^
remap_data=antrenor.id_antrenor:mask_person.mask_person_fk ^
remap_data=receptionist.id_receptionist:mask_person.mask_person_fk ^
remap_data=client.id_client:mask_person.mask_person_fk ^
directory=MASK_DUMP parallel=8 dumpfile=mask_person.dmp logfile=mask_person.log reuse_dumpfiles=y

echo Done exporting mask persoana
exit /b 0
