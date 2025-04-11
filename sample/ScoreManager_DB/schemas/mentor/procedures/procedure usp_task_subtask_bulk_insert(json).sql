/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/procedure/name/usp_task_subtask_bulk_insert(json)
  object_name: usp_task_subtask_bulk_insert(json)
  object_schema: mentor
  object_type: procedure
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE PROCEDURE mentor.usp_task_subtask_bulk_insert(IN jsn json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    no_matched_task_topic_from_json     VARCHAR(250) := '';
    no_matched_course_name_from_json    VARCHAR(250) := '';
    no_matched_subtask_topic_from_json  VARCHAR(250) := '';
BEGIN
/*========================================================================================================================
 * Insert temp data from JSON
========================================================================================================================*/

    CREATE TEMPORARY TABLE temp_source (
        course_name             VARCHAR(250),
        task_name               VARCHAR(100),
        task_description        VARCHAR(100),
        task_topic              VARCHAR(250),
        subtask_name            VARCHAR(250),
        subtask_description     TEXT,
        subtask_topic           VARCHAR(250),
        subtask_max_score       NUMERIC(8,2)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(
        course_name,
        task_name,
        task_description,
        task_topic,
        subtask_name,
        subtask_description,
        subtask_topic,
        subtask_max_score
    )
    SELECT
        j.course_name,
        j.task_name,
        j.task_description,
        j.task_topic,
        j.subtask_name,
        j.subtask_description,
        j.subtask_topic,
        j.subtask_max_score
    FROM json_to_recordset(jsn) AS j (
        course_name             VARCHAR(250),
        task_name               VARCHAR(100),
        task_description        VARCHAR(100),
        task_topic              VARCHAR(250),
        subtask_name            VARCHAR(250),
        subtask_description     TEXT,
        subtask_topic           VARCHAR(250),
        subtask_max_score       NUMERIC(8,2)
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
 * Merge task_topic
========================================================================================================================*/

    MERGE INTO lab.topic AS tgt
    USING (
        SELECT DISTINCT
            task_topic  AS topic,
            True        AS is_topic_for_tasks
        FROM temp_source
    ) src
        ON TRIM(UPPER(tgt."name")) = TRIM(UPPER(src.topic))
    WHEN MATCHED THEN
    UPDATE SET
        is_topic_for_tasks = src.is_topic_for_tasks,
        sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
    INSERT (
        "name",
        is_topic_for_tasks
    ) VALUES (
        src.topic,
        src.is_topic_for_tasks
    );

/*========================================================================================================================
 * Merge subtask_topic
========================================================================================================================*/

    MERGE INTO lab.topic AS tgt
    USING (
        SELECT DISTINCT
            subtask_topic   AS topic,
            True            AS is_topic_for_subtasks
        FROM temp_source
    ) src
        ON TRIM(UPPER(tgt."name")) = TRIM(UPPER(src.topic))
    WHEN MATCHED THEN
    UPDATE SET
        is_topic_for_subtasks = src.is_topic_for_subtasks,
        sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
    INSERT (
        "name",
        is_topic_for_subtasks
    ) VALUES (
        src.topic,
        src.is_topic_for_subtasks
    );

/*========================================================================================================================
 * Merge task
========================================================================================================================*/

    MERGE INTO lab.task tgt
    USING (
        SELECT DISTINCT
            course_id,
            tmp.task_name,
            tmp.task_description,
            tt.topic_id
        FROM temp_source AS tmp
        INNER JOIN lab.course AS c
            ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
        INNER JOIN lab.topic AS tt
            ON TRIM(UPPER(tt."name")) = TRIM(UPPER(tmp.task_topic))
    ) src
        ON (tgt."name" = src.task_name
            AND tgt.course_id = src.course_id)
    WHEN MATCHED THEN
    UPDATE SET
        description = src.task_description,
        topic_id = src.topic_id,
        sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
    INSERT (
        "name",
        description,
        topic_id,
        course_id
    ) VALUES (
        src.task_name,
        src.task_description,
        src.topic_id,
        src.course_id
    );

/*========================================================================================================================
 * Merge subtask
========================================================================================================================*/

    MERGE INTO lab.subtask tgt
    USING (
        SELECT
            t.task_id,
            tmp.subtask_name,
            tmp.subtask_description,
            stt.topic_id,
            tmp.subtask_max_score
        FROM temp_source AS tmp
        INNER JOIN lab.topic AS stt
            ON TRIM(UPPER(stt."name")) = TRIM(UPPER(tmp.subtask_topic))
        INNER JOIN lab.task AS t
            ON TRIM(UPPER(t."name")) = TRIM(UPPER(tmp.task_name))
        WHERE tmp.subtask_name IS NOT NULL) src
    ON (src.subtask_name = tgt."name"
        AND src.task_id = tgt.task_id)
    WHEN MATCHED THEN
    UPDATE SET
        description = src.subtask_description,
        topic_id = src.topic_id,
        max_score = src.subtask_max_score,
        sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
    INSERT (
        task_id,
        "name",
        description,
        topic_id,
        max_score
    ) VALUES (
        src.task_id,
        src.subtask_name,
        src.subtask_description,
        src.topic_id,
        src.subtask_max_score
    );
END; $$;


ALTER PROCEDURE mentor.usp_task_subtask_bulk_insert(IN jsn json) OWNER TO bi_admin;
