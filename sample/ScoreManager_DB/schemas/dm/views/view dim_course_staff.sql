/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/dm/type/view/name/dim_course_staff
  object_name: dim_course_staff
  object_schema: dm
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW dm.dim_course_staff AS
 SELECT cs.course_staff_id AS "Staff Key",
    u.name AS "Staff",
    s.name AS "Staff Status",
    ct.name AS "Staff City",
    ct.geo_point AS "Staff City Geo",
    ut.description AS "Staff Type",
    c.name AS "Staff Course"
   FROM (((((lab.course_staff cs
     JOIN lab.user_type ut ON ((ut.user_type_id = cs.user_type_id)))
     JOIN lab."user" u ON ((u.id = cs.user_id)))
     JOIN lab.city ct ON ((ct.city_id = u.city_id)))
     JOIN lab.course c ON ((c.course_id = cs.course_id)))
     LEFT JOIN lab.status s ON ((s.status_id = cs.status_id)));


ALTER VIEW dm.dim_course_staff OWNER TO bi_admin;
