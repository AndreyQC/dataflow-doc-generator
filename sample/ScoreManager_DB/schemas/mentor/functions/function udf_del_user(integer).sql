/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_del_user(integer)
  object_name: udf_del_user(integer)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_del_user(p_user_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
/*=============================================================================
* example of RETURN
* {"query_result" : "success" , "affected_row_count" : 1}
=============================================================================*/
DECLARE
    v_user_id INT := p_user_id;
    v_query_result TEXT;
    v_affected_row_count TEXT;
BEGIN
    --====================================================================
    -- predefine
    --====================================================================
    v_query_result := 'failed';

    DELETE FROM lab.user
    WHERE user_id = v_user_id;

    GET DIAGNOSTICS v_affected_row_count = ROW_COUNT;

    IF v_affected_row_count = '0'
    THEN
        RAISE NOTICE 'Record with user_id=% not found.', v_user_id;
    ELSE
        RAISE NOTICE 'Record with user_id=% successfully deleted.', v_user_id;
    END IF;

    v_query_result := 'success';

    RETURN JSON_BUILD_OBJECT
    (
        'query_result',v_query_result,
        'affected_row_count', v_affected_row_count
    );
END;
$$;


ALTER FUNCTION mentor.udf_del_user(p_user_id integer) OWNER TO bi_admin;
