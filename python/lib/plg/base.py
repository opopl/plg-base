
def table_exists (ref):
       table  = ref.get('table')
       cur    = ref.get('cur')
       dbfile = ref.get('dbfile')
       tables = []
       q='''
               SELECT
                       name
               FROM
                       sqlite_master
               WHERE
                       type IN ('table','view') AND name NOT LIKE 'sqlite_%'
               UNION ALL
               SELECT
                       name
               FROM
                       sqlite_temp_master
               WHERE
                       type IN ('table','view')
               ORDER BY 1
       '''
       if cur:
               cur.execute(q)
               rows = cur.fetchall()
               tables = map(lambda x: x[0], rows)
               if table in tables:
                       return 1
       return 0
