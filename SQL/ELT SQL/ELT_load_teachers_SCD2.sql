USE DataWarehouses;
GO


If (object_id('vETLDimTeacher') is not null) Drop view vETLDimTeacher;
go


CREATE VIEW vETLDimTeacher AS
SELECT 
    teacher_PESEL, 
	subject_teacher, 
	MIN([year]) AS year
FROM dbo.ExcelFile
WHERE teacher_PESEL IS NOT NULL AND subject_teacher IS NOT NULL AND [year] IS NOT NULL
GROUP BY teacher_PESEL, subject_teacher;
GO

MERGE INTO DimTeacher AS TT
USING vETLDimTeacher AS ST
    ON TT.Teacher_PESEL = ST.teacher_PESEL
   AND TT.Subject = ST.subject_teacher

WHEN NOT MATCHED BY TARGET THEN
    INSERT (Teacher_PESEL, Subject, year, isCurrent)
    VALUES (ST.teacher_PESEL, ST.subject_teacher, ST.[year], 1);
GO

UPDATE DT
SET DT.isCurrent = 0
FROM dbo.DimTeacher DT
WHERE EXISTS (
    SELECT 1
    FROM (
        SELECT teacher_PESEL, MAX(year) AS LatestYear
        FROM dbo.DimTeacher
        GROUP BY teacher_PESEL
    ) AS Latest
    WHERE Latest.teacher_PESEL = DT.Teacher_PESEL
      AND DT.year < Latest.LatestYear
      AND DT.isCurrent = 1
);

DROP VIEW vETLDimTeacher;
GO


