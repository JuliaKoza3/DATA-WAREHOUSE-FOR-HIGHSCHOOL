use DataWarehouses;
go

If (object_id('vETLDimProfile_Class') is not null) Drop view vETLDimProfile_Class;
go



CREATE VIEW vETLDimProfileClass AS
SELECT DISTINCT
    class_name,
    CAST(description AS VARCHAR(50)) AS description
FROM PROFILE_CLASS
WHERE class_name IS NOT NULL AND description IS NOT NULL;
GO

-- Step 3: Load into DimProfile_Class only new values
MERGE INTO DimProfile_Class AS TT
USING vETLDimProfileClass AS ST
    ON TT.Class_name = ST.class_name
    AND TT.Description = ST.description

WHEN NOT MATCHED THEN
    INSERT (Class_name, Description)
    VALUES (ST.class_name, ST.description);
GO


DROP VIEW vETLDimProfileClass;
GO