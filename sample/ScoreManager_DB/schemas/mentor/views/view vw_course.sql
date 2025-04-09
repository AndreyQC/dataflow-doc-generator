/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_course
  object_name: vw_course
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_course AS
 SELECT crs.course_id,
    crs.name AS course_name,
    COALESCE(crs.description, ''::character varying) AS course_description,
    crs.datestart,
    crs.datefinish,
    row_number() OVER (ORDER BY crs.datestart DESC) AS course_number
   FROM lab.course crs;


ALTER VIEW mentor.vw_course OWNER TO bi_admin;
