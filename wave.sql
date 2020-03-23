select count(*) from adj_level2 al ;

select (select pub_price from _land l where al.id=l.id), (select array_agg(l2.pub_price) from _land l2 where l2.id in (select unnest(al.array_agg))) from adj_level2 al ;

select count(*) from _land where pub_price is null;

select 
(select pub_price from _land l where al.id=l.id), 
(select array_agg(l2.pub_price) from _land l2 where l2.id in (select unnest(al.array_agg))),
(select array_agg(st_azimuth( st_centroid( (select geom from _land l3 where l3.id=al.id) ), st_centroid(geom) )) from _land l4 where l4.id in (select unnest(al.array_agg)) )
from adj_level2 al ; -- 인접대지들과 대상 대지의 중심점끼리 각도 



create or replace FUNCTION adj_level2(
id text,
adj_id_arr text[]
) 
RETURNS text[]
AS $$
return [ adj_id for adj_id in adj_id_arr if adj_id != id ]
$$ LANGUAGE plpython3u
IMMUTABLE
RETURNS NULL ON NULL INPUT;

select id, adj_level2(id, array_agg) from adj_level2 al ;

create or replace FUNCTION adj_level3(
id text,
adj_id_arr text[]
) 
RETURNS text[]
AS $$
level2 = [ adj_id for adj_id in adj_id_arr if adj_id != id ]
tmp = []
for l2_id in level2:
    l3_cands = plpy.execute("select array_agg from adj_level2 where id='%s'"%l2_id)[0]['array_agg']
    for l3_cand in l3_cands:
        if l3_cand!=id and l3_cand not in level2 and l3_cand not in tmp:
            tmp.append(l3_cand)
return tmp
$$ LANGUAGE plpython3u
IMMUTABLE
RETURNS NULL ON NULL INPUT;

select id, adj_level2(id, array_agg), adj_level3(id, array_agg) from adj_level2 al limit 10;
select (select geom from _land l where l.id=al.id), (select st_collect(geom) from _land l2 where l2.id in (select unnest(adj_level2(al.id, al.array_agg)))), (select st_collect(geom) from _land l3 where l3.id in (select unnest(adj_level3(al.id, al.array_agg)))) from adj_level2 al limit 10;

-- 인접 대지들을 원형 파동 혹은 함수로 만들 때 단지 중심점간의 각도로 접근하면 안될듯,,, 테두리를 따라 각 대지와 가장 가까운 점을 위치로 잡고 다시 전체 테두리 길이를 normalize해서 대응시키는 방법으로? 해야할것같음 

select (select geom from _land l where l.id=al.id), 
(select st_collect(geom) from _land l2 where l2.jimok!='도' and l2.id in (select unnest(adj_level2(al.id, al.array_agg)))), 
(select st_collect(geom) from _land l3 where l3.jimok!='도' and l3.id in (select unnest(adj_level3(al.id, al.array_agg)))) from adj_level2 al limit 10;