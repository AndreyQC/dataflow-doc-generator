/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/procedure/name/usp_scores_insert(json)
  object_name: usp_scores_insert(json)
  object_schema: mentor
  object_type: procedure
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE PROCEDURE mentor.usp_scores_insert(IN jsn json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    reviewer_name_from_json VARCHAR(100) := '';
    student_name_from_json  VARCHAR(100) := '';
    course_name_from_json   VARCHAR(250) := '';
    tmp_reviewer_id         INT := -1;
    tmp_student_id          INT := -1;
    tmp_course_id           INT := -1;
    row record;
BEGIN
/*========================================================================================================================
 * Insert temp data from JSON
========================================================================================================================*/
    CREATE TEMPORARY TABLE temp_source (
        course_name     VARCHAR(250),
        reviewer_name   VARCHAR(100),
        student_name    VARCHAR(100),
        task_name       VARCHAR(250),
        subtask_name    VARCHAR(250),
        score           NUMERIC(8,2),
        name_conv       NUMERIC(8,2),
        readability     NUMERIC(8,2),
        sarg            NUMERIC(8,2),
        schema_name     NUMERIC(8,2),
        aliases         NUMERIC(8,2),
        determ_sorting  NUMERIC(8,2),
        ontime          NUMERIC(8,2),
        extra           NUMERIC(8,2),
        "comment"       VARCHAR(2000)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(
        course_name,
        reviewer_name,
        student_name,
        task_name,
        subtask_name,
        score,
        name_conv,
        readability,
        sarg,
        schema_name,
        aliases,
        determ_sorting,
        ontime,
        extra,
        "comment"
    )
    SELECT
        j.course_name,
        j.reviewer_name,
        j.student_name,
        j.task_name,
        t.subtask_name,
        t.score,
        t.name_conv,
        t.readability,
        t.sarg,
        t.schema_name,
        t.aliases,
        t.determ_sorting,
        t.ontime,
        t.extra,
        t."comment"
    FROM json_to_record(jsn) AS j(
        course_name     VARCHAR(250),
        reviewer_name   VARCHAR(100),
        student_name    VARCHAR(100),
        task_name       VARCHAR(250)
    )
    CROSS JOIN LATERAL(
        SELECT *
        FROM json_to_recordset(
                json_extract_path(jsn, 'subtasks')
                ) AS j(
                    subtask_name    VARCHAR(250),
                    score           NUMERIC(8,2),
                    name_conv       NUMERIC(8,2),
                    readability     NUMERIC(8,2),
                    sarg            NUMERIC(8,2),
                    schema_name     NUMERIC(8,2),
                    aliases         NUMERIC(8,2),
                    determ_sorting  NUMERIC(8,2),
                    ontime          NUMERIC(8,2),
                    extra           NUMERIC(8,2),
                    "comment"       VARCHAR(2000)
        )
    ) AS t;

/*========================================================================================================================
 * Get course info
========================================================================================================================*/
    SELECT t.course_name
    INTO course_name_from_json
    FROM temp_source AS t
    LIMIT 1;

    SELECT c.course_id
    INTO tmp_course_id
    FROM lab.course AS c
    WHERE c."name" = course_name_from_json
    LIMIT 1;

/*========================================================================================================================
 * Check reviewer_name
========================================================================================================================*/
    SELECT t.reviewer_name
    INTO reviewer_name_from_json
    FROM temp_source AS t
    LIMIT 1;

    SELECT sc.course_staff_id
    INTO tmp_reviewer_id
    FROM lab.user AS u
    INNER JOIN lab.course_staff AS sc
        ON sc.user_id = u.id
    INNER JOIN lab.user_type AS ut
        ON ut.user_type_id = sc.user_type_id
    WHERE ut."name" = 'mentor'
        AND sc.course_id = tmp_course_id
        AND u."name" = reviewer_name_from_json
    LIMIT 1;

    IF (tmp_reviewer_id IS NULL)
    THEN
        RAISE EXCEPTION 'Reviewer: ''%'' isn''t found', reviewer_name_from_json;
    END IF;

/*========================================================================================================================
 * Check student_name
========================================================================================================================*/
    SELECT t.student_name
    INTO student_name_from_json
    FROM temp_source AS t
    LIMIT 1;

    SELECT sc.course_staff_id
    INTO tmp_student_id
    FROM lab."user" AS u
    INNER JOIN lab.course_staff AS sc
        ON sc.user_id = u.id
    INNER JOIN lab.user_type AS ut
        ON ut.user_type_id = sc.user_type_id
    WHERE ut."name" = 'student'
        AND sc.course_id = tmp_course_id
        AND u."name" = student_name_from_json;

    IF (tmp_student_id IS NULL)
    THEN
        RAISE EXCEPTION 'Student: ''%'' isn''t found', student_name_from_json;
    END IF;

/*========================================================================================================================
 * Check subtask
========================================================================================================================*/
    IF EXISTS (
        SELECT t.task_name, t.subtask_name
        FROM temp_source AS t
        EXCEPT
        SELECT t."name", st."name"
        FROM lab.subtask AS st
        INNER JOIN lab.task AS t
            ON t.task_id = st.task_id
        WHERE t.course_id = tmp_course_id
    )
    THEN
        RAISE EXCEPTION 'Some subtasks aren''t found';
    END IF;

/*========================================================================================================================
 * Merge data
========================================================================================================================*/
    MERGE INTO lab.subtask_log AS tgt
    USING (
        SELECT
            stl.subtask_log_id,
            st.subtask_id,
            tmp.score,
            COALESCE(tmp.ontime, 0)         AS ontime,
            COALESCE(tmp.name_conv,0)       AS name_conv,
            COALESCE(tmp.readability,0)     AS readability,
            COALESCE(tmp.sarg,0)            AS sarg,
            COALESCE(tmp.schema_name,0)     AS schema_name,
            COALESCE(tmp.aliases,0)         AS aliases,
            COALESCE(tmp.determ_sorting,0)  AS determ_sorting,
            COALESCE(tmp.extra, 0)          AS extra,
            tmp.comment
        FROM temp_source AS tmp
                INNER JOIN lab.task AS t
                    ON t."name" = tmp.task_name
                        AND t.course_id = tmp_course_id
                INNER JOIN lab.subtask AS st
                    ON st.task_id = t.task_id
                        AND st."name" = tmp.subtask_name
                LEFT JOIN lab.subtask_log AS stl
                    ON stl.subtask_id = st.subtask_id
                        AND stl.student_id = tmp_student_id
    ) as src
        ON tgt.subtask_log_id = src.subtask_log_id
    WHEN MATCHED THEN
        UPDATE SET
            reviewer_id     = tmp_reviewer_id,
            score           = src.score,
            ontime          = src.ontime,
            name_conv       = src.name_conv,
            readability     = src.readability,
            sarg            = src.sarg,
            schema_name     = src.schema_name,
            aliases         = src.aliases,
            determ_sort     = src.determ_sorting,
            extra           = src.extra,
            "comment"       = src."comment",
            sys_changed_at  = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
        INSERT (
            subtask_id,
            student_id,
            reviewer_id,
            score,
            ontime,
            name_conv,
            readability,
            sarg,
            schema_name,
            aliases,
            determ_sort,
            extra,
            "comment"
        )
    VALUES (
        src.subtask_id,
        tmp_student_id,
        tmp_reviewer_id,
        src.score,
        src.ontime,
        src.name_conv,
        src.readability,
        src.sarg,
        src.schema_name,
        src.aliases,
        src.determ_sorting,
        src.extra,
        src."comment"
    );

/*========================================================================================================================
 * Return result
========================================================================================================================*/
FOR row IN
    SELECT
        c."name"                                AS course_name,
        tmp.reviewer_name                       AS reviewer_name,
        tmp.student_name                        AS student_name,
        t."name"                                AS task_name,
        st."name"                               AS subtask_name,
        stl.score                               AS score,
        stl.name_conv                           AS name_conv,
        stl.readability                         AS readability,
        stl.sarg                                AS sarg,
        stl.schema_name                         AS schema_name,
        stl.aliases                             AS aliases,
        stl.determ_sort                         AS determ_sort,
        stl.ontime                              AS ontime,
        stl.extra                               AS extra,
        COALESCE(stl.score,0)
            + COALESCE(tmp.name_conv,0)
            + COALESCE(tmp.readability,0)
            + COALESCE(tmp.sarg,0)
            + COALESCE(tmp.schema_name,0)
            + COALESCE(tmp.aliases,0)
            + COALESCE(tmp.determ_sorting,0)
            + COALESCE(tmp.ontime,0)
            + COALESCE(tmp.extra,0)             AS total_score,
        stl."comment"       AS "comment"
    FROM temp_source AS tmp
    INNER JOIN lab.task AS t
        ON t."name" = tmp.task_name
            AND t.course_id = tmp_course_id
    INNER JOIN lab.course AS c
        ON c.course_id = t.course_id
    INNER JOIN lab.subtask AS st
        ON st.task_id = t.task_id
            AND st."name" = tmp.subtask_name
    INNER JOIN lab.subtask_log AS stl
        ON stl.subtask_id = st.subtask_id
            AND stl.student_id = tmp_student_id
            AND stl.reviewer_id = tmp_reviewer_id
LOOP
    RAISE NOTICE 'course_name: %, reviewer_name: %, student_name: %, task_name: %, subtask_name: %, score: %, name_conv: %, readability: %, sarg: %, schema_name: %, aliases: %, determ_sort: %, ontime: %, extra: %, total_score: %, comment: %',
        row.course_name,
        row.reviewer_name,
        row.student_name,
        row.task_name,
        row.subtask_name,
        row.score,
        row.name_conv,
        row.readability,
        row.sarg,
        row.schema_name,
        row.aliases,
        row.determ_sort,
        row.ontime,
        row.extra,
        row.total_score,
        row."comment";
END LOOP;

DROP TABLE IF EXISTS tmp_course_id;
DROP TABLE IF EXISTS tmp_student_id;

END; $$;


ALTER PROCEDURE mentor.usp_scores_insert(IN jsn json) OWNER TO bi_admin;
