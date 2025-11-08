use DataWarehouses;
go

If (object_id('vETLDimStudent') is not null) Drop view vETLDimStudent;
go

CREATE VIEW vETLDimStudent AS
SELECT 
    PESEL,
    student_name_surname,
    S.class_id, 
    graduation_year, 
    class_name
FROM STUDENT AS S
JOIN PROFILE_CLASS AS P ON P.class_id = S.class_id
WHERE PESEL IS NOT NULL AND student_name_surname IS NOT NULL AND S.class_id IS NOT NULL AND graduation_year IS NOT NULL;
GO

MERGE INTO DimStudent AS TT
USING (
    SELECT 
        PESEL, 
        student_name_surname, 
        class_id, 
        graduation_year
    FROM vETLDimStudent
    WHERE class_name IN (SELECT class_name FROM dbo.DimProfile_Class)
) AS ST
    ON TT.Student_PESEL = ST.PESEL
   AND TT.Student_name_surname = ST.student_name_surname
   AND TT.ID_Class = ST.class_id
   AND TT.Graduation_year = ST.graduation_year

WHEN NOT MATCHED THEN
    INSERT (Student_PESEL, Student_name_surname, ID_Class, Graduation_year)
    VALUES (ST.PESEL, ST.student_name_surname, ST.class_id, ST.graduation_year);
GO

DROP VIEW vETLDimStudent;
GO