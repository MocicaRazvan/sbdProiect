with c as (
   select mod_op,
          cheie
     from bro_admin.chei_client
    where id_client = 18
)
select decript_string(
   ca.id_program,
   c.mod_op,
   c.cheie
) as id_program,
       decript_string(
          ca.descriere_program,
          c.mod_op,
          c.cheie
       ) as descriere_program,
       decript_string(
          ca.tip_program,
          c.mod_op,
          c.cheie
       ) as tip_program,
       decript_string(
          ca.durata_antrenament,
          c.mod_op,
          c.cheie
       ) as durata_antrenament,
       decript_string(
          ca.id_echipament,
          c.mod_op,
          c.cheie
       ) as id_echipament,
       decript_string(
          ca.nume_echipament,
          c.mod_op,
          c.cheie
       ) as nume_echipament,
       decript_string(
          ca.data_instalare_echipament,
          c.mod_op,
          c.cheie
       ) as data_instalare_echipament,
       decript_string(
          ca.data_revizie_echipament,
          c.mod_op,
          c.cheie
       ) as data_revizie_echipament,
       decript_string(
          ca.id_filiala,
          c.mod_op,
          c.cheie
       ) as id_filiala,
       decript_string(
          ca.id_client,
          c.mod_op,
          c.cheie
       ) as id_client,
       checksum
  from client_antrenament ca,
       c;


select *
  from table ( fetch_decrypted_client_data(
   (
      select mod_op
        from bro_admin.chei_client
       where id_client = 18
   ),
   (
      select cheie
        from bro_admin.chei_client
       where id_client = 18
   ),
   18
) );