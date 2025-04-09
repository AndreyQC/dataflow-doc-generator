/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/dm/type/view/name/dim_mentors
  object_name: dim_mentors
  object_schema: dm
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW dm.dim_mentors AS
 SELECT cs.course_staff_id AS "Mentor Key",
    u.name AS "Mentor",
    s.name AS "Mentor Status",
    ct.name AS "Mentor City",
    ct.geo_point AS "Mentor City Geo"
   FROM ((((lab.course_staff cs
     JOIN lab.user_type ut ON (((ut.user_type_id = cs.user_type_id) AND ((ut.name)::text = 'mentor'::text))))
     JOIN lab."user" u ON ((u.id = cs.user_id)))
     JOIN lab.city ct ON ((ct.city_id = u.city_id)))
     LEFT JOIN lab.status s ON ((s.status_id = cs.status_id)));


ALTER VIEW dm.dim_mentors OWNER TO bi_admin;
