CREATE FUNCTION pnu_generate(sgg_cd double precision, atch_bjd_cd double precision, atch_bun double precision, atch_ji double precision) RETURNS text
    AS 'select format( ''%s%s1%s%s'', text($1), text($2), lpad(text($3),4,''0''), lpad(text($4),4,''0'') )'
    LANGUAGE SQL
    IMMUTABLE
    RETURNS NULL ON NULL INPUT;


create extension plpython3u;

--python ver
create or replace FUNCTION pnu_generate_py(
sgg_cd double precision, 
atch_bjd_cd double precision, 
atch_bun double precision, 
atch_ji double precision, 
daeji_type integer) 
RETURNS text
AS $$
pnu_gen = '%d%d%d%04d%04d'%( int(sgg_cd), int(atch_bjd_cd), daeji_type, int(atch_bun), int(atch_ji) )
if len(pnu_gen)==19:
    return pnu_gen
else:
    return None
$$ LANGUAGE plpython3u
IMMUTABLE
RETURNS NULL ON NULL INPUT;

select * from 
(select 
bbg.pnu, 
(select array_agg(bpg.mgm_bldrgst_pk) from building_pyojebu_gn bpg where bpg.pnu=bbg.pnu),
bbg.mgm_bldrgst_pk,
bbg.adr_bsc, 
bbg.atch_sgg_cd,
bbg.atch_bjd_cd,
bbg.atch_etc_bunji_nm,
bbg.atch_bun, 
bbg.atch_ji, 
bbg.atch_daeji_cd,
rgst_typ_nm,
pnu_generate_py(atch_sgg_cd, atch_bjd_cd, atch_bun, atch_ji, 1) pnu_gen, 
(case 
when ((select count(*) from lot_information_gn lig where lig.pnu = pnu_generate_py(atch_sgg_cd, atch_bjd_cd, atch_bun, atch_ji, 1)) > 0) 
then 1 
when ((select count(*) from lot_information_gn lig where lig.pnu = pnu_generate_py(atch_sgg_cd, atch_bjd_cd, atch_bun, atch_ji, 2)) > 0)
then 1
else (select count(*) from lot_information_gn lig where lig.pnu = pnu_generate_py(atch_sgg_cd, atch_bjd_cd, atch_bun, atch_ji, 0))
end) cnt 
from building_busok_gn bbg 
where bbg.pnu in (select pnu from building_pyojebu_gn bpg where bpg.etclot_cnt > 0) ) tt where cnt=0; --pnu_gen isnull;

select * from building_busok_gn where mgm_bldrgst_pk='11680-403';

select * from 
(select 
bbg.pnu, 
bbg.adr_bsc, 
bbg.atch_bun, 
bbg.atch_ji, 
bbg.atch_daeji_cd,
--format('%s%s1%s%s', text(atch_sgg_cd), text(atch_bjd_cd), lpad(text(atch_bun),4,'0'), lpad(text(atch_ji),4,'0')) pnu_gen,
pnu_generate_py(atch_sgg_cd, atch_bjd_cd, atch_bun, atch_ji, 1), 
(select count(*) from lot_information_gn lig where lig.pnu = pnu_generate_py(atch_sgg_cd, atch_bjd_cd, atch_bun, atch_ji, 1)) cnt 
from building_busok_gn bbg 
where bbg.pnu in (select pnu from building_pyojebu_gn bpg where bpg.etclot_cnt > 0) ) tt 
where cnt=1;
