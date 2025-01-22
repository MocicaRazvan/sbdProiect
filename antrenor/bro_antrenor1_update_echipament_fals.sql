begin
   for i in 1..20 loop
      update echipament o
         set
         data_revizie = (
            select data_revizie
              from echipament i
             where i.id_echipament = o.id_echipament
         );
         commit;
   end loop;
end;
/

