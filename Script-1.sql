select id, pnu
FROM gnlands
WHERE st_within(
  geom,
  ST_GeomFromText('POLYGON((127.06230804789996 37.50839784542325,127.06408046412909 37.50454960590649,127.05752094076199 37.504643082641756,127.06230804789996 37.50839784542325))', 4326)
);

CREATE TABLE pols_gn_office_zones (
  id SERIAL PRIMARY KEY,
  pol GEOMETRY(Polygon, 4326),
  name VARCHAR(128)
);

drop table pols_gn_lands2 ;
CREATE TABLE pols_gn_lands2 (
  id SERIAL PRIMARY KEY,
  pol geometry(geometry, 4326),
  pnu VARCHAR(19)
);
-- Add a spatial index
CREATE INDEX pols_gn_lands_idx
  ON pols_gn_lands
  USING GIST (pol);

INSERT INTO pols (pol, name) VALUES (
  ST_GeomFromText(
  'POLYGON(
(127.06230804789996 37.50839784542325,
127.06408046412909 37.50454960590649,
127.05752094076199 37.504643082641756,
127.06230804789996 37.50839784542325)
)', 4326), 'test');

INSERT INTO pols (pol, name) VALUES (
  ST_GeomFromText(
  'POLYGON(
(127.06230804789996 37.50839784542325,127.06408046412909 37.50454960590649,127.05752094076199 37.504643082641756,127.06230804789996 37.50839784542325), 
(127.06249970569665 37.50765892027005,127.06193265190872 37.50578512861986,127.0600557905906 37.506497891726646,127.06249970569665 37.50765892027005))', 4326), 'test2');

SELECT ST_AsText('0103000020E610000002000000040000008200E5DAFCC35F4090B93B2E13C14240CE6FF2E419C45F40FE49DC1495C042401BDA4F6CAEC35F40AB0C002598C042408200E5DAFCC35F4090B93B2E13C142400400000083FEC3FEFFC35F40910AAEF7FAC0424029A05EB4F6C35F40DC1C2D91BDC0424069213EF4D7C35F40BD3A44ECD4C0424083FEC3FEFFC35F40910AAEF7FAC04240');


--- A 등급 찾기
select pol from pols_gn_offices_zone where name like 'A%';
select st_union( (select st_union((select pol from pols_gn_offices_zone where id=50),(select pol from pols_gn_offices_zone where id=56))), (select pol from pols_gn_offices_zone where id=57));

select count(pnu) from gnlands where st_within(geom, (select st_union( (select st_union((select pol from pols_gn_offices_zone where id=50),(select pol from pols_gn_offices_zone where id=56))), (select pol from pols_gn_offices_zone where id=57))));

select count(pnu) from pols_gn_lands2 where st_intersects(pol, (select st_union( (select st_union((select pol from pols_gn_offices_zone where id=50),(select pol from pols_gn_offices_zone where id=56))), (select pol from pols_gn_offices_zone where id=57))));
select count(pnu) from pols_gn_lands2;
--- B 등급 찾기
select id from pols_gn_offices_zone  where name like 'B%';
select st_union((select array_agg(pol) from pols_gn_offices_zone  where name like 'B%' and id!=55 and id!=49));

select id, st_distance( st_geomfromtext('POINT(127.04270844540515 37.504407713517978)', 4326), pol) from pols_gn_offices_zone where name like 'B%';
select id, st_distance( st_geomfromtext('POINT(127.03858528431435 37.508965895879399)', 4326), pol) from pols_gn_offices_zone where name like 'B%';

select count(pnu) from pols_gn_lands2 where st_intersects(pol, (select st_union((select array_agg(pol) from pols_gn_offices_zone  where name like 'B%' and id!=55 and id!=49))));

select st_union(st_union( (select st_difference((select pol from pols_gn_offices_zone where id=65),(select pol from pols_gn_offices_zone where id=66))) , (select pol from pols_gn_offices_zone where id=64) ),(select st_union((select array_agg(pol) from pols_gn_offices_zone  where name like 'B%' and id!=49 and id!=55 and id!=64 and id!=65 and id!=66))) );

select st_union( (select st_difference((select pol from pols_gn_offices_zone where id=65),(select pol from pols_gn_offices_zone where id=66))) , (select pol from pols_gn_offices_zone where id=64) );

--- merged table 작성 
CREATE TABLE pols_gn_offices_zone_merged (
  id SERIAL PRIMARY KEY,
  pol geometry(geometry, 4326),
  name CHAR(1)
);
INSERT INTO pols_gn_offices_zone_merged (pol, name) values (
st_union(st_union( (select st_difference((select pol from pols_gn_offices_zone where id=65),(select pol from pols_gn_offices_zone where id=66))) , (select pol from pols_gn_offices_zone where id=64) ),(select st_union((select array_agg(pol) from pols_gn_offices_zone  where name like 'B%' and id!=49 and id!=55 and id!=64 and id!=65 and id!=66))) ),
'B'
);
INSERT INTO pols_gn_offices_zone_merged (pol, name) values (
st_union( (select st_union((select pol from pols_gn_offices_zone where id=50),(select pol from pols_gn_offices_zone where id=56))), (select pol from pols_gn_offices_zone where id=57)),
'A'
);

--- if구문 
select (case when st_intersects(pol, (select pol from pols_gn_offices_zone_merged where name='A')) then 'A' when st_intersects(pol, (select pol from pols_gn_offices_zone_merged where name='B')) then 'B' else 'C' end) from pols_gn_lands2

----
drop table pols_gn_deals ;
CREATE TABLE pols_gn_deals (
  id SERIAL PRIMARY KEY,
  pnu VARCHAR(19),
  pol geometry(geometry, 4326)
);

select id, pnu, (case when st_intersects(pol, (select pol from pols_gn_offices_zone_merged where name='A')) then 'A' when st_intersects(pol, (select pol from pols_gn_offices_zone_merged where name='B')) then 'B' else 'C' end) from pols_gn_deals;

-- 대상지
drop table pols_test_area;
CREATE TABLE pols_test_area (
  id SERIAL PRIMARY KEY,
  name varchar(50),
  pol geometry(geometry, 4326)
);
select pnu, 
(case when st_intersects(pol, (select pol from pols_gn_offices_zone_merged where name='A')) then 'A' when st_intersects(pol, (select pol from pols_gn_offices_zone_merged where name='B')) then 'B' else 'C' end)
from pols_gn_lands2 where st_intersects(pol, (select pol from pols_test_area) );

--대상지 블록별 공시지가 격차율
CREATE TABLE pols_eval_block (
  id SERIAL PRIMARY KEY,
  name varchar(50),
  pol geometry(geometry, 4326),
  rate float
);

--select pol from pols_gn_lands2 where pnu=;
select sum(rate)/count(rate) from pols_eval_block;
select pnu,
(case 
when st_within(pol, (select pol from pols_eval_block where name='1-1')) then (select rate from pols_eval_block where name='1-1')
when st_within(pol, (select pol from pols_eval_block where name='1-2')) then (select rate from pols_eval_block where name='1-2')
when st_within(pol, (select pol from pols_eval_block where name='5')) then (select rate from pols_eval_block where name='5')
when st_within(pol, (select pol from pols_eval_block where name='6')) then (select rate from pols_eval_block where name='6')
when st_within(pol, (select pol from pols_eval_block where name='7')) then (select rate from pols_eval_block where name='7')
else (select sum(rate)/count(rate) from pols_eval_block where name in ('6','7'))
end)
from pols_gn_lands2 where st_intersects(pol, (select pol from pols_test_area) );


-- 지하철역 test
CREATE TABLE subway (
  id SERIAL PRIMARY KEY,
  geom GEOMETRY(Point, 4326),
  name VARCHAR(50),
  line integer
);

INSERT INTO subway (geom, name, line) VALUES (
  ST_GeomFromText('POINT(127.0610428 37.94818878)', 4326),'소요산',1
);

INSERT INTO subway (geom, name, line) VALUES (
  ST_GeomFromText('POINT(127.0490951984712 37.50457480454128)', 4326),'삼성',2
);

select st_distance((select geom from subway where id=1),(select geom from subway where id=2), true);

-- 지하철역
CREATE TABLE sb_stations_point (
  id SERIAL PRIMARY KEY,
  geom GEOMETRY(Point, 4326),
  name VARCHAR(50),
  line VARCHAR(50)
);
CREATE INDEX sb_stations_point_gix
  ON sb_stations_point
  USING GIST (geom);
  
SELECT lands.pnu, ST_Distance(lands.pol, subways.geom, true) dist, subways.name, subways.line 
FROM
  pols_gn_deals lands,
  sb_stations_point subways
where lands.pol && ST_Expand(subways.geom, 0.015) -- Magic number: 200m
--group by lands.pnu
--having count(lands.pnu)
ORDER BY pnu, dist ASC
;

SELECT count(lands.pnu)
FROM
  pols_gn_deals lands,
  sb_stations_point subways
where not (lands.pol && ST_Expand(subways.geom, 0.015)) -- Magic number: 200m
group by lands.pnu
--having count(lands.pnu)
;

select count(distinct pnu) from pols_gn_deals

-- 건용 테이블
CREATE table gpyj (
  id SERIAL PRIMARY KEY,
  landuse_nm VARCHAR(50),
  gpr integer,
  yjr integer
);


select pol from pols_gn_lands2 where pnu='1168010600109450010';
select pol from pols_gn_lands2 where pnu in ('1168010600109450010', '1168010600109450011');