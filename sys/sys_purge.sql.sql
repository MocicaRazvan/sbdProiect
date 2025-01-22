alter session set container = orclpdb;
alter session set "_oracle_script" = true;
begin
   for user_rec in (
      select username
        from dba_users
       where username like 'BRO_%'
   ) loop
      -- Revoke all roles from the user
      for role_rec in (
         select granted_role
           from dba_role_privs
          where grantee = user_rec.username
      ) loop
         execute immediate 'REVOKE '
                           || role_rec.granted_role
                           || ' FROM '
                           || user_rec.username;
      end loop;
      
      -- Drop the user
      execute immediate 'DROP USER '
                        || user_rec.username
                        || ' CASCADE';
   end loop;
end;
/

begin
   for role_rec in (
      select role
        from dba_roles
       where role like 'R_BRO%'
   ) loop
      execute immediate 'DROP ROLE ' || role_rec.role;
   end loop;
end;
/

begin
   dbms_resource_manager.create_pending_area();
   for plan_rec in (
      select plan
        from dba_rsrc_plans
       where plan like 'P_BRO%'
   ) loop
      dbms_resource_manager.delete_plan(plan_rec.plan);
   end loop;
   dbms_resource_manager.submit_pending_area();
end;
/

commit;