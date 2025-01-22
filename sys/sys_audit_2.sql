alter session set container = orclpdb;

create or replace directory fgadump_dir as 'D:\OracleEE\install\admin\orcl\fgadump';

-- salvare intr-un fisier txt a logurilor
create or replace procedure bro_audit_tablese_handler (
   object_schema varchar2,
   object_name   varchar2,
   policy_name   varchar2
) is
   fga_file    utl_file.file_type;
   log_message varchar2(5000);
begin
   log_message := 'FGA Triggered:'
                  || chr(10)
                  || 'Timestamp: '
                  || to_char(
      sysdate,
      'YYYY-MM-DD HH24:MI:SS'
   )
                  || chr(10)
                  || 'Object Schema: '
                  || object_schema
                  || chr(10)
                  || 'Object Name: '
                  || object_name
                  || chr(10)
                  || 'Policy Name: '
                  || policy_name
                  || chr(10);
   fga_file := utl_file.fopen(
      'FGADUMP_DIR',
      policy_name || '.txt',
      'a'
   );
   utl_file.put_line(
      fga_file,
      log_message
   );
   utl_file.fflush(fga_file);
   utl_file.fclose(fga_file);
exception
   when others then
      if utl_file.is_open(fga_file) then
         utl_file.fclose(fga_file);
      end if;
      raise;
end;
/

create or replace procedure echipament_revizie_audit is
begin
   dbms_fga.add_policy(
      object_schema   => 'BRO_ADMIN',
      object_name     => 'ECHIPAMENT',
      policy_name     => 'AUDIT_DATA_REVIZIE',
      audit_condition => 'data_revizie IS NOT NULL',
      audit_column    => 'data_revizie',
      handler_schema  => 'SYS',
      handler_module  => 'bro_audit_tablese_handler',
      enable          => true,
      statement_types => 'insert,update'
   );
end;
/

exec echipament_revizie_audit();


select *
  from dba_fga_audit_trail
 where policy_name = 'AUDIT_DATA_REVIZIE';


begin
   dbms_fga.enable_policy(
      object_schema => 'BRO_ADMIN',
      object_name   => 'ECHIPAMENT',
      policy_name   => 'AUDIT_DATA_REVIZIE'
   );
end;
/


-- begin
--    dbms_fga.disable_policy(
--       object_schema => 'BRO_ADMIN',
--       object_name   => 'ECHIPAMENT',
--       policy_name   => 'AUDIT_DATA_REVIZIE'
--    );
-- end;
-- /

-- begin
--    dbms_fga.drop_policy(
--       object_schema => 'BRO_ADMIN',
--       object_name   => 'ECHIPAMENT',
--       policy_name   => 'AUDIT_DATA_REVIZIE'
--    );
-- end;
-- /