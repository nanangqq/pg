select count(*) from adj_level2 al ;

select (select pub_price from _land l where al.id=l.id), (select array_agg(l2.pub_price) from _land l2 where l2.id in (select unnest(al.array_agg))) from adj_level2 al ;

select count(*) from _land where pub_price is null;

select 
(select pub_price from _land l where al.id=l.id), 
(select array_agg(l2.pub_price) from _land l2 where l2.id in (select unnest(al.array_agg))),
(select st_azimuth( st_centroid( (select geom from _land l3 where l3.id=al.id) ), st_centroid( (select geom from _land l4 where l4.id in (select unnest(al.array_agg) limit 1) ) ) ))
from adj_level2 al ;


