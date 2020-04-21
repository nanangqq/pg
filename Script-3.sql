--jd

create table jd_merged_0420 as select st_union(st_makevalid(pol)) jd_merged from polygon_jd_breakdown pjb ;