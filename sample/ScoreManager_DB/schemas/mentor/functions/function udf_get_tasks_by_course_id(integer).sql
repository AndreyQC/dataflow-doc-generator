/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_get_tasks_by_course_id(integer)
  object_name: udf_get_tasks_by_course_id(integer)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_get_tasks_by_course_id(course_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(t)), '[]')
    INTO result
    FROM (
        SELECT DISTINCT
            t.task_id       AS task_id,
            t."name"        AS task_name,
            t.description   AS task_description,
            tp."name"       AS task_topic
        FROM lab.task AS t
        INNER JOIN lab.topic AS tp
            ON tp.topic_id = t.topic_id
        WHERE t.course_id = udf_get_tasks_by_course_id.course_id
        ORDER BY t.name
    ) t;

    RETURN result;
END;
$$;


ALTER FUNCTION mentor.udf_get_tasks_by_course_id(course_id integer) OWNER TO bi_admin;
