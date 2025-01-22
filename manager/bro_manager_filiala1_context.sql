select sys_context(
      'bro_context',
      'id_filiala'
   ) from dual;
   
   
select distinct id_filiala from bro_admin.echipament;

update bro_admin.echipament o
   set
   nume = (
      select nume
        from bro_admin.echipament i
       where i.id_echipament = o.id_echipament
   )
 where o.id_filiala = 1;
 
update bro_admin.echipament o
   set
   nume = (
      select nume
        from bro_admin.echipament i
       where i.id_echipament = o.id_echipament
   )
 where o.id_filiala != 1;
 
 update bro_admin.echipament o
   set
   nume = (
      select nume
        from bro_admin.echipament i
       where i.id_echipament = o.id_echipament
   );
   
   
select count(*)
  from bro_admin.audit_echipament a
  where a.old_values.id_filiala=1 or  a.old_values.id_filiala=1;
  
select count(*)
  from bro_admin.audit_echipament a
  where a.old_values.id_filiala!=1 and  a.old_values.id_filiala!=1;