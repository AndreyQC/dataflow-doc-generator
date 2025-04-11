/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/lab/type/function/name/udf_get_check_script_by_subtask_id(integer)
  object_name: udf_get_check_script_by_subtask_id(integer)
  object_schema: lab
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION lab.udf_get_check_script_by_subtask_id(subtask_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    json_result JSON;
BEGIN
    SELECT json_agg(json_build_object(
                        'check_script_text', cs.text,
                        'connection_string', c.connection_string,
                        'check_script_type_name', cst.name,
                        'connection_type_name', ct.name))
    INTO json_result
    FROM lab.subtask st 
        INNER JOIN lab.check_script cs ON cs.check_script_id = st.check_script_id
        INNER JOIN lab.connection c ON c.connection_id = cs.connection_id
        INNER JOIN lab.connection_type ct ON ct.connection_type_id = c.connection_type_id
        INNER JOIN lab.check_script_type cst ON cst.check_script_type_id = cs.check_script_type_id
    WHERE st.subtask_id = subtask_id;
    
    RETURN json_result::TEXT;
END;
$$;


ALTER FUNCTION lab.udf_get_check_script_by_subtask_id(subtask_id integer) OWNER TO bi_admin;
