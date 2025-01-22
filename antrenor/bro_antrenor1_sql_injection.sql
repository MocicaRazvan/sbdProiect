CREATE OR REPLACE PROCEDURE get_program_full (
   id_prg    NUMBER,
   data_inst VARCHAR2
) IS
   TYPE program_echipament_rec IS RECORD (
         id_echipament  bro_admin.echipament.id_echipament%TYPE,
         nume           bro_admin.echipament.nume%TYPE,
         data_instalare bro_admin.echipament.data_instalare%TYPE,
         data_revizie   bro_admin.echipament.data_revizie%TYPE,
         id_filiala     bro_admin.echipament.id_filiala%TYPE,
         id_furnizor    bro_admin.echipament.id_furnizor%TYPE,
         id_program     program.id_program%TYPE,
         descriere      program.descriere%TYPE,
         tip_program    program.tip_program%TYPE
   );
   TYPE program_echipament_tab IS
      TABLE OF program_echipament_rec;
   v_program_echipament program_echipament_tab;
   v_sql                VARCHAR2(2500) := 'SELECT * FROM bro_admin.echipament e 
                        NATURAL JOIN program p
                        WHERE p.id_program = '
                           || id_prg
                           || ' AND upper(to_char(data_revizie, ''DD-MON-YY'')) LIKE ''%'
                           || upper(data_inst)
                           || '%''';
BEGIN
   dbms_output.put_line('SQL: ' || v_sql);
   EXECUTE IMMEDIATE v_sql
   BULK COLLECT
     INTO v_program_echipament;
   dbms_output.put_line('Program and Equipment Details:');
   dbms_output.new_line();
   FOR i IN 1..v_program_echipament.count LOOP
      dbms_output.put_line('ID_ECHIPAMENT: '
                           || v_program_echipament(i).id_echipament
                           || ', NUME: '
                           || v_program_echipament(i).nume
                           || ', DATA_INSTALARE: '
                           || to_char(
         v_program_echipament(i).data_instalare,
         'YYYY-MM-DD'
      )
                           || ', DATA_REVIZIE: '
                           || to_char(
         v_program_echipament(i).data_revizie,
         'YYYY-MM-DD'
      )
                           || ', ID_FILIALA: '
                           || v_program_echipament(i).id_filiala
                           || ', ID_FURNIZOR: '
                           || v_program_echipament(i).id_furnizor
                           || ', ID_PROGRAM: '
                           || v_program_echipament(i).id_program
                           || ', DESCRIERE: '
                           || v_program_echipament(i).descriere
                           || ', TIP_PROGRAM: '
                           || v_program_echipament(i).tip_program);
      dbms_output.new_line();
   END LOOP;
EXCEPTION
   WHEN no_data_found THEN
      dbms_output.put_line('No data found for the specified program ID: ' || id_prg);
   WHEN OTHERS THEN
      dbms_output.put_line('An error occurred running get_program_full: ' || sqlerrm);
END;
/

GRANT EXECUTE ON get_program_full TO bro_client1;
/
-- sql injection fix

CREATE OR REPLACE PROCEDURE get_program_full_safe  (
   id_prg    NUMBER,
   data_inst VARCHAR2
) IS
  TYPE program_echipament_rec IS RECORD (
         id_echipament  bro_admin.echipament.id_echipament%TYPE,
         nume           bro_admin.echipament.nume%TYPE,
         data_instalare bro_admin.echipament.data_instalare%TYPE,
         data_revizie   bro_admin.echipament.data_revizie%TYPE,
         id_filiala     bro_admin.echipament.id_filiala%TYPE,
         id_furnizor    bro_admin.echipament.id_furnizor%TYPE,
         id_program     program.id_program%TYPE,
         descriere      program.descriere%TYPE,
         tip_program    program.tip_program%TYPE
   );
    TYPE program_echipament_tab IS TABLE OF program_echipament_rec;
   v_program_echipament program_echipament_tab;
   v_sql VARCHAR2(2500) := 'SELECT 
                                 e.id_echipament, 
                                 e.nume, 
                                 e.data_instalare, 
                                 e.data_revizie, 
                                 e.id_filiala, 
                                 e.id_furnizor, 
                                 p.id_program, 
                                 p.descriere, 
                                 p.tip_program
                             FROM bro_admin.echipament e 
                             NATURAL JOIN program p
                             WHERE p.id_program = :id_prg
                               AND UPPER(TO_CHAR(e.data_revizie, ''DD-MON-YY'')) LIKE :data_inst';
BEGIN
   dbms_output.put_line('Executing SQL: ' || v_sql);

   EXECUTE IMMEDIATE v_sql BULK COLLECT
      INTO v_program_echipament
      USING id_prg, '%' || upper(data_inst) || '%';

   dbms_output.put_line('Program and Equipment Details:');
   dbms_output.new_line();

   FOR i IN 1 .. v_program_echipament.count LOOP
      dbms_output.put_line('ID_ECHIPAMENT: ' || v_program_echipament(i).id_echipament ||
                           ', NUME: ' || v_program_echipament(i).nume ||
                           ', DATA_INSTALARE: ' || to_char(v_program_echipament(i).data_instalare, 'YYYY-MM-DD') ||
                           ', DATA_REVIZIE: ' || to_char(v_program_echipament(i).data_revizie, 'YYYY-MM-DD') ||
                           ', ID_FILIALA: ' || v_program_echipament(i).id_filiala ||
                           ', ID_FURNIZOR: ' || v_program_echipament(i).id_furnizor ||
                           ', ID_PROGRAM: ' || v_program_echipament(i).id_program ||
                           ', DESCRIERE: ' || v_program_echipament(i).descriere ||
                           ', TIP_PROGRAM: ' || v_program_echipament(i).tip_program);
      dbms_output.new_line();
   END LOOP;

EXCEPTION
   WHEN no_data_found THEN
      dbms_output.put_line('No data found for the specified program ID: ' || id_prg);
   WHEN OTHERS THEN
      dbms_output.put_line('An error occurred running get_program_full: ' || sqlerrm);
END;
/

GRANT EXECUTE ON get_program_full_safe TO bro_client1;
