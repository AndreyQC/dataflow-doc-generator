/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/procedure/name/usp_check_script_bulk_insert(json)
  object_name: usp_check_script_bulk_insert(json)
  object_schema: mentor
  object_type: procedure
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE PROCEDURE mentor.usp_check_script_bulk_insert(IN jsn json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    no_matched_course_name_from_json                VARCHAR(250) := '';
    no_matched_task_name_from_json                  VARCHAR(250) := '';
    no_matched_subtask_name_from_json               VARCHAR(250) := '';
    no_matched_check_script_type_name_from_json     VARCHAR(250) := '';
    no_matched_connection_string_from_json          VARCHAR(250) := '';
    no_matched_connection_type_name_from_json       VARCHAR(250) := '';
BEGIN
    CREATE TEMPORARY TABLE temp_source (
        course_name             VARCHAR(250),
        task_name               VARCHAR(100),
        subtask_name            VARCHAR(250),
        check_script_text       TEXT,
        check_script_desc       TEXT,
        check_script_type_name  VARCHAR(250),
        connection_string       VARCHAR(250),
        connection_type_name    VARCHAR(250)
    ) ON COMMIT DROP;

    SELECT
        j->> 'course_name'              AS course_name,
        j->> 'task_name'                AS task_name,
        j->> 'subtask_name'             AS subtask_name,
        j->> 'check_script_text'        AS check_script_text,
        j->> 'check_script_desc'        AS check_script_desc,
        j->> 'check_script_type_name'   AS check_script_type_name,
        j->> 'connection_string'        AS connection_string,
        j->> 'connection_type_name'     AS connection_type_name
    FROM json_array_elements(jsn) AS j;

    -- Check course names
    SELECT no_matched_course_name_from_json = tmp.course_name
    FROM temp_source AS tmp
        LEFT JOIN lab.course AS c
            ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
    WHERE tmp.course_name IS NOT NULL
        AND c.course_id IS NULL
    LIMIT 1;
    IF no_matched_course_name_from_json IS NOT NULL
    THEN
        BEGIN
            RAISE EXCEPTION 'course with name: ''%s'' isn''t found', no_matched_course_name_from_json;
        END;
    END IF;

    -- Check task_name
    SELECT no_matched_task_name_from_json = tmp.task_name
    FROM temp_source AS tmp
        LEFT JOIN lab.task AS t
            ON TRIM(UPPER(t."name")) = TRIM(UPPER(tmp.task_name))
    WHERE tmp.task_name IS NOT NULL
        AND t.task_id IS NULL
    LIMIT 1;
    IF no_matched_task_name_from_json IS NOT NULL
    THEN
        BEGIN
            RAISE EXCEPTION 'task with name: ''%s'' isn''t found', no_matched_task_name_from_json;
        END;
    END IF;

    -- Check subtask_name
    SELECT no_matched_subtask_name_from_json = tmp.subtask_name
    FROM temp_source AS tmp
        LEFT JOIN lab.subtask AS t
            ON TRIM(UPPER(t."name")) = TRIM(UPPER(tmp.subtask_name))
    WHERE tmp.subtask_name IS NOT NULL
        AND t.subtask_id IS NULL
    LIMIT 1;
    IF no_matched_subtask_name_from_json IS NOT NULL
    THEN
        BEGIN
            RAISE EXCEPTION 'subtask with name: ''%s'' isn''t found', no_matched_subtask_name_from_json;
        END;
    END IF;

    -- Check check_script_type_name
    SELECT no_matched_check_script_type_name_from_json = tmp.check_script_type_name
    FROM temp_source AS tmp
        LEFT JOIN lab.check_script_type AS t
            ON TRIM(UPPER(t."name")) = TRIM(UPPER(tmp.check_script_type_name))
    WHERE tmp.check_script_type_name IS NOT NULL
        AND t.check_script_type_id IS NULL
    LIMIT 1;
    IF no_matched_check_script_type_name_from_json IS NOT NULL
    THEN
        BEGIN
            RAISE EXCEPTION 'subtask with name: ''%s'' isn''t found', no_matched_check_script_type_name_from_json;
        END;
    END IF;

    -- Check connection_type_name
    SELECT no_matched_connection_type_name_from_json = tmp.connection_type_name
    FROM temp_source AS tmp
        LEFT JOIN lab.connection_type AS t
            ON TRIM(UPPER(t."name")) = TRIM(UPPER(tmp.connection_type_name))
    WHERE tmp.connection_type_name IS NOT NULL
        AND t.connection_type_id IS NULL
    LIMIT 1;
    IF no_matched_connection_type_name_from_json IS NOT NULL
    THEN
        BEGIN
            RAISE EXCEPTION 'connection_type with name: ''%s'' isn''t found', no_matched_connection_type_name_from_json;
        END;
    END IF;

    -- Check connection_string
    MERGE INTO lab.connection tgt
    USING (
            SELECT DISTINCT tmp.connection_string
                            ,ct.connection_type_id
            FROM temp_source AS tmp
                LEFT  JOIN  lab.connection AS c
                    ON TRIM(UPPER(c.connection_string)) = TRIM(UPPER(tmp.connection_string))
                INNER JOIN lab.connection_type AS ct
                    ON TRIM(UPPER(ct."name")) = TRIM(UPPER(tmp.connection_type_name))
            WHERE tmp.connection_string IS NOT NULL
                AND c.connection_id IS NULL
    ) src
        ON TRIM(UPPER(src.connection_string)) = TRIM(UPPER(tgt.connection_string))
    WHEN NOT MATCHED
    THEN INSERT (connection_string, connection_type_id)
         VALUES (src.connection_string, src.connection_type_id);

    -- check_script insert
    MERGE INTO lab.check_script tgt
    USING (
        SELECT DISTINCT  tmp.check_script_text
                        ,tmp.check_script_desc
                        ,  c.connection_id
                        ,cst.check_script_type_id
        FROM temp_source AS tmp
        INNER JOIN lab.connection AS c
            ON TRIM(UPPER(c.connection_string)) = TRIM(UPPER(tmp.connection_string))
        INNER JOIN lab.check_script_type AS cst
            ON TRIM(UPPER(cst."name")) = TRIM(UPPER(tmp.check_script_type_name))
        INNER JOIN lab.connection_type AS ct
            ON TRIM(UPPER(ct."name")) = TRIM(UPPER(tmp.connection_type_name))
            AND ct.connection_type_id = c.connection_type_id) src
                ON (TRIM(UPPER(src.check_script_text)) = TRIM(UPPER(tgt.text)))
    WHEN MATCHED THEN
    UPDATE SET
         tgt.description        = src.check_script_desc
        ,tgt.connection_id       = src.connection_id
        ,tgt.check_script_type_id= src.check_script_type_id
        ,tgt.sys_changed_at       = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
    INSERT (
         text
        ,description
        ,connection_id
        ,check_script_type_id
    ) VALUES
    (
         src.check_script_text
        ,src.check_script_desc
        ,src.connection_id
        ,src.check_script_type_id
    );

    -- subtask check_script_id update
    UPDATE st
    SET  st.check_script_id = cs.check_script_id
        ,st.sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    FROM lab.subtask st
        INNER JOIN temp_source tmp
            ON TRIM(UPPER(st."name")) = TRIM(UPPER(tmp.subtask_name))
        INNER JOIN lab.check_script CS
            ON TRIM(UPPER(cs.text)) = TRIM(UPPER(tmp.check_script_text))
        INNER JOIN lab.task T
            ON TRIM(UPPER(t."name")) = TRIM(UPPER(tmp.task_name))
                AND t.task_id = st.task_id
        INNER JOIN lab.course C
            ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
                AND c.course_id= t.course_id;
    COMMIT;
    EXCEPTION WHEN OTHERS
        THEN ROLLBACK;
END; $$;


ALTER PROCEDURE mentor.usp_check_script_bulk_insert(IN jsn json) OWNER TO bi_admin;
