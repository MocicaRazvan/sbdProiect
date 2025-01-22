--drop table persoana_mask cascade constraints;
--drop table angajat_mask cascade constraints;
--drop table antrenor_mask cascade constraints;
--drop table receptionist_mask cascade constraints;
--drop table client_mask cascade constraints;

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM USER_CONSTRAINTS
WHERE TABLE_NAME = upper('angajat_mask');

select * from persoana_mask;

select * from angajat_mask
join persoana_mask 
on id_angajat=id_persoana;


