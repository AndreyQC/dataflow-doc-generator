/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_get_bonus_codes_by_subtask_id(integer)
  object_name: udf_get_bonus_codes_by_subtask_id(integer)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_get_bonus_codes_by_subtask_id(p_subtask_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_agg(b.code) AS bonus_codes
    INTO result
    FROM lab.subtask_bonus AS sb
    INNER JOIN lab.bonus AS b 
        ON b.bonus_id = sb.bonus_id
    WHERE sb.subtask_id = p_subtask_id;

    RETURN result;
END;
$$;


ALTER FUNCTION mentor.udf_get_bonus_codes_by_subtask_id(p_subtask_id integer) OWNER TO bi_admin;
