create extension plpython3u; -- 吏��썝 �븞�빀
CREATE EXTENSION postgis; -- �꽕移� 媛��뒫

create index pol_dong_bounds_geom_idx on pol_dong_bounds using gist(geom);
create index pol_dong_bounds_emdcd_idx on pol_dong_bounds("EMD_CD");

create index pol_seoul_lands_gn_pnu_idx on pol_seoul_lands_gn(pnu);
create index pol_seoul_lands_geom_idx on pol_seoul_lands_gn using gist(geom);

create index pol_sgg_bounds_geom_idx on pol_sgg_bounds using gist(geom);

create index pub_price_gn_lands_pnu_idx on pub_price_gn_lands(pnu);

select * from pol_seoul_lands_gn pslg where st_within(geom, st_expand(st_geometryfromtext('POINT(127.0642451 37.5087215)', 4326), 0.001)) and st_intersects( st_geometryfromtext('POINT(127.0642451 37.5087215)', 4326), geom);

select st_expand(st_geometryfromtext('POINT(127.0642451 37.5087215)', 4326), 0.001);

select * from pol_seoul_lands_gn pslg where st_intersects( st_geometryfromtext('POINT(127.0642451 37.5087215)', 4326), geom);
select st_asgeojson(geom), pnu, longitude x, latitude y, bjd_nm, jibun, jimok from pol_seoul_lands_gn pslg where st_intersects( st_geometryfromtext('POINT(127.0642451 37.5087215)', 4326), geom);

create index pol_gwand_bounds_geom_idx on pol_gwang_bounds_sim using gist(geom);

-- avg price
--update pol_gwang_bounds_sim
--set avg_pub_price = (select 
--sum(
--"PNILP"*(select area from jijuk_50 jj where jj."PNU"=pp."PNU" )
--)/sum(
--(select area from jijuk_50 jj where jj."PNU"=pp."PNU" )
--) from pub_price_50 pp)
--where ctprvn_cd='50';


-- 100m -> 2917媛� �넗吏� 
--max
--x: 127.0754445
--y: 37.5128137
--_min: n.LatLng
--x: 127.0540941
--y: 37.4967105
select count(*) from pol_seoul_lands_gn pslg where st_intersects(geom, st_envelope(st_geometryfromtext('LINESTRING(127.0540941 37.4967105,127.0754445 37.5128137)', 4326)) );
select pnu, (select jiga from pub_price_gn_lands ppgl where ppgl.pnu=pslg.pnu), st_asgeojson(geom)::jsonb from pol_seoul_lands_gn pslg where st_intersects(geom, st_envelope(st_geometryfromtext('LINESTRING(127.0540941 37.4967105,127.0754445 37.5128137)', 4326)) );
select pnu, st_asgeojson(geom)::jsonb from pol_seoul_lands_gn pslg where st_intersects(geom, st_envelope(st_geometryfromtext('LINESTRING(127.0540941 37.4967105,127.0754445 37.5128137)', 4326)) );

select json_build_object(
    'type', 'FeatureCollection',
    'features', jsonb_agg(ST_AsGeoJSON(t.*)::jsonb)
    )::jsonb
from ( values (1, 'one', 'POINT(1 1)'::geometry),
              (2, 'two', 'POINT(2 2)'),
              (3, 'three', 'POINT(3 3)')
     ) as t(id, name, geom);
( values (1, 'one', 'POINT(1 1)'::geometry),
              (2, 'two', 'POINT(2 2)'),
              (3, 'three', 'POINT(3 3)')
);

select st_envelope(st_geometryfromtext('LINESTRING(127.0540941 37.4967105,127.0754445 37.5128137)', 4326));

-- 30m -> 414媛� �넗吏� 
--max
--x: 127.0667703
--y: 37.509435
--_min: n.LatLng
--x: 127.0590348
--y: 37.5044263
select count(*) from pol_seoul_lands_gn pslg where st_intersects(geom, st_envelope(st_geometryfromtext('LINESTRING(127.0667703 37.509435,127.0590348 37.5044263)', 4326)) );
select jsonb_build_object(
'type', 'FeatureCollection',
'features', jsonb_agg(ST_AsGeoJSON(t.*)::jsonb)
)::jsonb
from (select pnu, geom from pol_seoul_lands_gn pslg where st_intersects( geom, st_envelope(st_geometryfromtext('LINESTRING(127.0667703 37.509435,127.0590348 37.5044263)', 4326)) )) as t(pnu, geom);
select st_envelope(st_geometryfromtext('LINESTRING(127.0540941 37.4967105,127.0754445 37.5128137)', 4326));

-- 20m -> 128媛� �넗吏� 
--max
--x: 127.0651771
--y: 37.5089819
--_min: n.LatLng
--x: 127.0613093
--y: 37.5064776
select count(*) from pol_seoul_lands_gn pslg where st_intersects(geom, st_envelope(st_geometryfromtext('LINESTRING(127.0651771 37.5089819,127.0613093 37.5064776)', 4326)) );
select st_envelope(st_geometryfromtext('LINESTRING(127.0540941 37.4967105,127.0754445 37.5128137)', 4326));


SELECT TRUE;

select min(jiga),
percentile_disc(0.01) within group (order by jiga) "0.01",
percentile_disc(0.1) within group (order by jiga) "0.1",
percentile_disc(0.25) within group (order by jiga) "0.25",
percentile_disc(0.5) within group (order by jiga) "0.5",
percentile_disc(0.75) within group (order by jiga) "0.75",
percentile_disc(0.9) within group (order by jiga) "0.9",
percentile_disc(0.99) within group (order by jiga) "0.99",
percentile_disc(0.999) within group (order by jiga) "0.999",
max(jiga)
from pub_price_gn_lands ppgl where (select jimok from pol_seoul_lands_gn pslg where pslg.pnu=ppgl.pnu)!='도';

select min(jiga),
percentile_disc(0.01) within group (order by jiga) "0.01",
percentile_disc(0.1) within group (order by jiga) "0.1",
percentile_disc(0.25) within group (order by jiga) "0.25",
percentile_disc(0.5) within group (order by jiga) "0.5",
percentile_disc(0.75) within group (order by jiga) "0.75",
percentile_disc(0.9) within group (order by jiga) "0.9",
percentile_disc(0.99) within group (order by jiga) "0.99",
percentile_disc(0.999) within group (order by jiga) "0.999",
max(jiga)
from pub_price_gn_lands ppgl;

select jsonb_build_object(
    'type', 'FeatureCollection',
    'features', jsonb_agg(st_asgeojson(t.*)::jsonb)
)::jsonb
from (select
    asset_pnu, true, asset_pol
    from asset where pnu='1168010600109450029'
) as t(asset_pnu, asset, geom);