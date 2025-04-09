/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_get_reviewer_by_course_user_id(integer,
    integer)
  object_name: udf_get_reviewer_by_course_user_id(integer, integer)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_get_reviewer_by_course_user_id(course_id integer, user_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(t)), '[]')
    INTO result
    FROM (
        SELECT 
            cs.course_staff_id      AS reviewer_id,
            u."name"                AS reviewer_name
        FROM lab.course_staff AS cs
        INNER JOIN lab.user_type AS ut 
            ON ut.user_type_id = cs.user_type_id 
                AND ut."name" = 'mentor'
        INNER JOIN lab."user" AS u
            ON u.id = cs.user_id 
        WHERE 1 = 1
            AND cs.course_id = udf_get_reviewer_by_course_user_id.course_id
            AND u.id = udf_get_reviewer_by_course_user_id.user_id
    ) t;

    RETURN result;
END;
$$;


ALTER FUNCTION mentor.udf_get_reviewer_by_course_user_id(course_id integer, user_id integer) OWNER TO bi_admin;
