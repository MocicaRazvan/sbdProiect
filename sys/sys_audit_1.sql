
alter session set container = orclpdb;

SHOW parameter audit_trail;

audit insert,update on bro_admin.client_extins by access whenever not successful;
audit insert,update,delete on bro_admin.echipament;
audit insert,update,delete on bro_admin.account_mapping;
audit insert,update on bro_admin.supliment;

create or replace directory json_dir as 'D:\ORACLEEE\INSTALL\ADMIN\ORCL\MYDUMP';

-- Multumiri deosebite primului raspuns de aici si nu documentatiei oracle care este oribila
-- https://stackoverflow.com/questions/50417586/write-a-clob-to-file-in-oracle  
create or replace procedure convert_clob_2_file (
   p_filename in varchar2,
   p_dir      in varchar2,
   p_clob     in clob
) as
   v_lob_image_id number;
   v_clob         clob := p_clob;
   v_buffer       raw(32767);
   c_buffer       varchar2(32767);
   v_buffer_size  binary_integer;
   v_amount       binary_integer;
   v_pos          number(38) := 1;
   v_clob_size    integer;
   v_out_file     utl_file.file_type;
begin
   v_pos := 1;
   v_clob_size := dbms_lob.getlength(v_clob);
   v_buffer_size := 32767;
   v_amount := v_buffer_size;
   if ( dbms_lob.isopen(v_clob) = 0 ) then
      dbms_lob.open(
         v_clob,
         dbms_lob.lob_readonly
      );
   end if;
   v_out_file := utl_file.fopen(
      p_dir,
      p_filename,
      'WB',
      max_linesize => 32767
   );
   while v_amount >= v_buffer_size loop
      dbms_lob.read(
         v_clob,
         v_amount,
         v_pos,
         c_buffer
      );
      v_buffer := utl_raw.cast_to_raw(c_buffer);
      v_pos := v_pos + v_amount;
      utl_file.put_raw(
         v_out_file,
         v_buffer,
         true
      );
      utl_file.fflush(v_out_file);
   end loop;
   utl_file.fflush(v_out_file);
   utl_file.fclose(v_out_file);
   if ( dbms_lob.isopen(v_clob) = 1 ) then
      dbms_lob.close(v_clob);
   end if;
exception
   when others then
      if ( dbms_lob.isopen(v_clob) = 1 ) then
         dbms_lob.close(v_clob);
      end if;
      raise;
end;
/

create or replace procedure save_audit_to_json (
   p_obj_name varchar2
) is
   obj_name   varchar2(128) := dbms_assert.simple_sql_name(p_obj_name);
   a_file     utl_file.file_type;
   a_json     clob;
   a_filename varchar2(1000);
begin
   for owner_rec in (
      select distinct obj$creator
        from sys.aud$
       where obj$name = upper(obj_name)
   ) loop
      a_filename := 'audit_json_bro_'
                    || owner_rec.obj$creator
                    || '_'
                    || obj_name
                    || '_'
                    || to_char(
         sysdate,
         'YYYYMMDD_HH24MISS'
      )
                    || '.json';




      select to_clob(json_arrayagg(
         json_object(
            key 'sessionId' value sessionid,
                     key 'userId' value userid,
                     key 'entryId' value entryid,
                     key 'userhost' value userhost,
                     key 'returncode' value returncode,
                     key 'timestamp' value to_char(
               ntimestamp#,
               'yyyy-mm-dd hh24:mi:ss'
            ),
                     key 'sqltext' value sqltext,
                     key 'objectName' value obj_name,
                     key 'objectOwner' value owner_rec.obj$creator
         returning clob)
      returning clob))
        into a_json
        from sys.aud$
       where obj$name = upper(obj_name)
         and obj$creator = upper(owner_rec.obj$creator);

      convert_clob_2_file(
         p_clob     => a_json,
         p_dir      => 'JSON_DIR',
         p_filename => a_filename
      );
      execute immediate 'delete from SYS.AUD$ where obj$name = upper(:1) and obj$creator = upper(:2)'
         using obj_name,
         owner_rec.obj$creator;
   end loop;
   commit;
exception
   when others then
      dbms_output.put_line('Error occurred: ' || sqlerrm);
      raise;
end;
/

exec save_audit_to_json('client_extins');
exec save_audit_to_json('echipament');
exec save_audit_to_json('account_mapping');

 -- create audit jobs
declare
   job_names odcivarchar2list := odcivarchar2list(
      'client_extins',
      'echipament',
      'account_mapping',
      'supliment'
   );
begin
   for i in 1..job_names.count loop
      dbms_scheduler.create_job(
         job_name        => 'SAVE_AUDIT_TO_JSON_JOB_' || upper(job_names(i)),
         job_type        => 'PLSQL_BLOCK',
         job_action      => 'BEGIN save_audit_to_json('''
                       || upper(job_names(i))
                       || '''); END;',
         start_date      => systimestamp,
         repeat_interval => 'FREQ=DAILY; BYHOUR=17; BYMINUTE=22; BYSECOND=0',
         enabled         => true
      );
   end loop;
end;
/

-- drop audit jobs
-- declare
--    job_names odcivarchar2list;
-- begin
--    select job_name
--    bulk collect
--      into job_names
--      from user_scheduler_jobs
--     where job_name like 'SAVE_AUDIT_TO_JSON_JOB_%';
--    for i in 1..job_names.count loop
--       dbms_scheduler.drop_job(job_name => upper(job_names(i)));
--    end loop;

-- end;
-- /

-- noaudit all on bro_admin.client_extins;
-- noaudit all on bro_admin.echipament;
-- noaudit all on bro_admin.account_mapping;
-- noaudit all on bro_admin.supliment;

select * from dba_audit_trail 
where username like upper('bro%');

SELECT * FROM dba_scheduler_jobs
WHERE job_name LIKE upper('save_audit_to_json_job_%')
ORDER BY job_name;

