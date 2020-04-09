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




