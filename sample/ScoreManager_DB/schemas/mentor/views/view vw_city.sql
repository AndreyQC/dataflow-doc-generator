/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_city
  object_name: vw_city
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_city AS
 SELECT ct.city_id,
    ct.name AS city_name,
    ct.geo_point AS city_geo_point
   FROM lab.city ct;


ALTER VIEW mentor.vw_city OWNER TO bi_admin;
