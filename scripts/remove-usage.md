```
docker exec -it <postgres-container> psql -U <username> -d <database>
```
---
```sql
BEGIN;

DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOREACH tbl IN ARRAY ARRAY[
        'LiteLLM_SpendLogs',
        'LiteLLM_SpendLogToolIndex',
        'LiteLLM_SpendLogGuardrailIndex',
        'LiteLLM_DailyUserSpend',
        'LiteLLM_DailyTeamSpend',
        'LiteLLM_DailyOrgSpend',
        'LiteLLM_DailyTagSpend',
        'LiteLLM_DailyEndUserSpend',
        'LiteLLM_DailyAgentSpend',
        'LiteLLM_DailyGatewayRequests'
    ]
    LOOP
        IF to_regclass('public."' || tbl || '"') IS NOT NULL THEN
            EXECUTE format('DELETE FROM %I', tbl);
            RAISE NOTICE 'Cleared %', tbl;
        END IF;
    END LOOP;
END $$;

COMMIT;
```
