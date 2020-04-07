select count(*) from pnu_bpk_busok2_mat pbbm ;

select count(*) from pnu_main_comb_map pmcm ;

select count(*) from busok_main_pnu_map bmpm ;
select count(distinct pnu_main) from busok_main_pnu_map bmpm ;

select count(*) from building_pyo2 where pnu like '11680%';

select count(distinct unnest) from (select unnest(bpnus) from pnu_bpk_busok2_mat) pbbm ;

select count(*) from _asset;

create view asset_bpks as select a.pnu, a.asset_pnu, coalesce( (select pbb.bpks from pnu_bpk_busok2_mat pbb where pbb.pnu_main=a.asset_pnu), (select array_agg(bp.mgm_bldrgst_pk) from building_pyo2 bp where bp.pnu=a.pnu), null ) from _asset a;

select * from asset_bpks where pnu='1168010300101670004';
select * from asset_bpks where pnu='1168010300101670005';

create table asset_bpks_comb_tmp as select pmcm.pnu_main,
(select bpnus from pnu_bpk_busok2_mat pbbm2 where pnu_main=pmcm.pnu_main),
(select pnu from asset_bpks where pnu=pmcm.pnu_main),
(select asset_pnu from asset_bpks where pnu=pmcm.pnu_main),
(select coalesce from asset_bpks where pnu=pmcm.pnu_main),
(select bpks from pnu_bpk_busok2_mat pbbm where pnu_main=pmcm.pnu_main)
from pnu_main_comb_map pmcm;  

select * from building_pyo2 where pnu='1168011800101160001';
select * from pol_seoul_lands_gn_mat pslgm where pnu='1168011800101160001'; 


-- 건물 없는 땅들 ,,
select count(*) from asset_bpks where "coalesce" is null;
select (select jimok_nm from lot_information li where li.pnu=ab.pnu) from asset_bpks ab where "coalesce" is null;

select count(t.bpks)
from 
(select pmcm.pnu_main,
(select bpnus from pnu_bpk_busok2_mat pbbm2 where pnu_main=pmcm.pnu_main),
(select pnu from asset_bpks where pnu=pmcm.pnu_main),
(select asset_pnu from asset_bpks where pnu=pmcm.pnu_main),
(select coalesce from asset_bpks where pnu=pmcm.pnu_main),
(select bpks from pnu_bpk_busok2_mat pbbm where pnu_main=pmcm.pnu_main)
from pnu_main_comb_map pmcm) t
group by t.asset_pnu having count(t.bpks)=2;  

select *, (select distinct asset_pol from _asset a where a.asset_pnu=abct.asset_pnu) from asset_bpks_comb_tmp abct ;

select * from building_pyo2 bp where mgm_bldrgst_pk in ('11680-21278','11680-1821','11680-219');
select * from building_pyo2 bp where mgm_bldrgst_pk in ('11680-100270514','11680-100270535');

select * from asset_bpks_comb_tmp abct where pnu_main='1168011800101160001';
update asset_bpks_comb_tmp set asset_pnu = '1168011800101160001' where pnu_main='1168011800101160001';
update asset_bpks_comb_tmp set asset_pnu = '1168011500101810002' where pnu_main='1168011500101810002';

select array_cat( (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168010300101670004'), (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168010300101670005') );

update asset_bpks_comb_tmp set bpks_merged = array_cat( (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168010300101670004'), (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168010300101670005') )
where pnu_main in ('1168010300101670004','1168010300101670005');

update asset_bpks_comb_tmp set bpks_merged = array_cat( (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168010300111840004'), (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168010300111840022') )
where pnu_main in ('1168010300111840004','1168010300111840022');
update asset_bpks_comb_tmp set bpks_merged = array_cat( (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168010400101330003'), (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168010400101340015') )
where pnu_main in ('1168010400101330003','1168010400101340015');
update asset_bpks_comb_tmp set bpks_merged = array_cat( (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168011000104430000'), (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168011000104620000') )
where pnu_main in ('1168011000104430000','1168011000104620000');
update asset_bpks_comb_tmp set bpks_merged = array_cat( (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168011500102010005'), (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168011500101810002') )
where pnu_main in ('1168011500102010005','1168011500101810002');
update asset_bpks_comb_tmp set bpks_merged = array_cat( (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168011800101160001'), (select bpks from asset_bpks_comb_tmp abct where pnu_main = '1168011800108950008') )
where pnu_main in ('1168011800101160001','1168011800108950008');

select count(*) from asset_bpks;
select pnu, (select bpks_merged from asset_bpks_comb_tmp abct2 where abct2.pnu=ab.pnu) from asset_bpks ab where ab.pnu in (select abct.pnu from asset_bpks_comb_tmp abct);
create table asset_bpks_merged as select ab.pnu, coalesce( (select bpks_merged from asset_bpks_comb_tmp abct2 where abct2.pnu=ab.pnu), "coalesce" ) from asset_bpks ab;


-- 자산 토지정보 데이터 가공
select count(*) from asset;
select (select array_agg(jsonb_build_object('jimok', ligm.jimok_nm)) from lot_information_gn_mat ligm where ligm.pnu in (select unnest(a.pnus))) from asset a;
select (select array_agg(jsonb_build_object(t.pnu, (select jimok_nm from lot_information_gn_mat ligm where ligm.pnu=t.pnu))) from (select unnest(a.pnus) pnu) t) from asset a; -- 토지별 지목 정보
select lu_area_dist, asset_area from asset a;

--import sys
--sys.setrecursionlimit(10000)
--def find_nearby(pnu, state):
--    if pnu not in state['explored']:
--        state['explored'].append(pnu)
--    nearby = plpy.execute("select pnu from not_in_blocks where st_dwithin( geom, (select geom from pol_seoul_lands_gn pslg2 where pslg2.pnu='%s'), 0.0000001) and jimok='%s'"%(pnu,jimok))
--    for rec in nearby:
--        if rec['pnu'] in state['found']:
--            continue
--        else:
--            state['found'].append(rec['pnu'])
--    end_chk = True
--    for opnu in state['found']:
--        if opnu not in state['explored']:
--            end_chk = False
--            return find_nearby(opnu, state)
--    if end_chk:
--        return state 
--state = {'found':[], 'explored':[]}

--allowance_map = {
--'일반상업지역':[800,60],
--'제1종전용주거지역':[100,50],
--'제1종일반주거지역':[150,60],
--'제2종전용주거지역':[120,40],
--'제2종일반주거지역':[200,60],
--'제2종일반주거지역(7층이하)':[200,60],
--'제3종일반주거지역':[250,50],
--'준주거지역':[400,60],
--'생산녹지지역':[50,20],
--'자연녹지지역':[50,20],
--'중심상업지역':[1000,60],
--'중심상업지역(역사도심)':[800,60],
--'일반상업지역(역사도심)':[600,60],
--'근린상업지역':[600,60],
--'근린상업지역(역사도심)':[500,60],
--'유통상업지역':[600,60],
--'유통상업지역(역사도심)':[500,60],
--'전용공업지역':[200,60],
--'일반공업지역':[200,60],
--'준공업지역':[400,60],
--'보전녹지지역':[50,20],
--'중심상업지역(학교이적지10년미만)':[500,60],
--'일반상업지역(학교이적지10년미만)':[500,60],
--'근린상업지역(학교이적지10년미만)':[500,60],
--'유통상업지역(학교이적지10년미만)':[500,60],
--'준주거지역(학교이적지10년미만)':[320,60],
--'제1종전용주거지역(학교이적지10년미만)':[100,60],
--'제1종일반주거지역(학교이적지10년미만)':[120,60],
--'제2종전용주거지역(학교이적지10년미만)':[100,60],
--'제2종일반주거지역(학교이적지10년미만)':[160,60],
--'제2종일반주거지역(7층이하)(학교이적지10년미만)':[160,60],
--'제3종일반주거지역(학교이적지10년미만)':[200,50]
--}


--lu_name_map = {
--'jnju_1':'제1종전용주거지역',
--'ilju_1':'제1종일반주거지역',
--'ilju_2':'제2종일반주거지역',
--'ilju_2_und7':'제2종일반주거지역',
--'ilju_3':'제3종일반주거지역',
--'ilsang':'일반상업지역',
--'nt_green':'자연녹지지역',
--'pd_green':'생산녹지지역',
--'semiju':'준주거지역'
--}

--#{lu_name_map[lu]: allowance_map[lu_name_map[lu]] for lu in lu_area_dist}

create or replace function get_yj_gp(lu_area_dist jsonb, asset_area float4) returns jsonb
as $$
import json
a={'a': 1}

return json.dumps(a)
$$ LANGUAGE plpython3u
IMMUTABLE
RETURNS NULL ON NULL INPUT;

select get_yj_gp(lu_area_dist, asset_area) from asset a;
