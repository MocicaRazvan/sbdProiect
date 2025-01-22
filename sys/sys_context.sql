alter session set container = orclpdb;
--creare contextului
create or replace procedure bro_context_proc is
begin
   if regexp_like(
      upper(user),
      '^BRO_ADMIN'
   ) then
      dbms_session.set_context(
         'bro_context',
         'id_filiala',
         -1
      ); -- pentru a lasa adminul in pace
   elsif regexp_like(
      upper(user),
      '^BRO_MANAGER_FILIALA[0-9]+$'
   ) then
      dbms_session.set_context(
         'bro_context',
         'id_filiala',
         regexp_substr(
            user,
            'BRO_MANAGER_FILIALA([0-9]+)',
            1,
            1,
            null,
            1
         )
      );
   end if;
end;
/
drop context bro_context;
create context bro_context using bro_context_proc;

--trigger pt a popula contextul
create or replace trigger manager_id_filiala_trg
   after logon on database begin
      bro_context_proc();
   end;
/


-- fiecare manager face dml pe filiala lui
create or replace function manager_echipament_management_policy (
   schema_name in varchar2,
   table_name  in varchar2
) return varchar2 is
   v_id_filiala int := sys_context(
      'bro_context',
      'id_filiala'
   );
begin
   if v_id_filiala = -1 then
      return ''; -- pentru a lasa adminul in pace
   else
      return 'id_filiala = ' || v_id_filiala;
   end if;
end;
/
begin
   dbms_rls.add_policy(
      object_schema   => 'BRO_ADMIN',
      object_name     => 'ECHIPAMENT',
      policy_name     => 'MANAGER_ECHIPAMENT_POLICY',
      function_schema => 'SYS',
      policy_function => 'manager_echipament_management_policy',
      statement_types => 'INSERT, UPDATE, DELETE',
      update_check    => true,
      enable          => true
   );
end;
/


-- begin
--    dbms_rls.drop_policy(
--       object_schema => 'BRO_ADMIN',
--       object_name   => 'ECHIPAMENT',
--       policy_name   => 'MANAGER_ECHIPAMENT_POLICY'
--    );
-- end;
-- /

-- fiecare manager vede istoric cu leagatura la filiala lui
create or replace function audit_echipament_policy (
   schema_name in varchar2,
   table_name  in varchar2
) return varchar2 as
   v_id_filiala int := sys_context(
      'bro_context',
      'id_filiala'
   );
begin
   if upper(user) = upper(schema_name) then
      return ''; -- pentru a lasa adminul in pace
   else
      return '
        (TREAT(old_values AS bro_admin.t_echipament).id_filiala = '
             || v_id_filiala
             || ' OR TREAT(new_values AS bro_admin.t_echipament).id_filiala = '
             || v_id_filiala
             || ')';
   end if;
end audit_echipament_policy;
/

begin
   dbms_rls.add_policy(
      object_schema   => 'bro_admin',
      object_name     => 'audit_echipament',
      policy_name     => 'AUDIT_MANAGER_ECHIPAMENT_POLICY',
      function_schema => 'SYS',
      policy_function => 'audit_echipament_policy',
      statement_types => 'SELECT',
      update_check    => true,
      enable          => true
   );
end;
/

-- begin
--    dbms_rls.drop_policy(
--       object_schema => 'BRO_ADMIN',
--       object_name   => 'audit_echipament',
--       policy_name   => 'AUDIT_MANAGER_ECHIPAMENT_POLICY'
--    );
-- end;
-- /


SELECT *
FROM dba_policies
where object_owner like upper('bro%');
