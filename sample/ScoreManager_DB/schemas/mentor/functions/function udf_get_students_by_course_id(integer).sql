/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_get_students_by_course_id(integer)
  object_name: udf_get_students_by_course_id(integer)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_get_students_by_course_id(course_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(t)), '[]')
    INTO result
    FROM (
        SELECT 
            cs.course_staff_id      AS student_id,
            u."name"                AS student_name
        FROM lab.course_staff AS cs
        INNER JOIN lab.user_type AS ut 
            ON ut.user_type_id = cs.user_type_id 
                AND ut."name" = 'student'
        INNER JOIN lab."user" AS u
            ON u.id = cs.user_id 
        WHERE 1 = 1
            AND cs.course_id = udf_get_students_by_course_id.course_id
        ORDER BY student_name
    ) t;

    RETURN result;
END;
$$;


ALTER FUNCTION mentor.udf_get_students_by_course_id(course_id integer) OWNER TO bi_admin;
