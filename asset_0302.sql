-------------- vos-proto
select count(*) from asset;

select count(*) from lu_areas_gn_lands_bu laglb;
create index lu_areas_gn_lands_bu_pnu_idx on lu_areas_gn_lands_bu(pnu);
create index asset_asset_pnu_idx on asset(asset_pnu);
create index asset_pnu_idx on asset(pnu);
create index lu_areas_gn_lands_bu_asset_pnu_idx on lu_areas_gn_lands_bu(asset_pnu);

select (ilju_1 + ilju_2 + ilju_2_und7 + ilju_3 + jnju_1 + ilsang + semiju + nt_green + pd_green), st_area, area from lu_areas_gn_lands_bu laglb;

select ubp_fc, (ilju_1 + ilju_2 + ilju_2_und7 + ilju_3 + jnju_1 + ilsang + semiju + nt_green + pd_green), st_area, area from lu_areas_gn_lands_bu laglb where ubp_fc!=0;

-- 도시계획시설(ubp_fc => 일반상업으로 합쳐야 할듯?)
-- update lu_areas_gn_lands_bu set ilsang = ilsang+ubp_fc where ubp_fc!=0;
-- 합치고 ubp_fc drop!

select * from lu_areas_gn_lands_bu laglb; 

--select (select ilju_1 from lu_areas_gn_lands_bu laglb where laglb.pnu in unnest(apnumap.bpnus) ) from (select array_agg(pnu) bpnus, asset_pnu from asset group by asset_pnu) as apnumap;
--select laglb.pnu, (select sum(ilsang) from lu_areas_gn_lands_bu laglb2 where laglb2.pnu = any ((select (select array_agg(pnu) from asset a2 where a2.asset_pnu = asset.asset_pnu) from asset where asset.pnu=laglb.pnu) )) from lu_areas_gn_lands_bu laglb;

update lu_areas_gn_lands_bu l set asset_pnu = (select asset_pnu from asset a where a.pnu=l.pnu);

select asset_pnu, sum(ilsang), sum(jnju_1), sum(ilju_1), sum(ilju_2), sum(ilju_2_und7), sum(ilju_3), sum(semiju), sum(nt_green), sum(pd_green) from lu_areas_gn_lands_bu laglb group by asset_pnu;

select asset_pnu, sum(ilsang), sum(jnju_1), sum(ilju_1), sum(ilju_2), sum(ilju_2_und7), sum(ilju_3), sum(semiju), sum(nt_green), sum(pd_green) from lu_areas_gn_lands_bu laglb where asset_pnu = '1168010100106010012' group by asset_pnu;

select jsonb_build_object(
    'type', 'FeatureCollection',
    'features', jsonb_agg(ST_AsGeoJSON(t.*)::jsonb)
    )::jsonb
from ( values (1, 'one', 'POINT(1 1)'::geometry),
              (2, 'two', 'POINT(2 2)'),
              (3, 'three', 'POINT(3 3)')
     ) as t(id, name, geom);

drop function get_lu_area_dist;    
create or replace function get_lu_area_dist(pnu text) returns jsonb
as $$
import json
asset_pnu = plpy.execute("select asset_pnu from asset where pnu='%s'"%pnu)[0]['asset_pnu']
lu_list = ['ilsang', 'jnju_1', 'ilju_1', 'ilju_2', 'ilju_2_und7', 'ilju_3', 'semiju', 'nt_green', 'pd_green']
lu_area_dist = plpy.execute("select %s from lu_areas_gn_lands_bu laglb where asset_pnu='%s' group by asset_pnu"%(', '.join(['sum(%s) %s'%(lu,lu) for lu in lu_list]) ,asset_pnu))
return json.dumps({lu:lu_area_dist[0][lu] for lu in lu_list if lu_area_dist[0][lu]>0})
$$ LANGUAGE plpython3u
IMMUTABLE
RETURNS NULL ON NULL INPUT;

select pnu, get_lu_area_dist(pnu)::jsonb, st_area, area from lu_areas_gn_lands_bu laglb ;
update asset a set lu_area_dist = get_lu_area_dist(a.pnu), area = (select area from lu_areas_gn_lands_bu l where l.pnu=a.pnu)
where a.pnu = '1168010400101410012';

update asset a set lu_area_dist = get_lu_area_dist(a.pnu), area = (select sum(area) from lu_areas_gn_lands_bu l where l.asset_pnu=a.asset_pnu);
update asset a set area = (select sum(area) from lu_areas_gn_lands_bu l where l.asset_pnu=a.asset_pnu);

update asset a1 set pnus = (select array_agg(pnu) from asset a2 where a2.asset_pnu = a1.asset_pnu);

select asset_pol from asset limit 1;
select geom from pol_seoul_lands_gn pslg where st_intersects( geom, (select st_offsetcurve(st_boundary((select geom from pol_seoul_lands_gn pslg2 limit 1)), 0.000001)) ) and jimok!='도';

drop function get_block_pnus;
--create or replace function get_block_pnus(pnu text) returns text[]
--as $$
--def find_nearby(pnu, out, explored):
--    #if pnu in out:
--    #    return out 
--    #else:
--    chk = True
--    for opnu in out:
--        if opnu not in explored:
--            chk = False
--            break
--    if chk:
--        return out
--    
--    nearby = plpy.execute("select pnu from pol_seoul_lands_gn pslg where st_intersects( geom, (select st_offsetcurve(st_boundary((select geom from pol_seoul_lands_gn pslg2 limit 1)), 0.000001)) ) and jimok!='도'")
--    for rec in nearby:
--        if rec['pnu'] in out:
--            out.append(rec['pnu'])
--        else:
--            continue 
--    
--    if pnu not in explored:
--        explored.append(pnu)
--    
--    for rec in nearby:
--        find_nearby(rec['pnu'], out, explored)
--out = []
--explored = []
--return find_nearby(pnu, out, explored)
--$$ LANGUAGE plpython3u
--IMMUTABLE
--RETURNS NULL ON NULL INPUT;
--create or replace function get_block_pnus(pnu text) returns text[]
--as $$
--import sys
--sys.setrecursionlimit(2000)
--def find_nearby(pnu, state):
--    if pnu not in state['explored']:
--        state['explored'].append(pnu)
--    nearby = plpy.execute("select pnu from pol_seoul_lands_gn pslg where st_intersects( geom, (select st_offsetcurve(st_boundary((select geom from pol_seoul_lands_gn pslg2 where pslg2.pnu='%s')), 0.000001)) ) and jimok!='도'"%pnu)
--    for rec in nearby:
--        if rec['pnu'] in state['found']:
--            continue
--        else:
--            state['found'].append(rec['pnu'])
--    end_chk = True
--    for opnu in state['found']:
--        if opnu not in state['explored']:
--            end_chk = False
--            return find_nearby(opnu, state)
--    if end_chk:
--        return state 
--state = {'found':[], 'explored':[]}
--return find_nearby(pnu, state)['found']
--$$ LANGUAGE plpython3u
--IMMUTABLE
--RETURNS NULL ON NULL INPUT;

create or replace function get_block_pnus(pnu text) returns text[]
as $$
import sys
sys.setrecursionlimit(10000)
def find_nearby(pnu, state):
    if pnu not in state['explored']:
        state['explored'].append(pnu)
    nearby = plpy.execute("select pnu from pol_seoul_lands_gn pslg where st_dwithin( geom, (select geom from pol_seoul_lands_gn pslg2 where pslg2.pnu='%s'), 0.0000001) and jimok!='도'"%pnu)
    for rec in nearby:
        if rec['pnu'] in state['found']:
            continue
        else:
            state['found'].append(rec['pnu'])
    end_chk = True
    for opnu in state['found']:
        if opnu not in state['explored']:
            end_chk = False
            return find_nearby(opnu, state)
    if end_chk:
        return state 
state = {'found':[], 'explored':[]}
return find_nearby(pnu, state)['found']
$$ LANGUAGE plpython3u
IMMUTABLE
RETURNS NULL ON NULL INPUT;

select unnest( (select get_block_pnus(pnu) from pol_seoul_lands_gn pslg limit 1) );
select pnu, (select st_union(st_buffer(geom, 0.0000001)) from pol_seoul_lands_gn pslg2 where pslg2.pnu in (select unnest( (select get_block_pnus(pnu) from pol_seoul_lands_gn pslg where pslg.pnu=pslg3.pnu ) ) ) ) from pol_seoul_lands_gn pslg3 where pslg3.jimok='대' limit 10;

select st_area(st_buffer(geom,0.0000001), true), st_area(geom, true), st_buffer(geom,0.000001), geom from pol_seoul_lands_gn pslg;

-------------- vos_test
select * from pol_landuse_comm where st_intersects(geom, (select geom from pol_sgg_bounds psb where psb."ADM_SECT_C"='11680'));
select * from pol_landuse_comm where st_intersects(geom, (select geom from pol_sgg_bounds psb where psb."ADM_SECT_C"='11680')) and "LABEL"!='일반상업지역'; --1개 

