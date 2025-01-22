--- Cripatre in schema lui bro_admin
create or replace function select_random_from_nr_list (
   input_list sys.odcinumberlist
) return number is
   selected_value number;
begin
   select input_list(trunc(dbms_random.value(
      1,
      input_list.count + 1
   )))
     into selected_value
     from dual;

   return selected_value;
end;
/



create table chei_client (
   id_client number
      constraint fk_client_chei
         references client ( id_client )
   primary key,
   mod_op    int not null,
   cheie     raw(16) not null
);

create or replace procedure insert_into_chei_client (
   p_client number
) is
   mod_op_value number;
   v_nr         smallint;
   v_cheie      raw(16) := dbms_crypto.randombytes(16);
begin
   select count(*)
     into v_nr
     from chei_client c
    where c.id_client = p_client;
   if v_nr > 0 then
      raise_application_error(
         -20022,
         'The client is already in the table keys. Client ' || p_client
      );
   end if;
   mod_op_value := dbms_crypto.encrypt_aes128 + bro_admin.select_random_from_nr_list(sys.odcinumberlist(
      dbms_crypto.pad_pkcs5,
      dbms_crypto.pad_zero
   )) + bro_admin.select_random_from_nr_list(sys.odcinumberlist(
      dbms_crypto.chain_cbc,
      dbms_crypto.chain_cfb,
      dbms_crypto.chain_ecb,
      dbms_crypto.chain_ofb
   ));

   insert into chei_client (
      id_client,
      mod_op,
      cheie
   ) values ( p_client,
              mod_op_value,
              v_cheie );
end;
/

exec insert_into_chei_client(18);
exec insert_into_chei_client(18);
exec insert_into_chei_client(19);
exec insert_into_chei_client(20);
exec insert_into_chei_client(21);
exec insert_into_chei_client(22);
exec insert_into_chei_client(25);
exec insert_into_chei_client(26);
exec insert_into_chei_client(27);

select *
  from chei_client;
commit;

create or replace type chei_client_object as object (
      id_client number,
      mod_op    int,
      cheie     raw(16)
);
/

create or replace function get_client_key return chei_client_object is
   res chei_client_object;
begin
   select chei_client_object(
      c.id_client,
      c.mod_op,
      c.cheie
   )
     into res
     from account_mapping a
     join chei_client c
   on a.id_persoana = c.id_client
    where username = sys_context(
      'userenv',
      'session_user'
   );

   return res;
exception
   when no_data_found then
      raise_application_error(
         -20023,
         'Client with username '
         || sys_context(
            'userenv',
            'session_user'
         )
         || ' does not have a cript key'
      );
end;
/