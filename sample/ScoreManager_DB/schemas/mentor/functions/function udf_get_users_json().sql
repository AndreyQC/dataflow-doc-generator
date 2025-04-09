/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_get_users_json()
  object_name: udf_get_users_json()
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_get_users_json() RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_agg(row_to_json(user_table))
    INTO result
    FROM (
        SELECT id, name, email FROM lab."user"
        ORDER BY name
    ) AS user_table;

    RETURN result;
END;
$$;


ALTER FUNCTION mentor.udf_get_users_json() OWNER TO bi_admin;
