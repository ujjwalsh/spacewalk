alter trigger rhn_errata_file_mod_trig disable;

declare
 md5_id number;
begin
  select id
    into md5_id
    from rhnChecksumType
   where label = 'md5';

  insert into rhnChecksum (id, checksum_type_id, checksum)
         (select rhnChecksum_seq.nextval, md5_id, csum
            from (select distinct md5sum as csum
                    from rhnErrataFile
                   minus
                  select checksum as csum
                    from rhnChecksum
                   where checksum_type_id = md5_id));
  commit;
  update rhnErrataFile p
     set checksum_id = (select id
                          from rhnChecksum c
                         where checksum_type_id = md5_id
                           and p.md5sum =  c.checksum);
  commit;
end;
/

alter trigger rhn_errata_file_mod_trig enable;
