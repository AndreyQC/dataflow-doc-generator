/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_get_max_score_by_subtask_id(integer)
  object_name: udf_get_max_score_by_subtask_id(integer)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_get_max_score_by_subtask_id(subtask_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(t)), '[]')
    INTO result
    FROM (
        SELECT st.max_score AS subtask_max_score
        FROM lab.subtask AS st
        WHERE st.subtask_id = udf_get_max_score_by_subtask_id.subtask_id
    ) t;

    RETURN result;
END;
$$;


ALTER FUNCTION mentor.udf_get_max_score_by_subtask_id(subtask_id integer) OWNER TO bi_admin;
