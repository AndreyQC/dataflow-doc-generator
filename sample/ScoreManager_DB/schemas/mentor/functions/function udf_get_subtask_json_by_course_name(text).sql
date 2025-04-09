/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_get_subtask_json_by_course_name(text)
  object_name: udf_get_subtask_json_by_course_name(text)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_get_subtask_json_by_course_name(course_name text) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSON;
BEGIN
   SELECT COALESCE(json_agg(row_to_json(tt)), '[]')
   INTO result
   FROM (
     SELECT DISTINCT
     c.name AS course_name,
     t.name AS task_name,
     t.description  AS task_description,
     tp.name AS task_topic,
     s.name AS subtask_name,
     s.description  AS subtask_description,
     tp1.name AS subtask_topic,
     s.max_score AS subtask_max_score
     FROM   lab.course_staff AS cs
        INNER JOIN lab.course AS c
              ON   cs.course_id = c.course_id
        INNER JOIN lab.task AS t
              ON  c.course_id =t.course_id
        INNER JOIN lab.topic AS tp
              ON t.topic_id = tp.topic_id
        INNER JOIN lab.subtask AS s
              ON  s.task_id =t.task_id
        INNER JOIN lab.topic AS tp1
              ON s.topic_id = tp1.topic_id
        WHERE c.name = udf_get_subtask_json_by_course_name.course_name
     ) tt;
    RETURN result;
END;
$$;


ALTER FUNCTION mentor.udf_get_subtask_json_by_course_name(course_name text) OWNER TO bi_admin;
