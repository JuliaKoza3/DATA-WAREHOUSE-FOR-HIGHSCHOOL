INSERT INTO DimRoom (Room_number, Size) VALUES
('101', 'Small'),
('102', 'Big'),
('103', 'Small'),
('104', 'Big'),
('105', 'Big'),
('201', 'Small'),
('202', 'Small'),
('203', 'Small'),
('204', 'Big'),
('205', 'Big');


INSERT INTO DimProfile_Class (Class_name, Description) VALUES 
('medical', 'Extended subjects: Biology, Chemistry'),
('science', 'Extended subjects: Mathematics, Physics'),
('economics', 'Extended subjects: Mathematics, Geography'),
('law', 'Extended subjects: Polish, History'),
('programming', 'Extended subjects: Mathematics, Informatics'),
('biological', 'Extended subjects: Mathematics, Biology'),
('chemical', 'Extended subjects: Mathematics, Chemistry'),
('linguistic', 'Extended subjects: Polish, English');

INSERT INTO DimStudent (ID_Class, Student_Pesel, Student_name_surname, Graduation_year) VALUES
(1, '01234567890', 'John Smith', '2023'),
(2, '11234567891', 'Anna Kowalski', '2023'),
(3, '21234567892', 'Maria Lopez', '2022'),
(4, '31234567893', 'Tom Lee', '2022'),
(5, '41234567894', 'Lucy Liu', '2023'),
(6, '51234567895', 'Ahmed Khan', '2024'),
(7, '61234567896', 'Sara Connor', '2023'),
(8, '71234567897', 'David Kim', '2022'),
(1, '81234567898', 'Emma Brown', '2023'),
(2,'91234567899', 'Liam Johnson', '2024');

INSERT INTO DimMatura (Subject, Level) VALUES
('Mathematics', 'basic'),
('Polish', 'basic'),
('English', 'basic'),
('Physics', 'extended'),
('History', 'extended'),
('Biology', 'extended'),
('Chemistry', 'extended'),
('Geography', 'extended'),
('Mathematics', 'extended'),
('Polish', 'extended'),
('English', 'extended');


INSERT INTO DimTeacher (Teacher_Pesel, Subject) VALUES
('12345678901', 'Math'),
('12345678902', 'Math'),
('12345678903', 'English'),
('12345678904', 'English'),
('12345678905', 'History'),
('12345678906', 'History'),
('12345678907', 'Biology'),
('12345678908', 'Biology'),
('12345678909', 'Geography'),
('12345678910', 'Geography');

INSERT INTO DimDate (Year) VALUES
('2018'),
('2019'),
('2020'),
('2021'),
('2022'),
('2023'),
('2024');

INSERT INTO DimJunk (Passed, Annulled, Retake) VALUES
('Passed', 'Not annulled', 'Not retaken'),
('Passed', 'Not annulled', 'Retaken'),
('Not passed', 'Annulled', 'Not retaken'),
('Not passed', 'Not annulled', 'Retaken'),
('Passed', 'Not annulled', 'Not retaken'),
('Passed', 'Not annulled', 'Not retaken'),
('Not passed', 'Annulled', 'Not retaken'),
('Passed', 'Not annulled', 'Retaken'),
('Not passed', 'Not annulled', 'Not retaken'),
('Passed', 'Not annulled', 'Not retaken');

INSERT INTO FactWriting_Matura_Exam (
    ID_Date, ID_Matura, ID_Student, ID_Room, ID_Teacher,
    Result, Score, Duration, IsRetake
) VALUES
(1, 1, 1, 1, 1, 0.78, 78, 90, 0),
(2, 2, 2, 2, 2, 0.84, 84, 85, 1),
(3, 3, 3, 3, 3, 0.42, 42, 75, 0),
(4, 4, 4, 4, 4, 0.55, 55, 95, 1),
(5, 5, 5, 5, 5, 0.91, 91, 88, 0),
(6, 6, 6, 6, 6, 0.88, 88, 92, 0),
(7, 7, 7, 7, 7, 0.39, 39, 80, 0),
(1, 8, 8, 8, 8, 0.75, 75, 89, 1),
(2, 9, 9, 9, 9, 0.60, 60, 87, 0),
(3, 10, 10, 10, 10, 0.82, 82, 93, 0);