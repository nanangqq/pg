select 1;

select st_buffer(geom, 0.001),st_buffer(geom, 0.0001) from _gu where nm='강남구';

select jsonb_agg(nm) from _dong d where st_covers((select st_buffer(g.geom, 0,001) from _gu g where g.nm='강남구'), d.geom);

create table card_overview (
	region text,
	organization text,
	corporate text,
	mall text,
	education text,
	culture text
);

select (select jsonb_agg(nm) from _dong d where st_covers((select st_buffer(g.geom, 0,001) from _gu g where g.nm='강남구'), d.geom)) dong, * from card_overview co where region = '강남';

SELECT count(*) from api_logs;

select substring('12345',1,2); 

select * from api_logs order by time_ms desc limit 1000;

select * from api_logs order by time_ms limit 1000;

select distinct badge_bigguy from asset;

select badge_bigguy, count(*) from asset group by badge_bigguy ;

select random_pick, count(*) from asset group by random_pick ;

select badge_mxd , count(*) from asset group by badge_mxd ;

select badge_trophy , count(*) from asset group by badge_trophy ;
