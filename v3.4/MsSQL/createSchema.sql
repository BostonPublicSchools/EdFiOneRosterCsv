IF NOT EXISTS ( SELECT  *
                FROM    sys.schemas
                WHERE   name = N'onerosterv11csv' )
    EXEC('CREATE SCHEMA [onerosterv11csv]');
GO
