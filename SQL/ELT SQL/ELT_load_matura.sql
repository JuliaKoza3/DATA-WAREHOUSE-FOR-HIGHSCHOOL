use DataWarehouses;
go

If (object_id('vETLDimMatura') is not null) Drop view vETLDimMatura;
go

CREATE VIEW vETLDimMatura AS
SELECT DISTINCT
    subject,
    level, 
	year
FROM MATURA
WHERE subject IS NOT NULL AND level IS NOT NULL AND year IS NOT NULL;
GO

MERGE INTO DimMatura AS TT
USING vETLDimMatura AS ST
    ON TT.Subject = ST.subject
    AND TT.Level = ST.level
	AND TT.year =  ST.year

WHEN NOT MATCHED THEN
    INSERT (Subject, Level, year)
    VALUES (ST.subject, ST.level, ST.year);
GO

DROP VIEW vETLDimMatura;
GO