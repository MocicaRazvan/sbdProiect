-- Inserare date in tabelele din baza de date pentru antrenor
insert into program (
   descriere,
   tip_program
) values ( 'Push, Pull Legs Light, for beginners',
           'MASS' );
insert into program (
   descriere,
   tip_program
) values ( 'Push, Pull Legs Medium',
           'MASS' );
insert into program (
   descriere,
   tip_program
) values ( 'Push, Pull Legs Hard',
           'MASS' );
insert into program (
   descriere,
   tip_program
) values ( 'Full Body Variant Light',
           'CARDIO' );
insert into program (
   descriere,
   tip_program
) values ( 'Body Recovery Variant Light',
           'RECOVERY' );
insert into program (
   descriere,
   tip_program
) values ( 'Body Bluster Variant Blusting',
           'RECOVERY' );
insert into program (
   descriere,
   tip_program
) values ( 'Cardio Workout for Weight Loss',
           'CARDIO' );
insert into program (
   descriere,
   tip_program
) values ( 'Cardio workout for beginners',
           'CARDIO' );
insert into program (
   descriere,
   tip_program
) values ( 'Cardio workout for older adults',
           'CARDIO' );


insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 20,
           1,
           1,
           18 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 11,
           1,
           2,
           18 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 11,
           4,
           1,
           18 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 10,
           4,
           2,
           18 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 5,
           1,
           1,
           19 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 25,
           1,
           2,
           19 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 32,
           1,
           3,
           19 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 10,
           5,
           2,
           19 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 5,
           4,
           3,
           20 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 25,
           4,
           4,
           20 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 12,
           4,
           5,
           21 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 42,
           4,
           2,
           21 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 20,
           4,
           5,
           22 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 10,
           4,
           4,
           22 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 10,
           7,
           8,
           25 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 20,
           7,
           9,
           25 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 10,
           7,
           10,
           25 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 10,
           8,
           3,
           26 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 20,
           8,
           4,
           19 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 10,
           8,
           5,
           19 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 10,
           8,
           12,
           27 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 20,
           8,
           9,
           27 );
insert into antrenament (
   durata,
   id_program,
   id_echipament,
   id_client
) values ( 10,
           8,
           11,
           27 );

commit;
