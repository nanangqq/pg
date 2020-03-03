create index jijuk_45_pnu_index on jijuk_45("PNU");

update pol_gwang_bounds_sim
set avg_pub_price = (select 
sum(
"PNILP"*(select area from jijuk_45 jj where jj."PNU"=pp."PNU" )
)/sum(
(select area from jijuk_45 jj where jj."PNU"=pp."PNU" )
) from pub_price_45 pp)
where ctprvn_cd='45';

update jijuk_45 set area = (select st_area(geom, true));


select pnu, (select name from polygon_jd_1 pj where st_intersects(pgl.pol, pj.pol)), (select array_agg("yj(standard / permit)") from polygon_jd_breakdown pjb where st_intersects(pgl.pol, st_makevalid(pjb.pol))) from pols_gn_lands2 pgl;

select count(*) from pols_gn_lands2;