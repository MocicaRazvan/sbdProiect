create or replace directory mask_dump as 'D:\OracleEE\install\admin\orcl\maskdump';
grant read,write on directory mask_dump to bro_admin;
 --pt import ca sa nu avem coliziuni la import
create user bro_import identified by bro_import;
grant
   create session
to bro_import;
grant
   create table,
   create sequence
to bro_import;
alter user bro_import
   quota 20M on users;
grant datapump_imp_full_database to bro_import;