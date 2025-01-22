set serveroutput on;
-- apel onest
exec bro_antrenor1.get_program_full(1,'may');

--apel care intoarce toate programele cu echipamente, subminand filtrarea
exec bro_antrenor1.get_program_full(1,'may%'' OR 1=1 --');

--apel care intorace toate antrenamentele, desi clientul nu are drept de select pe tabela antrenament

select * from bro_antrenor1.antrenament;

exec bro_antrenor1.get_program_full(1, 'may%'' UNION SELECT ID_ECHIPAMENT, ''Injectat'', SYSDATE, SYSDATE, ID_CLIENT, DURATA, ID_PROGRAM, ''Injectat Desc'', ''Tip injectat'' FROM ANTRENAMENT --');

begin
     bro_antrenor1.get_program_full(1, 'may%'' UNION SELECT ID_ECHIPAMENT, ''Injectat'', 
                                     SYSDATE, SYSDATE, ID_CLIENT, DURATA, ID_PROGRAM, 
                                     ''Injectat Desc'', ''Tip injectat'' FROM ANTRENAMENT --');
end;
/

-- repetam cu safe 

-- apel onest
exec bro_antrenor1.get_program_full_safe(1,'may');

--apel care intoarce toate programele cu echipamente, subminand filtrarea
exec bro_antrenor1.get_program_full_safe(1,'may%'' OR 1=1 --');


exec bro_antrenor1.get_program_full_safe(1, 'may%'' UNION SELECT ID_ECHIPAMENT, ''Injectat'', SYSDATE, SYSDATE, ID_CLIENT, DURATA, ID_PROGRAM, ''Injectat Desc'', ''Tip injectat'' FROM ANTRENAMENT --');


begin
     bro_antrenor1.get_program_full_safe(1, 'may%'' UNION SELECT ID_ECHIPAMENT, ''Injectat'', 
                                     SYSDATE, SYSDATE, ID_CLIENT, DURATA, ID_PROGRAM, 
                                     ''Injectat Desc'', ''Tip injectat'' FROM ANTRENAMENT --');
end;
/