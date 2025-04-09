/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_ins_course_staff(json)
  object_name: udf_ins_course_staff(json)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_ins_course_staff(p_parameters_json json) RETURNS json
    LANGUAGE plpgsql
    AS $$
/*=============================================================================
* p_parameters_json
* example p_parameters_json {
                    "course_id": 1,
                    "user_id": "4",
                    "user_email": "sergei_boikov@rntgroup.com",
                    "user_type": "student"
                    }
* example of RETURN
* {"query_result" : "success" , "affected_row_count" : 1}
*
=============================================================================*/

DECLARE
    v_course_id INT := (p_parameters_json->>'course_id')::INT;
    v_user_id INT := (p_parameters_json->>'user_id')::INT;
    v_user_email TEXT := (p_parameters_json->>'user_email')::TEXT;
    v_user_type TEXT := (p_parameters_json->>'user_type')::TEXT;
    v_select_user_type_id INT;
    v_select_user_id INT;
    v_query_result TEXT;
    v_affected_row_count TEXT;
BEGIN

    --====================================================================
    -- predefine
    --====================================================================
    v_query_result := 'failed';

    --=============================================================================
    -- Validate data before upsert
    --=============================================================================

    SELECT u.id INTO v_select_user_id
    FROM lab.user AS u
    WHERE u.id = v_user_id;

    IF v_select_user_id IS NULL THEN
        RAISE EXCEPTION 'User "%" not found', v_user_email;
    END IF;

    SELECT ut.user_type_id
    INTO v_select_user_type_id
    FROM lab.user_type AS ut
    WHERE ut.name = v_user_type;

    IF v_select_user_type_id IS NULL THEN
        RAISE EXCEPTION 'User type "%" not found', v_user_type;
    END IF;

    --=============================================================================
    -- Upsert data into target
    --=============================================================================

    INSERT INTO lab.course_staff (course_id, user_id, user_type_id)
    VALUES (v_course_id, v_user_id, v_select_user_type_id)
    ON CONFLICT (course_id, user_id) DO UPDATE
   		SET user_type_id = EXCLUDED.user_type_id;

    GET DIAGNOSTICS v_affected_row_count = ROW_COUNT;

    v_query_result := 'success';

    RETURN JSON_BUILD_OBJECT
    (
        'query_result',v_query_result,
        'affected_row_count', v_affected_row_count
    );


END;
$$;


ALTER FUNCTION mentor.udf_ins_course_staff(p_parameters_json json) OWNER TO bi_admin;
