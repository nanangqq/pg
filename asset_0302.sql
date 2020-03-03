-------------- vos-proto
select count(*) from asset;

select count(*) from lu_areas_gn_lands_bu laglb;
create index lu_areas_gn_lands_bu_pnu_idx on lu_areas_gn_lands_bu(pnu);

select (ilju_1 + ilju_2 + ilju_2_und7 + ilju_3 + jnju_1 + ilsang + semiju + nt_green + pd_green), st_area, area from lu_areas_gn_lands_bu laglb;

select ubp_fc, (ilju_1 + ilju_2 + ilju_2_und7 + ilju_3 + jnju_1 + ilsang + semiju + nt_green + pd_green), st_area, area from lu_areas_gn_lands_bu laglb where ubp_fc!=0;

-- 도시계획시설(ubp_fc => 일반상업으로 합쳐야 할듯?)
update lu_areas_gn_lands_bu set ilsang = ilsang+ubp_fc where ubp_fc!=0;
-- 합치고 ubp_fc drop!




-------------- vos_test
select * from pol_landuse_comm where st_intersects(geom, (select geom from pol_sgg_bounds psb where psb."ADM_SECT_C"='11680'));
select * from pol_landuse_comm where st_intersects(geom, (select geom from pol_sgg_bounds psb where psb."ADM_SECT_C"='11680')) and "LABEL"!='일반상업지역'; --1개 

