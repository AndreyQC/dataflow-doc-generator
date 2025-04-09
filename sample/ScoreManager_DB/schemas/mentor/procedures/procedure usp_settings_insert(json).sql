/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/procedure/name/usp_settings_insert(json)
  object_name: usp_settings_insert(json)
  object_schema: mentor
  object_type: procedure
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE PROCEDURE mentor.usp_settings_insert(IN jsn json)
    LANGUAGE plpgsql
    AS $$
DECLARE no_matched_user_from_json           VARCHAR(100) := '';
        no_matched_course_name_from_json    VARCHAR(250) := '';
BEGIN
/*========================================================================================================================
 * Insert temp data from JSON
========================================================================================================================*/
    CREATE TEMPORARY TABLE temp_source (
        user_email              VARCHAR(100),
        current_course_name     VARCHAR(250)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(user_email, current_course_name)
    SELECT
        user_email,
        current_course_name
    FROM json_to_recordset(jsn) AS j(
        user_email          VARCHAR(100),
        current_course_name VARCHAR(250)
    );

/*========================================================================================================================
 * Check user
========================================================================================================================*/
    SELECT tmp.user_email
    INTO no_matched_user_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.user AS u ON TRIM(UPPER(u.email)) = TRIM(UPPER(tmp.user_email))
    WHERE tmp.user_email IS NOT NULL
        AND u.id IS NULL
    LIMIT 1;

    IF (no_matched_user_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'User with email: ''%'' isn''t found', no_matched_user_from_json;
    END IF;

/*========================================================================================================================
 * Check course names
========================================================================================================================*/
    SELECT tmp.current_course_name
    INTO no_matched_course_name_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.course AS c ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.current_course_name))
    WHERE tmp.current_course_name IS NOT NULL
        AND c.course_id IS NULL
    LIMIT 1;

    IF (no_matched_course_name_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'Course: ''%'' isn''t found', no_matched_course_name_from_json;
    END IF;

/*========================================================================================================================
 * Merge data to Settings
========================================================================================================================*/
MERGE INTO lab.settings AS tgt
USING (
    SELECT DISTINCT
         u.id AS user_id
        ,'current_course_name' AS setting_name
        ,tmp.current_course_name AS setting_value
    FROM temp_source AS tmp
    JOIN lab.user AS u
        ON TRIM(UPPER(u.email)) = TRIM(UPPER(tmp.user_email))) src ON src.setting_name = tgt.setting_name
            AND src.user_id = tgt.user_id
WHEN MATCHED THEN
    UPDATE SET
        setting_value = src.setting_value,
        sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
WHEN NOT MATCHED THEN
    INSERT (
        user_id,
        setting_name,
        setting_value
    ) VALUES (
        src.user_id,
        src.setting_name,
        src.setting_value
    );
END; $$;


ALTER PROCEDURE mentor.usp_settings_insert(IN jsn json) OWNER TO bi_admin;
