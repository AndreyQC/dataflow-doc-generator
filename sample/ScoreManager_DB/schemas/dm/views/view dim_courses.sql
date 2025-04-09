/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/dm/type/view/name/dim_courses
  object_name: dim_courses
  object_schema: dm
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW dm.dim_courses AS
 SELECT c.course_id AS "Course Key",
    c.name AS "Course Name",
    c.datestart AS "Course Datestart",
    c.datefinish AS "Course Datefinish"
   FROM lab.course c;


ALTER VIEW dm.dim_courses OWNER TO bi_admin;
