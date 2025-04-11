/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_get_courses_by_user_id(integer)
  object_name: udf_get_courses_by_user_id(integer)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_get_courses_by_user_id(user_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(t)), '[]')
    INTO result
    FROM (
        SELECT DISTINCT
            c.course_id     AS course_id,
            c.name          AS course_name
        FROM lab.course AS c
        INNER JOIN lab.course_staff AS cs
            ON cs.course_id = c.course_id
        WHERE cs.user_id = udf_get_courses_by_user_id.user_id
    ) t;

    RETURN result;
END;
$$;


ALTER FUNCTION mentor.udf_get_courses_by_user_id(user_id integer) OWNER TO bi_admin;
