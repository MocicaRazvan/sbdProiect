-- dupa ce admin a create tabelel pt antrenori
alter session set container = orclpdb;
create or replace procedure bro_admin_programs_privilegies is
   v_user  global_user_table := get_users_by_suffix('ANTRENOR');
   v_first boolean := true;
begin
   for i in 1..v_user.count loop
      dbms_output.put_line(v_user(i));
      begin
         execute immediate 'SELECT 1 FROM '
                           || v_user(i)
                           || '.program WHERE ROWNUM = 1';
         execute immediate 'grant select on '
                           || v_user(i)
                           || '.program to bro_admin with grant option';
         dbms_output.put_line('Giving select privileges on '
                              || v_user(i)
                              || '.program to bro_admin.');
         if v_first then
            v_first := false;
         end if;
      exception
         when others then
            dbms_output.put_line('Skipping '
                                 || v_user(i)
                                 || '.program as it does not exist.');
      end;
   end loop;

   if not v_first then
      dbms_output.put_line('Giving select privileges on program tables to bro_admin.');
   else
      dbms_output.put_line('No valid program tables found');
   end if;
end bro_admin_programs_privilegies;
/
   set SERVEROUTPUT ON;

exec bro_admin_programs_privilegies;