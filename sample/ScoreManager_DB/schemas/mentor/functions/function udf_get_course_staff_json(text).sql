/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_get_course_staff_json(text)
  object_name: udf_get_course_staff_json(text)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_get_course_staff_json(course_name text) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(tt)), '[]')
    INTO result
    FROM (
            SELECT
            u.name                  AS user_name,
            c.name                  AS course_name,
            u.email                 AS user_email,
            ut.name                 AS user_type,
            ct.name                 AS user_city,
            u.user_yc_id            AS user_yc_id
            FROM lab.course_staff AS cs
            INNER JOIN lab.course AS c
                  ON   cs.course_id = c.course_id
            INNER JOIN lab.user_type AS ut
                  ON ut.user_type_id = cs.user_type_id
                  AND ut."name" = 'student'
            INNER JOIN lab."user" AS u
                  ON u.id = cs.user_id
            INNER JOIN lab.city as ct
                  ON ct.city_id = u.city_id
            WHERE c.name = udf_get_course_staff_json.course_name
    ) tt;
    RETURN result;
END;
$$;


ALTER FUNCTION mentor.udf_get_course_staff_json(course_name text) OWNER TO bi_admin;
