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

-- 1168010300101670004
-- 1168010300101670005
-- 1168010300111840004
-- 1168010300111840022
-- 1168010400101330003
-- 1168010400101340015
-- 1168011000104430000
-- 1168011000104620000
-- 1168011500101810002
-- 1168011500102010005
-- 1168011800101160001
-- 1168011800108950008  20/06 기준 데이터 => 20/03때와 같은 pnu들만 추려짐

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


-- 자산 토지/건물 정보 데이터 가공
-- 지목정보
select count(*) from asset;
select (select array_agg(jsonb_build_object('jimok', ligm.jimok_nm)) from lot_information_gn_mat ligm where ligm.pnu in (select unnest(a.pnus))) from asset a;
select a.pnu, jsonb_build_object(
'jimok_list', (select array_agg(jsonb_build_object(t.pnu, (select jimok_nm from lot_information_gn_mat ligm where ligm.pnu=t.pnu))) from (select unnest(a.pnus) pnu) t),
'jimok_rep', (select jimok_nm from lot_information_gn_mat ligm where ligm.pnu=a.asset_pnu)
) from asset a; -- 토지별 지목 정보

drop table asset_jimok;
create table asset_jimok as select a.pnu, jsonb_build_object(
'jimok_list', (select array_agg(jsonb_build_object(t.pnu, (select jimok_nm from lot_information_gn_mat ligm where ligm.pnu=t.pnu))) from (select unnest(a.pnus) pnu) t),
'jimok_rep', (select jimok_nm from lot_information_gn_mat ligm where ligm.pnu=a.asset_pnu)
) from asset a;


-- 용적률/건폐율
select lu_area_dist, asset_area from asset a;

create or replace function get_yj_gp(lu_area_dist jsonb, asset_area float4) returns jsonb
as $$
import json
lu_area_dist2 = json.loads(lu_area_dist)
lu_name_map = {
'jnju_1': '제1종전용주거지역',
'ilju_1': '제1종일반주거지역',
'ilju_2': '제2종일반주거지역',
'ilju_2_und7': '제2종일반주거지역(7층이하)',
'ilju_3': '제3종일반주거지역',
'ilsang': '일반상업지역',
'nt_green': '자연녹지지역',
'pd_green': '생산녹지지역',
'semiju': '준주거지역'
}
allowance_map = {
'일반상업지역':[800,60],
'제1종전용주거지역':[100,50],
'제1종일반주거지역':[150,60],
'제2종전용주거지역':[120,40],
'제2종일반주거지역':[200,60],
'제2종일반주거지역(7층이하)':[200,60],
'제3종일반주거지역':[250,50],
'준주거지역':[400,60],
'생산녹지지역':[50,20],
'자연녹지지역':[50,20],
'중심상업지역':[1000,60],
'중심상업지역(역사도심)':[800,60],
'일반상업지역(역사도심)':[600,60],
'근린상업지역':[600,60],
'근린상업지역(역사도심)':[500,60],
'유통상업지역':[600,60],
'유통상업지역(역사도심)':[500,60],
'전용공업지역':[200,60],
'일반공업지역':[200,60],
'준공업지역':[400,60],
'보전녹지지역':[50,20],
'중심상업지역(학교이적지10년미만)':[500,60],
'일반상업지역(학교이적지10년미만)':[500,60],
'근린상업지역(학교이적지10년미만)':[500,60],
'유통상업지역(학교이적지10년미만)':[500,60],
'준주거지역(학교이적지10년미만)':[320,60],
'제1종전용주거지역(학교이적지10년미만)':[100,60],
'제1종일반주거지역(학교이적지10년미만)':[120,60],
'제2종전용주거지역(학교이적지10년미만)':[100,60],
'제2종일반주거지역(학교이적지10년미만)':[160,60],
'제2종일반주거지역(7층이하)(학교이적지10년미만)':[160,60],
'제3종일반주거지역(학교이적지10년미만)':[200,50]
}
#result = { lu_name_map[lu]: allowance_map[lu_name_map[lu]] for lu in lu_area_dist2 }
#result['area']=asset_area
if asset_area==None:
    asset_area2 = sum(lu_area_dist2.values())
else:
    asset_area2 = asset_area
if len(lu_area_dist2)==0:
    result = {'rt_fa': 60, 'rt_bc': 200}
elif len(lu_area_dist2)==1:
    lu = list(lu_area_dist2.keys())[0]
    result = {'rt_fa': allowance_map[lu_name_map[lu]][0], 'rt_bc': allowance_map[lu_name_map[lu]][1]}
    #result = {'yj': 0, 'gp': 0}
else:
    #result = {'yj': list(lu_area_dist2.keys())}
    max_area_lu = max(list(lu_area_dist2.keys()), key=lambda lu: lu_area_dist2[lu])
    max_area_rt = lu_area_dist2[max_area_lu]/asset_area2
    if max_area_rt>0.95:
        result = {'rt_fa': allowance_map[lu_name_map[max_area_lu]][0], 'rt_bc': allowance_map[lu_name_map[max_area_lu]][1]}
    else:
        yj = 0
        gp = 0
        for lu in lu_area_dist2:
            area_rt = lu_area_dist2[lu]/asset_area2
            yj += allowance_map[lu_name_map[lu]][0]*area_rt
            gp += allowance_map[lu_name_map[lu]][1]*area_rt
        result = {'rt_fa': yj, 'rt_bc': gp}
return json.dumps(result)
$$ LANGUAGE plpython3u
immutable;
--RETURNS NULL ON NULL INPUT;

select * from asset where asset_area is null;
select pnu, get_yj_gp(lu_area_dist, asset_area) yjgp from asset a; -- 자산별 용적률/건폐율 정보

create table asset_yjgp_merged as select pnu, get_yj_gp(lu_area_dist, asset_area) yjgp from asset a;
drop table asset_yjgp_merged ;
select * from asset_yjgp_merged aym where yjgp @> '{"rt_fa": 0}'::jsonb;

select * from lot_landuse ll where ll.pnu in (
'1168010300101560003',
'1168010300101500001',
'1168010300101530002',
'1168010300101730000',
'1168010300101740000',
'1168010300101840005',
'1168010300101840006',
'1168010300101940000',
'1168010600103980002',
'1168010600103980005',
'1168010600103980006',
'1168010600105100005',
'1168010600105100006',
'1168010600105050000',
'1168010600105100001',
'1168010600105100002',
'1168010600105100003',
'1168010600105100004'
) and ll.landuse_nm in (
'제2종일반주거지역','제1종일반주거지역','제3종일반주거지역','일반상업지역'
) and ll.state_nm = '포함'; -- lu_area_dist 값 없는 땅들 -> 전부 제2종일반주거지역

select * from asset_yjgp_merged aym where pnu in (
'1168010100108020024',
'1168011100101150003',
'1168011100101150007',
'1168010300105680046',
'1168010300105680047',
'1168010300105680048',
'1168010300105680042',
'1168010300105680043',
'1168010300105680044',
'1168010300105680045',
'1168010300105680049',
'1168010400100770036',
'1168010400100770037',
'1168010400100770038',
'1168010400100770073',
'1168010400100770056',
'1168010400100770072',
'1168010400100770102',
'1168010400100770055',
'1168011100104290003',
'1168011100101000031',
'1168011100101020033',
'1168011100101290003',
'1168011200101990001',
'1168011300101940006',
'1168011400106700014'
);

select count(*) from lu_areas_gn_lands_bu laglb ;
select count(*) from asset;

select get_yj_gp( jsonb_build_object(
'ilsang', laglb.ilsang, 
'ilju_1', laglb.ilju_1 ,
'ilju_2', laglb.ilju_2 ,
'ilju_2_und7', laglb.ilju_2_und7 ,
'ilju_3', laglb.ilju_3 ,
'jnju_1', laglb.jnju_1 ,
'semiju', laglb.semiju ,
'nt_green', laglb.nt_green ,
'pd_green', laglb.pd_green
) , coalesce(area, st_area) ) from lu_areas_gn_lands_bu laglb ;

select * from lu_areas_gn_lands_bu laglb where area is null;
select * from lu_areas_gn_lands_bu laglb where st_area is null;

create table asset_yjgp_lands as select pnu, get_yj_gp2( jsonb_build_object(
'ilsang', laglb.ilsang, 
'ilju_1', laglb.ilju_1 ,
'ilju_2', laglb.ilju_2 ,
'ilju_2_und7', laglb.ilju_2_und7 ,
'ilju_3', laglb.ilju_3 ,
'jnju_1', laglb.jnju_1 ,
'semiju', laglb.semiju ,
'nt_green', laglb.nt_green ,
'pd_green', laglb.pd_green
) , coalesce(area, st_area) ) yjgp from lu_areas_gn_lands_bu laglb ; -- 토지별 용적률, 건폐율
drop table asset_yjgp_lands;
select * from asset_yjgp_lands where yjgp @> '{"yj": 0}'::jsonb;

select * from lot_landuse ll where ll.pnu in (
'1168010600105100005',
'1168010600103980002',
'1168010600103980005',
'1168010600103980006',
'1168010600105050000',
'1168010600105100001',
'1168010600105100002',
'1168010600105100003',
'1168010600105100004',
'1168010600105100006',
'1168010300101560003',
'1168010300101500001',
'1168010300101530002',
'1168010300101550002',
'1168010300101730000',
'1168010300101740000',
'1168010300101840005',
'1168010300101840006',
'1168010300101940000'
) and ll.landuse_nm in (
'제2종일반주거지역','제1종일반주거지역','제3종일반주거지역','일반상업지역'
) and ll.state_nm = '포함'; -- lu_area_dist 값 없는 땅들 -> 전부 제2종일반주거지역

create or replace function get_yj_gp2(lu_area_dist jsonb, asset_area float4) returns jsonb
as $$
import json
lu_area_dist2 = json.loads(lu_area_dist)
lu_name_map = {
'jnju_1': '제1종전용주거지역',
'ilju_1': '제1종일반주거지역',
'ilju_2': '제2종일반주거지역',
'ilju_2_und7': '제2종일반주거지역(7층이하)',
'ilju_3': '제3종일반주거지역',
'ilsang': '일반상업지역',
'nt_green': '자연녹지지역',
'pd_green': '생산녹지지역',
'semiju': '준주거지역'
}
allowance_map = {
'일반상업지역':[800,60],
'제1종전용주거지역':[100,50],
'제1종일반주거지역':[150,60],
'제2종전용주거지역':[120,40],
'제2종일반주거지역':[200,60],
'제2종일반주거지역(7층이하)':[200,60],
'제3종일반주거지역':[250,50],
'준주거지역':[400,60],
'생산녹지지역':[50,20],
'자연녹지지역':[50,20],
'중심상업지역':[1000,60],
'중심상업지역(역사도심)':[800,60],
'일반상업지역(역사도심)':[600,60],
'근린상업지역':[600,60],
'근린상업지역(역사도심)':[500,60],
'유통상업지역':[600,60],
'유통상업지역(역사도심)':[500,60],
'전용공업지역':[200,60],
'일반공업지역':[200,60],
'준공업지역':[400,60],
'보전녹지지역':[50,20],
'중심상업지역(학교이적지10년미만)':[500,60],
'일반상업지역(학교이적지10년미만)':[500,60],
'근린상업지역(학교이적지10년미만)':[500,60],
'유통상업지역(학교이적지10년미만)':[500,60],
'준주거지역(학교이적지10년미만)':[320,60],
'제1종전용주거지역(학교이적지10년미만)':[100,60],
'제1종일반주거지역(학교이적지10년미만)':[120,60],
'제2종전용주거지역(학교이적지10년미만)':[100,60],
'제2종일반주거지역(학교이적지10년미만)':[160,60],
'제2종일반주거지역(7층이하)(학교이적지10년미만)':[160,60],
'제3종일반주거지역(학교이적지10년미만)':[200,50]
}
#result = { lu_name_map[lu]: allowance_map[lu_name_map[lu]] for lu in lu_area_dist2 }
#result['area']=asset_area
if asset_area==None:
    asset_area2 = sum(lu_area_dist2.values())
else:
    asset_area2 = asset_area
if sum(lu_area_dist2.values())==0:
    result = {'rt_fa': 60, 'rt_bc': 200}
elif len(lu_area_dist2)==1:
    lu = list(lu_area_dist2.keys())[0]
    result = {'rt_fa': allowance_map[lu_name_map[lu]][0], 'rt_bc': allowance_map[lu_name_map[lu]][1]}
    #result = {'yj': 0, 'gp': 0}
else:
    #result = {'yj': list(lu_area_dist2.keys())}
    max_area_lu = max(list(lu_area_dist2.keys()), key=lambda lu: lu_area_dist2[lu])
    max_area_rt = lu_area_dist2[max_area_lu]/asset_area2
    if max_area_rt>0.95:
        result = {'rt_fa': allowance_map[lu_name_map[max_area_lu]][0], 'rt_bc': allowance_map[lu_name_map[max_area_lu]][1]}
    else:
        yj = 0
        gp = 0
        for lu in lu_area_dist2:
            area_rt = lu_area_dist2[lu]/asset_area2
            yj += allowance_map[lu_name_map[lu]][0]*area_rt
            gp += allowance_map[lu_name_map[lu]][1]*area_rt
        result = {'rt_fa': yj, 'rt_bc': gp}
return json.dumps(result)
$$ LANGUAGE plpython3u
immutable;


--규제정보
create index lot_landuse_pnu_idx on lot_landuse(pnu);
select pnu, array_agg(landuse_nm), count(*) from lot_landuse ll where pnu like '11680%' and state_nm='포함' group by pnu;

select pnu from lot_landuse ll ;

select avg(count) from (select pnu, count(*) from lot_landuse ll where pnu like '11680%' group by pnu) t; -- 강남구 토지당 규제정보 평균 7.74개

select pnu, count(*) from lot_landuse ll where pnu like '11680%' group by pnu;

create materialized view lot_landuse_gn_ext as select pnu, array_agg(jsonb_build_object(landuse_nm, state_nm)) from lot_landuse ll where pnu like '11680%' group by pnu;

select count(*) from lot_landuse_gn_ext llge2 ;
select pnu, (select array_agg(jsonb_build_object(llge.pnu, array_agg)) from lot_landuse_gn_ext llge where llge.pnu in (select unnest(a.pnus))) from asset a; -- 자산당 연관 pnu에 해당하는 규제정보 매핑하여 array로
create table asset_rst_lands as select pnu, (select array_agg(jsonb_build_object(llge.pnu, array_agg)) from lot_landuse_gn_ext llge where llge.pnu in (select unnest(a.pnus))) from asset a;

create or replace function get_landrst_merged(rst_data jsonb[]) returns jsonb
as $$
import json
result = {}
for land in rst_data:
    data = json.loads(land)
    for pnu, rst_list in data.items():
        for rst in rst_list:
            rst_name, rst_state = list(rst.items())[0]
            if rst_name in result:
                if rst_state in result[rst_name].keys():
                    result[rst_name][rst_state].append(pnu)
                else:
                    result[rst_name][rst_state] = [pnu]
            else:
                result[rst_name] = {rst_state: [pnu]}
return json.dumps(result)
$$ LANGUAGE plpython3u
immutable
RETURNS NULL ON NULL INPUT;

select pnu, get_landrst_merged((select array_agg(jsonb_build_object(llge.pnu, array_agg)) from lot_landuse_gn_ext llge where llge.pnu in (select unnest(a.pnus)))) from asset a; -- 자산마다 규제정보 가공 완료(통합)

create table asset_rst_merged as select pnu, get_landrst_merged((select array_agg(jsonb_build_object(llge.pnu, array_agg)) from lot_landuse_gn_ext llge where llge.pnu in (select unnest(a.pnus)))) from asset a;

select distinct ll.landuse_nm from lot_landuse ll where pnu like '11680%';
select distinct ll.state_nm from lot_landuse ll where pnu like '11680%';
select ll.state_nm from lot_landuse ll where pnu like '11680%' and state_nm is null;

-- 건물정보
create or replace function get_own(rgst_typ_nm text) returns text
as $$
if rgst_typ_nm=='일반':
    return '토지・건물소유권'
else:
    return '구분소유권'
$$ LANGUAGE plpython3u
immutable
RETURNS NULL ON NULL INPUT;

create table asset_bld_data as select pnu, (select jsonb_agg( jsonb_build_object(bp.mgm_bldrgst_pk , jsonb_build_object(
'ar_gf', bp.gf_ar, 
'use_main', bp.use_nm,
'strc_main', bp.strc_nm,
'strc_roof', bp.roof_nm,
'fl_cnt', bp.floor_cnt,
'und_fl_cnt', bp.ungflr_cnt,
'rt_fa', bp.fa_rt,
'rt_bc', bp.bc_rt,
'own', get_own(bp.rgst_typ_nm),
'elev', bp.elevator_cnt,
'elev_emg', bp.emgelev_cnt,
'parklot', jsonb_build_object(
    'self_in', bp.in_self_parklot_cnt,
    'self_out', bp.out_self_parklot_cnt,
    'auto_in', bp.in_auto_parklot_cnt,
    'auto_out', bp.out_auto_parklot_cnt,
    'total', bp.in_self_parklot_cnt+bp.out_self_parklot_cnt+bp.in_auto_parklot_cnt+bp.out_auto_parklot_cnt,
    'total_self', bp.in_self_parklot_cnt+bp.out_self_parklot_cnt,
    'total_out', bp.in_auto_parklot_cnt+bp.out_auto_parklot_cnt
),
'approval_dt', bp.approval_dt,
'ar_bc', bp.bc_ar,
'ar_fr', bp.far_gf_ar,
'ar_lot', (select area from lot_information_gn_mat ligm where ligm.pnu=bp.pnu),
'bld_name', bp.bld_nm
)) ) from building_pyo2 bp where bp.mgm_bldrgst_pk in (select unnest(abm."coalesce")) ) from asset_bpks_merged abm; -- 자산별 건물 데이터
-- where abm.pnu='1168010100106640021'; 

select distinct rgst_typ_nm from building_pyo2 bp ;

select * from building_pyojebu_gn bpg where approval_dt/10000000<1 ;

select * from building_pyojebu_gn bpg where approval_dt is null ;


-- 건물 히스토리(허가, 착공, 사용승인 )
select tnt(permit_dt), tnt(const_dt) from building_pyojebu_gn bpg;

create or replace function tnt(txt text) returns text
as $$
t = txt.replace(' ','')
return str(int(float(t)))
$$ LANGUAGE plpython3u
immutable
RETURNS NULL ON NULL INPUT;

create materialized view permit_date as select pnu, bld_nm, adr_bsc, lot_ar, tnt(permit_dt) from building_pyojebu_gn bpg where length(tnt(permit_dt))<8;
select count(*) from permit_date; -- 147 개 
select * from permit_date;
select * from permit_date where length(tnt)<4; -- 6개 19, 200 => 없는셈..
select * from permit_date where length(tnt)=4; -- 23개 년도 
select * from permit_date where length(tnt)=5; -- 3개 년+월 2개, 20020 1개 
select * from permit_date where length(tnt)=6; -- 84개 년+월 (뒷 두자리가 12보다 크면 월+일로)
select * from permit_date where length(tnt)=7; -- 31개 각각 다르게 따져야 할듯??
select count(*) from building_pyojebu_gn bpg where tnt(permit_dt) is null; -- 3081 개 
select count(*) from building_pyojebu_gn bpg where length(tnt(permit_dt))=8; -- 21347 개 
select count(*) from building_pyojebu_gn bpg where length(tnt(permit_dt))>8; -- 0 개 
select pnu, bld_nm, adr_bsc, lot_ar, tnt(permit_dt), substring(tnt(permit_dt),5,2) from building_pyojebu_gn bpg where length(tnt(permit_dt))=8 and cast(substring(tnt(permit_dt),5,2) as integer)>12;
select pnu, bld_nm, adr_bsc, lot_ar, tnt(permit_dt), substring(tnt(permit_dt),7,2) from building_pyojebu_gn bpg where length(tnt(permit_dt))=8 and cast(substring(tnt(permit_dt),7,2) as integer)>31;
select pnu, bld_nm, adr_bsc, lot_ar, tnt(permit_dt), substring(tnt(permit_dt),5,2) from building_pyojebu_gn bpg where length(tnt(permit_dt))=8 and cast(substring(tnt(permit_dt),5,2) as integer)<1;
select pnu, bld_nm, adr_bsc, lot_ar, tnt(permit_dt), substring(tnt(permit_dt),7,2) from building_pyojebu_gn bpg where length(tnt(permit_dt))=8 and cast(substring(tnt(permit_dt),7,2) as integer)<1;

select count(*) from building_pyojebu_gn bpg where tnt(const_dt) is null; -- 7776 개 
select count(*) from building_pyojebu_gn bpg where length(tnt(const_dt))=8; -- 15782 개 
select count(*) from building_pyojebu_gn bpg where length(tnt(const_dt))>8; -- 0 개 
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt), substring(tnt(const_dt),5,2) from building_pyojebu_gn bpg where length(tnt(const_dt))=8 and cast(substring(tnt(const_dt),5,2) as integer)>12;
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt), substring(tnt(const_dt),7,2) from building_pyojebu_gn bpg where length(tnt(const_dt))=8 and cast(substring(tnt(const_dt),7,2) as integer)>31;
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt), substring(tnt(const_dt),5,2) from building_pyojebu_gn bpg where length(tnt(const_dt))=8 and cast(substring(tnt(const_dt),5,2) as integer)<1;
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt), substring(tnt(const_dt),7,2) from building_pyojebu_gn bpg where length(tnt(const_dt))=8 and cast(substring(tnt(const_dt),7,2) as integer)<1;
select count(*) from building_pyojebu_gn bpg where length(tnt(const_dt))<8; -- 1017 개 
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt) from building_pyojebu_gn bpg where length(tnt(const_dt))<8;
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt) from building_pyojebu_gn bpg where length(tnt(const_dt))=1; -- 1개 0
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt) from building_pyojebu_gn bpg where length(tnt(const_dt))=2; -- 16개 19 
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt) from building_pyojebu_gn bpg where length(tnt(const_dt))=3; -- 0개 
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt) from building_pyojebu_gn bpg where length(tnt(const_dt))=4; -- 163개 년도 
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt) from building_pyojebu_gn bpg where length(tnt(const_dt))=5; -- 20개 년+월로 추정, 1개만 35377 이상값 
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt), substring(tnt(const_dt),5,2) from building_pyojebu_gn bpg where length(tnt(const_dt))=6; -- 793개 년+월로 추정 (뒷 두자리가 12보다 크면,,, 월+일로 ,,)
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt), substring(tnt(const_dt),5,2) from building_pyojebu_gn bpg where length(tnt(const_dt))=6 and cast(substring(tnt(const_dt),5,2) as integer)>12; -- 793개 년+월로 추정 (뒷 두자리가 12보다 크면,,, 월+일로 ,,)
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt), substring(tnt(const_dt),5,2) from building_pyojebu_gn bpg where length(tnt(const_dt))=6 and cast(substring(tnt(const_dt),5,2) as integer)<1; -- 793개 년+월로 추정 (뒷 두자리가 12보다 크면,,, 월+일로 ,,)
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt) from building_pyojebu_gn bpg where length(tnt(const_dt))=6 and substring(tnt(const_dt), 1, 1) not in ('1','2') ; -- 1,2 로 시작하지 않는 값 없음 
select pnu, bld_nm, adr_bsc, lot_ar, tnt(const_dt) from building_pyojebu_gn bpg where length(tnt(const_dt))=7; -- 24개.. 이상함... 종류별로 따져서 입력해야 할듯,, 

create table asset_bld_history as
select a.pnu, (select jsonb_agg(jsonb_build_object(mgm_bldrgst_pk,jsonb_build_object('approval_dt', approval_dt, 'permit_dt', tnt(permit_dt), 'const_dt', tnt(const_dt)))) from building_pyojebu_gn bpg where bpg.mgm_bldrgst_pk in (select unnest(a.coalesce))) from asset_bpks_merged a; 

select approval_dt from building_pyojebu_gn bpg where length((cast(approval_dt as text)))=7;

select count(*) from building_pyojebu_gn bpg where approval_dt is null;
select count(*) from building_pyojebu_gn bpg where length((cast(approval_dt as text)))>8;
select approval_dt, substring(cast(approval_dt as text), 5, 2) from building_pyojebu_gn bpg where length(cast(approval_dt as text))=8 and cast(substring(cast(approval_dt as text),5,2) as integer)>12;
select approval_dt, substring(cast(approval_dt as text), 7, 2) from building_pyojebu_gn bpg where length(cast(approval_dt as text))=8 and cast(substring(cast(approval_dt as text),7,2) as integer)>31;

select pnu, approval_dt, const_dt, permit_dt from building_pyojebu_gn where approval_dt is null and const_dt is not null;

-- 거래 히스토리 
create table asset_deals_history(
pnu text,
history jsonb
);

-- 지하철역 
CREATE TABLE gn_subways (
  id SERIAL PRIMARY KEY,
  geom geometry(geometry, 4326),
  name text,
  line text
);
create index subways_spt_idx on gn_subways using gist(geom);

select st_buffer(psb.geom, 0.05) from pol_sgg_bounds psb where psb."ADM_SECT_C" ='11680';

drop table gn_subways_merged ;
create table gn_subways_merged as
select geom, replace(names[1], $$'$$, '')  as name, lines from (select geom, array_agg(name) as names, array_agg(line) as lines from gn_subways where st_intersects(geom, (select st_buffer(psb.geom, 0.05) from pol_sgg_bounds psb where psb."ADM_SECT_C" ='11680')) group by geom) t;
--'
;
--

create index gn_subways_spt_idx on gn_subways_merged using gist(geom);

select st_buffer(geom, 0.02) from gn_subways_merged gsm where gsm.name='선릉';

select * from gn_subways_merged where st_dwithin(geom, (select geom from gn_subways_merged gsm where gsm.name='선릉'), 0.02);

select asset_pol, (select array_agg(name) from (select name from gn_subways_merged gsm where st_dwithin(gsm.geom, a.asset_pol, 0.02) limit 4) t) from asset a limit 100;

drop function get_subways_dist(text);
create or replace function get_subways_dist(asset_pnu text) returns jsonb[]
as $$
rec = plpy.execute("select array_agg(jsonb_build_object('name', name, 'dist', dist, 'lines', lines)) from (select name, lines, st_distance((select asset_pol from asset a where a.pnu='%s'), gsm.geom, true) as dist from gn_subways_merged gsm where st_dwithin((select asset_pol from asset a where a.pnu='%s'), gsm.geom, 0.02) order by st_distance((select asset_pol from asset a where a.pnu='%s'), gsm.geom, true) limit 4) t"%(asset_pnu, asset_pnu, asset_pnu))
if rec[0]['array_agg'] and len(rec[0]['array_agg'])==4:
    return rec[0]['array_agg']
else:
    rec = plpy.execute("select array_agg(jsonb_build_object('name', name, 'dist', dist, 'lines', lines)) from (select name, lines, st_distance((select asset_pol from asset a where a.pnu='%s'), gsm.geom, true) as dist from gn_subways_merged gsm where st_dwithin((select asset_pol from asset a where a.pnu='%s'), gsm.geom, 0.1) order by st_distance((select asset_pol from asset a where a.pnu='%s'), gsm.geom, true) limit 4) t"%(asset_pnu, asset_pnu, asset_pnu))
    if rec[0]['array_agg'] and len(rec[0]['array_agg'])==4:
        return rec[0]['array_agg']
    else:
        rec = plpy.execute("select array_agg(jsonb_build_object('name', name, 'dist', dist, 'lines', lines)) from (select name, lines, st_distance((select asset_pol from asset a where a.pnu='%s'), gsm.geom, true) as dist from gn_subways_merged gsm order by st_distance((select asset_pol from asset a where a.pnu='%s'), gsm.geom, true) limit 4) t"%(asset_pnu, asset_pnu))
        return rec[0]['array_agg']

$$ LANGUAGE plpython3u
immutable
RETURNS NULL ON NULL INPUT;

select get_subways_dist(asset_pnu) from asset a limit 100;
create table asset_subways_dists as select pnu, get_subways_dist(asset_pnu) from asset;


-- 면적단가 
select * from building_pyojebu_gn bpg where gf_ar is null;
select floor_cnt, ungflr_cnt, bc_ar, gf_ar, far_gf_ar from building_pyojebu_gn bpg where gf_ar=0;
select * from building_pyojebu_gn bpg where gf_ar<5;

create or replace function get_gf_ar(gf_ar float8, bc_ar float8, far_gf_ar float8, floor_cnt int8, ungflr_cnt int8) returns float8
as $$
if gf_ar==0:
    if far_gf_ar==0:
        return (floor_cnt + ungflr_cnt*1.5)*bc_ar
    else:
        if bc_ar==0:
            return far_gf_ar + ungflr_cnt*1.5*(far_gf_ar/floor_cnt)
        else:
            return far_gf_ar + ungflr_cnt*1.5*(bc_ar)
else:
    return gf_ar
$$ LANGUAGE plpython3u
immutable
RETURNS NULL ON NULL INPUT;

select get_gf_ar(gf_ar, bc_ar, far_gf_ar, floor_cnt, ungflr_cnt), floor_cnt, ungflr_cnt, bc_ar, gf_ar, far_gf_ar from building_pyojebu_gn bpg where gf_ar=0;

select count(*) from building_pyojebu_gn bpg ;

select pnu, 
(case when st_intersects(a.asset_pol, (select pol from pols_gn_offices_zone_merged where name='A')) then 1 else 0 end) as type_a,  
(case when st_intersects(a.asset_pol, (select pol from pols_gn_offices_zone_merged where name='B')) then 1 else 0 end) as type_b,
(select array_agg(jsonb_build_object(mgm_bldrgst_pk, get_gf_ar(gf_ar, bc_ar, far_gf_ar, floor_cnt, ungflr_cnt))) from building_pyojebu_gn bpg where bpg.mgm_bldrgst_pk in (select unnest(coalesce) from asset_bpks_merged abm where abm.pnu=a.pnu)) as gr_ar_list,
a.bl_area_dist,
(select abd.jsonb_agg from asset_bld_data abd where abd.pnu=a.pnu) as bld_data
from asset a;

create index asset_bpks_pnu_idx on asset_bpks_merged(pnu);
create index asset_bld_dat_pnu_idx on asset_bld_data(pnu);

create table asset_building_estimate(
pnu text, 
estimate jsonb
);


-- 랭킹 연산 테스트
select count(*) from pol_seoul_lands_gn_mat; 
create table gn_land_points_all as select pnu, st_centroid(geom) from pol_seoul_lands_gn_mat pslgm ;

-- 지구단위계획 여부
select pnu, st_intersects(geom, (select jd_merged from jd_merged_0420)) from gnlands2;
update gnlands2 g set jd_check = st_intersects(g.geom, (select jd_merged from jd_merged_0420));

select count(*) from gn_land_points_all glpa ;
select count(*) from lot_information_gn_mat ligm ;

create index gn_points_pnu_idx on gn_land_points_all(pnu);
select count(*) from (select pnu, st_intersects((select glpa.geom from gn_land_points_all glpa where glpa.pnu=li.pnu), (select jd_merged from jd_merged_0420)) jd_check from lot_information_gn_mat li) t where t.jd_check is null;

create table gn_lands_jdcheck as select pnu, st_intersects((select glpa.geom from gn_land_points_all glpa where glpa.pnu=li.pnu), (select jd_merged from jd_merged_0420)) jd_check from lot_information_gn_mat li;
update gn_lands_jdcheck set jd_check=false where jd_check is null;

-- 집합건물 유닛구성 데이터
select * from building_pyojebu_gn bpg where rgst_typ_nm ='집합';
select count(*) from building_pyojebu_gn bpg where rgst_typ_nm ='집합';

select count(mgm_bldrgst_pk) from building_pyojebu_gn;
select count(mgm_bldrgst_pk) from building_busok_gn bbg;

create table asset_coll_units_data(
pnu text,
coll_units_data jsonb
);
create index asset_cud_pnu_idx on asset_coll_units_data(pnu);

-- 지하철 인원수 데이터 
select name, (select count(*) from metro_user_counts muc where muc.station = gsm.name) from gn_subways_merged gsm;

drop table asset_subways_dists2; 
create table asset_subways_dists2 as select pnu, 
(case 
when (select count(*) from gn_subways_merged gsm where st_intersects(st_buffer(a.asset_pol, 0.015), gsm.geom))>=4
then (select array_agg(jsonb_build_object('name', gsm."name", 'dist', st_distance(a.asset_pol, gsm.geom, true), 'lines', gsm.lines )) from gn_subways_merged gsm where st_intersects(st_buffer(a.asset_pol, 0.015), gsm.geom))
when (select count(*) from gn_subways_merged gsm where st_intersects(st_buffer(a.asset_pol, 0.03), gsm.geom))>=4
then (select array_agg(jsonb_build_object('name', gsm."name", 'dist', st_distance(a.asset_pol, gsm.geom, true), 'lines', gsm.lines)) from gn_subways_merged gsm where st_intersects(st_buffer(a.asset_pol, 0.03), gsm.geom))
when (select count(*) from gn_subways_merged gsm where st_intersects(st_buffer(a.asset_pol, 0.1), gsm.geom))>=4
then (select array_agg(jsonb_build_object('name', gsm."name", 'dist', st_distance(a.asset_pol, gsm.geom, true), 'lines', gsm.lines)) from gn_subways_merged gsm where st_intersects(st_buffer(a.asset_pol, 0.1), gsm.geom))
else (select array_agg(jsonb_build_object('name', gsm."name", 'dist', st_distance(a.asset_pol, gsm.geom, true), 'lines', gsm.lines)) from gn_subways_merged gsm )
end)
from asset a;

select count(distinct asset_pnu) from asset;
select count(*) from asset

select count(distinct asset_pnu) from asset_subways_dists2 asd; 

select count(pnu) from asset_subway;
select count(distinct pnu) from asset_subway;
select pnu, count(*) from asset_subway group by pnu;

-- 유사 거래사례(토지, 건물) 업데이트 

-- 집합건물 추정가 업데이트 

select count(*) from "asset_jiphap_unit_module 1";
select count(distinct pnu) from "asset_jiphap_unit_module 1";

select count(distinct pnu) from "asset_jiphap_unit_module 1 statics";

select count(distinct pnu) from "asset_jiphap_unit_module 2";

select * from "asset_jiphap_unit_module 2" where use <> '공동주택';

select count(distinct pnu) from "asset_jiphap_unit_module 1 statics" aj where aj.pnu not in (select pnu from asset);

create index ajum1_pnu on 

