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

create table gn_block_final_roadblocks as
select * from gn_block_final where (select jimok from pol_seoul_lands_gn pslg where pslg.pnu=pnu_block_rep)!='도' union
select block, 
(select array_agg(pslg.pnu) from pol_seoul_lands_gn pslg where st_within(pslg.geom, block) and jimok='도') pnus, 
(select min(pslg.pnu) from pol_seoul_lands_gn pslg where st_within(pslg.geom, block) and jimok='도') pnu_block_rep 
from (select (select st_intersection(pdb.geom, st_union) block from gn_roads gr) from pol_dong_bounds pdb where substring("EMD_CD",1,5)='11680') as road_blocks;

create index gn_block_final_roadblocks_pnu_block_rep_idx on gn_block_final_roadblocks(pnu_block_rep);
create index gn_block_final_roadblocks_block_idx on gn_block_final_roadblocks using gist(block);
