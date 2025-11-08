SELECT *
FROM DimTeacher
WHERE Teacher_Pesel IN (
    SELECT Teacher_Pesel
    FROM DimTeacher
    GROUP BY Teacher_Pesel
    HAVING COUNT(*) > 1
)
ORDER BY Teacher_Pesel;