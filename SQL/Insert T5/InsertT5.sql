drop table if exists MATURA_Staging
DROP TABLE if exists STUDENT_MATURA_RESULT
drop table if exists Student_temp
--drop table if exists STUDENT
drop table if exists MATURA
DROP TABLE if exists TempStudentMaturaResult;



CREATE TABLE MATURA_Staging (
    matura_id INT, 
    subject VARCHAR(50),
    level VARCHAR(10),
    year INT
);

BULK INSERT MATURA_Staging
FROM 'C:\Users\user\Desktop\data warehouses\matura_2022.bulk'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'
);

CREATE TABLE MATURA (
    matura_id INT PRIMARY KEY IDENTITY (1,1),
    subject VARCHAR(50) NOT NULL,
    level VARCHAR(10) CHECK (level IN ('basic', 'extended')) NOT NULL, 
	year INT
);
MERGE INTO MATURA AS Target
USING (
    SELECT DISTINCT subject, level, year
    FROM MATURA_Staging
) AS Source
    ON Target.subject = Source.subject
    AND Target.level = Source.level
    AND Target.year = Source.year

WHEN NOT MATCHED THEN
    INSERT (subject, level, year)
    VALUES (Source.subject, Source.level, Source.year);


CREATE TABLE dbo.Student_temp (
    student_PESEL VARCHAR(11),
    student_name_surname VARCHAR(50),
    class_id INT,
    graduation_year INT,
    isRetaken BIT,
    anulled VARCHAR(20)
);

BULK INSERT dbo.Student_temp
FROM 'C:\Users\user\Desktop\data warehouses\students_2022.bulk'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '\n',
    TABLOCK
);

/*CREATE TABLE STUDENT (
    ID_Student INT IDENTITY(1,1) PRIMARY KEY,
    PESEL VARCHAR(11),
    student_name_surname VARCHAR(50) NOT NULL,
    class_id INT,
    graduation_year INT NOT NULL,
    FOREIGN KEY (class_id) REFERENCES PROFILE_CLASS(class_id)
);*/

INSERT INTO STUDENT (PESEL, student_name_surname, class_id, graduation_year)
SELECT DISTINCT
    st.student_PESEL,
    st.student_name_surname,
    st.class_id,
    st.graduation_year
FROM dbo.Student_temp st
JOIN dbo.PROFILE_CLASS pc ON st.class_id = pc.class_id
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.STUDENT s
    WHERE s.PESEL = st.student_PESEL
);

CREATE TABLE TempStudentMaturaResult (
    student_PESEL VARCHAR(11),
    matura_id INT,
    score DECIMAL(3,2),
    passed VARCHAR(15),
    duration DECIMAL(5,1),
    isRetaken BIT,
    annulled VARCHAR(15)
);



BULK INSERT TempStudentMaturaResult
FROM 'C:\Users\user\Desktop\data warehouses\student_matura_result_2022.bulk'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);


CREATE TABLE STUDENT_MATURA_RESULT (
    ID INT PRIMARY KEY IDENTITY (1,1),
    ID_Student INT,
    matura_id INT,
    score DECIMAL(3,2) CHECK (score >= 0 AND score <= 1),
    passed VARCHAR(15),
    duration DECIMAL(5,1),
    isRetaken BIT,
    annulled VARCHAR(15),
    FOREIGN KEY (ID_Student) REFERENCES STUDENT(ID_Student),
    FOREIGN KEY (matura_id) REFERENCES MATURA(matura_id)
);


INSERT INTO STUDENT_MATURA_RESULT (
    ID_Student, matura_id, score, passed, duration, isRetaken, annulled
)
SELECT 
    s.ID_Student,
    t.matura_id,
    t.score,
    t.passed,
    t.duration,
    t.isRetaken,
    t.annulled
FROM TempStudentMaturaResult t
JOIN STUDENT s ON s.PESEL = t.student_PESEL;

UPDATE STUDENT_MATURA_RESULT
SET duration = 0
WHERE duration IS NULL;

UPDATE STUDENT_MATURA_RESULT
SET score = 0
WHERE score IS NULL;

UPDATE STUDENT_MATURA_RESULT
SET passed = 'NotPassed'
WHERE passed IS NULL;

