select bro_admin.get_client_key
  from dual;
  
select ( bro_admin.get_client_key() ).id_client as id_client,
       ( bro_admin.get_client_key() ).mod_op as mod_op,
       ( bro_admin.get_client_key() ).cheie as cheie
  from dual;

with user_key as (
   select bro_admin.get_client_key() as client_key
     from dual
)
select ( user_key.client_key ).id_client as id_client,
       ( user_key.client_key ).mod_op as mod_op,
       ( user_key.client_key ).cheie as cheie
  from user_key;


with user_key as (
   select bro_admin.get_client_key() as client_key
     from dual
)



SELECT ant.*,cs.*,
    case when ant.checksum = cs.cur_cs then 'ok' else 'not ok' end as cs_v
FROM 
    (SELECT bro_admin.get_client_key() AS client_key
    FROM dual)
 user_key,
LATERAL (SELECT *FROM TABLE(
        bro_antrenor1.fetch_decrypted_client_data(
            p_mod_op=>user_key.client_key.mod_op,
            p_cheie=>user_key.client_key.cheie,
            p_id_client=>user_key.client_key.id_client))) ant,
lateral (
select bro_antrenor1.hash_checksum(SYS.ODCIVARCHAR2LIST(ant.id_program,ant.descriere_program,ant.tip_program,
                        ant.durata_antrenament,ant.id_echipament,ant.nume_echipament,
                        ant.data_instalare_echipament,ant.data_revizie_echipament,ant.id_filiala,
                        user_key.client_key.cheie)) as cur_cs from dual
) cs;

select * from bro_admin.programs_view;
