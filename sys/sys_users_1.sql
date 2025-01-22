-- Conexiune sys pentru crearea utilizatorilor

ALTER SESSION SET container = "orclpdb";
alter database orclpdb open;

-- Functie ce asigura ca parolele contin cel putin un _
-- Trebuie sa fie standalone pt ca oracle nu vrea din pachet
CREATE OR REPLACE FUNCTION password_verify_function_standalone (
   username     VARCHAR2,
   new_password VARCHAR2,
   old_password VARCHAR2
) RETURN BOOLEAN IS
BEGIN
   IF instr(
      new_password,
      '_'
   ) = 0 THEN
      raise_application_error(
         -20003,
         'Password must contain at least one underscore (_) character.'
      );
   ELSE
      RETURN FALSE;
   END IF;
END;
/
--Pachet utiliztar pentru gestiunea utilizatorilor 
CREATE OR REPLACE PACKAGE bro_user_utils IS
   antrenor_suffix CONSTANT VARCHAR2(40) := 'ANTRENOR';
   receptionist_suffix CONSTANT VARCHAR2(40) := 'RECEPTIONIST';
   manager_suffix CONSTANT VARCHAR2(40) := 'MANAGER_FILIALA';
   client_suffix CONSTANT VARCHAR2(40) := 'CLIENT';
   public_suffix CONSTANT VARCHAR2(40) := 'PUBLIC_GENERAL';
   admin_suffix CONSTANT VARCHAR2(40) := 'ADMIN';
   bro_tablespace CONSTANT VARCHAR2(40) := 'USERS';
   antrenor_quota CONSTANT VARCHAR2(40) := '10M';
   bro_profile_public_general CONSTANT VARCHAR2(40) := 'BRO_PROFILE_PUBLIC_GENERAL';
   bro_profile_antrenor CONSTANT VARCHAR2(40) := 'BRO_PROFILE_ANTRENOR';
   bro_profile_receptionist CONSTANT VARCHAR2(40) := 'BRO_PROFILE_RECEPTIONIST';
   bro_profile_manager CONSTANT VARCHAR2(40) := 'BRO_PROFILE_MANAGER';
   bro_profile_client CONSTANT VARCHAR2(40) := 'BRO_PROFILE_CLIENT';
   bro_plan CONSTANT VARCHAR2(10) := 'P_BRO';
   bro_role CONSTANT VARCHAR2(10) := 'R_BRO_';
   TYPE user_names IS
      TABLE OF VARCHAR2(128) INDEX BY PLS_INTEGER;
   TYPE suffix_names IS
      TABLE OF VARCHAR2(40) INDEX BY PLS_INTEGER;
   FUNCTION get_suffixes RETURN suffix_names;

   FUNCTION get_users (
      suffix VARCHAR2
   ) RETURN user_names;

   PROCEDURE create_user_by_suffix (
      suffix          VARCHAR2,
      password_expire BOOLEAN := FALSE
   );

   PROCEDURE create_user (
      user_name       VARCHAR2,
      password_expire BOOLEAN := FALSE
   );

   PROCEDURE alter_quota (
      user_name VARCHAR2
   );

   PROCEDURE alter_quota_all (
      suffix VARCHAR2
   );

   FUNCTION password_verify_function (
      username     VARCHAR2,
      new_password VARCHAR2,
      old_password VARCHAR2
   ) RETURN BOOLEAN;

   PROCEDURE create_profile (
      suffix VARCHAR2
   );

   PROCEDURE assign_profile (
      user_name VARCHAR2
   );

   PROCEDURE assign_profile_all (
      suffix VARCHAR2
   );

   PROCEDURE configure_user_by_suffix (
      suffix      VARCHAR2,
      create_user BOOLEAN := TRUE
   );

   PROCEDURE create_bro_plan_rg;

   PROCEDURE clear_bro_plan_rg;

   PROCEDURE create_role (
      suffix   VARCHAR2,
      ovveride BOOLEAN := FALSE
   );
   PROCEDURE assign_role (
      suffix VARCHAR2
   );
END bro_user_utils;
/

CREATE OR REPLACE PACKAGE BODY bro_user_utils IS

   PROCEDURE is_valid_suffix (
      suffix VARCHAR2
   ) IS
   BEGIN
      IF suffix NOT IN ( antrenor_suffix,
                         receptionist_suffix,
                         manager_suffix,
                         client_suffix,
                         public_suffix ) THEN
         raise_application_error(
            -20002,
            'Invalid SUFFIX provided. Must be one of: ANTRENOR, RECEPTIONIST, MANAGER_FILIALA, CLIENT, PUBLIC_GENERAL.'
         );
      END IF;
   END;

   FUNCTION is_valid_user_name (
      user_name VARCHAR2
   ) RETURN VARCHAR2 IS
      v_suffix VARCHAR2(40);
   BEGIN
      IF NOT regexp_like(
         lower(user_name),
         '^bro_[a-z0-9_]+$',
         'i'
      ) THEN
         raise_application_error(
            -20005,
            'Invalid user name provided. Must start with "bro_" and contain only letters, numbers, and underscores (case-insensitive).'
         );
      END IF;

      v_suffix := regexp_replace(
         upper(substr(
            user_name,
            5
         )),
         '[0-9]',
         ''
      );
      is_valid_suffix(v_suffix);
      RETURN v_suffix;
   END;

   FUNCTION get_profile_name (
      suffix VARCHAR2
   ) RETURN VARCHAR2 IS
      v_profile_name VARCHAR2(40);
   BEGIN
      is_valid_suffix(suffix);
      CASE
         WHEN suffix = antrenor_suffix THEN
            v_profile_name := bro_profile_antrenor;
         WHEN suffix = receptionist_suffix THEN
            v_profile_name := bro_profile_receptionist;
         WHEN suffix = manager_suffix THEN
            v_profile_name := bro_profile_manager;
         WHEN suffix = client_suffix THEN
            v_profile_name := bro_profile_client;
         WHEN suffix = public_suffix THEN
            v_profile_name := bro_profile_public_general;
      END CASE;

      RETURN v_profile_name;
   END get_profile_name;

   PROCEDURE drop_profile (
      v_profile_name VARCHAR2
   ) IS
      v_cnt INT;
   BEGIN
      SELECT COUNT(DISTINCT profile)
        INTO v_cnt
        FROM dba_profiles
       WHERE profile = upper(v_profile_name);
      IF v_cnt > 1 THEN
         raise_application_error(
            -20004,
            'Impossible situation occured'
         );
      ELSIF v_cnt = 1 THEN
         EXECUTE IMMEDIATE 'DROP PROFILE '
                           || v_profile_name
                           || ' CASCADE';
      END IF;
   END;

   FUNCTION get_users (
      suffix VARCHAR2
   ) RETURN user_names IS
      v_names user_names;
   BEGIN
      is_valid_suffix(suffix);
      SELECT username
      BULK COLLECT
        INTO v_names
        FROM dba_users
       WHERE username LIKE upper('bro_'
                                 || suffix
                                 || '%');
      RETURN v_names;
   EXCEPTION
      WHEN no_data_found THEN
         dbms_output.put_line('No users found for suffix: ' || suffix);
         raise_application_error(
            -20006,
            'No users found for suffix: ' || suffix
         );
   END;

   FUNCTION get_user_by_suffix (
      suffix    VARCHAR2,
      next_user BOOLEAN := FALSE
   ) RETURN VARCHAR2 IS
      v_suffix_cnt INT;
      v_user_name  VARCHAR2(128);
   BEGIN
      SELECT COUNT(*)
        INTO v_suffix_cnt
        FROM dba_users
       WHERE username LIKE upper('bro_'
                                 || suffix
                                 || '%');
      IF next_user THEN
         v_suffix_cnt := v_suffix_cnt + 1;
      END IF;
      dbms_output.put_line('V_SUFFIX_CNT: ' || v_suffix_cnt);
      v_user_name := upper('bro_'
                           || suffix
                           || v_suffix_cnt);
      RETURN v_user_name;
   END;
 

    --public
   FUNCTION get_suffixes RETURN suffix_names IS
      v_suffixes suffix_names;
   BEGIN
      v_suffixes(1) := antrenor_suffix;
      v_suffixes(2) := receptionist_suffix;
      v_suffixes(3) := manager_suffix;
      v_suffixes(4) := client_suffix;
      v_suffixes(5) := public_suffix;
      RETURN v_suffixes;
   END;

   PROCEDURE create_user (
      user_name       VARCHAR2,
      password_expire BOOLEAN := FALSE
   ) IS
      user_count          SMALLINT;
      stmt                VARCHAR2(200);
      sanitized_user_name VARCHAR2(128);
   BEGIN
      sanitized_user_name := dbms_assert.simple_sql_name(user_name);
      SELECT COUNT(*)
        INTO user_count
        FROM dba_users
       WHERE username = upper(sanitized_user_name);
      IF user_count > 1 THEN
         raise_application_error(
            -20001,
            'Impossible situation occured'
         );
      ELSIF user_count = 1 THEN
         EXECUTE IMMEDIATE 'DROP USER "'
                           || upper(sanitized_user_name)
                           || '" CASCADE';
      ELSE
         EXECUTE IMMEDIATE 'CREATE USER "'
                           || upper(sanitized_user_name)
                           || '" IDENTIFIED BY "'
                           || lower(sanitized_user_name)
                           || '"';
         IF password_expire THEN
            EXECUTE IMMEDIATE 'ALTER USER "'
                              || upper(sanitized_user_name)
                              || '" PASSWORD EXPIRE';
         END IF;

         EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO "'
                           || upper(sanitized_user_name)
                           || '"';
      END IF;

      COMMIT;
   END;

   PROCEDURE create_user_by_suffix (
      suffix          VARCHAR2,
      password_expire BOOLEAN := FALSE
   ) IS
      v_user_name VARCHAR2(128);
   BEGIN
      v_user_name := get_user_by_suffix(
         suffix,
         TRUE
      );
      create_user(
         v_user_name,
         password_expire
      );
   END;

   PROCEDURE alter_quota (
      user_name VARCHAR2
   ) IS
      v_suffix VARCHAR2(40);
      v_quota  VARCHAR2(40);
   BEGIN
      v_suffix := is_valid_user_name(user_name);
      IF v_suffix = antrenor_suffix THEN
         v_quota := antrenor_quota;
      ELSE
         v_quota := '0M';
      END IF;

      EXECUTE IMMEDIATE 'ALTER USER '
                        || user_name
                        || ' QUOTA '
                        || v_quota
                        || ' ON '
                        || bro_tablespace;
      EXECUTE IMMEDIATE 'ALTER USER '
                        || user_name
                        || ' DEFAULT TABLESPACE '
                        || bro_tablespace;
      COMMIT;
   END;

   PROCEDURE alter_quota_all (
      suffix VARCHAR2
   ) IS
      v_names user_names;
      v_quota VARCHAR2(40);
   BEGIN
      v_names := get_users(suffix);
      dbms_output.put_line('V_NAMES.COUNT: ' || v_names.count);
      FOR i IN 1..v_names.count LOOP
         alter_quota(v_names(i));
      END LOOP;

      COMMIT;
   END;

   FUNCTION password_verify_function (
      username     VARCHAR2,
      new_password VARCHAR2,
      old_password VARCHAR2
   ) RETURN BOOLEAN IS
   BEGIN
      IF instr(
         new_password,
         '_'
      ) = 0 THEN
         raise_application_error(
            -20003,
            'Password must contain at least one underscore (_) character.'
         );
      ELSE
         RETURN FALSE;
      END IF;
   END;

   PROCEDURE create_profile (
      suffix VARCHAR2
   ) IS
      v_cnt                      SMALLINT;
      v_profile_name             VARCHAR2(40);
      v_password_verify_function CONSTANT VARCHAR2(80) := ' PASSWORD_VERIFY_FUNCTION PASSWORD_VERIFY_FUNCTION_STANDALONE';
   BEGIN
      v_profile_name := get_profile_name(suffix);
      drop_profile(v_profile_name);
      CASE v_profile_name
         WHEN bro_profile_public_general THEN
            EXECUTE IMMEDIATE 'CREATE PROFILE '
                              || v_profile_name
                              || ' LIMIT SESSIONS_PER_USER 6 IDLE_TIME 5 CONNECT_TIME 20 CPU_PER_CALL 6000 ';
         ELSE
            EXECUTE IMMEDIATE 'CREATE PROFILE '
                              || v_profile_name
                              || ' LIMIT SESSIONS_PER_USER 1 IDLE_TIME 15 PASSWORD_LIFE_TIME 90 FAILED_LOGIN_ATTEMPTS 5 '
                              || 'CPU_PER_CALL 12000  '
                              || v_password_verify_function;
      END CASE;
   END;

   PROCEDURE assign_profile (
      user_name VARCHAR2
   ) IS
      v_suffix       VARCHAR2(40);
      v_profile_name VARCHAR2(40);
   BEGIN
      v_suffix := is_valid_user_name(user_name);
      v_profile_name := get_profile_name(v_suffix);
      EXECUTE IMMEDIATE 'ALTER USER '
                        || user_name
                        || ' PROFILE '
                        || v_profile_name;
   END;

   PROCEDURE assign_profile_all (
      suffix VARCHAR2
   ) IS
      v_names        user_names;
      v_profile_name VARCHAR2(40);
   BEGIN
      v_names := get_users(suffix);
      FOR i IN 1..v_names.count LOOP
         assign_profile(v_names(i));
      END LOOP;
   END;

   PROCEDURE configure_user_by_suffix (
      suffix      VARCHAR2,
      create_user BOOLEAN := TRUE
   ) IS
      v_user_name VARCHAR2(128);
   BEGIN
      IF create_user THEN
         create_user_by_suffix(suffix);
         COMMIT;
      END IF;
      v_user_name := get_user_by_suffix(suffix);
      dbms_output.put_line('V_USER_NAME: ' || v_user_name);
      alter_quota(v_user_name);
      assign_profile(v_user_name);
      COMMIT;
   END;

   PROCEDURE create_bro_plan_rg IS
      v_suffixes             suffix_names := get_suffixes;
      v_user_names           user_names;
      v_exists_default_group SMALLINT;
      v_rg_prefix            VARCHAR2(40) := 'BRO_RG_';
   BEGIN
      v_suffixes(v_suffixes.count + 1) := admin_suffix;
      dbms_resource_manager.create_pending_area();
      dbms_resource_manager.create_plan(
         plan                      => bro_plan,
         comment                   => 'Consumption plan for BRO users',
         active_sess_pool_mth      => 'ACTIVE_SESS_POOL_ABSOLUTE',
         parallel_degree_limit_mth => 'PARALLEL_DEGREE_LIMIT_ABSOLUTE',
         queueing_mth              => 'FIFO_TIMEOUT',
         mgmt_mth                  => 'EMPHASIS',
         sub_plan                  => FALSE
      );
      FOR i IN 1..v_suffixes.count LOOP
         dbms_resource_manager.create_consumer_group(
            consumer_group => v_rg_prefix || v_suffixes(i),
            comment        => 'Consumer group for BRO '
                       || v_suffixes(i)
                       || ' users'
         );
      END LOOP;

      SELECT COUNT(*)
        INTO v_exists_default_group
        FROM dba_rsrc_consumer_groups
       WHERE consumer_group = 'OTHER_GROUPS';
      IF v_exists_default_group = 0 THEN
         dbms_resource_manager.create_consumer_group(
            consumer_group => 'OTHER_GROUPS',
            comment        => 'Default consumer group for all other users'
         );
      END IF;

      FOR i IN 1..v_suffixes.count LOOP
         IF ( v_suffixes(i) = admin_suffix ) THEN
            dbms_resource_manager.set_consumer_group_mapping(
               attribute      => dbms_resource_manager.oracle_user,
               value          => 'BRO_ADMIN',
               consumer_group => v_rg_prefix || v_suffixes(i)
            );
         ELSE
            v_user_names := get_users(v_suffixes(i));
            dbms_output.put_line('V_USER_NAMES.COUNT: ' || v_user_names.count);
            FOR j IN 1..v_user_names.count LOOP
               dbms_resource_manager.set_consumer_group_mapping(
                  attribute      => dbms_resource_manager.oracle_user,
                  value          => v_user_names(j),
                  consumer_group => v_rg_prefix || v_suffixes(i)
               );
            END LOOP;
         END IF;
      END LOOP;
 

        -- doar mgmt_p1 ca nu avem subplanuri
      dbms_resource_manager.create_plan_directive(
         plan             => bro_plan,
         group_or_subplan => 'OTHER_GROUPS',
         comment          => 'Default consumer group for all other users',
         mgmt_p1          => 5
      );
      dbms_resource_manager.create_plan_directive(
         plan             => bro_plan,
         group_or_subplan => v_rg_prefix || antrenor_suffix,
         comment          => 'Consumer group for BRO ANTRENOR users',
         mgmt_p1          => 20
      );
      dbms_resource_manager.create_plan_directive(
         plan             => bro_plan,
         group_or_subplan => v_rg_prefix || receptionist_suffix,
         comment          => 'Consumer group for BRO RECEPTIONIST users',
         mgmt_p1          => 15
      );
      dbms_resource_manager.create_plan_directive(
         plan             => bro_plan,
         group_or_subplan => v_rg_prefix || manager_suffix,
         comment          => 'Consumer group for BRO MANAGER users',
         mgmt_p1          => 15
      );
      dbms_resource_manager.create_plan_directive(
         plan             => bro_plan,
         group_or_subplan => v_rg_prefix || client_suffix,
         comment          => 'Consumer group for BRO CLIENT users',
         mgmt_p1          => 10
      );
      dbms_resource_manager.create_plan_directive(
         plan             => bro_plan,
         group_or_subplan => v_rg_prefix || public_suffix,
         comment          => 'Consumer group for BRO PUBLIC users',
         mgmt_p1          => 5
      );
      dbms_resource_manager.create_plan_directive(
         plan             => bro_plan,
         group_or_subplan => v_rg_prefix || admin_suffix,
         comment          => 'Consumer group for BRO ADMIN users',
         mgmt_p1          => 30
      );
      dbms_resource_manager.validate_pending_area();
      dbms_resource_manager.submit_pending_area();
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error: ' || sqlerrm);
         dbms_resource_manager.clear_pending_area();
         COMMIT;
   END;

   PROCEDURE clear_bro_plan_rg IS
      v_suffixes             suffix_names := get_suffixes;
      v_exists_default_group SMALLINT;
      v_rg_prefix            VARCHAR2(40) := 'BRO_RG_';
   BEGIN
      v_suffixes(v_suffixes.count + 1) := admin_suffix;
      dbms_resource_manager.create_pending_area();
      BEGIN
         dbms_resource_manager.delete_plan(plan => bro_plan);
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line('Error deleting plan: ' || sqlerrm);
      END;

      FOR i IN 1..v_suffixes.count LOOP
         BEGIN
            dbms_resource_manager.delete_consumer_group(consumer_group => v_rg_prefix || v_suffixes(i));
         EXCEPTION
            WHEN OTHERS THEN
               dbms_output.put_line('Error deleting consumer group: '
                                    || v_rg_prefix
                                    || v_suffixes(i)
                                    || ' - '
                                    || sqlerrm);
         END;
      END LOOP;

      SELECT COUNT(*)
        INTO v_exists_default_group
        FROM dba_rsrc_consumer_groups
       WHERE consumer_group = 'OTHER_GROUPS';
      IF v_exists_default_group > 0 THEN
         BEGIN
            dbms_resource_manager.delete_consumer_group(consumer_group => 'OTHER_GROUPS');
         EXCEPTION
            WHEN OTHERS THEN
               dbms_output.put_line('Error deleting OTHER_GROUPS: ' || sqlerrm);
         END;
      END IF;

      dbms_resource_manager.validate_pending_area();
      dbms_resource_manager.submit_pending_area();
      dbms_output.put_line('All objects created by CREATE_BRO_PLAN_RG have been cleared.');
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line('Error: ' || sqlerrm);
         dbms_resource_manager.clear_pending_area();
         COMMIT;
   END;

   PROCEDURE create_role (
      suffix   VARCHAR2,
      ovveride BOOLEAN := FALSE
   ) IS
      v_cnt       SMALLINT;
      v_role_name VARCHAR2(40);
   BEGIN
      is_valid_suffix(suffix);
      v_role_name := dbms_assert.simple_sql_name(upper(bro_role || suffix));
      SELECT COUNT(*)
        INTO v_cnt
        FROM dba_roles
       WHERE role = upper(v_role_name);
      dbms_output.put_line('NOT IMPLEMENTED');
    --   if v_cnt = 1 then
    --      if ovveride then
    --         execute immediate 'DROP ROLE ' || v_role_name;
    --      else
    --         raise_application_error(
    --            -20007,
    --            'Role already exists: ' || v_role_name
    --         );
    --      end if;
    --   end if;

    --   execute immediate 'CREATE ROLE ' || v_role_name;
    --   case suffix
    --      when admin_suffix then
    --         execute immediate 'grant create table, create view, create sequence,create indextype, create procedure, create trigger,create type to ' || v_role_name
    --         ;
    --      else
    --         raise_application_error(
    --            -20008,
    --            'Role not implemented for suffix: ' || suffix
    --         );
--    end case;
   END;

   PROCEDURE assign_role (
      suffix VARCHAR2
   ) IS
      v_role_name VARCHAR2(40);
      v_users     user_names;
      v_cnt       SMALLINT;
   BEGIN
      v_role_name := dbms_assert.simple_sql_name(upper(bro_role || suffix));
      v_users := get_users(suffix);
      SELECT COUNT(*)
        INTO v_cnt
        FROM dba_roles
       WHERE role = upper(v_role_name);
      dbms_output.put_line('NOT IMPLEMENTED');
    --   if v_cnt = 0 then
    --      raise_application_error(
    --         -20009,
    --         'Role does not exist: ' || v_role_name
    --      );
    --   end if;
    --   for i in 1..v_users.count loop
    --      execute immediate 'GRANT '
    --                        || v_role_name
    --                        || ' TO '
    --                        || v_users(i);
        --  case suffix
        --     when admin_suffix then
        --        execute immediate 'grant create index ' || v_users(i);
        --  end case;
    --   end loop;

   END;
END bro_user_utils;
/

-- Table si functie care intoarce toti utilizaotrii creati
-- pentru a permite adimnului access doar la cei
-- din cadrul aplicatiei noastre 
CREATE OR REPLACE TYPE global_user_table AS
   TABLE OF VARCHAR2(128);
/

CREATE OR REPLACE FUNCTION get_users_by_suffix (
   suffix VARCHAR2
) RETURN global_user_table IS
   result_cursor      SYS_REFCURSOR;
   user_indexed_table bro_user_utils.user_names;
   user_nested_table  global_user_table := global_user_table();
BEGIN
   user_indexed_table := bro_user_utils.get_users(suffix);
   FOR i IN user_indexed_table.first..user_indexed_table.last LOOP
      user_nested_table.extend;
      user_nested_table(user_nested_table.count) := user_indexed_table(i);
   END LOOP;
   RETURN user_nested_table;
END;
/


CREATE USER bro_admin IDENTIFIED BY bro_admin
   PASSWORD EXPIRE;
   
GRANT
   CREATE SESSION
TO bro_admin;
GRANT
   CREATE ANY TABLE
TO bro_admin;
GRANT
   CREATE ANY VIEW
TO bro_admin;
GRANT
   CREATE ANY TRIGGER
TO bro_admin;
GRANT
   CREATE ANY PROCEDURE
TO bro_admin;

GRANT
   CREATE ANY SEQUENCE
TO bro_admin;

GRANT
   CREATE ANY INDEX
TO bro_admin;

GRANT
   CREATE ANY TYPE
TO bro_admin;

GRANT
   CREATE TYPE
TO bro_admin;
GRANT EXECUTE ON global_user_table TO bro_admin;

-- Pt proceduri
GRANT EXECUTE ON dbms_crypto TO bro_admin WITH GRANT OPTION;
--Pt generated by default on null as identity la create in antrenor
GRANT
   SELECT ANY SEQUENCE
TO bro_admin;
GRANT EXECUTE ON get_users_by_suffix TO bro_admin;

--Profilul adminului 
CREATE PROFILE bro_profile_admin LIMIT
   IDLE_TIME 15
   PASSWORD_LIFE_TIME 90
   FAILED_LOGIN_ATTEMPTS 5
   CPU_PER_CALL 36000
   PASSWORD_VERIFY_FUNCTION password_verify_function_standalone;

ALTER USER bro_admin
   PROFILE bro_profile_admin;

ALTER USER bro_admin
   QUOTA 500M ON users;

-- Creare profilurilor pentru restul de utilizatori
exec BRO_USER_UTILS.CREATE_PROFILE(BRO_USER_UTILS.PUBLIC_SUFFIX);
exec BRO_USER_UTILS.CREATE_PROFILE(BRO_USER_UTILS.ANTRENOR_SUFFIX);
exec BRO_USER_UTILS.CREATE_PROFILE(BRO_USER_UTILS.RECEPTIONIST_SUFFIX);
exec BRO_USER_UTILS.CREATE_PROFILE(BRO_USER_UTILS.MANAGER_SUFFIX);
exec BRO_USER_UTILS.CREATE_PROFILE(BRO_USER_UTILS.CLIENT_SUFFIX);


-- public general
exec BRO_USER_UTILS.CONFIGURE_USER_BY_SUFFIX(BRO_USER_UTILS.PUBLIC_SUFFIX, TRUE);
--manager filiala
exec BRO_USER_UTILS.CONFIGURE_USER_BY_SUFFIX(BRO_USER_UTILS.MANAGER_SUFFIX, TRUE);
--antrenor
BEGIN
   FOR i IN 1..7 LOOP
      bro_user_utils.configure_user_by_suffix(
         bro_user_utils.antrenor_suffix,
         TRUE
      );
   END LOOP;
END;
/
--receptionist
BEGIN
   FOR i IN 1..10 LOOP
      bro_user_utils.configure_user_by_suffix(
         bro_user_utils.receptionist_suffix,
         TRUE
      );
   END LOOP;
END;
/
--client
BEGIN
   FOR i IN 1..10 LOOP
      bro_user_utils.configure_user_by_suffix(
         bro_user_utils.client_suffix,
         TRUE
      );
   END LOOP;
END;
/


 -- planul de resurse 
exec BRO_USER_UTILS.CREATE_BRO_PLAN_RG;

SELECT username,
       initial_rsrc_consumer_group
  FROM dba_users
 WHERE username LIKE upper('bro_%');
 
SELECT DISTINCT u.username, u.profile, p.group_or_subplan, p.mgmt_p1, p.plan 
FROM dba_users u  JOIN dba_rsrc_plan_directives p
ON u.initial_rsrc_consumer_group=p.group_or_subplan
WHERE username LIKE upper('bro_%');
SELECT DISTINCT 
    u.username, 
    u.profile, 
    p.group_or_subplan, 
    p.mgmt_p1, 
    p.plan, 
    r.granted_role
FROM 
    dba_users u 
    LEFT JOIN dba_rsrc_plan_directives p
        ON u.initial_rsrc_consumer_group = p.group_or_subplan
    LEFT JOIN dba_role_privs r
        ON u.username = r.grantee
WHERE 
    u.username LIKE UPPER('bro_%')
ORDER BY 
    u.username, r.granted_role;


-- Restul de privilegii si roluri vor fi data dupa ce admin creeaza tot
-- inclusiv in antrenori etc 