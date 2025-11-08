
drop table ExcelFile
CREATE TABLE dbo.ExcelFile (
    student_PESEL VARCHAR(11),
    matura_id INT,
    subject VARCHAR(50),
    level VARCHAR(20),
    [year] VARCHAR(4),
    classroom VARCHAR(20),
    size VARCHAR(5),
    teacher_PESEL CHAR(11),
    subject_teacher VARCHAR(50),
    isRetaken BIT,
    anulled VARCHAR(15)
);
GO

BULK INSERT dbo.ExcelFile
FROM 'C:\Users\user\Desktop\data warehouses\exam_schedule_2023.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO