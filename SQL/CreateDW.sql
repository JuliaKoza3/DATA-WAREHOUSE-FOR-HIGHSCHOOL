CREATE TABLE DimRoom (
ID_Room INTEGER PRIMARY KEY IDENTITY (1,1),
Room_number VARCHAR(20),
Size VARCHAR(5)
);

CREATE TABLE DimProfile_Class(
ID_Class INTEGER PRIMARY KEY IDENTITY (1,1),
Class_name VARCHAR(15),
Description VARCHAR(50)
);


CREATE TABLE DimStudent(
ID_Student INTEGER PRIMARY KEY IDENTITY (1,1),
ID_Class INTEGER,
Student_Pesel CHAR(11),
Student_name_surname VARCHAR(40),
Graduation_year VARCHAR(4),
FOREIGN KEY (ID_Class) REFERENCES DimProfile_Class(ID_Class)
);


CREATE TABLE DimMatura(
ID_Matura INTEGER PRIMARY KEY IDENTITY (1,1),
Subject VARCHAR(20),
Level VARCHAR(10), 
year int
);


CREATE TABLE DimTeacher(
ID_Teacher INTEGER PRIMARY KEY IDENTITY (1,1),
Teacher_Pesel CHAR(11),
Subject VARCHAR(20),
year int,
IsCurrent BIT
);

CREATE TABLE DimDate(
ID_Date INTEGER PRIMARY KEY IDENTITY (1,1),
Year CHAR(4)
);

CREATE TABLE DimJunk(
ID_Junk INTEGER PRIMARY KEY IDENTITY (1,1),
Passed VARCHAR(15),
Annulled VARCHAR(15),
Retake Varchar(15)
);

CREATE TABLE FactWriting_Matura_Exam (
    ID_Date INT,
    ID_Matura INT,
    ID_Student INT,
    ID_Room INT,
    ID_Teacher INT,
	ID_Junk INT,
    Result DECIMAL(3,2) CHECK (Result >= 0 AND Result <= 1),
    Score INT,
    Duration INT,
    IsRetake BIT,

    CONSTRAINT PK_FactWriting_Matura_Exam PRIMARY KEY (
        ID_Date,
        ID_Matura,
        ID_Student,
        ID_Room,
        ID_Teacher,
		ID_Junk
    ),

    FOREIGN KEY (ID_Date) REFERENCES DimDate(ID_Date),
    FOREIGN KEY (ID_Matura) REFERENCES DimMatura(ID_Matura),
    FOREIGN KEY (ID_Student) REFERENCES DimStudent(ID_Student),
    FOREIGN KEY (ID_Room) REFERENCES DimRoom(ID_Room),
    FOREIGN KEY (ID_Teacher) REFERENCES DimTeacher(ID_Teacher),
	FOREIGN KEY (ID_Junk) REFERENCES DimJunk(ID_Junk)
);




