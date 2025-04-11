/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/dm/type/view/name/vw_dashboard_geography
  object_name: vw_dashboard_geography
  object_schema: dm
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW dm.vw_dashboard_geography AS
 SELECT DISTINCT dc."Course Name",
    ds2."Student" AS "Name",
    'Student'::text AS "Role",
    ds2."Student City" AS "City",
    ds2."Student City Geo" AS "Coordinats",
    (sq.arr[1])::double precision AS "Latitude",
    (sq.arr[2])::double precision AS "Longitude"
   FROM (((dm.fact_scores fs2
     JOIN dm.dim_courses dc ON ((dc."Course Key" = fs2."Course Key")))
     JOIN dm.dim_students ds2 ON ((ds2."Student Key" = fs2."Student Key")))
     JOIN ( SELECT city.name,
            city.geo_point,
            string_to_array(replace(replace(city.geo_point, '['::text, ''::text), ']'::text, ''::text), ','::text) AS arr
           FROM lab.city) sq ON (((sq.name)::text = (ds2."Student City")::text)))
UNION ALL
 SELECT DISTINCT dc."Course Name",
    dm."Mentor" AS "Name",
    'Mentor'::text AS "Role",
    dm."Mentor City" AS "City",
    dm."Mentor City Geo" AS "Coordinats",
    (sq.arr[1])::double precision AS "Latitude",
    (sq.arr[2])::double precision AS "Longitude"
   FROM (((dm.fact_scores fs2
     JOIN dm.dim_courses dc ON ((dc."Course Key" = fs2."Course Key")))
     JOIN dm.dim_mentors dm ON ((dm."Mentor Key" = fs2."Mentor Key")))
     JOIN ( SELECT city.name,
            city.geo_point,
            string_to_array(replace(replace(city.geo_point, '['::text, ''::text), ']'::text, ''::text), ','::text) AS arr
           FROM lab.city) sq ON (((sq.name)::text = (dm."Mentor City")::text)));


ALTER VIEW dm.vw_dashboard_geography OWNER TO bi_admin;
