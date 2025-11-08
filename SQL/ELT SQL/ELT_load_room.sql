USE DataWarehouses;
GO

IF OBJECT_ID('vETLDimRoom') IS NOT NULL 
    DROP VIEW vETLDimRoom;
GO

CREATE VIEW vETLDimRoom AS
SELECT DISTINCT
    EF.classroom,
    EF.size
FROM ExcelFile AS EF  
WHERE EF.classroom IS NOT NULL 
  AND EF.size IS NOT NULL;
GO

MERGE INTO DimRoom AS TT
USING vETLDimRoom AS ST
    ON TT.Room_number = ST.classroom
    AND TT.Size = ST.size

WHEN NOT MATCHED THEN
    INSERT (Room_number, Size)
    VALUES (ST.classroom, ST.size);
GO

DROP VIEW vETLDimRoom;
GO
