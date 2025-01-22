---SYS
alter session set container = orclpdb;
-- Dupa ce bro_admin a create tabele si a si inserat datele
-- Dupa ce bro_admin  a creat tabele si a si inserat datele pt bro_antrenor1..n
create role r_bro_public_general;
grant
   create session
to r_bro_public_general;
grant select on bro_admin.antrenor_extins to r_bro_public_general;
grant select on bro_admin.filiala to r_bro_public_general;
grant select on bro_admin.adresa to r_bro_public_general;
grant select on bro_admin.supliment to r_bro_public_general;

grant select on bro_admin.echipament to r_bro_public_general;
grant select on bro_antrenor1.program to r_bro_public_general;
grant select on bro_antrenor2.program to r_bro_public_general;
grant select on bro_antrenor3.program to r_bro_public_general;
grant r_bro_public_general to bro_public_general1;


-- roluri
-- antrenor
create role r_bro_antrenor;
grant r_bro_public_general to r_bro_antrenor;
grant select on bro_admin.client_extins to r_bro_antrenor;
grant select on bro_admin.telefon to r_bro_antrenor;
grant select on bro_admin.antrenor to r_bro_antrenor;
grant select on bro_admin.chei_client to r_bro_antrenor;
grant execute on bro_admin.select_random_from_nr_list to r_bro_antrenor;
grant
   create table,
   create view,
   create sequence,
   create procedure,
   create type
to r_bro_antrenor;
grant execute on dbms_crypto to r_bro_antrenor;



grant r_bro_antrenor to bro_antrenor1;
grant r_bro_antrenor to bro_antrenor2;
grant r_bro_antrenor to bro_antrenor3;



-- client
create role r_bro_client;
grant r_bro_public_general to r_bro_client;
grant select on bro_admin.client_extins to r_bro_client;
grant execute on bro_admin.get_client_key to r_bro_client;

-- fiecare antrenor da la clientii sai
grant execute on bro_antrenor1.fetch_decrypted_client_data to bro_client1;
grant execute on bro_antrenor1.hash_checksum to bro_client1;
grant execute on bro_antrenor1.fetch_decrypted_client_data to bro_client2;
grant execute on bro_antrenor1.hash_checksum to bro_client2;
grant execute on bro_antrenor1.fetch_decrypted_client_data to bro_client3;
grant execute on bro_antrenor1.hash_checksum to bro_client3;
--programul e public


grant r_bro_client to bro_client1;
grant r_bro_client to bro_client2;
grant r_bro_client to bro_client3;

--receptionist
create role r_bro_receptionist;
grant r_bro_public_general to r_bro_receptionist;
grant select,insert,update on bro_admin.client_extins to r_bro_receptionist;
grant select,insert,update on bro_admin.telefon to r_bro_receptionist;
grant select,insert,update on bro_admin.abonament to r_bro_receptionist;
grant select on bro_admin.tip_abonament to r_bro_receptionist;
grant select on bro_admin.furnizor to r_bro_receptionist;
grant insert on bro_admin.comanda to r_bro_receptionist;
grant insert on bro_admin.informatii_comanda to r_bro_receptionist;
grant select on bro_admin.aprovizionare to r_bro_receptionist;
--programul e public
grant r_bro_receptionist to bro_receptionist1;
grant r_bro_receptionist to bro_receptionist2;
grant r_bro_receptionist to bro_receptionist3;

--manager filiala 
create role r_bro_manager_filiala;
grant r_bro_public_general to r_bro_manager_filiala;
grant select on bro_admin.receptionist_extins to r_bro_manager_filiala;
grant select on bro_admin.client_extins to r_bro_manager_filiala;
grant select on bro_admin.furnizor to r_bro_manager_filiala;

grant select on bro_antrenor1.program to r_bro_manager_filiala;
--pt fiecare antrenor in filiala sa
grant select on bro_antrenor1.antrenament to r_bro_manager_filiala;
grant select on bro_antrenor2.antrenament to r_bro_manager_filiala;
grant select on bro_antrenor3.antrenament to r_bro_manager_filiala;

grant select,update,insert,delete on bro_admin.echipament to r_bro_manager_filiala;

grant select on bro_admin.aprovizionare to r_bro_manager_filiala;
-- grant select on bro_admin.audit_echipament to r_bro_manager_filiala;
grant r_bro_manager_filiala to bro_manager_filiala1;