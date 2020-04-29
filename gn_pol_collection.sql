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


select pbb.pnu_main, pbb.bpks, (select st_union(geom) from pol_seoul_lands_gn pslg where pslg.pnu in ( select unnest(pbb2.bpnus) from pnu_bpk_busok2 pbb2 where pbb2.pnu_main=pbb.pnu_main) ) 
from pnu_bpk_busok2 pbb ;-- main 땅 pnu마다 폴리곤 union 

create materialized view pols_by_main_pnu_union as select pnu_main, bpks, (select st_union(st_collect) from pols_by_main_pnu2 pbmp2 where pbmp2.pnu_main=pbmp.pnu_main) from pols_by_main_pnu2 pbmp with data; -- 위에랑 same

select st_boundary(st_union) from pols_by_main_pnu_union; -- no 의미
select st_exteriorring(st_union) from pols_by_main_pnu_union; -- multipol => null

select count(*) from pols_by_main_pnu_union pbmpu where substring(st_astext(st_union), 0, 8)='POLYGON' ;
select count(*) from pols_by_main_pnu_union pbmpu where substring(st_astext(st_union), 0, 8)='MULTIPO' ;
select count(*) from pols_by_main_pnu_union pbmpu where substring(st_astext(st_union), 0, 8) not in ('POLYGON', 'MULTIPO') ;

select pmcm.pnu_main, (select st_union(st_union) from pols_by_main_pnu_union pbmpu where pbmpu.pnu_main in (select unnest(pnu_main_set) from pnu_main_comb_map pmcm2 where pmcm2.pnu_main=pmcm.pnu_main )) from pnu_main_comb_map pmcm;

select min(pnu_main), (select st_union(st_union) from pols_by_main_pnu_union pbmpu where pbmpu.pnu_main in (select unnest(pnu_main_set))) from pnu_main_comb_map pmcm group by pnu_main_set;

create materialized view pols_main_pnu_comb_union as 
select 
pnu_main, 
(select min(pnu) from unnest(pnu_main_set) as t(pnu)),
(select st_union((select st_union from pols_by_main_pnu_union pbmpu where pbmpu.pnu_main=pnu)) from unnest(pnu_main_set) as t(pnu))
from pnu_main_comb_map pmcm;

-- create materialized view pols_main_pnu_comb_union as select min(pnu_main), (select st_union(st_union) from pols_by_main_pnu_union pbmpu where pbmpu.pnu_main in (select unnest(pnu_main_set))) from pnu_main_comb_map pmcm group by pnu_main_set;

create or replace function asset_pol_by_pnu(pnu text) returns geometry
as $$
def pol_by_main_pnu(pnu):
    mp_comb_check = plpy.execute("select st_union, min from pols_main_pnu_comb_union where pnu_main='%s'"%pnu)
    if mp_comb_check:
        return mp_comb_check[0]['st_union']
    else:
        mp_check = plpy.execute("select st_union from pols_by_main_pnu_union where pnu_main='%s'"%pnu)
        if mp_check:
            return mp_check[0]['st_union']
        else:
            return None

busok_check = plpy.execute("select pnu_main from busok_main_pnu_map where bpnu='%s'"%pnu)
if busok_check:
    return pol_by_main_pnu(busok_check[0]['pnu_main'])
else:
    return pol_by_main_pnu(pnu)
$$ LANGUAGE plpython3u
immutable
RETURNS NULL ON NULL INPUT;

drop function asset_pnu_by_pnu;
create or replace function asset_pnu_by_pnu(pnu text)
returns text
as $$
def pol_by_main_pnu(pnu):
    mp_comb_check = plpy.execute("select st_union, min from pols_main_pnu_comb_union where pnu_main='%s'"%pnu)
    if mp_comb_check:
        return mp_comb_check[0]['min']
    else:
        mp_check = plpy.execute("select st_union from pols_by_main_pnu_union where pnu_main='%s'"%pnu)
        if mp_check:
            return pnu
        else:
            return None

busok_check = plpy.execute("select pnu_main from busok_main_pnu_map where bpnu='%s'"%pnu)
if busok_check:
    return busok_check[0]['pnu_main']
else:
    return pol_by_main_pnu(pnu)
$$ LANGUAGE plpython3u
immutable
RETURNS NULL ON NULL INPUT;

create table _asset as select pnu, coalesce(asset_pol_by_pnu(pnu), geom) asset_pol, coalesce(asset_pnu_by_pnu(pnu), pnu) asset_pnu from pol_seoul_lands_gn pslg;

-- block union 0303
create or replace function get_block_pnus(pnu text) returns text[]
as $$
import sys
sys.setrecursionlimit(3000)
def find_nearby(pnu, state):
    if pnu not in state['explored']:
        state['explored'].append(pnu)
    nearby = plpy.execute("select pnu from pol_seoul_lands_gn_mat pslg where st_intersects(geom, (select st_expand(geom, 0.0001) from pol_seoul_lands_gn_mat pslg2 where pslg2.pnu='%s')) and st_distance( geom, (select geom from pol_seoul_lands_gn_mat pslg2 where pslg2.pnu='%s'), true) < 0.1 and jimok!='도'"%(pnu,pnu))
    for rec in nearby:
        if rec['pnu'] in state['found']:
            continue
        else:
            state['found'].append(rec['pnu'])
    end_chk = True
    for opnu in state['found']:
        if opnu not in state['explored']:
            end_chk = False
            return find_nearby(opnu, state)
    if end_chk:
        return state 
state = {'found':[], 'explored':[]}
return find_nearby(pnu, state)['found']
$$ LANGUAGE plpython3u
IMMUTABLE
RETURNS NULL ON NULL INPUT;

select unnest( (select get_block_pnus(pnu) from pol_seoul_lands_gn_mat pslg limit 1) );
select pnu, geom, (select st_union(geom) from pol_seoul_lands_gn_mat pslg2 where pslg2.pnu in (select unnest( (select get_block_pnus(pnu) from pol_seoul_lands_gn_mat pslg where pslg.pnu=pslg3.pnu ) ) ) ) from pol_seoul_lands_gn_mat pslg3 where pslg3.jimok='대' limit 9;
create index pol_seoul_lands_gn_pnu_idx on pol_seoul_lands_gn_mat(pnu);

select st_geometrytype(geom) from pol_seoul_lands_gn_mat pslgm ; 
select count(*) from pol_seoul_lands_gn_mat pslgm where st_geometrytype(geom)='ST_MultiPolygon';
select count(*) from pol_seoul_lands_gn_mat pslgm where st_geometrytype(geom)='ST_Polygon';
select count(*) from pol_seoul_lands_gn_mat pslgm ;

select st_exteriorring(t) from (select (st_dump(geom)).geom t from pol_seoul_lands_gn_mat pslgm where st_geometrytype(geom)='ST_MultiPolygon') as foo;

select st_offsetcurve(st_exteriorring(geom), 0.00001) from pol_seoul_lands_gn_mat pslgm where st_geometrytype(geom)='ST_Polygon' limit 10;
select st_scale(geom, 1.01, 1.01), geom from pol_seoul_lands_gn_mat pslgm where st_geometrytype(geom)='ST_Polygon' limit 100;

select pnu, geom from pol_seoul_lands_gn pslg ;
select st_distance(
(select geom from pol_seoul_lands_gn pslg where pnu='1168010100106150020'),
(select geom from pol_seoul_lands_gn pslg where pnu='1168010100106150021'), true);

select st_expand(geom,0.0001), geom from pol_seoul_lands_gn pslg where pnu='1168010100106150020';
select st_expand(geom,0.0001), geom from pol_seoul_lands_gn pslg where pnu='1168010100106150021';

drop table gn_roads;
create table gn_roads as (select st_union(geom) from pol_seoul_lands_gn pslg where jimok='도');
select st_area((st_dump(st_union)).geom) area, (st_dump(st_union)).geom from gn_roads order by area desc;

create table gn_roads as (select st_union(st_buffer(geom, 0.0000001)) from pol_seoul_lands_gn pslg where jimok='도');

select distinct jimok from pol_seoul_lands_gn pslg ;

select (st_dumprings(geom)).geom from (select (st_dump(st_union)).geom, st_area((st_dump(st_union)).geom, true) area from gn_roads order by area desc) dump 
where st_nrings(geom)>1 and st_exteriorring(geom) in (select st_exteriorring(geom) from (select (st_dump(st_union)).geom, st_area((st_dump(st_union)).geom, true) area from gn_roads order by area desc) dump where st_nrings(geom)>1) ;
select st_exteriorring(geom) from (select (st_dump(st_union)).geom, st_area((st_dump(st_union)).geom, true) area from gn_roads order by area desc) dump where st_nrings(geom)>1;

create table gn_block_pols as select geom, (select count(*) from pol_seoul_lands_gn pslg where jimok='도' and st_intersects(dump_ring.geom, pslg.geom)) from (select (st_dumprings(geom)).geom from (select (st_dump(st_union)).geom from gn_roads) dump where st_nrings(geom)>1) dump_ring;

select count(*), count from gn_block_pols group by count;
select * from gn_block_pols where count>0;
select * from gn_block_pols where count=0;
select * from gn_block_pols ;
create table gn_block_pol_u1 as select st_union(geom) from gn_block_pols gbp where count<9 and (select count(*) from pol_seoul_lands_gn pslg where jimok!='도' and st_intersects(pslg.geom, gbp.geom))>0;

select count(geom) from pol_seoul_lands_gn pslg where not st_intersects(geom, (select st_union from gn_block_pol_u1)) ;

select st_union geom from gn_block_pol_u1 union
select geom from pol_seoul_lands_gn pslg where not st_intersects(geom, (select st_union from gn_block_pol_u1)) ;

select geom from pol_seoul_lands_gn pslg where jimok!='도' and not st_intersects(geom, (select st_union from gn_block_pol_u1));

drop table not_in_blocks;
create table not_in_blocks as select * from pol_seoul_lands_gn pslg where not st_intersects(geom, (select st_union from gn_block_pol_u1));

create index not_in_blocks_pnu_idx on not_in_blocks(pnu);
create index not_in_blocks_jimok_idx on not_in_blocks(jimok);
create index not_in_blocks_geom_idx on not_in_blocks using gist(geom);

create or replace function get_block_pnus(pnu text, jimok text) returns text[]
as $$
import sys
sys.setrecursionlimit(10000)
def find_nearby(pnu, state):
    if pnu not in state['explored']:
        state['explored'].append(pnu)
    nearby = plpy.execute("select pnu from not_in_blocks where st_dwithin( geom, (select geom from pol_seoul_lands_gn pslg2 where pslg2.pnu='%s'), 0.0000001) and jimok='%s'"%(pnu,jimok))
    for rec in nearby:
        if rec['pnu'] in state['found']:
            continue
        else:
            state['found'].append(rec['pnu'])
    end_chk = True
    for opnu in state['found']:
        if opnu not in state['explored']:
            end_chk = False
            return find_nearby(opnu, state)
    if end_chk:
        return state 
state = {'found':[], 'explored':[]}
return find_nearby(pnu, state)['found']
$$ LANGUAGE plpython3u
IMMUTABLE
RETURNS NULL ON NULL INPUT;

select get_block_pnus(pnu) from not_in_blocks nib where jimok='대';

select (select st_union(geom) from not_in_blocks nib3 where nib3.pnu in (select unnest(get_block_pnus(nib.pnu)) from not_in_blocks nib where nib.jimok='대' and nib.pnu=nib2.pnu) ) from not_in_blocks nib2 where nib2.jimok ='대';

select pnu, jimok, get_block_pnus(pnu,jimok), (select st_union(st_buffer(geom, 0.0000001)) from not_in_blocks nib3 where nib3.pnu in (select unnest(get_block_pnus(nib.pnu, nib.jimok)) from not_in_blocks nib where nib.jimok!='도' and nib.pnu=nib2.pnu) ) from not_in_blocks nib2 where nib2.jimok !='도' limit 100;

create table not_in_blocks_u1 as select pnu, jimok, get_block_pnus(pnu,jimok), (select st_union(st_buffer(geom, 0.0000001)) from not_in_blocks nib3 where nib3.pnu in (select unnest(get_block_pnus(nib.pnu, nib.jimok)) from not_in_blocks nib where nib.jimok!='도' and nib.pnu=nib2.pnu) ) from not_in_blocks nib2 where nib2.jimok !='도';

select count(*), jimok from not_in_blocks_u1 nibu group by jimok ;
select distinct st_union from not_in_blocks_u1 nibu where jimok = '전';

select distinct st_union geom from not_in_blocks_u1 nibu union
select geom from pol_seoul_lands_gn pslg where jimok ='도' union
select st_union geom from gn_block_pol_u1;

select * from pol_seoul_lands_gn pslg where pnu ='1168010600110100001';

create table gn_block_pol_all as (select distinct st_union geom from not_in_blocks_u1 nibu union
select geom from gn_block_pols gbp where count<9 and (select count(*) from pol_seoul_lands_gn pslg where jimok!='도' and st_intersects(pslg.geom, gbp.geom))>0 union 
select geom from pol_seoul_lands_gn pslg2 where jimok ='도' union
select geom from pol_seoul_lands_gn pslg where pnu ='1168010600110100001');

create index block_idx on gn_block_pol_all using gist(geom);
select * from gn_block_pol_all;
select pslg.geom, (select count(*) from gn_block_pol_all gbpa where st_intersects(gbpa.geom, st_buffer(pslg.geom, -0.0000005))), (select st_collect(geom) from gn_block_pol_all gbpa where st_intersects(gbpa.geom, st_buffer(pslg.geom, -0.0000005))) from pol_seoul_lands_gn pslg ;

create table block_map as select 
pnu, geom, 
(select count(*) from gn_block_pol_all gbpa where st_intersects(pslg.geom, gbpa.geom) and st_area(st_intersection(pslg.geom, gbpa.geom))/st_area(pslg.geom)>0.8) block_cnt, 
(select st_collect(geom) from gn_block_pol_all gbpa where st_intersects(pslg.geom, gbpa.geom) and st_area(st_intersection(pslg.geom, gbpa.geom))/st_area(pslg.geom)>0.8) blocks
from pol_seoul_lands_gn pslg;

create table gn_block_pol_all_buff as select st_buffer(geom, -0.000001) from gn_block_pol_all gbpa;
create index block_buf_idx on gn_block_pol_all_buff using gist(st_buffer);

create materialized view block_buff_with_ids as select (row_number() over()), st_buffer from gn_block_pol_all_buff gbpab with data;
select st_buffer from block_buff_with_ids bbwi ;

create materialized view block_counts as select pnu, geom, 
(select count(*) from block_buff_with_ids gbpab where st_intersects(gbpab.st_buffer, pslg.geom) and st_area(st_intersection(pslg.geom, gbpab.st_buffer))/st_area(pslg.geom)>0.8) block_cnt, 
(select array_agg(row_number) from block_buff_with_ids gbpab where st_intersects(gbpab.st_buffer, pslg.geom) and st_area(st_intersection(pslg.geom, gbpab.st_buffer))/st_area(pslg.geom)>0.8) blocks
from pol_seoul_lands_gn pslg order by block_cnt desc with data; 

select * from block_counts bc where block_cnt <1;

select pnu, geom, 
(select t.geom from (select gbpa.geom, st_area(st_intersection(st_makevalid(gbpa.geom), st_makevalid(pslg.geom)), true) ints_area from gn_block_pol_all gbpa where st_intersects(gbpa.geom, pslg.geom) order by ints_area desc limit 1) t),
(select count(*) from gn_block_pol_all gbpa where st_intersects(gbpa.geom, pslg.geom))
from pol_seoul_lands_gn pslg limit 1000;

create materialized view max_area_block 
as select pnu, geom, 
(select t.geom from (select gbpa.geom, st_area(st_intersection(st_makevalid(gbpa.geom), st_makevalid(pslg.geom)), true) ints_area from gn_block_pol_all gbpa where st_intersects(gbpa.geom, pslg.geom) order by ints_area desc limit 1) t) block,
(select count(*) from gn_block_pol_all gbpa where st_intersects(gbpa.geom, pslg.geom)) block_cnt
from pol_seoul_lands_gn pslg with data;

select count(*) from max_area_block where block_cnt=0;
select count(distinct block) from max_area_block ;
select count(*) from gn_block_pol_all gbpa ;
select count(*) from max_area_block where block isnull;

select count(*) from gn_block_pol_all gbpa where st_area(geom) notnull;
select count(*) from gn_block_pol_all gbpa where st_area(geom)>0;

create table gn_block_final as select block, array_agg(pnu) pnus, min(pnu) pnu_block_rep from max_area_block mab group by block;

select count(*) cnt, pnu_block_rep from gn_block_final gbf group by pnu_block_rep having count(*)>1;

drop table gn_block_pnu_map;
create table gn_block_pnu_map as select unnest(pnus) pnu, pnu_block_rep from gn_block_final gbf ;

create index gn_block_pnu_map_pnu_idx on gn_block_pnu_map(pnu);
create index gn_block_final_pnu_block_rep_idx on gn_block_final(pnu_block_rep);
create index gn_block_final_block_idx on gn_block_final using gist(block);

select (select st_intersection(pdb.geom, st_union) block from gn_roads gr) from pol_dong_bounds pdb where substring("EMD_CD",1,5)='11680';

select * from gn_block_final where (select jimok from pol_seoul_lands_gn pslg where pslg.pnu=pnu_block_rep)!='도';

select block, 
(select array_agg(pslg.pnu) from pol_seoul_lands_gn pslg where st_within(pslg.geom, block) and jimok='도') pnus, 
(select min(pslg.pnu) from pol_seoul_lands_gn pslg where st_within(pslg.geom, block) and jimok='도') pnu_block_rep 
from (select (select st_intersection(pdb.geom, st_union) block from gn_roads gr) from pol_dong_bounds pdb where substring("EMD_CD",1,5)='11680') as road_blocks;

drop table gn_block_final_roadblocks;
create table gn_block_final_roadblocks as
select *, false road from gn_block_final where (select jimok from pol_seoul_lands_gn pslg where pslg.pnu=pnu_block_rep)!='도' 
union
select block, 
(select array_agg(pslg.pnu) from pol_seoul_lands_gn pslg where st_within(pslg.geom, block) and jimok='도') pnus, 
(select min(pslg.pnu) from pol_seoul_lands_gn pslg where st_within(pslg.geom, block) and jimok='도') pnu_block_rep,
true road
from (select (select st_intersection(pdb.geom, st_union) block from gn_roads gr) from pol_dong_bounds pdb where substring("EMD_CD",1,5)='11680') as road_blocks;

create index gn_block_final_roadblocks_pnu_block_rep_idx on gn_block_final_roadblocks(pnu_block_rep);
create index gn_block_final_roadblocks_block_idx on gn_block_final_roadblocks using gist(block);

select count(*) cnt, pnu_block_rep from gn_block_final_roadblocks group by pnu_block_rep having count(*)>1; 
select count(*) from pub_price_gn_lands ppgl where ppgl.pnu in (select unnest(gbfr.pnus) from gn_block_final_roadblocks gbfr);

select count(*) from
(select sum(r.jiga*r.area)/sum(r.area), (select gbfr2.block from gn_block_final_roadblocks gbfr2 where gbfr2.pnu_block_rep = r.pnu_block_rep), r.pnu_block_rep from
(select t.pnu, t.pnu_block_rep, (select ppgl.jiga from pub_price_gn_lands ppgl where ppgl.pnu=t.pnu), (select pslg.area from pol_seoul_lands_gn pslg where pslg.pnu=t.pnu) from (select unnest(gbfr.pnus), pnu_block_rep from gn_block_final_roadblocks gbfr) as t(pnu, pnu_block_rep)) as r
group by r.pnu_block_rep) as avg_price_t;
select count(*) from gn_block_final_roadblocks gbfr ;

update gn_block_final_roadblocks gbfr3 set avg_pub_price = (select avg_pub_price from
(select sum(r.jiga*r.area)/sum(r.area) avg_pub_price, (select gbfr2.block from gn_block_final_roadblocks gbfr2 where gbfr2.pnu_block_rep = r.pnu_block_rep), r.pnu_block_rep from
(select t.pnu, t.pnu_block_rep, (select ppgl.jiga from pub_price_gn_lands ppgl where ppgl.pnu=t.pnu), (select pslg.area from pol_seoul_lands_gn pslg where pslg.pnu=t.pnu) from (select unnest(gbfr.pnus), pnu_block_rep from gn_block_final_roadblocks gbfr) as t(pnu, pnu_block_rep)) as r
group by r.pnu_block_rep) as avg_price_t where avg_price_t.pnu_block_rep=gbfr3.pnu_block_rep) ;

select (select jiga from pub_price_gn_lands ppgl where ppgl.pnu=t.pnu), (select pslg.area from pol_seoul_lands_gn pslg where pslg.pnu=t.pnu)  from (select unnest(pnus) pnu from gn_block_final_roadblocks gbfr where avg_pub_price isnull) t;
select * from pub_price_gn_lands ppgl where ppgl.pnu in (select unnest(pnus) pnu from gn_block_final_roadblocks gbfr where avg_pub_price isnull); -- 공시지가 자체가 없는 경우,,

select min(avg_pub_price),
percentile_disc(0.01) within group (order by avg_pub_price) "0.01",
percentile_disc(0.1) within group (order by avg_pub_price) "0.1",
percentile_disc(0.25) within group (order by avg_pub_price) "0.25",
percentile_disc(0.5) within group (order by avg_pub_price) "0.5",
percentile_disc(0.75) within group (order by avg_pub_price) "0.75",
percentile_disc(0.9) within group (order by avg_pub_price) "0.9",
percentile_disc(0.99) within group (order by avg_pub_price) "0.99",
percentile_disc(0.999) within group (order by avg_pub_price) "0.999",
max(avg_pub_price)
from gn_block_final_roadblocks gbfr ;

--frontend pricemap 테이블 작성 0310
create table _block as
select concat('block_', pnu_block_rep) id, block geom, avg_pub_price, road, pnus, 
concat(
(case when cast(substring(pnu_block_rep, 16, 4) as integer)>0 then concat(
(select pdb."EMD_NM" from pol_dong_bounds pdb where pdb."EMD_CD" = substring(pnu_block_rep, 1, 8)), 
'-', cast(cast(substring(pnu_block_rep, 12, 4) as integer) as text), 
'-', cast(cast(substring(pnu_block_rep, 16, 4) as integer) as text)
) else concat(
(select pdb."EMD_NM" from pol_dong_bounds pdb where pdb."EMD_CD" = substring(pnu_block_rep, 1, 8)), 
'-', cast(cast(substring(pnu_block_rep, 12, 4) as integer) as text)
) end),
' 블록') nm
from gn_block_final_roadblocks gbfr ;

create index _block_id_idx on _block(id);
create index _block_geom_idx on _block using gist(geom);


create table _land as
select concat('land_', pnu) id, geom, (select jiga from pub_price_gn_lands ppgl where ppgl.pnu=pslg.pnu) pub_price, jimok, 
concat((select pdb."EMD_NM" from pol_dong_bounds pdb where pdb."EMD_CD" = substring(pslg.pnu, 1, 8)), ' ', jibun) nm 
from pol_seoul_lands_gn pslg ;

create index _land_id_idx on _land(id);
create index _land_geom_idx on _land using gist(geom);


drop table _gwang;
create table _gwang as
select concat('gwang_', ctprvn_cd) id, geom, avg_pub_price, ctp_kor_nm nm from pol_gwang_bounds_sim pgbs;

create index _gwang_id_idx on _gwang(id);
create index _gwang_geom_idx on _gwang using gist(geom);


drop table _dong;
create table _dong as
select concat('dong_', "EMD_CD") id, geom, avg_pub_price, "EMD_NM" nm from pol_dong_bounds pdb ;

create index _dong_id_idx on _dong(id);
create index _dong_geom_idx on _dong using gist(geom);


create table _gu as
select concat('gu_', "ADM_SECT_C") id, geom, avg_pub_price, "SGG_NM" nm from pol_sgg_bounds psb ;

create index _gu_id_idx on _gu(id);
create index _gu_geom_idx on _gu using gist(geom);

-- 서비스 외 지역 polygon gen
drop table gwang_union_expt_seoul;
create table gwang_union_expt_seoul as select st_union(st_buffer(geom, 0.00001)) from _gwang where nm!='서울특별시';

select st_union(st_buffer(geom,0.0001)) from _gu where nm not in ('강남구', '서비스 준비중');

select geom from _gu union select geom from gu_out;

insert into _gu(id, geom, nm) values ('gu_00000', (select st_difference( go2.geom, (select st_union(g.geom) from _gu g where st_intersects(go2.geom, g.geom)) ) from gu_out go2), '서비스 준비중');

insert into _dong(id, geom, nm) values ('dong_00000000', (select st_difference( (select st_union( (select st_union(st_buffer(geom,0.0001)) from _gu where nm not in ('강남구', '서비스 준비중')), geom ) from gu_out), (select geom from _gu where nm='강남구'))), '서비스 준비중') ;
update _dong set geom = (select geom from _gu where id='gu_00000') where id='dong_00000000';

insert into _block(id, geom, nm) values ('block_0000000000100000000', (select st_difference( (select st_union( (select st_union(st_buffer(geom,0.0001)) from _gu where nm not in ('강남구', '서비스 준비중')), geom ) from gu_out), (select geom from _gu where nm='강남구'))), '서비스 준비중') ;
insert into _land(id, geom, nm) values ('land_0000000000100000000', (select geom from _block where id = 'block_0000000000100000000'), '서비스 준비중') ;


-- price range
select min(avg_pub_price),
percentile_disc(0.01) within group (order by avg_pub_price) "0.01",
percentile_disc(0.1) within group (order by avg_pub_price) "0.1",
percentile_disc(0.25) within group (order by avg_pub_price) "0.25",
percentile_disc(0.5) within group (order by avg_pub_price) "0.5",
percentile_disc(0.75) within group (order by avg_pub_price) "0.75",
percentile_disc(0.9) within group (order by avg_pub_price) "0.9",
percentile_disc(0.99) within group (order by avg_pub_price) "0.99",
percentile_disc(0.999) within group (order by avg_pub_price) "0.999",
max(avg_pub_price)
from _dong ;

select min(avg_pub_price),
percentile_disc(0.01) within group (order by avg_pub_price) "0.01",
percentile_disc(0.1) within group (order by avg_pub_price) "0.1",
percentile_disc(0.25) within group (order by avg_pub_price) "0.25",
percentile_disc(0.5) within group (order by avg_pub_price) "0.5",
percentile_disc(0.75) within group (order by avg_pub_price) "0.75",
percentile_disc(0.9) within group (order by avg_pub_price) "0.9",
percentile_disc(0.99) within group (order by avg_pub_price) "0.99",
percentile_disc(0.999) within group (order by avg_pub_price) "0.999",
max(avg_pub_price)
from _gu ;

select min(avg_pub_price),
percentile_disc(0.01) within group (order by avg_pub_price) "0.01",
percentile_disc(0.1) within group (order by avg_pub_price) "0.1",
percentile_disc(0.25) within group (order by avg_pub_price) "0.25",
percentile_disc(0.5) within group (order by avg_pub_price) "0.5",
percentile_disc(0.75) within group (order by avg_pub_price) "0.75",
percentile_disc(0.9) within group (order by avg_pub_price) "0.9",
percentile_disc(0.99) within group (order by avg_pub_price) "0.99",
percentile_disc(0.999) within group (order by avg_pub_price) "0.999",
max(avg_pub_price)
from _gwang ;

-- _block 도로 nm 수정 
select concat(split_part(nm, '-', 1), ' 도로') from _block where road;
update _block set nm = concat(split_part(nm, '-', 1), ' 도로') where road;
select nm from _block where road;

--
select count(*) from _dong;
select count(distinct id) from _dong;


-- asset 시작
create index asset_geom_index on asset using gist(asset_pol);

select asset_pol, st_centroid(asset_pol) from asset where st_intersects( st_pointfromtext('POINT(127.0608808 37.5086459)', 4326), asset_pol ); 

select st_asgeojson(asset_pol ) from asset where asset_pnu = '1168010600109450010';

select (select st_collect(l.geom) from _land l where split_part(l.id,'_',2) in (select unnest(a.pnus))), a.asset_pol from asset a limit 100;
select split_part(id, '_', 2) from _land;

select count(*) from asset where array_length(pnus,1)>1;


-- asset 마다 면적분포 데이터 작성 
create index asset_bpks_pnu_idx on asset_bpks_merged(pnu);

select count(*) from bpk_areadist ba ;
create index bpk_areadist_bpk_idx on bpk_areadist(bpk);

select pnu, coalesce, (select array_agg(area_dist) from bpk_areadist ba where ba.bpk in (select unnest(abm."coalesce" ))) from asset_bpks_merged abm ;

select jsonb_build_object(
bpk, area_dist 
)::jsonb
from bpk_areadist ba ;

select count(*) from asset_areadist_merged aam; 
select count(*) from asset_bpks_merged aam;
select count(*) from asset;

-- 면적분포 데이터 업데이트
create index asset_bpks_merged_pnu_idx on asset_bpks_merged(pnu);
update asset a set bl_area_dist = (select aam.area_dist from asset_areadist_merged aam where aam.pnu=a.pnu);

-- 자산 평균 공시지가 
select a.pnu, a.asset_area, 
(select sum(pub_price) from _land l where l.id in (select concat('land_', unnest(a.pnus)))), 
(select sum( (select laglb.area from lu_areas_gn_lands_bu laglb where laglb.pnu=split_part(id,'_',2)) ) from _land l where l.id in (select concat('land_', unnest(a.pnus)))),
(select sum( pub_price*(select laglb.area from lu_areas_gn_lands_bu laglb where laglb.pnu=split_part(id,'_',2)) ) from _land l where l.id in (select concat('land_', unnest(a.pnus)))),
(select sum( pub_price*(select laglb.area from lu_areas_gn_lands_bu laglb where laglb.pnu=split_part(id,'_',2)) ) from _land l where l.id in (select concat('land_', unnest(a.pnus))))/a.asset_area ,
(select array_agg(split_part(id,'_',2)) from _land l where l.id in (select concat('land_', unnest(a.pnus)))) from asset a;

update asset a 
set asset_pub_price = (select sum( pub_price*(select laglb.area from lu_areas_gn_lands_bu laglb where laglb.pnu=split_part(id,'_',2)) ) from _land l where l.id in (select concat('land_', unnest(a.pnus))))/a.asset_area;

-- 자산 토지정보
select (select array_agg from  a.pnus) from asset a;

-- landuse 테이블
create index landuse_pnu_idx on lot_landuse(pnu);
select pnu, array_agg(landuse_nm) lus from lot_landuse ll where pnu like('11680%') and state_nm='포함' group by pnu having '절대보호구역' in (select unnest(array_agg(landuse_nm))); -- 549 개 
select count(*) from (select pnu from lot_landuse ll where pnu like('11680%') and state_nm='포함' group by pnu having '절대보호구역' in (select unnest(array_agg(landuse_nm)))) as t;
select pnu, array_agg(landuse_nm) lus from lot_landuse ll where pnu like('11680%') and state_nm='포함' group by pnu having '상대보호구역' in (select unnest(array_agg(landuse_nm)));
select count(*) from (select pnu from lot_landuse ll where pnu like('11680%') and state_nm='포함' group by pnu having '상대보호구역' in (select unnest(array_agg(landuse_nm)))) as t; -- 11530 개
select count(*) from (select pnu from lot_landuse ll where pnu like('11680%') group by pnu ) as t; -- 34750
select * from asset where asset_pnu ='1168010100106140008';
select * from asset where asset_pnu ='1168010300112200003';


-- 토지, 건물, 추정가 데이터 자산테이블에 업데이트(추정가 데이터 나중에 추가해야 함)
create index asset_bld_data_pnu_idx on asset_bld_data(pnu);
create index asset_rst_lands_pnu_idx on asset_rst_lands(pnu);
create index asset_rst_merged_pnu_idx on asset_rst_merged(pnu);
create index asset_value_pnu_idx on asset_value(pnu);
create index asset_yjgp_lands_pnu_idx on asset_yjgp_lands(pnu);
create index asset_yjgp_merged_pnu_idx on asset_yjgp_merged(pnu);
create index asset_jimok_pnu_idx on asset_jimok(pnu);

update asset a set bld_data = (select abd.jsonb_agg from asset_bld_data abd where abd.pnu=a.pnu);
select count(*) from asset where bld_data is not null;

select jsonb_build_object(
'rst', jsonb_build_object(
    'rst_list', (select array_agg from asset_rst_lands arl where arl.pnu = a.pnu), 
    'rst_merged', (select get_landrst_merged from asset_rst_merged arm where arm.pnu=a.pnu)),
'jimok', (select jsonb_build_object from asset_jimok aj where aj.pnu=a.pnu),
'yjgp', jsonb_build_object(
    'yjgp_list', (select jsonb_agg(yjgp) from asset_yjgp_lands ayl where ayl.pnu in (select unnest(a.pnus))),
    'yjgp_merged', (select yjgp from asset_yjgp_merged aym where aym.pnu=a.pnu))
) from asset a; -- 건물 데이터 컬럼값 입력 

update asset a set lands_data = jsonb_build_object(
'rst', jsonb_build_object(
    'rst_list', (select array_agg from asset_rst_lands arl where arl.pnu = a.pnu), 
    'rst_merged', (select get_landrst_merged from asset_rst_merged arm where arm.pnu=a.pnu)),
'jimok', (select jsonb_build_object from asset_jimok aj where aj.pnu=a.pnu),
'yjgp', jsonb_build_object(
    'yjgp_list', (select jsonb_agg(jsonb_build_object( ayl.pnu, ayl.yjgp )) from asset_yjgp_lands ayl where ayl.pnu in (select unnest(a.pnus))),
    'yjgp_merged', (select yjgp from asset_yjgp_merged aym where aym.pnu=a.pnu))
); -- 토지 데이터 컬럼값 입력 

select (case when substring(value_str, 1,1)='n' then null else value_str end) from asset_value;
update asset a set asset_land_est_value = (select (case when substring(value_str, 1,1)='n' then null else value_str end) from asset_value av where av.pnu=a.pnu); -- 추정가 임시값 입력 

-- python function tmplet
create or replace function func_name(param jsonb[]) returns float4
as $$
import json
$$ LANGUAGE plpython3u
immutable
RETURNS NULL ON NULL INPUT;


-- 토지면적 null 값 보정 
select count(*) from asset where asset_area is null;
select lu_area_dist from asset where asset_area is null;


create or replace function get_areas_from_area_dist(area_dist jsonb) returns float4
as $$
import json
ad = json.loads(area_dist)
return sum(ad.values())
$$ LANGUAGE plpython3u
immutable
RETURNS NULL ON NULL INPUT;

select get_areas_from_area_dist(lu_area_dist), lu_area_dist from asset where asset_area is null;

update asset a set asset_area = get_areas_from_area_dist(lu_area_dist) where asset_area is null;


-- asset value 숫자 값으로 수정
-- select (select from asset pnu from asset_value av;
create index asset_value2_pnu_idx on asset_value2(pnu);
select count(*) from asset_value2 where land_value is null;
update asset a set asset_land_est_value = (select av.land_value from asset_value2 av where av.pnu=a.pnu); -- 추정가 임시값 입력 - 숫자 데이터로 변경 
select asset_land_est_value from asset;

-- 토지 추정가 업데이트 - 현웅님이 최종으로 구한 배율(0410)로 가격 산출 
create index asset_value3_pnu_idx on asset_value3(pnu);
select count(*) from asset_value3 where land_value is null;
update asset a set asset_land_est_value = (select av.land_value from asset_value3 av where av.pnu=a.pnu); -- 추정가 임시값 입력 - 숫자 데이터로 변경 


select pnu, pnus from asset;

select pnu,  from asset;

-- 거래사례 히스토리 데이터 자산테이블에 업데이트
create index asset_deals_hist_pnu_idx on asset_deals_history(pnu);
update asset a set deals_history = (select adh.history from asset_deals_history adh where adh.pnu=a.pnu);

-- 건물신축 히스토리 데이터 자산테이블에 업데이트
create index asset_bld_hist_pnu_idx on asset_bld_history(pnu);
update asset a set bld_history = (select abh.jsonb_agg from asset_bld_history abh where abh.pnu=a.pnu);

-- 히스토리 api 쿼리 테스트 
select bld_history, deals_history, bld_data from asset where pnu='1168010600109450010';

-- 건물단가 test data update
create index asset_building_est_pnu_idx on asset_building_estimate(pnu);
update asset a set bld_estimate = (select abe.estimate from asset_building_estimate abe where abe.pnu=a.pnu);

-- 대치동 유사 거래사례 데이터 업데이트 
create index asset_sim_deals_dch_pnu_idx on asset_sim_deals_daechi(pnu);
update asset a set sim_deals = (select asdd.sim_deals from asset_sim_deals_daechi asdd where asdd.pnu=a.pnu);

drop table test;
create table test(pnu text, price int4);

insert into test(pnu, price) values ('1168010600109450010', 1), ('1168010600109450010', 2), ('1168010600109450010', 3);

-- 집합건물 유닛구성 데이터 업데이트 
create index asset_cud_pnu_idx on asset_coll_units_data(pnu);
ALTER TABLE asset ADD coll_units_data jsonb NULL;
update asset a set coll_units_data = (select acud.coll_units_data from asset_coll_units_data acud where acud.pnu = a.pnu);

select count(*) from asset where coll_units_data is not null;

-- 지하철역 데이터 업데이트 
create index asset_subway_pnu_idx on asset_subway(pnu);
ALTER TABLE asset ADD subways_data jsonb NULL;
update asset a set subways_data = (select asb.subways_data from asset_subway asb where asb.pnu = a.pnu);

select count(pnu) from asset_subway;
select count(distinct pnu) from asset_subway;
select pnu, count(*) from asset_subway group by pnu;

select * from asset_subway as2 where pnu='1168010100107750007';

select * from asset where subways_data is not null;

select count(distinct pnu) from asset;


create view daechi_dong as select asset_area, bld_data, bld_history from asset where pnu like '1168010600%';

-- 강남 전체 일반 건축물 유사거래사례 데이터 업데이트 
create index asset_sim_d_pnu_idx on asset_sim_deals_bld(pnu);
ALTER TABLE asset ADD sim_deals_bld jsonb NULL;
update asset a set sim_deals_bld = (select asdb.sim_deals_bld from asset_sim_deals_bld asdb where asdb.pnu=a.pnu);

-- 강남 전체 토지 유사거래사례 데이터 업데이트 
create index asset_sim_d_land_pnu_idx on asset_sim_deals_land(pnu);
ALTER TABLE asset ADD sim_deals_land jsonb NULL;
update asset a set sim_deals_land = (select asdl.sim_deals_bld from asset_sim_deals_land asdl where asdl.pnu=a.pnu);

select st_area(geom, true) from _land where id=concat('land_', '1168010600109450010');
select count(*) from lu_areas_gn_lands_bu laglb ;
