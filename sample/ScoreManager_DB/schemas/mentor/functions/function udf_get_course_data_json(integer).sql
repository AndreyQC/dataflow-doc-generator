/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_get_course_data_json(integer)
  object_name: udf_get_course_data_json(integer)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_get_course_data_json(p_course_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'course_name', crs."name",
        'course_datestart', crs.datestart,
        'course_datefinish', crs.datefinish,
        'course_desc', COALESCE(crs.description,''),
        'course_staff', (
            SELECT json_agg(json_build_object(
                  'username', usr.name,
                  'user_email', usr.email,
                  'user_password','',
                  'user_type', ut.name,
                  'user_city', ct.name,
                  'notes', COALESCE(usr.notes, ''),
                  'is_active', usr.is_active
                  ))
            FROM lab.course_staff AS cstf
                INNER JOIN lab."user" AS usr
                    ON usr.id = cstf.user_id
                INNER JOIN lab.user_type AS ut
                    ON ut.user_type_id = cstf.user_type_id
                INNER JOIN lab.city AS ct
                    ON ct.city_id = usr.city_id
            WHERE cstf.course_id = crs.course_id
            ),
        'tasks',(
            SELECT json_agg(json_build_object(
                'task_name', tsk."name",
                'task_description', tsk.description,
                'task_topic', tsktp."name",
                'subtask_name', sbtsk."name",
                'subtask_description', sbtsk.description,
                'subtask_topic', sbtsktp."name",
                'subtask_max_score', sbtsk.max_score,
                'subtask_bonuses', (
                    SELECT COALESCE(json_agg(json_build_object(
                        'bonus_name', bns."name"
                        ))
                        ,'[]')
                    FROM lab.subtask_bonus AS sbns
                        INNER JOIN lab.bonus AS bns
                            ON bns.bonus_id = sbns.bonus_id
                        WHERE sbns.subtask_id = sbtsk.subtask_id
                ),
                'check_script',(
                    SELECT COALESCE(json_build_object(
                        'check_script_type', cst."name",
                        'check_script_connection_name', cn.connection_name,
                        'check_script_description', cs.description,
                        'check_script_text', REPLACE(cs."text", '''', '''''')
                        )
                        ,'{}')
                    FROM lab.subtask AS sbtsk_01
                        INNER JOIN lab.check_script AS cs
                            ON cs.check_script_id = sbtsk_01.check_script_id
                        INNER JOIN lab.check_script_type AS cst
                            ON cst.check_script_type_id = cs.check_script_type_id
                        INNER JOIN lab."connection" AS cn
                            ON cn.connection_id = cs.connection_id
                        WHERE sbtsk_01.subtask_id = sbtsk.subtask_id
                )
            ))
            FROM lab.task AS tsk
                INNER JOIN lab.subtask AS sbtsk
                    ON sbtsk.task_id = tsk.task_id
                INNER JOIN lab.topic AS tsktp
                    ON tsktp.topic_id = tsk.topic_id
                INNER JOIN lab.topic AS sbtsktp
                    ON sbtsktp.topic_id = sbtsk.topic_id
            WHERE tsk.course_id = crs.course_id
        )
    ) AS course_json
    INTO result
    FROM lab.course AS crs
    WHERE crs.course_id = p_course_id;

    RETURN result;

END;
$$;


ALTER FUNCTION mentor.udf_get_course_data_json(p_course_id integer) OWNER TO bi_admin;
