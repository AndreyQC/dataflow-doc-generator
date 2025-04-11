/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/procedure/name/usp_course_staff_insert(json)
  object_name: usp_course_staff_insert(json)
  object_schema: mentor
  object_type: procedure
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE PROCEDURE mentor.usp_course_staff_insert(IN jsn json)
    LANGUAGE plpgsql
    AS $$
DECLARE no_matched_course_name_from_json    VARCHAR(250) := '';
        no_matched_user_type_from_json      VARCHAR(100) := '';
        no_matched_user_city_from_json      VARCHAR(100) := '';
BEGIN
/*========================================================================================================================
 * Insert temp data from JSON
========================================================================================================================*/
    CREATE TEMPORARY TABLE temp_source (
        username        VARCHAR(100),
        course_name     VARCHAR(250),
        user_email      VARCHAR(100),
        user_type       VARCHAR(100),
        user_city       VARCHAR(100),
        user_yc_id      TEXT
    ) ON COMMIT DROP;

    INSERT INTO temp_source(username, course_name, user_email, user_type, user_city, user_yc_id)
    SELECT
        username,
        course_name,
        user_email,
        user_type,
        user_city,
        user_yc_id
    FROM json_to_recordset(jsn) AS j(
        username    VARCHAR(100),
        course_name VARCHAR(250),
        user_email  VARCHAR(100),
        user_type   VARCHAR(100),
        user_city   VARCHAR(100),
        user_yc_id  TEXT
    );

/*========================================================================================================================
 * Check course names
========================================================================================================================*/
    SELECT tmp.course_name
    INTO no_matched_course_name_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.course AS c ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
    WHERE tmp.course_name IS NOT NULL
        AND c.course_id IS NULL
    LIMIT 1;

    IF (no_matched_course_name_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'Course: ''%'' isn''t found', no_matched_course_name_from_json;
    END IF;

/*========================================================================================================================
 * Check user type
========================================================================================================================*/
    SELECT tmp.user_type
    INTO no_matched_user_type_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.user_type AS ut ON TRIM(UPPER(ut."name")) = TRIM(UPPER(tmp.user_type))
    WHERE tmp.user_type IS NOT NULL
        AND ut.user_type_id IS NULL
    LIMIT 1;

    IF (no_matched_user_type_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'User type:: ''%'' isn''t found', no_matched_user_type_from_json;
    END IF;

/*========================================================================================================================
 * Check user city
========================================================================================================================*/
    SELECT tmp.user_city
    INTO no_matched_user_city_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.city AS ct ON TRIM(UPPER(ct."name")) = TRIM(UPPER(tmp.user_city))
    WHERE tmp.user_city IS NOT NULL
        AND ct.city_id IS NULL
    LIMIT 1;

    IF (no_matched_user_city_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'User city:: ''%'' isn''t found', no_matched_user_city_from_json;
    END IF;

/*========================================================================================================================
 * Merge data to target tables
========================================================================================================================*/
    --Merge user
    MERGE INTO lab."user" AS tgt
    USING (
        SELECT DISTINCT
            tmp.username,
            tmp.user_email,
            ct.city_id,
            tmp.user_yc_id
        FROM temp_source AS tmp
        JOIN lab.city AS ct
            ON TRIM(UPPER(ct."name")) = TRIM(UPPER(tmp.user_city))
    ) src
        ON (TRIM(UPPER(src.user_email)) = TRIM(UPPER(tgt.email)))
    WHEN MATCHED THEN
        UPDATE SET
            "name" = src.username,
            city_id = src.city_id,
            user_yc_id = src.user_yc_id,
            sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
        INSERT (
            "name",
            email,
            city_id,
            user_yc_id
        )
        VALUES (
            src.username,
            src.user_email,
            src.city_id,
            src.user_yc_id
        );

    -- Merge course_staff
    MERGE INTO lab.course_staff tgt
    USING (
        SELECT DISTINCT
             u.id AS user_id
            ,c.course_id
            ,ut.user_type_id
        FROM temp_source AS tmp
        INNER JOIN lab."user" AS u
            ON TRIM(UPPER(u.email)) = TRIM(UPPER(tmp.user_email))
        INNER JOIN lab.course AS c
            ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
        INNER JOIN lab.user_type AS ut
            ON TRIM(UPPER(ut."name")) = TRIM(UPPER(tmp.user_type))
    ) src ON (src.user_id = tgt.user_id
            AND src.course_id = tgt.course_id)
    WHEN MATCHED THEN
        UPDATE SET
            user_type_id = src.user_type_id,
            sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
    INSERT (
        user_id,
        course_id,
        user_type_id
    ) VALUES
    (
        src.user_id,
        src.course_id,
        src.user_type_id
    );
END; $$;


ALTER PROCEDURE mentor.usp_course_staff_insert(IN jsn json) OWNER TO bi_admin;
