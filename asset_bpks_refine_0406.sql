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

