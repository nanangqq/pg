select geom from jd_seoul_all where index=1410;

insert into polygon_jd_1(pol) values((select geom from jd_seoul_all where index=1410));

insert into polygon_jd_1(pol) values((select geom from jd_seoul_all where index=1875));

insert into polygon_jd_1(pol) values((select geom from jd_seoul_all where index=5558));


select st_assvg(pol) from polygon_jd_1 pj ; 

select array_agg(st_assvg(pol)) from polygon_jd_breakdown; 