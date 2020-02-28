create extension plpython3u; -- 지원 안합
CREATE EXTENSION postgis; -- 설치 가능

create index pol_seoul_lands_gn_pnu_idx on pol_seoul_lands_gn(pnu);
create index pol_seoul_lands_geom_idx on pol_seoul_lands_gn using gist(geom);


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