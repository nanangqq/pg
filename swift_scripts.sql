-- script
select id, pnu from gnlands where st_dwithin(
geom, st_geomfromtext('POINT(127.06300954673709 37.508712824948745)', 4326), 0.002
)

select id, pnu from gnlands2 where st_dwithin(
geom, st_geomfromtext('POINT(127.06300954673709 37.508712824948745)', 4326), 0.002
)

-- script1
create extension postgis;

DROP table jd_seoul_all;
create table jd_seoul_all(
DGM_NM varchar(50),
SIGNGU_SE integer,
geometry GEOMETRY(geometry, 4326)
);

--script2
select id, pnu from gnlands where st_dwithin(
geom, st_geomfromtext('POINT(127.06300954673709 37.508712824948745)', 4326), 0.001
)

select id, pnu from gnlands2 where st_dwithin(
geom, st_geomfromtext('POINT(127.06300954673709 37.508712824948745)', 4326), 0.001
)

--script3
aa

--script4
select * from asset where pnu='1168010600110120019'

select count(*) from lu_areas_gn_lands_bu laglb;

select count(*) from lot_information_gn lig; 

create index lig_pnu_idx on lot_information_gn(pnu);
create index bpg_bpk_idx on building_pyo_gn(mgm_bldrgst_pk);

select distinct jimok_nm from lot_information_gn lig;

select pnu, (select jimok_nm from lot_information_gn lig where lig.pnu=a.pnu) from asset a;

select coalesce, (select array_agg(jsonb_build_object(bpg.mgm_bldrgst_pk , bpg.dong_nm) ) from building_pyo_gn bpg where bpg.mgm_bldrgst_pk in (select unnest(abm."coalesce")) ) from asset_bpks_merged abm ;

update asset a set dong_nms = (select (select array_agg(jsonb_build_object(bpg.mgm_bldrgst_pk , bpg.dong_nm) ) from building_pyo_gn bpg where bpg.mgm_bldrgst_pk in (select unnest(abm."coalesce")) ) from asset_bpks_merged abm where abm.pnu=a.pnu)

select pnus from asset;
select (select array_agg(jsonb_build_object(lig.pnu, lig.area)) from lot_information_gn lig where lig.pnu in (select unnest(a.pnus))) from asset a;
update asset a set lands_area = (select array_agg(jsonb_build_object(lig.pnu, lig.area)) from lot_information_gn lig where lig.pnu in (select unnest(a.pnus)));


select count(*) from asset_non_resi_accom_price anrap;

select count(*) from asset_jiphap_unit_module_2 ajum ;

select count(distinct pnu) from asset_jiphap_unit_module_2 ajum ;

select count(distinct use) from asset_jiphap_unit_module_2 ajum ;
select distinct use from asset_jiphap_unit_module_2 ajum ;

select count(distinct use_detail ) from asset_jiphap_unit_module_1_statics ajums ;


-- 0529 new data
select count(*) from asset_jiphap_unit_module_2 ajum ;
select count(distinct use_detail ) from asset_jiphap_unit_module_2 ajum ; -- 88종류

create index ajum_pnu_idx on asset_jiphap_unit_module_2(pnu);
create index ajum_bpk_idx on asset_jiphap_unit_module_2(building_pk);


select count(*) from asset_jiphap_unit_module_1_statics ajums ;
select count(distinct use_detail ) from asset_jiphap_unit_module_1_statics ajums ;

select subways_data->1 from asset limit 1;
select jsonb_array_length(subways_data) from asset limit 1; 
select jsonb_array_elements(subways_data) from asset limit 8; 

select * from seoul_subway_locs ssl where name in (select jsonb_array_elements(subways_data)->>'name' from asset where asset_pnu='1168010600109450010');

select (select jsonb_agg(
jsonb_build_object(
'loc',jsonb_build_object('lat', lat, 'lng', lng),
'name',subways_data->'name'
)) from seoul_subway_locs where name in (select jsonb_array_elements(subways_data)->>'name')) from asset where asset_pnu='1168010600109450010';

select jsonb_agg((
	select jsonb_build_object(
		'sd', t.sd,
		'loc', jsonb_build_object('lat', ssl.lat, 'lng', ssl.lng)
	) from seoul_subway_locs ssl where ssl.name = t.sd->>'name'))
from (select jsonb_array_elements(subways_data) sd from asset a where asset_pnu='1168010600109450010') as t;

create index ssl_name_idx on seoul_subway_locs(name);

select * from seoul_subway_locs ssl where name in (select jsonb_array_elements(subways_data)->>'name' from asset where asset_pnu='1168010600109440000');

select (
	select jsonb_build_object(
		'sd', t.sd,
		'loc', jsonb_build_object('lat', ssl.lat, 'lng', ssl.lng)
	) from seoul_subway_locs ssl where ssl.name = t.sd->>'name')
from (select jsonb_array_elements(subways_data) sd from asset a where asset_pnu='1168010600109440000') as t;

select jsonb_array_elements(a.subways_data) sd from asset a where asset_pnu='1168010600109440000';

select jsonb_array_length(subways_data) from asset where pnu='1168010600109440000'

select st_asgeojson(st_centroid(asset_pol))::jsonb from asset where asset_pnu='1168010600109450003';
select * from asset where asset_pnu='1168010600109450003';


select st_union(st_makevalid(geom)) geom from pols_gn_offices_zone where name='B-대로변';

create table ilsang_strips as select st_union(st_makevalid(geom)) geom from pols_gn_offices_zone where name='B-대로변';

select distinct "HAKGUDO_NM" from school_ele;
select distinct "HAKGUDO_NM" from school_mid;
select distinct "HAKGUDO_NM" from school_high;

--script5
create index bf_pnu on building_floor(pnu);

select * from building_floor bf where pnu=1168010400101300006;

--script6
select * from seoul_lu limit 10;


(select geom from seoul_lu where "ENT_NAME" ='일반상업지역' limit 1) ;

(select geom from lot_polygon limit 1);

select st_intersects((select geom from seoul_lu where "ENT_NAME" ='일반상업지역' limit 1), (select geom from lot_polygon limit 1))::text;

select * from lot_polygon lp where st_intersects((select geom from seoul_lu where "ENT_NAME" ='일반상업지역' limit 1), lp.geom);

create index geom_idx_lot_polygon on lot_polygon using gist(geom);


select 
st_area(st_intersection((select geom from seoul_lu where "ENT_NAME" ='일반상업지역' limit 1), lp.geom) , true),
st_intersection((select geom from seoul_lu where "ENT_NAME" ='일반상업지역' limit 1), lp.geom),
* 
from lot_polygon lp where st_intersects((select geom from seoul_lu where "ENT_NAME" ='일반상업지역' limit 1), lp.geom) ;

create extension plpython3u;

create or replace FUNCTION get_landuse_intersection(geom geometry) 
RETURNS jsonb
AS $$
import json
q = plpy.prepare('select jsonb_agg(jsonb_build_object( t."ENT_NAME", st_area(st_intersection( st_makevalid($1), t.st_union ), true) )) from (select sl."ENT_NAME", st_union(sl.geom) from seoul_lu sl where st_intersects( st_makevalid($2), sl.geom ) group by sl."ENT_NAME") as t', ['geometry', 'geometry'])
try:
    area = q.execute([geom, geom], 1)[0]['jsonb_agg']
    area = {list(lu.keys())[0]:list(lu.values())[0] for lu in json.loads(area)}
    area['total'] = sum(area.values())
except:
    area = {}
return json.dumps(area)
$$ LANGUAGE plpython3u
IMMUTABLE
RETURNS NULL ON NULL INPUT; 

select get_landuse_intersection((select geom from lot_polygon limit 1));

(select geom from lot_polygon limit 1)

select lp.geom, get_landuse_intersection(lp.geom) from lot_polygon lp limit 1000;
