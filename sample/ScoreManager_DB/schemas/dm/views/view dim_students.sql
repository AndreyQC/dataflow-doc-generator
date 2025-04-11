/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/dm/type/view/name/dim_students
  object_name: dim_students
  object_schema: dm
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW dm.dim_students AS
 SELECT cs.course_staff_id AS "Student Key",
    u.name AS "Student",
    s.name AS "Student Status",
    ct.name AS "Student City",
    ct.geo_point AS "Student City Geo"
   FROM ((((lab.course_staff cs
     JOIN lab.user_type ut ON (((ut.user_type_id = cs.user_type_id) AND ((ut.name)::text = 'student'::text))))
     JOIN lab."user" u ON ((u.id = cs.user_id)))
     JOIN lab.city ct ON ((ct.city_id = u.city_id)))
     LEFT JOIN lab.status s ON ((s.status_id = cs.status_id)));


ALTER VIEW dm.dim_students OWNER TO bi_admin;
