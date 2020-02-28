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