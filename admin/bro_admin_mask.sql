create or replace package mask_person is
   function mask_item (
      item varchar2
   ) return varchar2;
   function mask_item (
      item number
   ) return number;
   function mask_person_id (
      item number
   ) return number;
   function mask_person_fk (
      item number
   ) return number;
   procedure empty_person_ids;
end;
/
create or replace package body mask_person is
   type id_rec is record (
         old_value int,
         new_value int
   );
   type new_key_rec is record (
         new_val int,
         new_max int,
         new_min int
   );
   type ids_tbl is
      table of id_rec index by pls_integer;
   person_ids ids_tbl;
   function find_person_by_value (
      val         int,
      raise_empty boolean := false,
      use_old_val boolean := true
   ) return int is
   begin
    dbms_output.put_line(person_ids.count);
      for i in 1..person_ids.count loop
         if use_old_val then
            if person_ids(i).old_value = val then
               return person_ids(i).new_value;
            end if;
         else
            if person_ids(i).new_value = val then
               return person_ids(i).old_value;
            end if;
         end if;
      end loop;
      if raise_empty then
         raise_application_error(
            -20020,
            'Id-ul '
            || val
            || ' nu este prezent in baza originala'
         );
      else
         return null;
      end if;
   end;

   function generate_new_key (
      val            int,
      max_len_factor int := 1
   ) return new_key_rec is
      len         int := length(to_char(val));
      new_max_len int := len * max_len_factor;
      new_key     new_key_rec;
   begin
      if new_max_len > 38 then
         new_max_len := 38; -- mx nr id
      end if;
      new_key.new_min := to_number ( rpad(
         substr(
            to_char(val),
            1,
            1
         ),
         len,
         '0'
      ) );
      new_key.new_max := to_number ( rpad(
         substr(
            to_char(val),
            1,
            1
         ),
         new_max_len,
         '9'
      ) ); -- to not have colission as often
      dbms_random.seed(val => val);
      new_key.new_val := round(
         dbms_random.value(
            low  => new_key.new_min,
            high => new_key.new_max
         ),
         0
      );
      return new_key;
   end;

   function append_to_person_list (
      val int
   ) return int is
      rec      int := find_person_by_value(val);
      pers_cnt int := person_ids.count + 1;
      new_key  int;
   begin
      if rec is not null then
         return rec;
      end if;
      new_key := generate_new_key(
         val,
         5
      ).new_val;
      while ( find_person_by_value(
         val         => new_key,
         use_old_val => false
      ) is not null
      or find_person_by_value(
         val         => new_key,
         use_old_val => true
      ) is not null ) loop
         new_key := generate_new_key(
            val,
            5
         ).new_val; -- no colisions
      end loop;
      person_ids(pers_cnt).old_value := val;
      person_ids(pers_cnt).new_value := new_key;
      return new_key;
   end;
   
   -- ne trebuie tampenie asta crunta pt ca oracle exporta alfabetic
   -- nu stiu dc face asta, dar asa face
   procedure load_person_ids is
   TYPE id_list_type IS TABLE OF persoana.id_persoana%TYPE;
   id_list id_list_type;
   dummy_val int;
   begin
    if person_ids.count = 0 then
       SELECT id_persoana
       BULK COLLECT INTO id_list
       FROM persoana;
       FOR i IN 1 .. id_list.COUNT LOOP
         dummy_val := append_to_person_list(id_list(i));
       END LOOP;

   DBMS_OUTPUT.PUT_LINE('IDs have been initialized in the table type.');
   end if;
   end;
   

    
    --public
   function mask_person_id (
      item number
   ) return number is
   begin
   
        load_person_ids();
--      return append_to_person_list(item);
        return find_person_by_value(
         val         => item,
         raise_empty => true
      );
   end;

   function mask_item (
      item varchar2
   ) return varchar2 is
      masked_item varchar2(30);
      new_length  number;
      random_char char(1);
   begin
   
      if dbms_random.value(
         0,
         1
      ) > 0.5 then
         new_length := length(item) * 2;
      else
         new_length := length(item);
      end if;

      if new_length > 30 then
         new_length := 30; --max string length
      end if;
      masked_item := substr(
         item,
         1,
         1
      );
      for i in 2..new_length loop
         if dbms_random.value(
            0,
            1
         ) > 0.5 then
            random_char :=
               case
                  when dbms_random.value(
                     0,
                     1
                  ) > 0.5 then
                     '*'
                  else '#'
               end;
            masked_item := masked_item || random_char;
         end if;
      end loop;
      return masked_item;
   end;
   function mask_item (
      item number
   ) return number is
   begin
      return generate_new_key(item).new_val;
   end;

   function mask_person_fk (
      item number
   ) return number is
   begin
      if item is null then
         return null;
      end if;
      load_person_ids();
      return find_person_by_value(
         val         => item,
         raise_empty => true
      );
   end;

   procedure empty_person_ids is
   begin
      person_ids.delete;
   end;
   
end;
/



