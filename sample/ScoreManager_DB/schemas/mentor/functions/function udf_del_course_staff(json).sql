/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_del_course_staff(json)
  object_name: udf_del_course_staff(json)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_del_course_staff(p_parameters_json json) RETURNS json
    LANGUAGE plpgsql
    AS $$
/*=============================================================================
* p_parameters_json
* example p_parameters_json {
                    "course_id": 1,
                    "user_id": "4"
                    }
* example of RETURN
* {"query_result" : "success" , "affected_row_count" : 1}
*
=============================================================================*/
DECLARE
    v_course_id INT := (p_parameters_json->>'course_id')::INT;
    v_user_id INT := (p_parameters_json->>'user_id')::INT;
    v_query_result TEXT;
    v_affected_row_count TEXT;
BEGIN
    --====================================================================
    -- predefine
    --====================================================================
    v_query_result := 'failed';

    DELETE FROM lab.course_staff
    WHERE user_id = v_user_id AND course_id = v_course_id;

    GET DIAGNOSTICS v_affected_row_count = ROW_COUNT;

    IF v_affected_row_count = '0'
    THEN
        RAISE NOTICE 'Record with user_id=% and course_id=% not found.', v_user_id, v_course_id;
    ELSE
        RAISE NOTICE 'Record with user_id=% and course_id=% successfully deleted.', v_user_id, v_course_id;
    END IF;

    v_query_result := 'success';

    RETURN JSON_BUILD_OBJECT
    (
        'query_result',v_query_result,
        'affected_row_count', v_affected_row_count
    );
END;
$$;


ALTER FUNCTION mentor.udf_del_course_staff(p_parameters_json json) OWNER TO bi_admin;
