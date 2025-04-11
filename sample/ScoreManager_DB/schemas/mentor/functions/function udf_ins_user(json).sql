/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_ins_user(json)
  object_name: udf_ins_user(json)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_ins_user(p_parameters_json json) RETURNS json
    LANGUAGE plpgsql
    AS $_$
/*=============================================================================
* p_parameters_json
* example p_parameters_json {
                    "username": "Sergei Boikov",
                    "user_email": "sergei_boikov@rntgroup.com",
                    "user_city": "Sarator",
                    "user_notes": "ticket 20240703--01",
                    "user_password": "sha256$2cCnKvMl70MK1NBT$1f79....",
                    "user_is_active": "true"
                    }
* example of RETURN
* {"query_result" : "success" , "affected_row_count" : 1}
*
=============================================================================*/

DECLARE
    v_username TEXT := (p_parameters_json->>'username')::TEXT;
    v_user_email TEXT := (p_parameters_json->>'user_email')::TEXT;
    v_user_city TEXT := (p_parameters_json->>'user_city')::TEXT;
    v_user_notes TEXT := (p_parameters_json->>'user_notes')::TEXT;
    v_user_password TEXT := (p_parameters_json->>'user_password')::TEXT;
    v_user_is_active BOOLEAN := (p_parameters_json->>'user_is_active')::BOOLEAN;
    v_select_user_id INT;
    v_select_city_id INT;
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

    SELECT c.id INTO v_select_city_id
    FROM lab.city AS c
    WHERE c.name = v_user_city;

    IF v_select_city_id IS NULL THEN
        RAISE EXCEPTION 'City "%" not found', v_user_city;
    END IF;

    SELECT u.user_id
    INTO v_select_user_id
    FROM lab.user AS u
    WHERE u.email = v_user_email;


    --=============================================================================
    -- Upsert data into target
    --=============================================================================

    INSERT INTO lab.user (
        name,
        email,
        city_id,
        notes,
        password,
        is_active
    )
    VALUES (
        v_username,
        v_user_email,
        v_select_city_id,
        v_user_notes,
        v_user_password,
        v_user_is_active
    )
    ON CONFLICT (email) DO UPDATE
           SET name = EXCLUDED.name,
               city_id = EXCLUDED.city_id,
               notes = EXCLUDED.notes,
               password = EXCLUDED.password,
               is_active = EXCLUDED.is_active;

    GET DIAGNOSTICS v_affected_row_count = ROW_COUNT;

    v_query_result := 'success';

    RETURN JSON_BUILD_OBJECT (
        'query_result',v_query_result,
        'affected_row_count', v_affected_row_count
    );

END;
$_$;


ALTER FUNCTION mentor.udf_ins_user(p_parameters_json json) OWNER TO bi_admin;
