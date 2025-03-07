SET SERVEROUTPUT ON;

-- Crearea tabelelor si inserarea datelor initiale in schema bro_admin

--DROP TABLE persoana CASCADE CONSTRAINTS;
--DROP TABLE telefon CASCADE CONSTRAINTS;
--DROP TABLE client CASCADE CONSTRAINTS;
--DROP TABLE adresa CASCADE CONSTRAINTS;
--DROP TABLE filiala CASCADE CONSTRAINTS;
--DROP TABLE angajat CASCADE CONSTRAINTS;
--DROP TABLE receptionist CASCADE CONSTRAINTS;
--DROP TABLE antrenor CASCADE CONSTRAINTS;
--DROP TABLE furnizor CASCADE CONSTRAINTS;
--DROP TABLE echipament CASCADE CONSTRAINTS;
--DROP TABLE tip_abonament CASCADE CONSTRAINTS;
--DROP TABLE abonament CASCADE CONSTRAINTS;
--DROP TABLE comanda CASCADE CONSTRAINTS;
--DROP TABLE supliment CASCADE CONSTRAINTS;
--DROP TABLE aprovizionare CASCADE CONSTRAINTS;
--DROP TABLE informatii_comanda CASCADE CONSTRAINTS; 
--DROP TABLE account_mapping;
--drop table logger;
--drop sequence abonament_seq;
--drop sequence adresa_seq;
--drop sequence comanda_seq;
--drop sequence echipament_seq;
--drop sequence filiala_seq;
--drop sequence furnizor_seq;
--drop sequence persoana_seq_global;
--drop sequence supliment_seq;
--drop sequence logger_seq;

CREATE TABLE persoana(
    id_persoana NUMBER(*,0) CONSTRAINT pk_persoana PRIMARY KEY,
    nume VARCHAR2(20) CONSTRAINT nn_persoana_nume NOT NULL,
    prenume VARCHAR2(30) CONSTRAINT nn_persoana_prenume NOT NULL,
    email VARCHAR2(30) CONSTRAINT nn_u_persoana_email NOT NULL UNIQUE,
    varsta NUMBER(3,0) CONSTRAINT nn_persoana_varsta NOT NULL
);

CREATE TABLE telefon(
    tip VARCHAR2(20) CONSTRAINT nn_telefon_tip NOT NULL ,
    numar VARCHAR2(20) CONSTRAINT nn_telefon_numar NOT NULL,
    id_persoana NUMBER(*,0) CONSTRAINT fk_telefon_persoana REFERENCES persoana(id_persoana) ON DELETE CASCADE,
    CONSTRAINT pk_telefon PRIMARY KEY (id_persoana, numar)
); 

CREATE TABLE client(
    id_client NUMBER(*,0) CONSTRAINT pk_client PRIMARY KEY ,
    student VARCHAR2(1) DEFAULT 'N' CONSTRAINT ck_client_student CHECK (student IN('Y','N')) ,
    CONSTRAINT fk_client_persoana FOREIGN KEY (id_client) REFERENCES  persoana(id_persoana) ON DELETE CASCADE
);
CREATE TABLE adresa(
    id_adresa NUMBER(*,0) CONSTRAINT pk_adresa PRIMARY KEY,
    strada VARCHAR2(40) CONSTRAINT nn_adresa_strada NOT NULL,
    oras VARCHAR2(20) CONSTRAINT nn_adresa_oras NOT NULL,
    judet VARCHAR2(20) CONSTRAINT nn_adresa_judet NOT NULL,
    cod_postal NUMBER(10,0) CONSTRAINT nn_adresa_cod_postal NOT NULL,
    numar NUMBER(4,0) CONSTRAINT nn_adresa_numar NOT NULL
);

CREATE TABLE filiala (
    id_filiala NUMBER(*,0) CONSTRAINT pk_filiala PRIMARY KEY,
    nume VARCHAR2(40) CONSTRAINT nn_filiala_nume NOT NULL,
    data_deschidere DATE CONSTRAINT nn_filiala_data_deschidere NOT NULL,
    id_adresa NUMBER(*,0) CONSTRAINT fk_filiala_adresa REFERENCES adresa(id_adresa) NOT NULL UNIQUE
);

CREATE TABLE angajat(
    id_angajat NUMBER(*,0) CONSTRAINT pk_angajat PRIMARY KEY,
    data_angajare DATE CONSTRAINT nn_angajat_data_angjare NOT NULL,
    salariu NUMBER(20,2) CONSTRAINT ck_angajat_salariu CHECK (salariu > 0) NOT NULL,
    id_filiala NUMBER(*,0) CONSTRAINT fk_angajat_filiala REFERENCES filiala(id_filiala) ON DELETE CASCADE NOT NULL ,
    id_meneger NUMBER(*,0) CONSTRAINT fk_angajat_angajat REFERENCES angajat(id_angajat),
    CONSTRAINT fk_angajat_persoana FOREIGN KEY (id_angajat) REFERENCES  persoana(id_persoana) ON DELETE CASCADE
);

CREATE TABLE receptionist(
    id_receptionist NUMBER(*,0) CONSTRAINT pk_receptionist PRIMARY KEY,
    program_complet VARCHAR2(1) CONSTRAINT ck_receptionist_program_complet CHECK(program_complet IN ('Y','N')),
    CONSTRAINT fk_receptionist_angajat FOREIGN KEY (id_receptionist) REFERENCES  angajat(id_angajat) ON DELETE CASCADE
);

CREATE TABLE antrenor(
    id_antrenor NUMBER(*,0) CONSTRAINT pk_antrenor PRIMARY KEY,
    studii VARCHAR2(40) CONSTRAINT nn_antrenor_studii NOT NULL,
    CONSTRAINT fk_antrenor_angajat FOREIGN KEY (id_antrenor) REFERENCES  angajat(id_angajat) ON DELETE CASCADE

);
CREATE TABLE furnizor(
    id_furnizor NUMBER(*,0) CONSTRAINT pk_furnizor PRIMARY KEY,
    nume VARCHAR2(40) CONSTRAINT nn_furnizor_nume NOT NULL,
    cod_fiscal NUMBER(10,0) CONSTRAINT ck_furnizor_cod_fiscal NOT NULL UNIQUE,
    id_adresa NUMBER(*,0) CONSTRAINT fk_furnizor_adresa REFERENCES adresa(id_adresa) NOT NULL UNIQUE
);

CREATE TABLE echipament(
    id_echipament NUMBER(*,0) CONSTRAINT pk_echipament PRIMARY KEY,
    nume VARCHAR2(40) CONSTRAINT nn_echipament_nume NOT NULL,
    data_instalare DATE CONSTRAINT nn_echipament_data_instalare NOT NULL,
    data_revizie DATE CONSTRAINT nn_echipament_data_revizie NOT NULL ,
    id_filiala NUMBER(*,0) CONSTRAINT fk_echipament_filiala REFERENCES filiala(id_filiala) NOT NULL,
    id_furnizor NUMBER(*,0) CONSTRAINT fk_echipament_furnizor REFERENCES furnizor(id_furnizor) NOT NULL,
    CONSTRAINT ck_echipament_instalare_revizie CHECK(data_instalare <= data_revizie)
);

CREATE TABLE tip_abonament (
    nume_tip VARCHAR2(40) CONSTRAINT pk_tip_abonament PRIMARY KEY  CHECK (nume_tip IN ( 'lunar', 'trimestrial', 'bianual' ,'anual','extins')),
    pret NUMBER(8,2) CONSTRAINT ck_tip_abonament_pret NOT NULL UNIQUE
);

CREATE TABLE abonament(
    id_abonament NUMBER(*,0) CONSTRAINT pk_abonament PRIMARY KEY,
    nume_tip VARCHAR2(40) CONSTRAINT fk_abonament_tip_abonament REFERENCES tip_abonament(nume_tip) NOT NULL,
    id_client NUMBER(*,0) CONSTRAINT fk_abonament_client REFERENCES client(id_client) NOT NULL UNIQUE,
    data_inregistrare DATE CONSTRAINT nn_abonament_data_intregistrare NOT NULL
);

CREATE TABLE comanda(
    id_comanda NUMBER(*,0) CONSTRAINT pk_comanda PRIMARY KEY,
    id_receptionist NUMBER(*,0) CONSTRAINT fk_comanda_receptionist REFERENCES receptionist(id_receptionist) NOT NULL,
    id_client NUMBER(*,0) CONSTRAINT fk_comanda_client REFERENCES client(id_client) NOT NULL,
    data_comandare DATE CONSTRAINT nn_comanda_data_comandare NOT NULL,
    observatii VARCHAR2(255)
);

CREATE TABLE supliment (
    id_supliment NUMBER(*,0) CONSTRAINT pk_supliment PRIMARY KEY,
    nume VARCHAR2(50) CONSTRAINT nn_supliment_nume NOT NULL,
    descriere VARCHAR2(255),
    calorii NUMBER(10,4)CONSTRAINT nn_suplimen_calorii NOT NULL,
    pret NUMBER(10,4) CONSTRAINT nn_supliment_pret NOT NULL
);

CREATE TABLE aprovizionare (
    id_furnizor NUMBER(*,0),
    id_supliment NUMBER(*,0),
    cantitate NUMBER(4) CONSTRAINT ck_aprovizionare_cantitate CHECK(cantitate > 0) NOT NULL,
    CONSTRAINT pk_aprovizionare PRIMARY KEY (id_furnizor,id_supliment),
    CONSTRAINT fk_aprovizionare_furnizor FOREIGN KEY (id_furnizor) REFERENCES furnizor(id_furnizor),
    CONSTRAINT fk_aprovizionare_supliment FOREIGN KEY (id_supliment) REFERENCES supliment(id_supliment)

);

CREATE TABLE informatii_comanda (
    id_comanda NUMBER(*,0),
    id_supliment NUMBER(*,0),
    cantitate NUMBER(4) CONSTRAINT ck_ic_cantitate CHECK(cantitate > 0) NOT NULL,
    CONSTRAINT pk_informatii_comanda PRIMARY KEY (id_comanda,id_supliment),
    CONSTRAINT fk_ic_comanda FOREIGN KEY (id_comanda) REFERENCES comanda(id_comanda),
    CONSTRAINT fk_ic_supliment FOREIGN KEY (id_supliment) REFERENCES supliment(id_supliment)
);

CREATE TABLE account_mapping(
    id_persoana NUMBER(*,0) CONSTRAINT pk_account_mapping PRIMARY KEY,
    username VARCHAR2(128) UNIQUE
);

COMMIT;


CREATE TABLE logger(
    id_logger NUMBER(*,0) CONSTRAINT pk_logger PRIMARY KEY,
    message VARCHAR2(255),
    message_type VARCHAR2(1)CONSTRAINT ck_logger_message_type CHECK (message_type IN('E','W','I')),
    created_by VARCHAR2(40)CONSTRAINT nn_logger_created_by NOT NULL,
    created_at TIMESTAMP CONSTRAINT nn_logger_created_at NOT NULL
);

CREATE OR REPLACE PACKAGE logger_utils IS
    PROCEDURE logger_entry(mesaj VARCHAR2,tip_mesaj VARCHAR2, cod NUMBER);
    PROCEDURE logger_entry(mesaj VARCHAR2,tip_mesaj VARCHAR2);
END logger_utils;
/


-- PRAGMA AUTONOMOUS_TRANSACTION este necesara, deoarece functia
-- RAISE_APPLICATION_ERROR opreste tranzactia originala, ceea ce impiedica
-- inserarea in Logger. In acest caz folosirea acesteia nu conduce
-- la probleme pentru ca nu folosim date 
-- din noua tranzactie in cea originala.
CREATE OR REPLACE PACKAGE BODY logger_utils IS
    PROCEDURE logger_entry(mesaj VARCHAR2,tip_mesaj VARCHAR2, cod NUMBER) IS
     PRAGMA autonomous_transaction;
        BEGIN
            INSERT INTO logger(message, message_type,created_by, created_at) 
            VALUES (substr(mesaj,1,255), tip_mesaj,user, TO_DATE(to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'));
            COMMIT;
            raise_application_error(cod,mesaj);
            dbms_output.put_line(cod || ' : '||mesaj);
             EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                raise_application_error(sqlcode,sqlerrm);
        END logger_entry;
    PROCEDURE logger_entry(mesaj VARCHAR2,tip_mesaj VARCHAR2) IS
    PRAGMA autonomous_transaction;
        BEGIN
            dbms_output.put_line(tip_mesaj || ' : '||mesaj);
            INSERT INTO logger(message, message_type,created_by, created_at)  VALUES 
            (substr(mesaj,1,255), tip_mesaj,user, TO_DATE(to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'));
            COMMIT;
        END;
END logger_utils;
/

CREATE OR REPLACE PACKAGE sequence_utils IS
    PROCEDURE create_sequence(p_seq_name IN VARCHAR2);
    PROCEDURE create_sequence_trigger (p_tbl_name IN VARCHAR2);
END sequence_utils;
/

CREATE OR REPLACE PACKAGE BODY sequence_utils IS

       PROCEDURE create_sequence(p_seq_name IN VARCHAR2) IS
       seq_count INT;
       seq_name VARCHAR2(128);
        BEGIN
--            dbms_output.put_line(p_seq_name);
            seq_name:=dbms_assert.simple_sql_name(p_seq_name);
--            dbms_output.put_line(seq_name);
            SELECT COUNT(*) INTO seq_count FROM user_sequences WHERE sequence_name = upper(seq_name);
                IF seq_count > 0 THEN
                    EXECUTE IMMEDIATE 'DROP SEQUENCE '|| seq_name; 
                END IF;
            EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || seq_name || ' START WITH 1 INCREMENT BY 1';
        EXCEPTION
            WHEN OTHERS THEN
                logger_utils.logger_entry(sqlerrm,'E',sqlcode);
        END create_sequence;
    
    PROCEDURE create_sequence_trigger (p_tbl_name IN VARCHAR2) IS
            count_tables NUMBER;
            v_id_count INT;
            no_id EXCEPTION;
            table_not_found EXCEPTION;
            tbl_name VARCHAR2(128);
        BEGIN
            dbms_output.put_line(p_tbl_name);
            tbl_name:=dbms_assert.simple_sql_name(p_tbl_name);
            dbms_output.put_line(tbl_name);
            SELECT COUNT(*)
            INTO count_tables
            FROM all_tables
            WHERE table_name = upper(tbl_name);
        
            IF count_tables = 0 THEN
                RAISE table_not_found;
            END IF;
        
            EXECUTE IMMEDIATE  
                'SELECT COUNT(*) FROM all_tab_columns WHERE upper(table_name) = upper(''' || tbl_name || 
                ''') AND upper(column_name) = upper(''id_' || tbl_name || ''')' INTO v_id_count;
            
            IF v_id_count=0 THEN
                RAISE no_id;
            END IF;
            create_sequence(tbl_name ||'_seq');
        
            EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER ' || tbl_name || 
                              '_trigger BEFORE INSERT ON ' || tbl_name || 
                              ' FOR EACH ROW BEGIN SELECT ' ||tbl_name||'_seq.NEXTVAL INTO :NEW.id_'||
                              lower(tbl_name)||' FROM dual; END;';
        EXCEPTION
            WHEN no_id THEN
                logger_utils.logger_entry('Column named id_'|| tbl_name || ' does not exist in '||tbl_name,'E',-20006);
            WHEN table_not_found THEN
                logger_utils.logger_entry('Table '|| tbl_name || ' does not exist.','E',-20007);
            WHEN OTHERS THEN
                logger_utils.logger_entry( sqlerrm || ' code: ' || sqlcode,'E',-20010);
        END create_sequence_trigger;

END sequence_utils;
/
TRUNCATE TABLE logger;
EXEC sequence_utils.create_sequence_trigger('Logger');

CREATE OR REPLACE PROCEDURE insert_into_account_mapping(
    id_persoana NUMBER,acc_suff VARCHAR2
) IS 
    v_user VARCHAR2(128);
BEGIN
    SELECT column_value INTO v_user FROM (
    SELECT column_value,TO_NUMBER(regexp_substr(column_value, '[0-9]+$')) AS numeric_part
    FROM  TABLE(sys.get_users_by_suffix(acc_suff))
    WHERE NOT EXISTS(SELECT 1 FROM account_mapping WHERE username=upper(column_value))
    ORDER BY numeric_part ASC)
    WHERE ROWNUM =1 ;
    dbms_output.put_line('user '||v_user);
    INSERT INTO account_mapping VALUES (id_persoana,upper(v_user));
    EXCEPTION
        WHEN OTHERS THEN
         logger_utils.logger_entry( 'No avaialable account for the suffix '|| acc_suff,'E',-20020);
END;
/
CREATE OR REPLACE PACKAGE global_constants IS
    persoana_seq CONSTANT VARCHAR2(20) := 'PERSOANA_SEQ_GLOBAL';
END global_constants;
/
COMMIT;

-- multiple vizualizari si triggere de tipul instead of pentru a usura inserarea
CREATE OR REPLACE VIEW client_extins AS(
SELECT c.id_client, p.nume, p.prenume,p.email,p.varsta, c.student
FROM persoana p JOIN client c ON c.id_client = p.id_persoana
);

CREATE OR REPLACE TRIGGER client_extins_insert INSTEAD OF INSERT ON client_extins
    FOR EACH ROW
        DECLARE
            seq_count NUMBER;
            seq_not_found EXCEPTION;
            id_nr persoana.id_persoana%TYPE;
        BEGIN
            SELECT COUNT(*) 
            INTO seq_count 
            FROM user_sequences 
            WHERE sequence_name = global_constants.persoana_seq;
            IF seq_count = 0 THEN
                 RAISE seq_not_found;
            END IF;
            EXECUTE IMMEDIATE 'SELECT ' || global_constants.persoana_seq || '.NEXTVAL FROM dual' INTO id_nr;
            INSERT INTO persoana(id_persoana,nume,prenume,email,varsta) VALUES
            (id_nr, :new.nume, :new.prenume, :new.email, :new.varsta);
            INSERT INTO client VALUES 
            (id_nr,:new.student);
            insert_into_account_mapping(id_nr,'CLIENT');
            EXCEPTION
                WHEN seq_not_found THEN
                logger_utils.logger_entry('Secventa pentru persoana nu exista.','E',-20005);
            WHEN OTHERS THEN
                logger_utils.logger_entry( sqlerrm || ' code: ' || sqlcode,'E',-20010);
        END;
/

CREATE OR REPLACE VIEW angajat_extins AS (
    SELECT a.id_angajat,p.nume, p.prenume,p.email,p.varsta, 
            a.data_angajare, a.salariu, a.id_filiala, a.id_meneger
    FROM persoana p JOIN angajat a ON p.id_persoana = a.id_angajat
);

CREATE OR REPLACE TRIGGER angajat_extins_insert INSTEAD OF INSERT ON angajat_extins
    FOR EACH ROW 
        BEGIN
            INSERT INTO persoana(id_persoana,nume,prenume,email,varsta) VALUES
            (:new.id_angajat, :new.nume, :new.prenume, :new.email, :new.varsta);
            INSERT INTO angajat(id_angajat, data_angajare, salariu, id_filiala, id_meneger) VALUES
            (:new.id_angajat,:new.data_angajare, :new.salariu, :new.id_filiala, :new.id_meneger);
        EXCEPTION 
         WHEN OTHERS THEN
                logger_utils.logger_entry( sqlerrm || ' code: ' || sqlcode,'E',-20010);
        END;
/

CREATE OR REPLACE VIEW antrenor_extins AS (
    SELECT ant.id_antrenor,a.nume, a.prenume,a.email,a.varsta, 
            a.data_angajare, a.salariu, a.id_filiala, a.id_meneger,ant.studii
    FROM antrenor ant JOIN angajat_extins a ON ant.id_antrenor  = a.id_angajat
);

CREATE OR REPLACE TRIGGER antrenor_extins_insert INSTEAD OF INSERT ON antrenor_extins
    FOR EACH ROW
        DECLARE
            seq_count NUMBER;
            seq_not_found EXCEPTION;
            id_nr persoana.id_persoana%TYPE;
            id_men persoana.id_persoana%TYPE := NULL;
        BEGIN
            SELECT COUNT(*) 
            INTO seq_count 
            FROM user_sequences 
            WHERE sequence_name = global_constants.persoana_seq;
            IF seq_count = 0 THEN
                 RAISE seq_not_found;
            END IF;

            EXECUTE IMMEDIATE 'SELECT ' || global_constants.persoana_seq || '.NEXTVAL FROM dual' INTO id_nr;
            
            IF :new.id_meneger IS NOT NULL THEN
                id_men:=:new.id_meneger;
            END IF;
            
            INSERT INTO angajat_extins(id_angajat,nume, prenume,email,varsta, 
                data_angajare, salariu, id_filiala, id_meneger) VALUES
            (id_nr, :new.nume, :new.prenume,:new.email,:new.varsta, 
                :new.data_angajare, :new.salariu,:new.id_filiala, id_men);
            INSERT INTO antrenor VALUES 
            (id_nr,:new.studii);
            insert_into_account_mapping(id_nr,'ANTRENOR');
            EXCEPTION
                WHEN seq_not_found THEN
                logger_utils.logger_entry('Secventa pentru persoana nu exista.','E',-20005);
            WHEN OTHERS THEN
                dbms_output.put_line(sqlerrm);
                logger_utils.logger_entry( sqlerrm || ' code: ' || sqlcode,'E',-20010);
        END;
/

CREATE OR REPLACE VIEW receptionist_extins AS (
    SELECT r.id_receptionist,a.nume, a.prenume,a.email,a.varsta, 
            a.data_angajare, a.salariu, a.id_filiala, a.id_meneger,r.program_complet
    FROM receptionist r JOIN angajat_extins a ON r.id_receptionist  = a.id_angajat
);
/
CREATE OR REPLACE TRIGGER receptionist_extins_insert INSTEAD OF INSERT ON receptionist_extins
    FOR EACH ROW
        DECLARE
            seq_count NUMBER;
            seq_not_found EXCEPTION;
            id_nr persoana.id_persoana%TYPE;
            id_men persoana.id_persoana%TYPE := NULL;
        BEGIN
            SELECT COUNT(*) 
            INTO seq_count 
            FROM user_sequences 
            WHERE sequence_name = global_constants.persoana_seq;
            IF seq_count = 0 THEN
                 RAISE seq_not_found;
            END IF;

            EXECUTE IMMEDIATE 'SELECT ' || global_constants.persoana_seq || '.NEXTVAL FROM dual' INTO id_nr;
            
            IF :new.id_meneger IS NOT NULL THEN
                id_men:=:new.id_meneger;
            END IF;
            
            INSERT INTO angajat_extins(id_angajat,nume, prenume,email,varsta, 
                data_angajare, salariu, id_filiala, id_meneger) VALUES
            (id_nr, :new.nume, :new.prenume,:new.email,:new.varsta, 
                :new.data_angajare, :new.salariu,:new.id_filiala, id_men);
            INSERT INTO receptionist(id_receptionist,program_complet) VALUES 
            (id_nr,:new.program_complet);
            insert_into_account_mapping(id_nr,'RECEPTIONIST');
            EXCEPTION
                WHEN seq_not_found THEN
                    logger_utils.logger_entry('Secventa pentru persoana nu exista.','E',-20005);
            WHEN OTHERS THEN
                logger_utils.logger_entry( sqlerrm || ' code: ' || sqlcode,'E',-20010);
        END;

/

EXEC sequence_utils.create_sequence_trigger('Adresa');

INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Bd. Lujerului',
           33,
           'Bucuresti',
           'Bucuresti',
           '405985' );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Bd. Tineretului',
           21,
           'Bucuresti',
           'Bucuresti',
           '582155' );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Bd. Bucuresti',
           11,
           'Brasov',
           'Brasov',
           '123456' );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Bd. Republicii',
           3,
           'Ploiesti',
           'Prahova',
           55231 );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Str Parangului',
           100,
           'Craiova',
           'Dolj',
           7742101 );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Matei Basarab',
           18,
           'Bucuresti',
           'Bucuresti',
           665842 );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Unirii',
           33,
           'Bucuresti',
           'Bucuresti',
           868605 );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Mihai Bravu',
           22,
           'Bucuresti',
           'Bucuresti',
           78592 );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Frigului',
           77,
           'Brasov',
           'Brasov',
           888801 );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Calea Traian',
           99,
           'Craiova',
           'Dolj',
           224402 );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Calea Serban Voda',
           232,
           'Bucuresti',
           'Bucuresti',
           40578 );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Viilor',
           12,
           'Bucuresti',
           'Bucuresti',
           232454 );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Alea Tomis',
           36,
           'Arad',
           'Arad',
           111454 );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Anastasie Panu',
           56,
           'Iasi',
           'Iasi',
           999454 );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Aleea Tomis',
           1,
           'Dej',
           'Cluj',
           123454 );
INSERT INTO adresa (
   strada,
   numar,
   oras,
   judet,
   cod_postal
) VALUES ( 'Tiberiu Popoviciu ',
           22,
           'Cluj',
           'Cluj',
           538454 );

EXEC sequence_utils.create_sequence_trigger('Filiala');

INSERT INTO filiala (
   nume,
   data_deschidere,
   id_adresa
) VALUES ( 'Lujerului',
           TO_DATE('21-JAN-2014','DD-MON-YYYY'),
           1 );
INSERT INTO filiala (
   nume,
   data_deschidere,
   id_adresa
) VALUES ( 'Tineretului',
           TO_DATE('21-FEB-2000','DD-MON-YYYY'),
           2 );
INSERT INTO filiala (
   nume,
   data_deschidere,
   id_adresa
) VALUES ( 'Brasov',
           TO_DATE('14-FEB-2010','DD-MON-YYYY'),
           3 );
INSERT INTO filiala (
   nume,
   data_deschidere,
   id_adresa
) VALUES ( 'Ploiesti',
           TO_DATE('11-DEC-1999','DD-MON-YYYY'),
           4 );
INSERT INTO filiala (
   nume,
   data_deschidere,
   id_adresa
) VALUES ( 'Craiova',
           TO_DATE('01-NOV-1995','DD-MON-YYYY'),
           5 );
INSERT INTO filiala (
   nume,
   data_deschidere,
   id_adresa
) VALUES ( 'Filiala Sector 4',
           TO_DATE('01-FEB-1999','DD-MON-YYYY'),
           11 );
INSERT INTO filiala (
   nume,
   data_deschidere,
   id_adresa
) VALUES ( 'Filiala Sector 3',
           TO_DATE('15-MAR-2005','DD-MON-YYYY'),
           6 );
INSERT INTO filiala (
   nume,
   data_deschidere,
   id_adresa
) VALUES ( 'Sediul Unirii',
           TO_DATE('01-MAY-2000','DD-MON-YYYY'),
           7 );
INSERT INTO filiala (
   nume,
   data_deschidere,
   id_adresa
) VALUES ( 'Filiala Viilor',
           TO_DATE('01-APR-2012','DD-MON-YYYY'),
           12 );

EXEC sequence_utils.create_sequence(global_constants.persoana_seq);

SELECT *
  FROM account_mapping;

INSERT INTO antrenor_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   studii,
   id_meneger
) VALUES ( 'Popescu',
           'Ion',
           'popescuI@yahoo.com',
           30,
           TO_DATE('11-JAN-2020','DD-MON-YYYY'),
           1500,
           1,
           'Liceul Sportiv 1 Bucuresti',
           NULL );
INSERT INTO antrenor_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   studii,
   id_meneger
) VALUES ( 'Popescu',
           'George',
           'popescuG@yahoo.com',
           31,
           TO_DATE('01-FEB-2015','DD-MON-YYYY'),
           2100,
           1,
           'Liceul Sportiv Breaza',
           NULL );
INSERT INTO antrenor_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   studii,
   id_meneger
) VALUES ( 'Ionescu',
           'Andrei',
           'ionescuA@yahoo.com',
           21,
           TO_DATE('20-MAR-2017','DD-MON-YYYY'),
           2200,
           1,
           'Facultate Kinetoterapie',
           NULL );
INSERT INTO antrenor_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   studii,
   id_meneger
) VALUES ( 'Ionescu',
           'Ion',
           'ionescuI@yahoo.com',
           21,
           TO_DATE('01-FEB-2015','DD-MON-YYYY'),
           2000,
           1,
           'IEFS',
           NULL );
INSERT INTO antrenor_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   studii,
   id_meneger
) VALUES ( 'Mihai',
           'Marcel',
           'mihaimarcel@yahoo.com',
           22,
           TO_DATE('01-MAY-2021','DD-MON-YYYY'),
           2600,
           1,
           'Facultate Kinetoterapie',
           NULL );
INSERT INTO antrenor_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   studii,
   id_meneger
) VALUES ( 'Aioanei',
           'Andrei',
           'aioaneiandrei@yahoo.com',
           30,
           TO_DATE('01-JAN-2010','DD-MON-YYYY'),
           5000,
           1,
           'IEFS',
           NULL );
INSERT INTO antrenor_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   studii,
   id_meneger
) VALUES ( 'Stancioiu',
           'Razvan',
           'stancioiurazvan@yahoo.com',
           28,
           TO_DATE('15-APR-2005','DD-MON-YYYY'),
           3500,
           1,
           'Curs FRCF',
           NULL );

SELECT *
  FROM antrenor_extins;



INSERT INTO receptionist_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   program_complet,
   id_meneger
) VALUES ( 'Dinca',
           'Antoaneta',
           'dincaa@yahoo.com',
           22,
           TO_DATE('01-JUN-2001','DD-MON-YYYY'),
           2600,
           1,
           'Y',
           NULL );
INSERT INTO receptionist_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   program_complet,
   id_meneger
) VALUES ( 'Vasilescu',
           'Marcel',
           'vasilescum@yahoo.com',
           22,
           TO_DATE('01-JUL-2019','DD-MON-YYYY'),
           1300,
           1,
           'N',
           NULL );
INSERT INTO receptionist_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   program_complet,
   id_meneger
) VALUES ( 'Popescu',
           'George',
           'popescug@yahoo.com',
           22,
           TO_DATE('01-JAN-2018','DD-MON-YYYY'),
           2300,
           1,
           'Y',
           NULL );
INSERT INTO receptionist_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   program_complet,
   id_meneger
) VALUES ( 'Preda',
           'Marina',
           'predam@yahoo.com',
           27,
           TO_DATE('01-FEB-2017','DD-MON-YYYY'),
           2500,
           1,
           'Y',
           NULL );
INSERT INTO receptionist_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   program_complet,
   id_meneger
) VALUES ( 'Dumitrescu',
           'Anca',
           'dumitrescua@yahoo.com',
           22,
           TO_DATE('01-MAR-2015','DD-MON-YYYY'),
           2750,
           1,
           'Y',
           NULL );
INSERT INTO receptionist_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   program_complet,
   id_meneger
) VALUES ( 'Marinica',
           'Ion',
           'marinicaion@yahoo.com',
           60,
           TO_DATE('01-JUN-2016','DD-MON-YYYY'),
           1700,
           1,
           'N',
           NULL );
INSERT INTO receptionist_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   program_complet,
   id_meneger
) VALUES ( 'Dinca',
           'Ion',
           'dincaion@yahoo.com',
           45,
           TO_DATE('01-APR-2021','DD-MON-YYYY'),
           1700,
           9,
           'N',
           NULL );
INSERT INTO receptionist_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   program_complet,
   id_meneger
) VALUES ( 'Marinescu',
           'Ion',
           'marinescuion@yahoo.com',
           23,
           TO_DATE('01-JUN-2022','DD-MON-YYYY'),
           2900,
           9,
           'Y',
           NULL );
INSERT INTO receptionist_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   program_complet,
   id_meneger
) VALUES ( 'Ignat',
           'Ana',
           'ignatana@yahoo.com',
           20,
           TO_DATE('01-FEB-2023','DD-MON-YYYY'),
           2600,
           5,
           'Y',
           NULL );
INSERT INTO receptionist_extins (
   nume,
   prenume,
   email,
   varsta,
   data_angajare,
   salariu,
   id_filiala,
   program_complet,
   id_meneger
) VALUES ( 'Dancescu',
           'Sorin',
           'dancescusorin@yahoo.com',
           35,
           TO_DATE('01-FEB-2020','DD-MON-YYYY'),
           3000,
           4,
           'Y',
           NULL );

SELECT *
  FROM account_mapping;

UPDATE angajat
   SET
   id_meneger = NULL
 WHERE id_angajat = 7;
UPDATE angajat
   SET
   id_meneger = 7
 WHERE id_angajat != 7
   AND id_filiala = 1;
UPDATE angajat
   SET
   id_meneger = 14
 WHERE id_angajat = 15;
SELECT *
  FROM angajat;

INSERT INTO client_extins (
   nume,
   prenume,
   email,
   varsta,
   student
) VALUES ( 'Vasilescu',
           'Razvan',
           'vasilescurazvan@yahoo.com',
           21,
           'N' );
INSERT INTO client_extins (
   nume,
   prenume,
   email,
   varsta,
   student
) VALUES ( 'Ionescu',
           'Andrei',
           'ionescua@yahoo.com',
           19,
           'Y' );
INSERT INTO client_extins (
   nume,
   prenume,
   email,
   varsta,
   student
) VALUES ( 'Tanasescu',
           'Ion',
           'tanasescui@yahoo.com',
           19,
           'Y' );
INSERT INTO client_extins (
   nume,
   prenume,
   email,
   varsta,
   student
) VALUES ( 'Ionescu',
           'Vasile',
           'ionescuv@yahoo.com',
           32,
           'N' );
INSERT INTO client_extins (
   nume,
   prenume,
   email,
   varsta,
   student
) VALUES ( 'Tanasescu',
           'Anca',
           'tanasescua@yahoo.com',
           50,
           'N' );
INSERT INTO client_extins (
   nume,
   prenume,
   email,
   varsta,
   student
) VALUES ( 'Marinecu',
           'Vlad',
           'vladutz@yahoo.com',
           27,
           'N' );
INSERT INTO client_extins (
   nume,
   prenume,
   email,
   varsta,
   student
) VALUES ( 'Dobrescu',
           'Marcel',
           'dorescu_mar@yahoo.com',
           37,
           'N' );
INSERT INTO client_extins (
   nume,
   prenume,
   email,
   varsta,
   student
) VALUES ( 'Marinica',
           'Stefan',
           'marinicastefan@yahoo.com',
           35,
           'N' );
INSERT INTO client_extins (
   nume,
   prenume,
   email,
   varsta,
   student
) VALUES ( 'Marinica',
           'Bogdan',
           'marinicabogdan@yahoo.com',
           22,
           'Y' );
INSERT INTO client_extins (
   nume,
   prenume,
   email,
   varsta,
   student
) VALUES ( 'Stefanescu',
           'Ana',
           'stefanescuana@yahoo.com',
           19,
           'Y' );

SELECT *
  FROM account_mapping;

           
EXEC sequence_utils.create_sequence_trigger('Furnizor');

INSERT INTO furnizor (
   nume,
   cod_fiscal,
   id_adresa
) VALUES ( 'MyProtein',
           '8859692',
           1 );
INSERT INTO furnizor (
   nume,
   cod_fiscal,
   id_adresa
) VALUES ( 'Gym Beam',
           '9859692',
           2 );
INSERT INTO furnizor (
   nume,
   cod_fiscal,
   id_adresa
) VALUES ( 'Redis',
           '7859692',
           3 );
INSERT INTO furnizor (
   nume,
   cod_fiscal,
   id_adresa
) VALUES ( 'Decathlon',
           '1859692',
           4 );
INSERT INTO furnizor (
   nume,
   cod_fiscal,
   id_adresa
) VALUES ( 'Vexio',
           '9959692',
           5 );
INSERT INTO furnizor (
   nume,
   cod_fiscal,
   id_adresa
) VALUES ( 'BEWIT',
           '9059692',
           13 );
INSERT INTO furnizor (
   nume,
   cod_fiscal,
   id_adresa
) VALUES ( 'BODY NEWLINE CONCEPT',
           '48393052',
           14 );
INSERT INTO furnizor (
   nume,
   cod_fiscal,
   id_adresa
) VALUES ( 'Pro Nutrition',
           '12420890',
           15 );
INSERT INTO furnizor (
   nume,
   cod_fiscal,
   id_adresa
) VALUES ( 'Arena Systems',
           '32120890',
           16 );

EXEC sequence_utils.create_sequence_trigger('Supliment');

INSERT INTO supliment (
   nume,
   descriere,
   calorii,
   pret
) VALUES ( 'Whey Protein',
           'Zer premium cu 21 g de proteine per portie.',
           '430',
           '100' );
INSERT INTO supliment (
   nume,
   descriere,
   calorii,
   pret
) VALUES ( 'Izolat proteic din soia',
           'O alegere excelenta pentru vegetarieni si vegani.',
           300,
           150 );
INSERT INTO supliment (
   nume,
   descriere,
   calorii,
   pret
) VALUES ( 'Vitafiber',
           'Derivat din amidon de porumb nemodificat genetic.',
           150,
           210 );
INSERT INTO supliment (
   nume,
   descriere,
   calorii,
   pret
) VALUES ( 'Unt de arahide',
           'Amestec pudra cu 70% mai putine grasimi.',
           300,
           90 );
INSERT INTO supliment (
   nume,
   descriere,
   calorii,
   pret
) VALUES ( 'Impact Diet Lean',
           'Amestec fibre sub forma de fructo-oligozaharide.',
           250,
           200 );
INSERT INTO supliment (
   nume,
   descriere,
   calorii,
   pret
) VALUES ( 'Muscle Mass - pachet premium',
           'Pachet complet: gainer de top + preworkout Complete Workout + formula pe baza de creatina.',
           1000,
           334 );
INSERT INTO supliment (
   nume,
   descriere,
   calorii,
   pret
) VALUES ( 'X-plode plicuri',
           'Imbunatateste performanta fizica, regenerarea si volumizarea celulelor musculare.',
           80,
           56 );
INSERT INTO supliment (
   nume,
   descriere,
   calorii,
   pret
) VALUES ( 'Essential Amino Acids',
           'Con?ine un mix de 8 aminoacizi esen?iali.',
           30,
           54 );
INSERT INTO supliment (
   nume,
   descriere,
   calorii,
   pret
) VALUES ( 'Jeleuri cu arom? de otet de cidru de mere',
           'Ajuta la protejarea celulelor impotriva stresului oxidativ.',
           10,
           79 );
INSERT INTO supliment (
   nume,
   descriere,
   calorii,
   pret
) VALUES ( 'Jeleuri pre-antrenament',
           'Un mod simplu de a va pregati mintal si fizic pentru fiecare antrenament.',
           15,
           129 );

INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 1,
           1,
           10 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 3,
           2,
           10 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 1,
           3,
           20 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 3,
           4,
           50 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 1,
           5,
           15 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 2,
           1,
           10 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 2,
           5,
           20 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 2,
           3,
           90 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 3,
           3,
           70 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 8,
           6,
           5 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 8,
           7,
           15 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 8,
           8,
           20 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 8,
           9,
           15 );
INSERT INTO aprovizionare (
   id_furnizor,
   id_supliment,
   cantitate
) VALUES ( 8,
           10,
           20 );

EXEC sequence_utils.create_sequence_trigger('Echipament');

INSERT INTO echipament (
   nume,
   data_instalare,
   data_revizie,
   id_filiala,
   id_furnizor
) VALUES ( 'Leg Press',
           TO_DATE('20-MAY-2020','DD-MON-YYYY'),
           TO_DATE('20-MAY-2021','DD-MON-YYYY'),
           1,
           5 );
INSERT INTO echipament (
   nume,
   data_instalare,
   data_revizie,
   id_filiala,
   id_furnizor
) VALUES ( 'Chest Press',
           TO_DATE('20-JUN-2021','DD-MON-YYYY'),
           TO_DATE('20-JUN-2021','DD-MON-YYYY'),
           1,
           5 );
INSERT INTO echipament (
   nume,
   data_instalare,
   data_revizie,
   id_filiala,
   id_furnizor
) VALUES ( 'Peck Deck',
           TO_DATE('01-JAN-2019','DD-MON-YYYY'),
           TO_DATE('01-JAN-2021','DD-MON-YYYY'),
           2,
           4 );
INSERT INTO echipament (
   nume,
   data_instalare,
   data_revizie,
   id_filiala,
   id_furnizor
) VALUES ( 'Preacher Curl',
           TO_DATE('28-APR-2020','DD-MON-YYYY'),
           TO_DATE('28-APR-2021','DD-MON-YYYY'),
           3,
           3 );
INSERT INTO echipament (
   nume,
   data_instalare,
   data_revizie,
   id_filiala,
   id_furnizor
) VALUES ( 'Calves Raises',
           TO_DATE('20-APR-2021','DD-MON-YYYY'),
           TO_DATE('20-APR-2022','DD-MON-YYYY'),
           4,
           3 );
INSERT INTO echipament (
   nume,
   data_instalare,
   data_revizie,
   id_filiala,
   id_furnizor
) VALUES ( 'Lateral Raises',
           TO_DATE('10-APR-2021','DD-MON-YYYY'),
           TO_DATE('10-APR-2022','DD-MON-YYYY'),
           4,
           5 );
INSERT INTO echipament (
   nume,
   data_instalare,
   data_revizie,
   id_filiala,
   id_furnizor
) VALUES ( 'Frontal Raises',
           TO_DATE('20-MAR-2020','DD-MON-YYYY'),
           TO_DATE('20-MAR-2022','DD-MON-YYYY'),
           4,
           5 );
INSERT INTO echipament (
   nume,
   data_instalare,
   data_revizie,
   id_filiala,
   id_furnizor
) VALUES ( 'Sistem de catarare cu prindere pe perete',
           TO_DATE('30-SEP-2022','DD-MON-YYYY'),
           TO_DATE('30-SEP-2023','DD-MON-YYYY'),
           8,
           9 );
INSERT INTO echipament (
   nume,
   data_instalare,
   data_revizie,
   id_filiala,
   id_furnizor
) VALUES ( 'Semisfera de echilibru cu manere',
           TO_DATE('30-JUN-2022','DD-MON-YYYY'),
           TO_DATE('30-JUN-2023','DD-MON-YYYY'),
           8,
           9 );
INSERT INTO echipament (
   nume,
   data_instalare,
   data_revizie,
   id_filiala,
   id_furnizor
) VALUES ( 'Banca de gimnastica tip Pivetta',
           TO_DATE('01-JUN-2021','DD-MON-YYYY'),
           TO_DATE('01-JUN-2022','DD-MON-YYYY'),
           3,
           9 );
INSERT INTO echipament (
   nume,
   data_instalare,
   data_revizie,
   id_filiala,
   id_furnizor
) VALUES ( 'Coarda sarituri cu maner din lemn',
           TO_DATE('01-JAN-2022','DD-MON-YYYY'),
           TO_DATE('01-JUN-2023','DD-MON-YYYY'),
           3,
           9 );
INSERT INTO echipament (
   nume,
   data_instalare,
   data_revizie,
   id_filiala,
   id_furnizor
) VALUES ( 'Plan propioceptiv rotativ',
           TO_DATE('01-JUN-2023','DD-MON-YYYY'),
           TO_DATE('01-SEP-2023','DD-MON-YYYY'),
           3,
           9 );

EXEC sequence_utils.create_sequence_trigger('Comanda');

INSERT INTO comanda (
   id_client,
   id_receptionist,
   observatii,
   data_comandare
) VALUES ( 18,
           8,
           'Urgenta',
           TO_DATE('22-FEB-2022','DD-MON-YYYY') );
INSERT INTO comanda (
   id_client,
   id_receptionist,
   observatii,
   data_comandare
) VALUES ( 18,
           8,
           'Preluare dupa ora 17',
           TO_DATE('11-MAR-2022','DD-MON-YYYY') );
INSERT INTO comanda (
   id_client,
   id_receptionist,
   observatii,
   data_comandare
) VALUES ( 20,
           9,
           NULL,
           TO_DATE('01-APR-2022','DD-MON-YYYY') );
INSERT INTO comanda (
   id_client,
   id_receptionist,
   observatii,
   data_comandare
) VALUES ( 20,
           9,
           NULL,
           TO_DATE('02-APR-2022','DD-MON-YYYY') );
INSERT INTO comanda (
   id_client,
   id_receptionist,
   observatii,
   data_comandare
) VALUES ( 22,
           9,
           NULL,
           TO_DATE('22-APR-2022','DD-MON-YYYY') );
INSERT INTO comanda (
   id_client,
   id_receptionist,
   observatii,
   data_comandare
) VALUES ( 26,
           16,
           'In curs de achitare',
           TO_DATE('01-SEP-2023','DD-MON-YYYY') );
INSERT INTO comanda (
   id_client,
   id_receptionist,
   observatii,
   data_comandare
) VALUES ( 27,
           17,
           'Platita',
           TO_DATE('01-OCT-2023','DD-MON-YYYY') );
INSERT INTO comanda (
   id_client,
   id_receptionist,
   observatii,
   data_comandare
) VALUES ( 27,
           10,
           'Platita',
           TO_DATE('11-OCT-2023','DD-MON-YYYY') );
INSERT INTO comanda (
   id_client,
   id_receptionist,
   observatii,
   data_comandare
) VALUES ( 27,
           11,
           'Platita',
           TO_DATE('21-OCT-2023','DD-MON-YYYY') );
INSERT INTO comanda (
   id_client,
   id_receptionist,
   observatii,
   data_comandare
) VALUES ( 27,
           12,
           'Platita',
           TO_DATE('22-OCT-2023','DD-MON-YYYY') );
INSERT INTO comanda (
   id_client,
   id_receptionist,
   observatii,
   data_comandare
) VALUES ( 27,
           13,
           'Platita',
           TO_DATE('22-SEP-2022','DD-MON-YYYY') );


INSERT INTO tip_abonament (
   nume_tip,
   pret
) VALUES ( 'lunar',
           100 );
INSERT INTO tip_abonament (
   nume_tip,
   pret
) VALUES ( 'trimestrial',
           280 );
INSERT INTO tip_abonament (
   nume_tip,
   pret
) VALUES ( 'bianual',
           550 );
INSERT INTO tip_abonament (
   nume_tip,
   pret
) VALUES ( 'anual',
           800 );
INSERT INTO tip_abonament (
   nume_tip,
   pret
) VALUES ( 'extins',
           1500 );

EXEC sequence_utils.create_sequence_trigger('Abonament');
INSERT INTO abonament (
   nume_tip,
   id_client,
   data_inregistrare
) VALUES ( 'lunar',
           18,
           '01-APR-22' );
INSERT INTO abonament (
   nume_tip,
   id_client,
   data_inregistrare
) VALUES ( 'trimestrial',
           19,
           '01-APR-21' );
INSERT INTO abonament (
   nume_tip,
   id_client,
   data_inregistrare
) VALUES ( 'bianual',
           20,
           '01-FEB-22' );
INSERT INTO abonament (
   nume_tip,
   id_client,
   data_inregistrare
) VALUES ( 'extins',
           21,
           '01-SEP-21' );
INSERT INTO abonament (
   nume_tip,
   id_client,
   data_inregistrare
) VALUES ( 'anual',
           22,
           '01-NOV-20' );
INSERT INTO abonament (
   nume_tip,
   id_client,
   data_inregistrare
) VALUES ( 'anual',
           23,
           '01-NOV-22' );
INSERT INTO abonament (
   nume_tip,
   id_client,
   data_inregistrare
) VALUES ( 'anual',
           25,
           '01-DEC-22' );
INSERT INTO abonament (
   nume_tip,
   id_client,
   data_inregistrare
) VALUES ( 'bianual',
           26,
           '15-JUL-23' );
INSERT INTO abonament (
   nume_tip,
   id_client,
   data_inregistrare
) VALUES ( 'extins',
           27,
           '01-JAN-22' );

DECLARE
   nr NUMBER;
BEGIN
   FOR i IN 1..22 LOOP
      SELECT round(dbms_random.value(
         1000000000,
         9999999999
      ))
        INTO nr
        FROM dual;
      IF i <= 10 THEN
         INSERT INTO telefon (
            tip,
            numar,
            id_persoana
         ) VALUES ( 'serviciu',
                    nr,
                    i );
      ELSE
         INSERT INTO telefon (
            tip,
            numar,
            id_persoana
         ) VALUES ( 'personal',
                    nr,
                    i );
      END IF;
   END LOOP;
END;
/

INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 1,
           1,
           2 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 1,
           2,
           1 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 1,
           3,
           4 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 1,
           4,
           3 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 1,
           5,
           7 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 2,
           1,
           2 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 3,
           1,
           2 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 3,
           2,
           1 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 3,
           4,
           1 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 3,
           5,
           5 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 6,
           4,
           3 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 6,
           3,
           1 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 6,
           7,
           1 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 6,
           8,
           2 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 6,
           2,
           1 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 7,
           1,
           4 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 7,
           3,
           2 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 7,
           7,
           1 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 7,
           8,
           5 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 7,
           9,
           2 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 7,
           10,
           1 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 8,
           7,
           1 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 9,
           8,
           5 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 10,
           9,
           2 );
INSERT INTO informatii_comanda (
   id_comanda,
   id_supliment,
   cantitate
) VALUES ( 11,
           10,
           1 );
           
commit;




