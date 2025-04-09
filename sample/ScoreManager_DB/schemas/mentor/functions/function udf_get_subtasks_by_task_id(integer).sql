/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_get_subtasks_by_task_id(integer)
  object_name: udf_get_subtasks_by_task_id(integer)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_get_subtasks_by_task_id(task_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(t)), '[]')
    INTO result
    FROM (
        SELECT DISTINCT
            st.subtask_id       AS subtask_id,
            st.name             AS subtask_name,
            st.description      AS subtask_description,
            tp.name             AS subtask_topic,
            st.max_score        AS subtask_maxscore
        FROM lab.subtask AS st
        INNER JOIN lab.topic AS tp
            ON tp.topic_id = st.topic_id 
        WHERE st.task_id = udf_get_subtasks_by_task_id.task_id
        ORDER BY st.name
    ) t;

    RETURN result;
END;
$$;


ALTER FUNCTION mentor.udf_get_subtasks_by_task_id(task_id integer) OWNER TO bi_admin;
