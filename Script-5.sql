create table gnlands_points_text as select pnu, st_asewkt(st_centroid(geom)) from pol_seoul_lands_gn_mat pslgm;
