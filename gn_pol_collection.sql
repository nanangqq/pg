CREATE FUNCTION pnu_generate(sgg_cd double precision, atch_bjd_cd double precision, atch_bun double precision, atch_ji double precision) RETURNS text
    AS 'select format( ''%s%s1%s%s'', text($1), text($2), lpad(text($3),4,''0''), lpad(text($4),4,''0'') )'
    LANGUAGE SQL
    IMMUTABLE
    RETURNS NULL ON NULL INPUT;


create extension plpython3u;

--python ver 0215
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

--python ver2 0216
create or replace FUNCTION pnu_generate_py(
atch_sgg_cd double precision, 
atch_bjd_cd double precision, 
atch_bun double precision,
atch_ji double precision, 
--daeji_type integer,
atch_daeji_cd text,
adr_bsc text,
atch_etc_bunji_nm text) 
RETURNS text
AS $$
def get_pnu(atch_sgg_cd, atch_bjd_cd, daeji_type, atch_bun, atch_ji):
    return '%d%d%d%04d%04d'%( int(atch_sgg_cd), int(atch_bjd_cd), daeji_type, int(atch_bun), int(atch_ji) )

if atch_daeji_cd in ['1', '1.0']:
    daeji_type = 2
else:
    daeji_type = 1
pnu_gen = get_pnu(atch_sgg_cd, atch_bjd_cd, daeji_type, atch_bun, atch_ji)

if len(pnu_gen)==19:
    cnt = plpy.execute("select count(*) from lot_information_gn where pnu='%s'"%pnu_gen)[0]['count']
    if cnt > 0:
        return pnu_gen
    else:
        pnu_gen2 = get_pnu(atch_sgg_cd, atch_bjd_cd, 3-daeji_type, atch_bun, atch_ji) # 1->2, 2->1 로 바꿔서 pnu regen
        cnt2 = plpy.execute("select count(*) from lot_information_gn where pnu='%s'"%pnu_gen2)[0]['count']
        if cnt2 > 0:
            return pnu_gen2
bjd_cd_map = {
    '서울특별시 강남구 역삼동': 10100,
    '서울특별시 강남구 개포동': 10300,
    '서울특별시 강남구 청담동': 10400,
    '서울특별시 강남구 삼성동': 10500,
    '서울특별시 강남구 대치동': 10600,
    '서울특별시 강남구 신사동': 10700,
    '서울특별시 강남구 논현동': 10800,
    '서울특별시 강남구 압구정동': 11000,
    '서울특별시 강남구 세곡동': 11100,
    '서울특별시 강남구 자곡동': 11200,
    '서울특별시 강남구 율현동': 11300,
    '서울특별시 강남구 일원동': 11400,
    '서울특별시 강남구 수서동': 11500,
    '서울특별시 강남구 도곡동': 11800
}

if not atch_bjd_cd:
    atch_bjd_cd2 = bjd_cd_map[' '.join(adr_bsc.split()[:3])]
else:
    atch_bjd_cd2 = atch_bjd_cd

if not atch_bun and '-' in atch_etc_bunji_nm:
    atch_bun2, atch_ji2 = atch_etc_bunji_nm.replace('0^','').split('-')
else:
    atch_bun2, atch_ji2 = atch_bun, atch_ji

pnu_gen3 = get_pnu(atch_sgg_cd, atch_bjd_cd2, daeji_type, atch_bun2, atch_ji2)
cnt3 = plpy.execute("select count(*) from lot_information_gn where pnu='%s'"%pnu_gen3)[0]['count']

if cnt3 > 0:
    return pnu_gen3
$$ LANGUAGE plpython3u
immutable
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
pnu_generate_py( 
coalesce(bbg.atch_sgg_cd, 0),
coalesce(bbg.atch_bjd_cd, 0),
coalesce(bbg.atch_bun, 0),
coalesce(bbg.atch_ji, 0),
coalesce(bbg.atch_daeji_cd,''),
coalesce(bbg.adr_bsc, ''),
coalesce(bbg.atch_etc_bunji_nm, '')
) pnu_gen 
from building_busok_gn bbg 
where bbg.pnu in (select pnu from building_pyojebu_gn bpg where bpg.etclot_cnt > 0) ) tt where length(pnu_gen)<>19 or pnu_gen isnull;

-- 데이터 이상으로 pnu못찾던 것 추가: 5244->5360개
create view busok_pnu2 as 
select bbg.pnu, bbg.mgm_bldrgst_pk, bbg.adr_bsc, bbg.atch_bun, bbg.atch_ji, pnu_generate_py( 
coalesce(bbg.atch_sgg_cd, 0),
coalesce(bbg.atch_bjd_cd, 0),
coalesce(bbg.atch_bun, 0),
coalesce(bbg.atch_ji, 0),
coalesce(bbg.atch_daeji_cd,''),
coalesce(bbg.adr_bsc, ''),
coalesce(bbg.atch_etc_bunji_nm, '')
) pnu_gen
from building_busok_gn bbg where bbg.pnu in (select pnu from building_pyojebu_gn bpg where bpg.etclot_cnt > 0);

create view pnu_bpk_busok2 as 
select bp.pnu pnu_main, array_agg(distinct bp.mgm_bldrgst_pk) bpks, count(distinct bp.pnu_gen) bpnu_length, array_cat(array_agg(distinct bp.pnu),array_agg(distinct bp.pnu_gen)) bpnus 
from busok_pnu2 bp where bp.pnu_gen notnull group by bp.pnu;
select count(*) from pnu_bpk_busok2; --1764
select count(*) from (select distinct unnest(bpnus) from pnu_bpk_busok2) tt; --4742
select count(*) from (select unnest(bpnus) from pnu_bpk_busok2) tt; --4787
select * from busok_pnu2 bp 
where bp.pnu_gen in 
(select bpnu 
from (select count(tmp.pnu_main) cnt, tmp.bpnu from (select unnest(pbb.bpnus) bpnu, *, (select st_collect from pols_by_main_pnu pbmp where pbmp.pnu_main=pbb.pnu_main) from pnu_bpk_busok2 pbb) tmp 
group by tmp.bpnu) 
tmp2 where cnt>1); --같은 부속지번이 여러개의 MAIN_PNU집합에 걸려있는 것들 체크 -> 특별히 문제있는 것은 없어보임


--select distinct array_agg(distinct tmp.pnu_main)
--from (select unnest(pbb.bpnus) bpnu, *, (select st_collect from pols_by_main_pnu2 pbmp where pbmp.pnu_main=pbb.pnu_main) from pnu_bpk_busok2 pbb) tmp 
--group by tmp.bpnu having count(distinct tmp.pnu_main)>1; -- main PNU 안에 속한 부속 pnu가 겹치는 main pnu 조합

--create materialized view pnu_main_comb_map
--as select array_agg pnu_main_set, unnest(array_agg) pnu_main
--from (select distinct array_agg(distinct tmp.pnu_main)
--from (select unnest(pbb.bpnus) bpnu, *, (select st_collect from pols_by_main_pnu2 pbmp where pbmp.pnu_main=pbb.pnu_main) from pnu_bpk_busok2 pbb) tmp 
--group by tmp.bpnu having count(distinct tmp.pnu_main)>1) tmp;

create materialized view pols_by_main_pnu2 
as select pbb.pnu_main, pbb.bpks, st_collect( 
(select array_agg(geom) 
from pol_seoul_lands_gn pslg 
where pslg.pnu in (select unnest(pbb2.bpnus) from pnu_bpk_busok2 pbb2 where pbb2.pnu_main=pbb.pnu_main) 
)) from pnu_bpk_busok2 pbb with data;-- main 땅 pnu마다 폴리곤 collection
select count(distinct pnu_main) from pols_by_main_pnu2 pbmp;

create materialized view pnu_main_comb_map
as select unnest(pnu) pnu_main, pnu pnu_main_set 
from (select distinct array_agg(distinct pnu_main) pnu 
from (select unnest(bpnus) bpnu, pnu_main from pnu_bpk_busok2) un 
where un.bpnu != un.pnu_main group by bpnu having count(pnu_main)>1) a; -- main PNU 안에 속한 부속 pnu가 겹치는 main pnu 조합

create materialized view busok_main_pnu_map
as select bpnu, pnu_main from (select unnest(bpnus) bpnu, pnu_main from pnu_bpk_busok2) un where un.bpnu != un.pnu_main;
--select unnest(bpnus) bpnu, pnu_main from pnu_bpk_busok2;
--select count(*) from pnu_bpk_busok2 pbb;

select * from building_busok_gn bbg where atch_sgg_cd<>11680; -- 여러 구에 걸쳐있는 것도 있는듯
select atch_bjd_cd from building_busok_gn bbg where length(text(atch_bjd_cd))<>5;
select * from building_busok_gn bbg where atch_etc_bunji_nm notnull;

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

-- avg price
update pol_gwang_bounds_sim
set avg_pub_price = (select 
sum(
"PNILP"*(select area from jijuk_46 jj where jj."PNU"=pp."PNU" )
)/sum(
(select area from jijuk_46 jj where jj."PNU"=pp."PNU" )
) from pub_price_46 pp)
where ctprvn_cd='46';
