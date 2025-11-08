USE DataWarehouses;
GO

IF OBJECT_ID('vETLFWriting_Matura_Exam') IS NOT NULL 
    DROP VIEW vETLFWriting_Matura_Exam;
GO


CREATE VIEW vETLFWriting_Matura_Exam AS
SELECT DISTINCT
    D.ID_Date, 
    EF.matura_id AS ID_Matura, 
    Ds.ID_Student, 
    R.ID_Room, 
    T.ID_Teacher, 
    J.ID_Junk, 
    MR.score AS Result, 
    CAST(MR.score * 100 AS INT) AS Score, 
    CAST(MR.duration AS INT) AS Duration, 
    MR.isRetaken AS IsRetake
FROM ExcelFile AS EF
JOIN DimDate AS D 
    ON D.Year = EF.year

JOIN DimStudent AS Ds
    ON EF.student_PESEL = Ds.Student_Pesel

JOIN DimRoom AS R 
    ON R.Room_number = EF.classroom 
    AND R.Size = EF.size 

JOIN DimTeacher AS T 
    ON T.Teacher_Pesel = EF.teacher_PESEL 
JOIN STUDENT AS St 
    ON EF.student_PESEL = St.PESEL
JOIN STUDENT_MATURA_RESULT AS MR
    ON MR.ID_Student = St.ID_Student 
    AND MR.matura_id = EF.matura_id
JOIN DimJunk AS J 
    ON J.Passed = MR.passed
   AND J.Annulled = MR.annulled
   AND J.Retake = CASE WHEN MR.isRetaken = 1 THEN 'Retake' ELSE 'NotRetake' END;
GO
-- Merge data from the staging view into the fact table
MERGE INTO FactWriting_Matura_Exam AS TT
USING vETLFWriting_Matura_Exam AS ST
    ON TT.ID_Date = ST.ID_Date
    AND TT.ID_Matura = ST.ID_Matura
    AND TT.ID_Student = ST.ID_Student
    AND TT.ID_Room = ST.ID_Room
    AND TT.ID_Teacher = ST.ID_Teacher
    AND TT.ID_Junk = ST.ID_Junk			
WHEN NOT MATCHED THEN
INSERT (
    ID_Date, 
    ID_Matura, 
    ID_Student, 
    ID_Room, 
    ID_Teacher, 
    ID_Junk, 
    Result, 
    Score, 
    Duration, 
    IsRetake
)
VALUES (
    ST.ID_Date,
    ST.ID_Matura,
    ST.ID_Student,
    ST.ID_Room,
    ST.ID_Teacher,
    ST.ID_Junk, 
    ST.Result, 
    ST.Score, 
    ST.Duration, 
    ST.IsRetake
);
GO



