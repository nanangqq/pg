select count(*) from building_pyojebu;
select count(*) from building_busok;

-- primary key 추가 
alter table building_pyojebu add primary key (pnu, mgm_bldrgst_pk);

-- index 추가 
create index idx_busok_pnu on building_busok(pnu);
create index idx_busok_bpk on building_busok(mgm_bldrgst_pk);
create index idx_pyojebu_bpk on building_pyojebu(mgm_bldrgst_pk);
create index idx_lot_info_pnu on lot_information(pnu);
create index idx_pol_lands_pnu on pol_seoul_lands_all(pnu);

-- 외필지수 있을 경우 부속에서 pnu 탐색
select count(pnu) from building_pyojebu where etclot_cnt > 0;

select pnu, etclot_cnt, (select array_agg(bb.pnu) from building_busok bb where bb.mgm_bldrgst_pk = bp.mgm_bldrgst_pk) from building_pyojebu bp where etclot_cnt > 0;

select bb.pnu, bb.mgm_bldrgst_pk, 
--(select array_agg(bp.pnu) from building_pyojebu bp where bp.mgm_bldrgst_pk = bb.mgm_bldrgst_pk), 
(select count(bp2.pnu) from building_pyojebu bp2 where bp2.pnu=bb.pnu) 
from building_busok bb;

select * from building_busok bb where pnu='1141012000100500003';
select * from building_pyojebu where pnu='1141012000100500003';
select * from gnlands where pnu='1141012000100500003';

-- 강남구 대상 view 작성
select count(pnu) from pol_seoul_lands_all where pnu like '11680%';
select geom from pol_seoul_lands_all where pnu like '1168010600%';

create view pol_seoul_lands_gn as select * from pol_seoul_lands_all where pnu like '11680%';

CREATE INDEX idx_seoul_lands_all
  ON pol_seoul_lands_all
  USING GIST (geom);

select distinct jimok from pol_seoul_lands_all;
select jimok, count(pnu) from pol_seoul_lands_all group by jimok;
select * from pol_seoul_lands_all psla where jimok in ('5','6','2','3');
select * from pol_seoul_lands_all psla where pnu='1168010800102740012';
select * from lot_information li where pnu='1168010800102740012';
select * from lot_information li where pnu='1165010200101050023';

select jimok, count(pnu) from pol_seoul_lands_gn group by jimok;
select count(*) from pol_seoul_lands_gn;
select count(*) from lot_information li where pnu like '11680%';

select * from pol_seoul_lands_gn pslg where (select count(*) from lot_information li where li.pnu = pslg.pnu)=0;
select * from building_pyojebu bp where pnu in ('1168010100108020024',
'1168010300105680042',
'1168010300105680043',
'1168010300105680044',
'1168010300105680045',
'1168010300105680046',
'1168010300105680047',
'1168010300105680048',
'1168010300105680049',
'1168010400100770036',
'1168010400100770037',
'1168010400100770038',
'1168010400100770055',
'1168010400100770056',
'1168010400100770072',
'1168010400100770073',
'1168010400100770102',
'1168011100101000031',
'1168011100101020033',
'1168011100101150003',
'1168011100101150007',
'1168011100101290003',
'1168011100104290003',
'1168011200101990001',
'1168011300101940006',
'1168011400106700014'); -- 지적도는 있지만 토지대장에 없는 땅
select * from building_busok where pnu in ('1168010100108020024',
'1168010300105680042',
'1168010300105680043',
'1168010300105680044',
'1168010300105680045',
'1168010300105680046',
'1168010300105680047',
'1168010300105680048',
'1168010300105680049',
'1168010400100770036',
'1168010400100770037',
'1168010400100770038',
'1168010400100770055',
'1168010400100770056',
'1168010400100770072',
'1168010400100770073',
'1168010400100770102',
'1168011100101000031',
'1168011100101020033',
'1168011100101150003',
'1168011100101150007',
'1168011100101290003',
'1168011100104290003',
'1168011200101990001',
'1168011300101940006',
'1168011400106700014');

create view lot_information_gn as select * from lot_information li where pnu like '11680%';
select * from lot_information_gn li where (select count(*) from pol_seoul_lands_gn pslg where pslg.pnu = li.pnu) = 0;
select * from building_pyojebu bp where pnu in (
'1168010100108990001',
'1168010300100570008',
'1168010300201400004',
'1168010600100500034',
'1168010600100500035',
'1168010700103990002',
'1168010700104120006',
'1168010700104120009',
'1168010700104140005',
'1168010700104140007',
'1168010700104140008',
'1168010700104220000',
'1168010700105550041', -- 도로,, 신사동 555-7번(대지)과 같은 위치로 찍힘(네이버지도에서) 
'1168011100100010015',
'1168011100200340003',
'1168011400101680011',
'1168011400105510000',
'1168011800101150001',
'1168011800109350001'
); -- 토지대장엔 있지만 지적도는 없는 땅 
select * from building_busok bb where pnu in (
'1168010100108990001',
'1168010300100570008',
'1168010300201400004',
'1168010600100500034',
'1168010600100500035',
'1168010700103990002',
'1168010700104120006',
'1168010700104120009',
'1168010700104140005',
'1168010700104140007',
'1168010700104140008',
'1168010700104220000',
'1168010700105550041',
'1168011100100010015',
'1168011100200340003',
'1168011400101680011',
'1168011400105510000',
'1168011800101150001',
'1168011800109350001'
);
select * from pol_seoul_lands_gn pslg where pnu='1168010700105550041';

-- 표제부, 부속 강남구 뷰 작성 
create view building_pyojebu_gn as select * from building_pyojebu bp where pnu like '11680%';
create view building_busok_gn as select * from building_busok where pnu like '11680%';
select count(*) from building_busok_gn bbg ;
select count(*) from building_pyojebu_gn bpg ;

-- 외필지 있는 토지
select count(*) from building_pyojebu_gn bpg where etclot_cnt > 0; -- 표제부에서 외필지수 1 이상인 것들: 2360개 
select count(distinct mgm_bldrgst_pk) from building_pyojebu_gn bpg;
select count(*)	from building_pyojebu_gn bpg ;

-- 탐색적 ... 
select count(*) from building_busok_gn bbg where (select count(*) from building_pyojebu_gn bpg where bpg.mgm_bldrgst_pk = bbg.mgm_bldrgst_pk)>0;
select * from building_busok_gn bbg where (select count(*) from building_pyojebu_gn bpg where bpg.mgm_bldrgst_pk = bbg.mgm_bldrgst_pk)>0;
select count(distinct bbg.mgm_bldrgst_pk) from building_busok_gn bbg where (select count(*) from building_pyojebu_gn bpg where bpg.mgm_bldrgst_pk = bbg.mgm_bldrgst_pk)>0;

select bbg.mgm_bldrgst_pk, count(distinct bbg.pnu), array_agg(distinct bbg.pnu) from building_busok_gn bbg where (select count(*) from building_pyojebu_gn bpg where bpg.mgm_bldrgst_pk = bbg.mgm_bldrgst_pk)>0 group by bbg.mgm_bldrgst_pk;
create view etclots_tmp as select bbg.mgm_bldrgst_pk, count(distinct pnu), array_agg(distinct pnu) from building_busok_gn bbg where (select count(*) from building_pyojebu_gn bpg where bpg.mgm_bldrgst_pk = bbg.mgm_bldrgst_pk)>0 group by bbg.mgm_bldrgst_pk;
select count(*) from etclots_tmp et ; -- 부속에서 표제부에 건축물대장관리코드 같은것이 있는 것들: 2352개 
select count(distinct mgm_bldrgst_pk) from etclots_tmp et;
select pslg.pnu, pslg.geom from pol_seoul_lands_gn pslg where pslg.pnu in ;

create view  as select bbg.mgm_bldrgst_pk, bbg.pnu,(select array_agg from etclots_tmp et where et.mgm_bldrgst_pk = bbg.mgm_bldrgst_pk) from building_busok_gn bbg where (select count(*) from building_pyojebu_gn bpg where bpg.mgm_bldrgst_pk = bbg.mgm_bldrgst_pk)>0;
select count(*) from building_busok_gn bbg where (select count(*) from building_pyojebu_gn bpg where bpg.mgm_bldrgst_pk = bbg.mgm_bldrgst_pk)>0;

select * from building_pyojebu_gn bpg where etclot_cnt > 0 and (select count(*) from etclots_tmp et where et.mgm_bldrgst_pk = bpg.mgm_bldrgst_pk)=0 ; -- 표제부에서 etclots_tmp 에 건축물대장관리코드가 없는 것들: 20개
select pnu, rgst_case_nm from building_busok_gn bbg where (select count(*) from building_pyojebu_gn bpg where bpg.mgm_bldrgst_pk = bbg.mgm_bldrgst_pk)=0; -- 부속에서 표제부에 같은 건축물대장관리코드가 없는 것들: 400개 -> distinct pnu 110개 
select * from building_pyojebu_gn bpg2 where bpg2.pnu in (select distinct pnu from building_busok_gn bbg where (select count(*) from building_pyojebu_gn bpg where bpg.mgm_bldrgst_pk = bbg.mgm_bldrgst_pk)=0); -- 표제부에서 위 110개 pnu값과 같은 pnu인 건축물대장 -> 같은 땅에 있는 건축물인데 부속건물에 있지 않고 따로 표제부에 있는 것들: 34개   
select * from building_busok_gn bbg where bbg.pnu in (select distinct pnu from building_pyojebu_gn bpg); -- 부속에서 표제부에 동일한 pnu있는 것들: 45개 

select rgst_case_nm, count(*) from building_pyojebu_gn bpg group by rgst_case_nm; -- 표제부테이블에서 일반건축물대장, 표제부 개수 
select rgst_case_nm, count(*) from building_busok_gn group by rgst_case_nm; -- 부속테이블에서 일반건축물대장, 표제부, 총괄표제부 개수 (총괄표제부 400개 -> 부속에서 표제부에 같은 건축물대장관리코드가 없는 것들: 400개 와 동일)

select bbg.pnu, mgm_bldrgst_pk, atch_bjd_cd, atch_bun, atch_ji, atch_etc_bunji_nm from building_busok_gn bbg where bbg.pnu in (select distinct bpg.pnu from building_pyojebu_gn bpg where etclot_cnt > 0);

select bbg.pnu, mgm_bldrgst_pk, atch_bjd_cd, atch_bun, atch_ji, atch_etc_bunji_nm from building_busok_gn bbg where bbg.mgm_bldrgst_pk in (select distinct bpg.mgm_bldrgst_pk from building_pyojebu_gn bpg where etclot_cnt > 0);
select * from building_pyojebu_gn bpg where pnu='1168010100108270001';
select * from building_busok_gn bbg where pnu='1168010100108270001';
select * from building_pyojebu_gn bpg where mgm_bldrgst_pk = '11680-10009';

select * from building_pyojebu bp where mgm_bldrgst_pk = '11680-10009'; -- 테이블에서는 pnu 1168010100108270080 로 나오는데 실제 데이터 열어보면 1168010100108270001로 제대로 나옴. pandas에서 가져올 때, 혹은 여기서 데이터타입바꾸거나 할때 뭔가 문제가 있었던듯?? 
select count(distinct pnu) from building_pyojebu bp ; -- 7만개...
select count(distinct pnu) from building_busok ; -- 4.6만개
select count(distinct pnu) from lot_information; -- 94만 same as df
select count(distinct pnu) from pol_seoul_lands_all; -- 94만 same as df
-- 탐색 끝 ...
-- 표제부 pnu문자열로 바꿔서 다시 import 후 다시 탐색
select * from building_pyo2 where mgm_bldrgst_pk = '11680-10009'; -- pnu ok

-- primary key, index 추가 
alter table building_pyo2 add primary key (pnu, mgm_bldrgst_pk);
create index idx_pyojebu2_bpk on building_pyo2(mgm_bldrgst_pk);


select count(distinct pnu) from building_pyo2; -- 54만..
select count(distinct pnu) from building_busok2; -- 4.6만개 (동일) ? 왜 표제부만 문제가 생겼는지,,, 둘다 float으로 들어와서 문자열로 바꿔준건 똑같음 

create view building_pyojebu_gn as select * from building_pyo2 bp where pnu like '11680%';

select count(distinct mgm_bldrgst_pk) from building_pyojebu_gn bpg ; -- 24575
select count(*) from building_pyojebu_gn; --24575

select bpg.pnu, (select array_agg(format('%s-%s',text(bbg.atch_bun),text(bbg.atch_ji))) from building_busok_gn bbg where bbg.mgm_bldrgst_pk = bpg.mgm_bldrgst_pk ) from building_pyojebu_gn bpg where bpg.etclot_cnt > 0; -- 2360
select count(distinct bpg.pnu) from building_pyojebu_gn bpg where bpg.etclot_cnt > 0; -- 1843

select count(distinct bbg.pnu) from building_busok_gn bbg where bbg.pnu in (select pnu from building_pyojebu_gn bpg where bpg.etclot_cnt > 0); -- 1841
select count(distinct bbg.mgm_bldrgst_pk ) from building_busok_gn bbg where bbg.pnu in (select pnu from building_pyojebu_gn bpg where bpg.etclot_cnt > 0); -- 2450
select * from (select bbg.pnu, bbg.adr_bsc, bbg.atch_bun, bbg.atch_ji, format('%s%s1%s%s', text(atch_sgg_cd), text(atch_bjd_cd), lpad(text(atch_bun),4,'0'), lpad(text(atch_ji),4,'0')) pnu_gen, (select count(*) from lot_information_gn lig where lig.pnu = format('%s%s1%s%s', text(atch_sgg_cd), text(atch_bjd_cd), lpad(text(atch_bun),4,'0'), lpad(text(atch_ji),4,'0'))) cnt from building_busok_gn bbg where bbg.pnu in (select pnu from building_pyojebu_gn bpg where bpg.etclot_cnt > 0)) tt where cnt=0;
-- 380 개 (주소 정보 잘못 입력되어있는 것들, 혹은 산, 임야 같은 것들)
select count(*) from (select bbg.pnu, bbg.adr_bsc, bbg.atch_bun, bbg.atch_ji, format('%s%s1%s%s', text(atch_sgg_cd), text(atch_bjd_cd), lpad(text(atch_bun),4,'0'), lpad(text(atch_ji),4,'0')) pnu_gen, (select count(*) from lot_information_gn lig where lig.pnu = format('%s%s1%s%s', text(atch_sgg_cd), text(atch_bjd_cd), lpad(text(atch_bun),4,'0'), lpad(text(atch_ji),4,'0'))) cnt from building_busok_gn bbg where bbg.pnu in (select pnu from building_pyojebu_gn bpg where bpg.etclot_cnt > 0)) tt where cnt>0;
select count(*) from (select bbg.pnu, bbg.adr_bsc, bbg.atch_bun, bbg.atch_ji, format('%s%s1%s%s', text(atch_sgg_cd), text(atch_bjd_cd), lpad(text(atch_bun),4,'0'), lpad(text(atch_ji),4,'0')) pnu_gen, (select count(*) from lot_information_gn lig where lig.pnu = format('%s%s1%s%s', text(atch_sgg_cd), text(atch_bjd_cd), lpad(text(atch_bun),4,'0'), lpad(text(atch_ji),4,'0'))) cnt from building_busok_gn bbg where bbg.pnu in (select pnu from building_pyojebu_gn bpg where bpg.etclot_cnt > 0)) tt where cnt=1;
-- 5244 개 
select lpad('999',4,'0');

create view busok_pnu as select * from (select bbg.pnu, bbg.mgm_bldrgst_pk, bbg.adr_bsc, bbg.atch_bun, bbg.atch_ji, format('%s%s1%s%s', text(atch_sgg_cd), text(atch_bjd_cd), lpad(text(atch_bun),4,'0'), lpad(text(atch_ji),4,'0')) pnu_gen, (select count(*) from lot_information_gn lig where lig.pnu = format('%s%s1%s%s', text(atch_sgg_cd), text(atch_bjd_cd), lpad(text(atch_bun),4,'0'), lpad(text(atch_ji),4,'0'))) cnt from building_busok_gn bbg where bbg.pnu in (select pnu from building_pyojebu_gn bpg where bpg.etclot_cnt > 0)) tt where cnt=1;
select count(distinct pnu) from busok_pnu bp;
select count(distinct mgm_bldrgst_pk) from busok_pnu bp;
select count(distinct pnu) from busok_pnu bp where bp.pnu in (select bpg.pnu from building_pyojebu_gn bpg);
-- 1757 개 
select count(*) from pol_seoul_lands_gn pslg where pslg.pnu in (select distinct bp.pnu from busok_pnu bp); -- 1748개 (토지대장은 있지만 폴리곤 없는 것들)
select count(*) from lot_information_gn lig where lig.pnu in (select bp.pnu from busok_pnu bp); --and lig.pnu in (select pslg.pnu from pol_seoul_lands_gn pslg);
select count(*) from lot_information_gn lig2 where lig2.pnu in (select distinct pnu from busok_pnu bp);

select count(distinct pnu_gen) from busok_pnu bp; -- 2949개 
select count(*) from lot_information_gn lig where lig.pnu in (select distinct pnu_gen from busok_pnu bp); -- 2949

select * from busok_pnu bp where bp.pnu in (select distinct pnu_gen from busok_pnu bp2 ); --표제부 pnu중에서 부속 pnu에 같은 값이 있는 것들 104개
select count(*) from busok_pnu bp where bp.pnu not in (select distinct pnu_gen from busok_pnu bp2 ); --표제부 pnu중에서 부속 pnu에 같은 값이 없는 것들 5141 => select!!!!! 1차로 
select * from busok_pnu bp where pnu_gen='1168010400101340015';--뭔가 이상한데? 건축물대장 api에서 주소가 잘못 되어있음... 청담동 133-3 번지 부속건축물대장 api에서 가져오면 옆에 134번지쪽에 상가와 아파트 부속건축물 정보가 뜸,,,

select * from busok_pnu bp;
select * from building_pyojebu_gn bpg where pnu='1168010500100730000';

select array_agg(distinct bp.pnu),bp.mgm_bldrgst_pk,count(distinct bp.pnu_gen),array_agg(distinct bp.pnu_gen),array_cat(array_agg(distinct bp.pnu),array_agg(distinct bp.pnu_gen)) from busok_pnu bp where bp.pnu not in (select distinct pnu_gen from busok_pnu bp2) group by mgm_bldrgst_pk;
select * from (select count(distinct bp.pnu) cnt,array_agg(distinct bp.pnu),count(distinct bp.pnu_gen),array_agg(distinct bp.pnu_gen),array_cat(array_agg(distinct bp.pnu),array_agg(distinct bp.pnu_gen)) from busok_pnu bp where bp.pnu not in (select distinct pnu_gen from busok_pnu bp2) group by mgm_bldrgst_pk) kk where cnt>1; -- 없음 

select bp.pnu,array_agg(bp.mgm_bldrgst_pk),count(distinct bp.pnu_gen),array_agg(distinct bp.pnu_gen),array_cat(array_agg(distinct bp.pnu),array_agg(distinct bp.pnu_gen)) from busok_pnu bp where bp.pnu not in (select distinct pnu_gen from busok_pnu bp2) group by bp.pnu, bp.mgm_bldrgst_pk;

create view pnu_bpk_busok as select bp.pnu pnu_main, array_agg(distinct bp.mgm_bldrgst_pk) bpks, count(distinct bp.pnu_gen) bpnu_length, array_cat(array_agg(distinct bp.pnu),array_agg(distinct bp.pnu_gen)) bpnus from busok_pnu bp where bp.pnu not in (select distinct pnu_gen from busok_pnu bp2) group by bp.pnu;
select count(*) from pnu_bpk_busok; --1744

create view bpk_busok as select array_agg(distinct bp.pnu) pnu_main, array_agg(distinct bp.mgm_bldrgst_pk) bpks, count(distinct bp.pnu_gen) bpnu_length, array_cat(array_agg(distinct bp.pnu),array_agg(distinct bp.pnu_gen)) bpnus from busok_pnu bp where bp.pnu not in (select distinct pnu_gen from busok_pnu bp2) group by bp.mgm_bldrgst_pk;
select array_length(pnu_main,1) from bpk_busok bb;
select count(*) from (select a.pnu, array_agg(a.bpks), array_agg(a.bpnus) from (select unnest(bb.pnu_main) pnu, * from bpk_busok bb) a group by a.pnu) t; --1744

select count(distinct pnu_main) from pnu_bpk_busok; --1744
select pnu_main, bpks, unnest(bpnus) from pnu_bpk_busok;
select * from pnu_bpk_busok pbb;

select count(*) from (select distinct unnest(bpnus) from pnu_bpk_busok) tt; --4682
select count(*) from (select unnest(bpnus) from pnu_bpk_busok) tt; --4684
select cnt, bpnu from (select count(tmp.pnu_main) cnt, tmp.bpnu from (select unnest(pbb.bpnus) bpnu, *, (select st_collect from pols_by_main_pnu pbmp where pbmp.pnu_main=pbb.pnu_main) from pnu_bpk_busok pbb) tmp group by tmp.bpnu) tmp2 where cnt>1; --2개
--select tt.bpnu from (select distinct unnest(bpnus) bpnu from pnu_bpk_busok) tt;
select *, (select st_collect from pols_by_main_pnu pbmp where pbmp.pnu_main=tt.pnu_main) from (select distinct unnest(bpnus) bpnu, * from pnu_bpk_busok) tt where bpnu in ('1168010300111840025','1168011800101080000');
select * from building_busok_gn bbg where atch_bjd_cd=11800 and atch_bun=108;
select * from building_busok_gn bbg2 where bbg2.mgm_bldrgst_pk in (select mgm_bldrgst_pk from building_busok_gn bbg where atch_bjd_cd=11800 and atch_bun=108) and bbg2.atch_bun=108;

-- main 땅 pnu마다 폴리곤 union 만들기 -> 합쳐서 하나로 만들어버림,,
select st_union( (select array_agg(geom) from pol_seoul_lands_gn pslg where pslg.pnu in (select unnest(bpnus) from pnu_bpk_busok where pnu_main='1168010100106230003') ) );

-- main 땅 pnu마다 폴리곤 collection? => ok
select st_collect( (select array_agg(geom) from pol_seoul_lands_gn pslg where pslg.pnu in (select unnest(bpnus) from pnu_bpk_busok where pnu_main='1168010100106230003') ) );
select pbb.pnu_main, pbb.bpks, st_collect( (select array_agg(geom) from pol_seoul_lands_gn pslg where pslg.pnu in (select unnest(pbb2.bpnus) from pnu_bpk_busok pbb2 where pbb2.pnu_main=pbb.pnu_main) ) ) from pnu_bpk_busok pbb;

create materialized view pols_by_main_pnu 
as select pbb.pnu_main, pbb.bpks, st_collect( (select array_agg(geom) from pol_seoul_lands_gn pslg where pslg.pnu in (select unnest(pbb2.bpnus) from pnu_bpk_busok pbb2 where pbb2.pnu_main=pbb.pnu_main) ) ) from pnu_bpk_busok pbb
with data;


--select st_astext(st_collect), (select sum(area) from lot_information_gn li where li.pnu in ((select bpnus from pnu_bpk_busok2 pbb where pbb.pnu_main = pbmp.pnu_main)))) area from pols_by_main_pnu2 pbmp where pnu_main = (select pnu_main from busok_main_pnu_map where bpnu='1168010600109460010' limit 1);

-- 강남구 pnu마다 엮인 토지 있으면 합산면적 구하기 0217
select pnu, area, coalesce( 
(select sum(lig2.area) from lot_information_gn lig2 where lig2.pnu in (select unnest(pbb.bpnus) from pnu_bpk_busok2 pbb where pbb.pnu_main = (select bmpm.pnu_main from busok_main_pnu_map bmpm where bmpm.bpnu = lig.pnu limit 1))),
(select sum(lig2.area) from lot_information_gn lig2 where lig2.pnu in (select unnest(pbb.bpnus) from pnu_bpk_busok2 pbb where pbb.pnu_main = (select pbmp.pnu_main from pols_by_main_pnu2 pbmp where pbmp.pnu_main = lig.pnu))), 
area) area_total from lot_information_gn lig;-- 1000개 약 12~20 초 정도? 넘 오래걸림 

create materialized view lot_information_gn_mat as select * from lot_information_gn with data;
create materialized view pnu_bpk_busok2_mat as select * from pnu_bpk_busok2 with data;
create index idx_bmpm on busok_main_pnu_map(bpnu);
create index idx_pbmp on pols_by_main_pnu2(pnu_main);
create index idx_lot_pnu on lot_information_gn_mat(pnu);
create index idx_pbb on pnu_bpk_busok2_mat(pnu_main);
-- 인덱스 작성  

select pnu, area, coalesce( 
(select sum(lig2.area) from lot_information_gn_mat lig2 where lig2.pnu in (select unnest(pbb.bpnus) from pnu_bpk_busok2_mat pbb where pbb.pnu_main = (select bmpm.pnu_main from busok_main_pnu_map bmpm where bmpm.bpnu = lig.pnu limit 1))),
(select sum(lig2.area) from lot_information_gn_mat lig2 where lig2.pnu in (select unnest(pbb.bpnus) from pnu_bpk_busok2_mat pbb where pbb.pnu_main = (select pbmp.pnu_main from pols_by_main_pnu2 pbmp where pbmp.pnu_main = lig.pnu))), 
area) area_total from lot_information_gn lig;-- 1000개 412ms,, good

create materialized view pnu_area_total_gn as select pnu, area, coalesce( 
(select sum(lig2.area) from lot_information_gn_mat lig2 where lig2.pnu in (select unnest(pbb.bpnus) from pnu_bpk_busok2_mat pbb where pbb.pnu_main = (select bmpm.pnu_main from busok_main_pnu_map bmpm where bmpm.bpnu = lig.pnu limit 1))),
(select sum(lig2.area) from lot_information_gn_mat lig2 where lig2.pnu in (select unnest(pbb.bpnus) from pnu_bpk_busok2_mat pbb where pbb.pnu_main = (select pbmp.pnu_main from pols_by_main_pnu2 pbmp where pbmp.pnu_main = lig.pnu))), 
area) area_total from lot_information_gn lig with data;

select *, coalesce( 
(select text(pbb.bpnus) from pnu_bpk_busok2_mat pbb where pbb.pnu_main = (select bmpm.pnu_main from busok_main_pnu_map bmpm where bmpm.bpnu = patg.pnu limit 1)),
(select text(pbb.bpnus) from pnu_bpk_busok2_mat pbb where pbb.pnu_main = (select pbmp.pnu_main from pols_by_main_pnu2 pbmp where pbmp.pnu_main = patg.pnu)),
'') from pnu_area_total_gn patg; -- 엮인 토지 합산면적 + pnu 리스트 

-- 동 경계 
select * from pol_dong_bounds pdb where "EMD_NM" ='역삼동';

-- 용도지역 분류하기 
CREATE INDEX pol_sgg_bounds_idx ON pol_sgg_bounds USING GIST(geom);
CREATE INDEX pol_landuse_living_idx ON pol_landuse_living USING GIST(geom);
CREATE INDEX pol_landuse_comm_idx ON pol_landuse_comm USING GIST(geom);
CREATE INDEX pol_landuse_nature_idx ON pol_landuse_nature USING GIST(geom);

create view pol_landuse_living_gn as select * from pol_landuse_living pll where st_intersects( pll.geom, (select psb.geom from pol_sgg_bounds psb where "SGG_NM" = '강남구') );
create view pol_landuse_comm_gn as select * from pol_landuse_comm pll where st_intersects( pll.geom, (select psb.geom from pol_sgg_bounds psb where "SGG_NM" = '강남구') );
create view pol_landuse_nature_gn as select * from pol_landuse_nature pll where st_intersects( pll.geom, (select psb.geom from pol_sgg_bounds psb where "SGG_NM" = '강남구') );

select * from pol_landuse_living_gn pllg where "LABEL" != "ENT_NAME" ;
select * from pol_landuse_living_gn pllg where "ENT_NAME"='제2종일반주거지역(12층)' ;
select * from pol_landuse_living_gn pllg where "LABEL"='제2종일반주거지역(12층)' ;
select lb, ( select st_collect( (select array_agg(geom) from pol_landuse_living_gn pllg where pllg."ENT_NAME"=lb) ) ) from (select distinct "ENT_NAME" lb from pol_landuse_living_gn) lbs;
select st_collect( (select array_agg(geom) from pol_landuse_living_gn pllg ) );
select lb, ( select st_collect( (select array_agg(geom) from pol_landuse_comm_gn plcg where plcg."ENT_NAME"=lb) ) ) from (select distinct "ENT_NAME" lb from pol_landuse_comm_gn) lbs;

create materialized view landuse_unions as 
select lb, ( select st_union( (select array_agg(geom) from pol_landuse_living_gn pllg where pllg."ENT_NAME"=lb) ) ) from (select distinct "ENT_NAME" lb from pol_landuse_living_gn) lbs
union 
select lb, ( select st_union( (select array_agg(geom) from pol_landuse_comm_gn plcg where plcg."ENT_NAME"=lb) ) ) from (select distinct "ENT_NAME" lb from pol_landuse_comm_gn) lbs
union 
select lb, ( select st_union( (select array_agg(geom) from pol_landuse_nature_gn plng where plng."ENT_NAME"=lb) ) ) from (select distinct "ENT_NAME" lb from pol_landuse_nature_gn) lbs;

select * from pol_seoul_lands_gn pslg where st_intersects( pslg.geom, (select lc.st_union from landuse_unions lc where lc.lb='제1종일반주거지역') );

select * from pol_seoul_lands_gn_mat pslg where (select count(*) from landuse_unions lu where st_intersects( pslg.geom, lu.st_union ) ) > 1; -- 그냥하니 오래걸림,,, -> lauduse_union 인덱스 거니 36초,, (1000row)
select count(*) from pol_seoul_lands_gn_mat pslg where (select count(*) from landuse_unions lu where st_intersects( pslg.geom, lu.st_union ) ) > 1; -- 6327개,, -> 3분 30
create index lauduse_union_idx on landuse_unions using gist(st_union);
create index lauduse_union_lb_idx on landuse_unions(lb);
create materialized view pol_seoul_lands_gn_mat as select * from pol_seoul_lands_gn with data;
CREATE INDEX pol_seoul_lands_gn_idx ON pol_seoul_lands_gn_mat USING GIST(geom);

select st_area( st_intersection( geom, (select st_union from landuse_unions lu where lu.lb='제1종일반주거지역') ), true), (select area from lot_information_gn_mat ligm where ligm.pnu=pslgm.pnu) from pol_seoul_lands_gn_mat pslgm;

drop function get_landuse_ints;
create or replace FUNCTION get_landuse_ints(
geom geometry,
lu text) 
RETURNS float
AS $$
q = plpy.prepare("select st_area( st_intersection( st_makevalid($1), (select st_union from landuse_unions lu where lu.lb=$2) ), true)", ['geometry', 'text'])
try:
	area = q.execute([geom, lu], 1)[0]['st_area']
except:
	area = -1
return area
$$ LANGUAGE plpython3u
IMMUTABLE
RETURNS NULL ON NULL INPUT; --plpy.execute(""%pnu_gen)[0]['count']

select 
pslgm.pnu,
get_landuse_ints(geom, '일반상업지역') ilsang,
get_landuse_ints(geom, '제1종일반주거지역') ilju_1,
get_landuse_ints(geom, '제1종전용주거지역') jnju_1,
get_landuse_ints(geom, '제2종일반주거지역') ilju_2,
get_landuse_ints(geom, '제2종일반주거지역(7층이하)') ilju_2_und7,
get_landuse_ints(geom, '제3종일반주거지역') ilju_3,
get_landuse_ints(geom, '준주거지역') semiju,
get_landuse_ints(geom, '생산녹지지역') pd_green,
get_landuse_ints(geom, '자연녹지지역') nt_green,
get_landuse_ints(geom, '도시계획 시설') ubp_fc,
st_area(geom, true), 
(select area from lot_information_gn_mat ligm where ligm.pnu=pslgm.pnu) 
from pol_seoul_lands_gn_mat pslgm ; -- 용도지역별로 겹치는 영역 면적 계산 

create materialized view lu_areas_gn_lands as 
select 
pslgm.pnu,
get_landuse_ints(geom, '일반상업지역') ilsang,
get_landuse_ints(geom, '제1종일반주거지역') ilju_1,
get_landuse_ints(geom, '제1종전용주거지역') jnju_1,
get_landuse_ints(geom, '제2종일반주거지역') ilju_2,
get_landuse_ints(geom, '제2종일반주거지역(7층이하)') ilju_2_und7,
get_landuse_ints(geom, '제3종일반주거지역') ilju_3,
get_landuse_ints(geom, '준주거지역') semiju,
get_landuse_ints(geom, '생산녹지지역') pd_green,
get_landuse_ints(geom, '자연녹지지역') nt_green,
get_landuse_ints(geom, '도시계획 시설') ubp_fc,
st_area(geom, true), 
(select area from lot_information_gn_mat ligm where ligm.pnu=pslgm.pnu) 
--from pol_seoul_lands_gn_mat pslgm where not st_isvalid(geom) -- st_isvalid 로 나온 애들은 오히려 별 문제 없이 됨,,
from pol_seoul_lands_gn_mat pslgm 
with data; -- get_landuse_ints 함수에서 st_intersection에러뜨면 면적 -1 리턴하는 것으로 수정,,

select * from pol_seoul_lands_gn_mat pslgm where not st_isvalid(geom); --15개 정도 invalid...

select array[sum(ilsang), sum(ilju_1)] from lu_areas_gn_lands lagl where ilju_3 =-1;
select * from lu_areas_gn_lands lagl2 where pnu='1168010600109500005';
select * from lu_areas_gn_lands lagl2 where ubp_fc>0;
select * from lu_areas_gn_lands lagl where ubp_fc =-1; -- 3종 일반주거 말고는 에러뜬것 없음,,, 전체 면적에서 빼거나 하는 식으로 수정해주면 될듯

select *, st_area-(ilsang + ilju_1 + ilju_2 + ilju_2_und7 + semiju + jnju_1 + pd_green + nt_green + ubp_fc) from lu_areas_gn_lands lagl where ilju_3 =-1;
create table lu_areas_gn_lands_bu as (select * from lu_areas_gn_lands); -- update 전에 backup table 생성 
update lu_areas_gn_lands_bu set ilju_3=st_area-(ilsang + ilju_1 + ilju_2 + ilju_2_und7 + semiju + jnju_1 + pd_green + nt_green + ubp_fc) where ilju_3 = -1;
select * from lu_areas_gn_lands_bu where pnu in (select pnu from lu_areas_gn_lands lagl where ilju_3 =-1);
update lu_areas_gn_lands_bu set ilju_3=0 where ilju_3 < 0; -- update 후에 table 그냥 사용하기로,, 일단 

create index lu_areas_gn_lands_bu_pnu_idx on lu_areas_gn_lands_bu(pnu);

select distinct use_nm from building_floor bf ;

create index pub_price_pnu_idx on pub_price_gn_lands(pnu);

select count(*) from lu_areas_gn_lands_bu laglb ;
select count(*) from pub_price_gn_lands ppgl ;

select count(ilsang*(select "JIGA" from pub_price_gn_lands ppgl where ppgl.pnu=lagl.pnu)) from lu_areas_gn_lands lagl where (select "JIGA" from pub_price_gn_lands ppgl where ppgl.pnu=lagl.pnu) isnull; -- null 인 행은 카운트 안됨,,
select count(ilsang*(select "JIGA" from pub_price_gn_lands ppgl where ppgl.pnu=lagl.pnu)) from lu_areas_gn_lands lagl where (select "JIGA" from pub_price_gn_lands ppgl where ppgl.pnu=lagl.pnu) notnull;
select count(ilsang*(select "JIGA" from pub_price_gn_lands ppgl where ppgl.pnu=lagl.pnu)) from lu_areas_gn_lands lagl ;
select ilsang*(select "JIGA" from pub_price_gn_lands ppgl where ppgl.pnu=lagl.pnu) from lu_areas_gn_lands lagl ; -- 34767 rows

select *, (select "JIGA" from pub_price_gn_lands ppgl where ppgl.pnu=lagl.pnu) from lu_areas_gn_lands lagl ; --> python 으로,, 

select st_area("geom", true) from pol_sgg_bounds psb where "SGG_NM" = '강남구';

select sum(gf_ar) from building_pyojebu_gn bpg ;

select sum(area) from building_floor bf where sgg_cd = 11680 ;

select geom from pol_gwang_bounds_sim pgbs where st_intersects(st_geometryfromtext('POINT(126.8754483 37.6543926)',4326), geom );

-- 구역별 평균 공시지가


update pol_gwang_bounds_sim set avg_pub_price = (select avg("PNILP") from pub_price_seoul pps) where ctprvn_cd = '11'; -- 걍 평균 
update pol_gwang_bounds_sim set avg_pub_price = (select sum("PNILP"*(select li.area from lot_information li where li.pnu=pps."PNU"))/sum((select li.area from lot_information li where li.pnu=pps."PNU")) from pub_price_seoul pps) where ctprvn_cd = '11'; -- 면적 가중 평균 
select psb."SGG_NM" ,(select avg("PNILP") from pub_price_seoul pps where "COL_ADM_SECT_CD" = psb."COL_ADM_SE") from pol_sgg_bounds psb ; -- 걍 평균 
select psb."SGG_NM" ,(select sum("PNILP"*(select li.area from lot_information li where li.pnu=pps."PNU"))/sum((select li.area from lot_information li where li.pnu=pps."PNU")) from pub_price_seoul pps where "COL_ADM_SECT_CD" = psb."COL_ADM_SE") from pol_sgg_bounds psb ;--면적가중평균 
update pol_sgg_bounds psb set avg_pub_price = (select sum("PNILP"*(select li.area from lot_information li where li.pnu=pps."PNU"))/sum((select li.area from lot_information li where li.pnu=pps."PNU")) from pub_price_seoul pps where pps."COL_ADM_SECT_CD" = psb."COL_ADM_SE");--면적가중평균 

select substring("PNU",1,8) from pub_price_seoul pps ;
select (select avg("PNILP") from pub_price_seoul pps where substring(pps."PNU",1,8)=pdb."EMD_CD" ) from pol_dong_bounds pdb ;
create index pps_pnu_idx on pub_price_seoul("PNU");
update pol_dong_bounds pdb set avg_pub_price = (select sum("PNILP"*(select li.area from lot_information li where li.pnu=pps."PNU"))/sum((select li.area from lot_information li where li.pnu=pps."PNU")) from pub_price_seoul pps where substring(pps."PNU",1,8)=pdb."EMD_CD" );

-- 옮기기용 테이블 작성 from views
create table _pol_seoul_lands_gn as select * from pol_seoul_lands_gn ;

-- office db start

REFRESH MATERIALIZED view busok_main_pnu_map ;
REFRESH MATERIALIZED view lu_areas_gn_lands ;
REFRESH MATERIALIZED view pnu_bpk_busok2_mat ;
REFRESH MATERIALIZED view pols_by_main_pnu2 ;
REFRESH MATERIALIZED view pnu_area_total_gn ;
REFRESH MATERIALIZED view pnu_main_comb_map ;
-- dump 파일 로드하면서 mat view 관련 에러 몇개 뜸 => refresh materialized view 명령으로 복구 가능,,,

create index aaa on building_floor(mgm_bldrgst_pk);
select count(distinct mgm_bldrgst_pk) from building_floor bf where pnu/100000000000000=11680;

select pnu/100000000000000 from building_floor bf limit 100;

-- avg pub price(area weighted) by gwang
select sum("PNILP"*(select area from jijuk_26 jj where jj."PNU"=pp."PNU" ))/sum((select area from jijuk_26 jj where jj."PNU"=pp."PNU" )) from pub_price_26 pp limit 10;
select sum("PNILP"*(select area from jijuk_26 jj where jj."PNU"=pp."PNU" )) from pub_price_26 pp limit 10;
select sum(ap) from (select "PNILP"*(select area from jijuk_26 jj where jj."PNU"=pp."PNU" ) ap from pub_price_26 pp limit 10) t;

update pol_gwang_bounds_sim set avg_pub_price = (select sum("PNILP"*(select area from jijuk_26 jj where jj."PNU"=pp."PNU" ))/sum((select area from jijuk_26 jj where jj."PNU"=pp."PNU" )) from pub_price_26 pp)
where ctprvn_cd = '26';

select count(*) from pub_price_27 pp ;

-- avg price
update pol_gwang_bounds_sim
set avg_pub_price = (select 
sum(
"PNILP"*(select area from jijuk_47 jj where jj."PNU"=pp."PNU" )
)/sum(
(select area from jijuk_47 jj where jj."PNU"=pp."PNU" )
) from pub_price_47 pp)
where ctprvn_cd='47';

-- 0311 서비스 외 지역 polygon
create table gu_out as select st_union(geom) geom from pol_gwang_bounds_buf pgbb where "index" != 0; -- union 된 뒤에 불러오는것이 너무 오래걸림,,, buff 먹인 뒤에 simplify 하고 union 해야 할듯 

