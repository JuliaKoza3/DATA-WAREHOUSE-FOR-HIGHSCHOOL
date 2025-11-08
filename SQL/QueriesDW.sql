--Examine the trends in the number of students by the chosen level of matura exams across the last 4 years.

SELECT 
    d.Year,
    COUNT(DISTINCT f.ID_Student) AS Extended_Level_Student_Count
FROM FactWriting_Matura_Exam f
INNER JOIN DimDate d ON f.ID_Date = d.ID_Date
INNER JOIN DimMatura m ON f.ID_Matura = m.ID_Matura
WHERE 
    LOWER(m.Level) = 'extended' AND
    d.Year IN (
        SELECT TOP 4 Year
        FROM DimDate
        ORDER BY CAST(Year AS INT) DESC
    )
GROUP BY d.Year
ORDER BY CAST(d.Year AS INT) DESC;



SELECT 
    d.Year AS Exam_Year,
    m.Level AS Exam_Level,
    COUNT(DISTINCT f.ID_Student) AS Number_of_Students
FROM 
    FactWriting_Matura_Exam f
JOIN 
    DimMatura m ON f.ID_Matura = m.ID_Matura
JOIN 
    DimDate d ON f.ID_Date = d.ID_Date
WHERE 
    CAST(d.Year AS INT) >= YEAR(GETDATE()) - 4  -- last 4 years
GROUP BY 
    d.Year,
    m.Level
ORDER BY 
    d.Year,
    m.Level;


--Compare the results of students retaking the matura exam last year with the previous 3 years.

SELECT 
    d.Year,
    AVG(f.Score) AS Avg_Score,
    COUNT(*) AS Retake_Count
FROM FactWriting_Matura_Exam f
JOIN DimDate d ON f.ID_Date = d.ID_Date
WHERE 
    f.IsRetake = 1 AND
    CAST(d.Year AS INT) BETWEEN 2018 AND 2024
GROUP BY d.Year
ORDER BY CAST(d.Year AS INT) DESC;




SELECT 
    d.Year AS Exam_Year,
    COUNT(*) AS Retake_Count,
    AVG(f.Result) AS Average_Result,
    AVG(f.Score) AS Average_Score
FROM 
    FactWriting_Matura_Exam f
JOIN 
    DimDate d ON f.ID_Date = d.ID_Date
GROUP BY 
    d.Year
ORDER BY 
    d.Year;

--Compare the average results of the students who wrote exams in smaller classrooms (up to 15 people) ang big classrooms (16-40 people) in the last year.
SELECT 
    r.Size AS Room_Size,
    AVG(f.Score) AS Avg_Score,
    COUNT(*) AS Exam_Count
FROM FactWriting_Matura_Exam f
JOIN DimRoom r ON f.ID_Room = r.ID_Room
JOIN DimDate d ON f.ID_Date = d.ID_Date
WHERE CAST(d.Year AS INT) = (
    SELECT MAX(CAST(Year AS INT)) FROM DimDate
)
GROUP BY r.Size;

--Compare the results from the matura exam from last year to the previous 3 years.
SELECT 
    d.Year,
    AVG(f.Score) AS Avg_Score,
    COUNT(*) AS Exam_Count
FROM FactWriting_Matura_Exam f
JOIN DimDate d ON f.ID_Date = d.ID_Date
WHERE CAST(d.Year AS INT) IN (2024, 2023, 2022, 2021)
GROUP BY d.Year
ORDER BY d.Year DESC;

--Compare the results from extended math matura exams from students who were in a particular profiled class vs those who took the extended exam from the subject that was not extended in their class in the last 4 years. 

WITH SubjectType AS (
    SELECT 
        d.Year,
        m.Subject,
        CASE 
            WHEN m.Level = 'extended' AND (
                (pc.Class_name IN ('medical', 'science', 'biological', 'chemical', 'programming') AND m.Subject IN ('Biology', 'Chemistry', 'Mathematics', 'Physics', 'Geography')) OR
                (pc.Class_name IN ('law', 'linguistic') AND m.Subject IN ('History', 'Polish', 'English'))
            ) THEN 'Class Profiled Subject'
            ELSE 'Non-Class Subject'
        END AS Subject_Type,
        f.Score
    FROM FactWriting_Matura_Exam f
    JOIN DimDate d ON f.ID_Date = d.ID_Date
    JOIN DimMatura m ON f.ID_Matura = m.ID_Matura
    JOIN DimStudent s ON f.ID_Student = s.ID_Student
    JOIN DimProfile_Class pc ON s.ID_Class = pc.ID_Class
    WHERE CAST(d.Year AS INT) IN (
        SELECT TOP 4 CAST(Year AS INT)
        FROM DimDate
        ORDER BY CAST(Year AS INT) DESC
    )
    AND m.Level = 'extended'
)

SELECT 
    Subject,
    -- Average result for students who had the subject extended as part of their class profile
    AVG(CASE WHEN Subject_Type = 'Class Profiled Subject' THEN Score END) AS Avg_Score_Class_Extension,
    -- Average result for students who did not have the subject extended as part of their class profile
    AVG(CASE WHEN Subject_Type = 'Non-Class Subject' THEN Score END) AS Avg_Score_Non_Class_Extension
FROM SubjectType
GROUP BY Subject
ORDER BY Subject;

--In how many small classes the matura exams were held last year compared to the previous 3 years?
SELECT 
    d.Year,
    COUNT(DISTINCT f.ID_Room) AS Small_Class_Count
FROM FactWriting_Matura_Exam f
JOIN DimDate d ON f.ID_Date = d.ID_Date
JOIN DimRoom r ON f.ID_Room = r.ID_Room
WHERE r.Size = 'Small' 
AND CAST(d.Year AS INT) IN (
    SELECT TOP 4 CAST(Year AS INT)
    FROM DimDate
    ORDER BY CAST(Year AS INT) DESC
)
GROUP BY d.Year
ORDER BY d.Year DESC;


-- How many people were writing other than extended math, extended maturas last year?

SELECT 
    COUNT(DISTINCT f.ID_Student) AS Student_Count
FROM FactWriting_Matura_Exam f
JOIN DimDate d ON f.ID_Date = d.ID_Date
JOIN DimMatura m ON f.ID_Matura = m.ID_Matura
WHERE CAST(d.Year AS INT) = (
    SELECT TOP 1 CAST(Year AS INT)
    FROM DimDate
    ORDER BY CAST(Year AS INT) DESC
)
AND m.Level = 'extended'
AND m.Subject != 'Mathematics' 


SELECT COUNT(DISTINCT f.ID_Student) AS NumberOfStudents
FROM FactWriting_Matura_Exam f
JOIN DimMatura m ON f.ID_Matura = m.ID_Matura
JOIN DimDate d ON f.ID_Date = d.ID_Date
WHERE d.Year = '2019'
  AND NOT (
        (m.Subject = 'Math' AND m.Level = 'Extended')
        OR m.Level = 'Extended'  -- Exclude all extended maturas
      )

SELECT COUNT(DISTINCT f.ID_Student) AS NumberOfStudents
FROM FactWriting_Matura_Exam f
JOIN DimMatura m ON f.ID_Matura = m.ID_Matura
JOIN DimDate d ON f.ID_Date = d.ID_Date
WHERE f.Duration > 0
  AND NOT (m.Subject = 'Mathematics' AND m.Level = 'extended')
  AND d.Year = '2019';


SELECT * 
FROM FactWriting_Matura_Exam f 
JOIN DimMatura m ON f.ID_Matura = m.ID_Matura
JOIN DimDate d ON f.ID_Date = d.ID_Date
WHERE d.Year = '2019' AND IsRetake = 1

SELECT *
FROM FactWriting_Matura_Exam f 





SELECT 
    pc.Class_name AS Class_Name,
    COUNT(DISTINCT f.ID_Student) AS Student_Count
FROM FactWriting_Matura_Exam f
JOIN DimDate d ON f.ID_Date = d.ID_Date
JOIN DimMatura m ON f.ID_Matura = m.ID_Matura
JOIN DimStudent s ON f.ID_Student = s.ID_Student
JOIN DimProfile_Class pc ON s.ID_Class = pc.ID_Class
WHERE CAST(d.Year AS INT) = (
    SELECT TOP 1 CAST(Year AS INT)
    FROM DimDate
    ORDER BY CAST(Year AS INT) DESC
)
AND m.Level = 'extended'
AND m.Subject = 'Mathematics'
AND pc.Class_name IN ('medical', 'science', 'biological', 'chemical', 'programming') -- Adjust this based on your classes
GROUP BY pc.Class_name
ORDER BY pc.Class_name;


SELECT 
    CAST(d.Year AS INT) AS Year,
    COUNT(DISTINCT f.ID_Student) AS Retake_Student_Count
FROM FactWriting_Matura_Exam f
JOIN DimDate d ON f.ID_Date = d.ID_Date
JOIN DimMatura m ON f.ID_Matura = m.ID_Matura
JOIN DimStudent s ON f.ID_Student = s.ID_Student
WHERE m.Level = 'extended'
AND m.Subject = 'Mathematics'
AND f.IsRetake = 1
AND CAST(d.Year AS INT) IN (
    SELECT TOP 2 CAST(Year AS INT)
    FROM DimDate
    ORDER BY CAST(Year AS INT) DESC
)
GROUP BY CAST(d.Year AS INT)
ORDER BY CAST(d.Year AS INT) DESC;

WITH PresentStudents AS (
    SELECT DISTINCT f.ID_Student
    FROM FactWriting_Matura_Exam f
    JOIN DimDate d ON f.ID_Date = d.ID_Date
    WHERE CAST(d.Year AS INT) = (
        SELECT TOP 1 CAST(Year AS INT)
        FROM DimDate
        ORDER BY CAST(Year AS INT) DESC
    )
    AND f.Duration is NULL -- Include only students who have a non-zero duration
)
SELECT 
    -- Subtract the number of present students from the total number of students who were supposed to take the exam
    (SELECT COUNT(DISTINCT f.ID_Student)
     FROM FactWriting_Matura_Exam f
     JOIN DimDate d ON f.ID_Date = d.ID_Date
     WHERE CAST(d.Year AS INT) = (
        SELECT TOP 1 CAST(Year AS INT)
        FROM DimDate
        ORDER BY CAST(Year AS INT) DESC
     )
    )
    - (SELECT COUNT(*) FROM PresentStudents) AS Absent_Student_Count;

SELECT 
    r.Room_number,
    COUNT(DISTINCT r.Room_number) AS Number_of_Classrooms
FROM FactWriting_Matura_Exam f
JOIN DimRoom r ON f.ID_Room = r.ID_Room
JOIN DimDate d ON f.ID_Date = d.ID_Date
JOIN DimJunk j ON f.ID_Junk = j.ID_Junk
WHERE 
    j.Annulled = 'Annulled' 
    AND CAST(d.Year AS INT) = 2023 
GROUP BY r.Room_number
ORDER BY r.Room_number;




SELECT COUNT(DISTINCT ID_Student)
FROM FactWriting_Matura_Exam
WHERE Duration = 0;


SELECT * 
FROM STUDENT_MATURA_RESULT
WHERE annulled = 'Anulled'

SELECT * 
FROM FactWriting_Matura_Exam f
JOIN STUDENT s ON f.ID_Student = s.ID_Student
WHERE ID_Matura = 8 and class_id = 8



SELECT COUNT(*)
FROM FactWriting_Matura_Exam f
JOIN DimMatura m ON f.ID_Matura = m.ID_Matura
WHERE Subject = 'Mathematics' and Level = 'basic'
GROUP BY ID_Date




SELECT *
FROM STUDENT_MATURA_RESULT s
LEFT JOIN MATURA m ON s.matura_id = m.matura_id
WHERE subject = 'Mathematics' AND level = 'basic'

SELECT COUNT(*)
FROM FactWriting_Matura_Exam


