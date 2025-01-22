set serveroutput on;
declare
   users sys.global_user_table;
begin
   users := sys.get_users_by_suffix('ANTRENOR');
   for i in 1..users.count loop
      dbms_output.put_line(users(i));
   end loop;
end;
/
create or replace procedure bro_admin_programs_view is
   v_user  sys.global_user_table := sys.get_users_by_suffix('ANTRENOR');
   v_sql   clob := 'CREATE OR REPLACE VIEW programs_view AS ';
   v_first boolean := true;
begin
   for i in 1..v_user.count loop
      begin
         -- check existance of program table for antrenor
         execute immediate 'SELECT 1 FROM '
                           || v_user(i)
                           || '.program WHERE ROWNUM = 1';
         if v_first then
            v_sql := v_sql
                     || 'SELECT '''
                     || v_user(i)
                     || ''' AS antrenor, id_program, descriere, tip_program FROM '
                     || v_user(i)
                     || '.program';
            v_first := false;
         else
            v_sql := v_sql
                     || ' UNION ALL SELECT '''
                     || v_user(i)
                     || ''' AS antrenor, id_program, descriere, tip_program FROM '
                     || v_user(i)
                     || '.program';
         end if;

      exception
         when others then
            -- skip if table its not in antrenor
            dbms_output.put_line('Skipping '
                                 || v_user(i)
                                 || '.program as it does not exist.');
      end;
   end loop;
   dbms_output.put_line(v_sql);
   if not v_first then
      execute immediate v_sql;
      dbms_output.put_line('View programs_view created successfully.');
   else
      dbms_output.put_line('No valid program tables found. View not created.');
   end if;
end bro_admin_programs_view;
/
exec bro_admin_programs_view;

select *
  from programs_view;
  

  

-- poate da grant la role, desi nu vede rolurile
--SELECT role FROM dba_roles WHERE role = 'R_BRO_PUBLIC_GENERAL';

grant select on bro_admin.programs_view to r_bro_public_general;
