--Drop Database Advising_Team_13
CREATE DATABASE Advising_Team_13
GO---------------********************************
USE Advising_Team_13
GO

--N) 2.3
CREATE PROC Procedure_AdminUpdateStudentStatus @StudentID INT
AS
IF @StudentID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
DECLARE @financial_status BIT ;
				SET @financial_status = CASE WHEN Exists (Select * 
												  from (SELECT CASE WHEN CURRENT_TIMESTAMP > i.deadline AND i.status = 'notPaid'  THEN 0 ELSE 1 END as paid
														from Installment i INNER JOIN Payment p on (p.payment_id = i.payment_id 
															AND p.student_id = @StudentID)) as paids 
											      WHERE paids.paid = 0) Then 0 ELSE 1 END
		UPDATE Student
		SET Student.financial_status = @financial_status
		WHERE student_id = @StudentID
END
GO

------------------------------------------2.1----------------------------------------------------
--2)
CREATE PROCEDURE CreateAllTables AS
	CREATE TABLE Course (
	course_id             INT IDENTITY PRIMARY KEY,
	name                  VARCHAR(40),
	major                 VARCHAR(40),
	is_offered            BIT,
	credit_hours          INT,
	semester              INT
	);

	CREATE TABLE Instructor (
	instructor_id        INT IDENTITY PRIMARY KEY,
	name                 VARCHAR(40) ,
	email                VARCHAR(40) UNIQUE,
	faculty              VARCHAR(40),
	office               VARCHAR(40),
	Check(email LIKE '%@%.%') ------------------------------additional constraint e7teyatiiiiii-------
	) ;

	CREATE TABLE Semester (
	semester_code       VARCHAR(40) PRIMARY KEY ,
	start_date          DATE , 
	end_date            DATE
	);

	CREATE TABLE Advisor (
	advisor_id        INT IDENTITY PRIMARY KEY, 
	name              VARCHAR(40),
	email             VARCHAR(40) UNIQUE, 
	office            VARCHAR(40), 
	password          VARCHAR(40),
	Check(email LIKE '%@%.%') ------------------------------additional constraint e7teyatiiiiii-------
	);



	CREATE TABLE Student (
	student_id            INT IDENTITY PRIMARY KEY ,
	f_name                VARCHAR (40) ,
	l_name                VARCHAR (40) , 
	gpa	                  DECIMAL (3,2) , 
	faculty               VARCHAR (40), 
	email                 VARCHAR (40) UNIQUE, 
	major                 VARCHAR (40),
	password              VARCHAR (40), 
	financial_status      BIT  ,		
	semester              INT, 
	acquired_hours        INT, 
	assigned_hours        INT DEFAULT NULL, 
	advisor_id            INT ,
	CONSTRAINT FK_advisor1 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id), --ON DELETE SET NULL
	Check(email LIKE '%@%.%'), ------------------------------additional constraint e7teyatiiiiii-------
	Check (gpa between 0.7 AND 5.0)
	);
	
	CREATE TABLE Student_Phone (
	student_id            INT  ,
	phone_number          VARCHAR(40) ,
	CONSTRAINT PK_Student_Phone PRIMARY KEY (student_id, phone_number),
    CONSTRAINT FK_student1 FOREIGN KEY (student_id) REFERENCES Student (student_id) --ON DELETE CASCADE -- do not truncate
   	);



	CREATE TABLE PreqCourse_course (
	prerequisite_course_id  INT ,
	course_id               INT NOT NULL ,
	CONSTRAINT PK_PreqCourse_course PRIMARY KEY (prerequisite_course_id, course_id),
	CONSTRAINT FK_PreqCourse_course FOREIGN KEY (prerequisite_course_id ) REFERENCES Course (course_id ), --ON DELETE CASCADE ,
	CONSTRAINT FK_PreqCourse_course2 FOREIGN KEY (course_id ) REFERENCES Course (course_id)  --ON DELETE CASCADE
	);

	CREATE TABLE Instructor_Course ( 
	course_id            INT ,
	instructor_id        INT ,
	CONSTRAINT PK_Instructor_Course PRIMARY KEY (course_id, instructor_id),
	CONSTRAINT FK_course1 FOREIGN KEY (course_id) REFERENCES Course (course_id), --ON DELETE CASCADE,
	CONSTRAINT FK_instructor1 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id)-- ON DELETE CASCADE
	);

	CREATE TABLE Student_Instructor_Course_Take (
	student_id          INT ,
	course_id           INT ,
	instructor_id       INT , 
    semester_code       VARCHAR(40),
	exam_type           VARCHAR(40) DEFAULT 'Normal',
	grade               VARCHAR(40) ,
	CONSTRAINT PK_Student_Instructor_Course_Take PRIMARY KEY (student_id, course_id , semester_code),-- deleted instuctor id
	CONSTRAINT FK_student2 FOREIGN KEY (student_id) REFERENCES Student (student_id), -- ON DELETE CASCADE,
	CONSTRAINT FK_course2 FOREIGN KEY (course_id) REFERENCES Course (course_id) , --ON DELETE CASCADE,
	CONSTRAINT FK_instructor2 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id),--  ON DELETE CASCADE,
	CONSTRAINT FK_semester1 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) ,--ON DELETE CASCADE
	); 

	CREATE TABLE Course_Semester (
	course_id          INT ,
	semester_code      VARCHAR(40) ,
	CONSTRAINT PK_Course_Semester PRIMARY KEY (course_id, semester_code),
	CONSTRAINT FK_course3 FOREIGN KEY (course_id) REFERENCES Course (course_id),-- ON DELETE CASCADE,
	CONSTRAINT FK_semester2 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code)-- ON DELETE CASCADE,
	);

	CREATE TABLE Slot (
	slot_id           INT IDENTITY PRIMARY KEY,
	day               VARCHAR(40), 
	time              VARCHAR(40), 
	location          VARCHAR(40), 
	course_id         INT , 
	instructor_id     INT,
	CONSTRAINT FK_course4 FOREIGN KEY (course_id) REFERENCES Course (course_id), --ON DELETE SET NULL,
	CONSTRAINT FK_instructor3 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) --ON DELETE SET NULL
	);

	CREATE TABLE Graduation_Plan (
	  plan_id                INT IDENTITY , 
	  semester_code          VARCHAR(40), 
	  semester_credit_hours  INT, 
	  expected_grad_date	 DATE, 
	  advisor_id             INT, 
	  student_id             INT,
	  CONSTRAINT PK_Graduation_Plan PRIMARY KEY (plan_id, semester_code),
	  CONSTRAINT FK_advisor2 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) ,--ON DELETE SET NULL,
	  CONSTRAINT FK_student3 FOREIGN KEY (student_id) REFERENCES Student (student_id) --ON DELETE CASCADE
	);														   

	CREATE TABLE GradPlan_Course (
	  plan_id                INT, -- Can i make it identity
	  semester_code          VARCHAR(40), 
	  course_id              INT,
	  CONSTRAINT PK_GradPlan_Course PRIMARY KEY (plan_id, semester_code, course_id),
	  CONSTRAINT FK_planSem FOREIGN KEY (plan_id, semester_code) REFERENCES Graduation_Plan (plan_id, semester_code) , --ON DELETE CASCADE,
	  CONSTRAINT FK_semester3 FOREIGN KEY (semester_code)  REFERENCES Semester (semester_code) ,-- ON DELETE CASCADE, -- OR SET NULL???
	  CONSTRAINT FK_course5 FOREIGN KEY (course_id)  REFERENCES Course (course_id),-- ON DELETE CASCADE  -- not FK in schema !!
	);
	/*is type not null since a request is either course or credit hours*/
	CREATE TABLE Request (
	request_id             INT IDENTITY PRIMARY KEY, 
	type                   VARCHAR(40) ,
	comment                VARCHAR(40), 
	status                 VARCHAR(40) DEFAULT 'pending', 
	credit_hours           INT , 
	student_id             INT , 
	advisor_id             INT, 
	course_id              INT ,
	CONSTRAINT FK_student4 FOREIGN KEY (student_id) REFERENCES Student (student_id) ,-- ON DELETE CASCADE , -- ????
	CONSTRAINT FK_advisor3 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) ,--ON DELETE SET NULL, --??
	CONSTRAINT FK_course6 FOREIGN KEY (course_id) REFERENCES Course (course_id) ON DELETE SET NULL
	);

	CREATE TABLE MakeUp_Exam (
	exam_id        INT IDENTITY PRIMARY KEY, 
	date           DATE, 
	type           VARCHAR(40), 
	course_id      INT ,
	CONSTRAINT FK_course7 FOREIGN KEY (course_id) REFERENCES Course (course_id) ON DELETE SET NULL,
	);

	CREATE TABLE Exam_Student (
	exam_id         INT , 
	student_id      INT , 
	course_id       INT ,
	CONSTRAINT PK_Exam_Student PRIMARY KEY (exam_id ,student_id ,course_id ),
	CONSTRAINT FK_student5 FOREIGN KEY (student_id) REFERENCES Student (student_id) ,--  ON DELETE CASCADE, 
	CONSTRAINT FK_exam FOREIGN KEY (exam_id) REFERENCES MakeUp_Exam (exam_id),--  ON DELETE CASCADE,
	CONSTRAINT FK_course8 FOREIGN KEY (course_id) REFERENCES Course (course_id)-- ON DELETE CASCADE
	);

	CREATE TABLE Payment(
	payment_id      INT IDENTITY PRIMARY KEY, 
	amount          INT , 
	start_date       DATE,
	deadline        DATE,
	n_installments  INT DEFAULT 0,
	status          VARCHAR(40) DEFAULT 'notPaid',
	fund_percentage DECIMAL(5,2), 
	student_id      INT, 
	semester_code   VARCHAR(40), 
	CONSTRAINT FK_student6 FOREIGN KEY (student_id) REFERENCES Student (student_id) ,-- ON DELETE SET NULL,
	CONSTRAINT FK_semester4 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) --ON DELETE SET NULL,
	);

	CREATE TABLE Installment (
	payment_id     INT , 
	deadline       DATE, 
	amount         INT, 
	status         VARCHAR(40),
	start_date     DATE ,
	CONSTRAINT PK_Installment PRIMARY KEY (payment_id, deadline),
	CONSTRAINT FK_Payment FOREIGN KEY (payment_id) REFERENCES Payment (payment_id),
	);
GO
EXEC CreateAllTables;

INSERT INTO Course(name, major, is_offered, credit_hours, semester)  VALUES
( 'Mathematics 2', 'Science', 1, 3, 2),
( 'CSEN 2', 'Engineering', 1, 4, 2),
( 'Database 1', 'MET', 1, 3, 5),
( 'Physics', 'Science', 0, 4, 1),
( 'CSEN 4', 'Engineering', 1, 3, 4),
( 'Chemistry', 'Engineering', 1, 4, 1),
( 'CSEN 3', 'Engineering', 1, 3, 3),
( 'Computer Architecture', 'MET', 0, 3, 6),
( 'Computer Organization', 'Engineering', 1, 4, 4),
( 'Database2', 'MET', 1, 3, 6);


-- Adding 10 records to the Instructor table
INSERT INTO Instructor(name, email, faculty, office) VALUES
( 'Professor Smith', 'prof.smith@example.com', 'MET', 'Office A'),
( 'Professor Johnson', 'prof.johnson@example.com', 'MET', 'Office B'),
( 'Professor Brown', 'prof.brown@example.com', 'MET', 'Office C'),
( 'Professor White', 'prof.white@example.com', 'MET', 'Office D'),
( 'Professor Taylor', 'prof.taylor@example.com', 'Mechatronics', 'Office E'),
( 'Professor Black', 'prof.black@example.com', 'Mechatronics', 'Office F'),
( 'Professor Lee', 'prof.lee@example.com', 'Mechatronics', 'Office G'),
( 'Professor Miller', 'prof.miller@example.com', 'Mechatronics', 'Office H'),
( 'Professor Davis', 'prof.davis@example.com', 'IET', 'Office I'),
( 'Professor Moore', 'prof.moore@example.com', 'IET', 'Office J');

-- Adding 10 records to the Semester table
INSERT INTO Semester(semester_code, start_date, end_date) VALUES
('W23', '2023-10-01', '2024-01-31'),
('S23', '2023-03-01', '2023-06-30'),
('S23R1', '2023-07-01', '2023-07-31'),
('S23R2', '2023-08-01', '2023-08-31'),
('W24', '2024-10-01', '2025-01-31'),
('S24', '2024-03-01', '2024-06-30'),
('S24R1', '2024-07-01', '2024-07-31'),
('S24R2', '2024-08-01', '2024-08-31')

-- Adding 10 records to the Advisor table
INSERT INTO Advisor(name, email, office, password) VALUES
( 'Dr. Anderson', 'anderson@example.com', 'Office A', 'password1'),
( 'Prof. Baker', 'baker@example.com', 'Office B', 'password2'),
( 'Dr. Carter', 'carter@example.com', 'Office C', 'password3'),
( 'Prof. Davis', 'davis@example.com', 'Office D', 'password4'),
( 'Dr. Evans', 'evans@example.com', 'Office E', 'password5'),
( 'Prof. Foster', 'foster@example.com', 'Office F', 'password6'),
( 'Dr. Green', 'green@example.com', 'Office G', 'password7'),
( 'Prof. Harris', 'harris@example.com', 'Office H', 'password8'),
( 'Dr. Irving', 'irving@example.com', 'Office I', 'password9'),
( 'Prof. Johnson', 'johnson@example.com', 'Office J', 'password10');

-- Adding 10 records to the Student table
INSERT INTO Student (f_name, l_name, GPA, faculty, email, major, password, financial_status, semester, acquired_hours, assigned_hours, advisor_id)   VALUES 
( 'John', 'Doe', 3.5, 'Engineering', 'john.doe@example.com', 'CS', 'password123', 1, 1, 90, 30, 1),
( 'Jane', 'Smith', 3.8, 'Engineering', 'jane.smith@example.com', 'CS', 'password456', 1, 2, 85, 34, 2),
( 'Mike', 'Johnson', 3.2, 'Engineering', 'mike.johnson@example.com', 'CS', 'password789', 1, 3, 75, 34, 3),
( 'Emily', 'White', 3.9, 'Engineering', 'emily.white@example.com', 'CS', 'passwordabc', 0, 4, 95, 34, 4),
( 'David', 'Lee', 3.4, 'Engineering', 'david.lee@example.com', 'IET', 'passworddef', 1, 5, 80, 34, 5),
( 'Grace', 'Brown', 3.7, 'Engineering', 'grace.brown@example.com', 'IET', 'passwordghi', 0, 6, 88, 34, 6),
( 'Robert', 'Miller', 3.1, 'Engineerings', 'robert.miller@example.com', 'IET', 'passwordjkl', 1, 7, 78, 34, 7),
( 'Sophie', 'Clark', 3.6, 'Engineering', 'sophie.clark@example.com', 'Mechatronics', 'passwordmno', 1, 8, 92, 34, 8),
( 'Daniel', 'Wilson', 3.3, 'Engineering', 'daniel.wilson@example.com', 'DMET', 'passwordpqr', 1, 9, 87, 34, 9),
( 'Olivia', 'Anderson', 3.7, 'Engineeringe', 'olivia.anderson@example.com', 'Mechatronics', 'passwordstu', 0, 10, 89, 34, 10);
INSERT INTO Student (f_name, l_name, GPA, faculty, email, major, password, financial_status, semester, acquired_hours, assigned_hours, advisor_id)   VALUES 
('mahmoud', 'dahroug', 0.7,'Engineering', 'mahmoiuod.dahroug@example.com', 'CS', 'password123', 1, 1, 1325, 30, 1)

-- Adding 10 records to the Student_Phone table
INSERT INTO Student_Phone(student_id, phone_number) VALUES
(4, '456-789-0123'),
(5, '567-890-1234'),
(6, '678-901-2345'),
(7, '789-012-3456'),
(8, '890-123-4567'),
(9, '901-234-5678'),
(10, '012-345-6789');


-- Adding 10 records to the PreqCourse_course table
INSERT INTO PreqCourse_course(prerequisite_course_id, course_id) VALUES
(2, 7),
(3, 10),
(2, 4),
(5, 6),
(4, 7),
(6, 8),
(7, 9),
(9, 10),
(9, 1),
(10, 3);


-- Adding 10 records to the Instructor_Course table
INSERT INTO Instructor_Course (instructor_id, course_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);


-- Adding 10 records to the Student_Instructor_Course_Take table
INSERT INTO Student_Instructor_Course_Take (student_id, course_id, instructor_id, semester_code,exam_type, grade) VALUES
(1, 1, 1, 'W23', 'Normal', 'A'),
(2, 2, 2, 'S23', 'First_makeup', 'B'),
(3, 3, 3, 'S23R1', 'Second_makeup', 'C'),
(4, 4, 4, 'S23R2', 'Normal', 'B+'),
(5, 5, 5, 'W23', 'Normal', 'A-'),
(6, 6, 6, 'W24', 'First_makeup', 'B'),
(7, 7, 7, 'S24', 'Second_makeup', 'C+'),
(8, 8, 8, 'S24R1', 'Normal', 'A+'),
(9, 9, 9, 'S24R2', 'Normal', 'FF'),
(10, 10, 10, 'S24', 'First_makeup', 'B-');



-- Adding 10 records to the Course_Semester table
INSERT INTO Course_Semester (course_id, semester_code) VALUES
(1, 'W23'),
(2, 'S23'),
(3, 'S23R1'),
(4, 'S23R2'),
(5, 'W23'),
(6, 'W24'),
(7, 'S24'),
(8, 'S24R1'),
(9, 'S24R2'),
(10, 'S24');

-- Adding 10 records to the Slot table
INSERT INTO Slot (day, time, location, course_id, instructor_id) VALUES
( 'Monday', 'First', 'Room A', 1, 1),
( 'Tuesday', 'First', 'Room B', 2, 2),
( 'Wednesday', 'Third', 'Room C', 3, 3),
( 'Thursday', 'Fifth', 'Room D', 4, 4),
( 'Saturday', 'Second', 'Room E', 5, 5),
( 'Monday', 'Fourth', 'Room F', 6, 6),
( 'Tuesday', 'Second', 'Room G', 7, 7),
( 'Wednesday', 'Fifth', 'Room H', 8, 8),
( 'Thursday', 'First', 'Room I', 9, 9),
( 'Sunday', 'Fourth', 'Room J', 10, 10);


-- Adding 10 records to the Graduation_Plan table
INSERT INTO Graduation_Plan (semester_code, semester_credit_hours, expected_grad_date, student_id, advisor_id) VALUES
( 'W23', 90,    '2024-01-31' ,   1, 1),
( 'S23', 85,    '2025-01-31'  ,     2, 2),
( 'S23R1', 75,  '2025-06-30' ,  3, 3),
( 'S23R2', 95,  '2024-06-30' , 4, 4),
( 'W23', 80,    '2026-01-31'   ,  5, 5),
( 'W24', 88,    '2024-06-30'   ,    6, 6),
( 'S24', 78,    '2024-06-30'    ,  7, 7),
( 'S24R1', 92,  '2025-01-31'  , 8, 8),
( 'S24R2', 87,  '2024-06-30'    ,  9, 9),
( 'S24', 89,    '2025-01-31'    ,    10, 10);

-- Adding 10 records to the GradPlan_Course table
INSERT INTO GradPlan_Course(plan_id, semester_code, course_id) VALUES
(1, 'W23', 1),
(2, 'S23', 2),
(3, 'S23R1', 3),
(4, 'S23R2', 4),
(5, 'W23', 5),
(6, 'W24', 6),
(7, 'S24', 7),
(8, 'S24R1', 8),
(9, 'S24R2', 9),
(10, 'S24', 10);

-- Adding 10 records to the Request table
INSERT INTO Request (type, comment, status, credit_hours, course_id, student_id, advisor_id) VALUES 
( 'course', 'Request for additional course', 'pending', null, 1, 1, 2),
( 'course', 'Need to change course', 'approved', null, 2, 2, 2),
( 'credit_hours', 'Request for extra credit hours', 'pending', 3, null, 3, 3),
( 'credit_hours', 'Request for reduced credit hours', 'approved', 1, null, 4, 5),
( 'course', 'Request for special course', 'rejected', null, 5, 5, 5),
( 'credit_hours', 'Request for extra credit hours', 'pending', 4, null, 6, 7),
( 'course', 'Request for course withdrawal', 'approved', null, 7, 7, 7),
( 'course', 'Request for course addition', 'rejected', null, 8, 8, 8),
( 'credit_hours', 'Request for reduced credit hours', 'approved', 2, null, 9, 8),
( 'course', 'Request for course substitution', 'pending', null, 10, 10, 10);

-- Adding 10 records to the MakeUp_Exam table
INSERT INTO MakeUp_Exam (date, type, course_id) VALUES
('2023-02-10', 'First MakeUp', 1),
('2023-02-15', 'First MakeUp', 2),
('2023-02-05', 'First MakeUp', 3),
('2023-02-25', 'First MakeUp', 4),
('2023-02-05', 'First MakeUp', 5),
('2024-09-10', 'Second MakeUp', 6),
('2024-09-20', 'Second MakeUp', 7),
('2024-09-05', 'Second MakeUp', 8),
('2024-09-10', 'Second MakeUp', 9),
( '2024-09-15', 'Second MakeUp', 10);

-- Adding 10 records to the Exam_Student table
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (1, 1, 1);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (1, 2, 2);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (1, 3, 3);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (2, 2, 4);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (2, 3, 5);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (2, 4, 6);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (3, 3, 7);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (3, 4, 8);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (3, 5, 9);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (4, 4, 10);

-- Adding 10 records to the Payment table
INSERT INTO Payment (amount, start_date,n_installments, status, fund_percentage, student_id, semester_code, deadline)  VALUES
( 500, '2023-11-22', 1, 'notPaid', 50.00, 1, 'W23', '2023-12-22'),
( 700, '2023-11-23', 1, 'notPaid', 60.00, 2, 'S23', '2023-12-23'),
( 600, '2023-11-24', 4, 'notPaid', 40.00, 3, 'S23R1', '2024-03-24'),
( 800, '2023-11-25', 1, 'notPaid', 70.00, 4, 'S23R2', '2023-12-25'),
( 550, '2023-11-26', 5, 'notPaid', 45.00, 5, 'W23', '2024-04-26'),
( 900, '2023-11-27', 1, 'notPaid', 80.00, 6, 'W24', '2023-12-27'),
( 750, '2023-10-28', 2, 'Paid', 65.00, 7, 'S24', '2023-12-28'),
( 620, '2023-08-29', 4, 'Paid', 55.00, 8, 'S24R1', '2023-12-29'),
( 720, '2023-11-30', 2, 'notPaid', 75.00, 9, 'S24R2', '2024-01-30'),
( 580, '2023-11-30', 1, 'Paid', 47.00, 10, 'S24', '2023-12-31');



-- Adding 10 records to the Installment table
--INSERT INTO Installment (payment_id, start_date, amount, status, deadline) VALUES
--(1, '2023-11-22', 50, 'notPaid','2023-12-22'),
--(2, '2023-11-23', 70, 'notPaid','2023-12-23'),
--(3, '2023-12-24', 60, 'notPaid','2024-01-24'),
--( 4,'2023-11-25', 80, 'notPaid','2023-12-25'),
--(5, '2024-2-26', 55, 'notPaid','2024-3-26'),
--( 6,'2023-11-27', 90, 'notPaid','2023-12-06'),
--(7, '2023-10-28', 75, 'Paid','2023-11-28'),
--( 7,'2023-11-28', 62, 'Paid','2023-12-28'),
--( 9,'2023-12-30', 72, 'notPaid','2024-01-30'),
--( 10,'2023-11-30', 58, 'Paid','2023-12-30');
--Truncate table Installment

GO
--3)
CREATE PROCEDURE  DropAllTables AS
	DROP TABLE Installment;
	DROP TABLE Payment;
	DROP TABLE Exam_Student;
	DROP TABLE MakeUp_Exam;
	DROP TABLE Request;
    DROP TABLE GradPlan_Course ;
    DROP TABLE Graduation_Plan;
	DROP TABLE Slot;
    DROP TABLE Course_Semester;
	DROP TABLE Student_Instructor_Course_Take;
	DROP TABLE Instructor_Course;
	DROP TABLE PreqCourse_course;
	DROP TABLE Student_Phone;
	DROP TABLE Student;
	DROP TABLE Advisor;
	DROP TABLE Semester;
	DROP TABLE Instructor;
	DROP TABLE Course;

GO
--4)
CREATE PROCEDURE clearAllTables AS
	ALTER TABLE Student DROP CONSTRAINT FK_advisor1
	ALTER TABLE Student_Phone DROP CONSTRAINT FK_student1
	ALTER TABLE PreqCourse_course DROP CONSTRAINT FK_PreqCourse_course
	ALTER TABLE PreqCourse_course DROP CONSTRAINT FK_PreqCourse_course2
	ALTER TABLE Instructor_Course DROP CONSTRAINT FK_course1
	ALTER TABLE Instructor_Course DROP CONSTRAINT FK_instructor1
	ALTER TABLE Student_Instructor_Course_Take DROP CONSTRAINT FK_student2
	ALTER TABLE Student_Instructor_Course_Take DROP CONSTRAINT FK_course2
	ALTER TABLE Student_Instructor_Course_Take DROP CONSTRAINT FK_instructor2
	ALTER TABLE Student_Instructor_Course_Take DROP CONSTRAINT FK_semester1
	ALTER TABLE Course_Semester DROP CONSTRAINT FK_course3
	ALTER TABLE Course_Semester DROP CONSTRAINT FK_semester2
	ALTER TABLE Slot DROP CONSTRAINT FK_course4
	ALTER TABLE Slot DROP CONSTRAINT FK_instructor3
	ALTER TABLE Graduation_Plan DROP CONSTRAINT FK_advisor2
	ALTER TABLE Graduation_Plan DROP CONSTRAINT FK_student3
	ALTER TABLE GradPlan_Course DROP CONSTRAINT FK_planSem
	ALTER TABLE GradPlan_Course DROP CONSTRAINT FK_semester3
	ALTER TABLE GradPlan_Course DROP CONSTRAINT FK_course5
	ALTER TABLE Request DROP CONSTRAINT FK_student4
	ALTER TABLE Request DROP CONSTRAINT FK_advisor3
	ALTER TABLE Request DROP CONSTRAINT FK_course6
	ALTER TABLE MakeUp_Exam DROP CONSTRAINT FK_course7
	ALTER TABLE Exam_Student DROP CONSTRAINT FK_student5
	ALTER TABLE Exam_Student DROP CONSTRAINT FK_exam
	ALTER TABLE Exam_Student DROP CONSTRAINT FK_course8
	ALTER TABLE Payment DROP CONSTRAINT FK_student6
	ALTER TABLE Payment DROP CONSTRAINT FK_semester4
	ALTER TABLE Installment DROP CONSTRAINT FK_Payment

	TRUNCATE TABLE Installment;
	TRUNCATE TABLE Payment
	TRUNCATE TABLE Exam_Student;
	TRUNCATE TABLE MakeUp_Exam;
	TRUNCATE TABLE Request;
    TRUNCATE TABLE GradPlan_Course ;
    TRUNCATE TABLE Graduation_Plan;
	TRUNCATE TABLE Slot;
    TRUNCATE TABLE Course_Semester;
	TRUNCATE TABLE Student_Instructor_Course_Take;
	TRUNCATE TABLE Instructor_Course;
	TRUNCATE TABLE PreqCourse_course;
	TRUNCATE TABLE Student_Phone;
	TRUNCATE TABLE Student ;
	TRUNCATE TABLE Advisor;
	TRUNCATE TABLE Semester;
	TRUNCATE TABLE Instructor;
	TRUNCATE TABLE Course;
	
	ALTER TABLE Student ADD	CONSTRAINT FK_advisor1 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id)
	ALTER TABLE Student_Phone ADD CONSTRAINT FK_student1 FOREIGN KEY (student_id) REFERENCES Student (student_id)
	ALTER TABLE PreqCourse_course ADD CONSTRAINT FK_PreqCourse_course FOREIGN KEY (prerequisite_course_id ) REFERENCES Course (course_id ) ON DELETE CASCADE
	ALTER TABLE PreqCourse_course ADD CONSTRAINT FK_PreqCourse_course2 FOREIGN KEY (course_id ) REFERENCES Course (course_id)
	ALTER TABLE Instructor_Course ADD CONSTRAINT FK_course1 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE Instructor_Course ADD CONSTRAINT FK_instructor1 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id)
	ALTER TABLE Student_Instructor_Course_Take ADD CONSTRAINT FK_student2 FOREIGN KEY (student_id) REFERENCES Student (student_id)
	ALTER TABLE Student_Instructor_Course_Take ADD CONSTRAINT FK_course2 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE Student_Instructor_Course_Take ADD CONSTRAINT FK_instructor2 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id)
	ALTER TABLE Student_Instructor_Course_Take ADD CONSTRAINT FK_semester1 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code)
	ALTER TABLE Course_Semester ADD CONSTRAINT FK_course3 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE Course_Semester ADD CONSTRAINT FK_semester2 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code)
	ALTER TABLE Slot ADD CONSTRAINT FK_course4 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE Slot ADD CONSTRAINT FK_instructor3 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id)
	ALTER TABLE Graduation_Plan ADD CONSTRAINT FK_advisor2 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id)
	ALTER TABLE Graduation_Plan ADD CONSTRAINT FK_student3 FOREIGN KEY (student_id) REFERENCES Student (student_id)
	ALTER TABLE GradPlan_Course ADD CONSTRAINT FK_planSem FOREIGN KEY (plan_id, semester_code) REFERENCES Graduation_Plan (plan_id, semester_code)
	ALTER TABLE GradPlan_Course ADD CONSTRAINT FK_semester3 FOREIGN KEY (semester_code)          REFERENCES Semester (semester_code)
	ALTER TABLE GradPlan_Course ADD CONSTRAINT FK_course5 FOREIGN KEY (course_id)              REFERENCES Course (course_id)
	ALTER TABLE Request ADD CONSTRAINT FK_student4 FOREIGN KEY (student_id) REFERENCES Student (student_id)
	ALTER TABLE Request ADD CONSTRAINT FK_advisor3 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id)
	ALTER TABLE Request ADD CONSTRAINT FK_course6 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE MakeUp_Exam ADD CONSTRAINT FK_course7 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE Exam_Student ADD CONSTRAINT FK_student5 FOREIGN KEY (student_id) REFERENCES Student (student_id)
	ALTER TABLE Exam_Student ADD CONSTRAINT FK_exam FOREIGN KEY (exam_id) REFERENCES MakeUp_Exam (exam_id)
	ALTER TABLE Exam_Student ADD CONSTRAINT FK_course8 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE Payment ADD CONSTRAINT FK_student6 FOREIGN KEY (student_id) REFERENCES Student (student_id)
	ALTER TABLE Payment ADD CONSTRAINT FK_semester4 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code)
	ALTER TABLE Installment ADD CONSTRAINT FK_Payment FOREIGN KEY (payment_id) REFERENCES Payment (payment_id)

GO

------------------------------Helper for student status------------------------------------------
CREATE FUNCTION CALC_STUDENT_FINANTIAL_STATUS_HELPER (@StudentId INT)
	RETURNS BIT
	BEGIN
		DECLARE @financial_status BIT;

		SET @financial_status = CASE WHEN Exists (Select * 
												  from (SELECT CASE WHEN CURRENT_TIMESTAMP > i.deadline AND i.status = 'notPaid'  THEN 0 ELSE 1 END as paid
														from Installment i INNER JOIN Payment p on (p.payment_id = i.payment_id 
															AND p.student_id = @StudentID)) as paids 
											      WHERE paids.paid = 0) Then 0 ELSE 1 END

	RETURN @financial_status
	END
GO

------------------------------------------2.2----------------------------------------------------
--A)
CREATE VIEW view_Students AS 
SELECT * 
FROM student 
WHERE financial_status = 1;
GO
--B)
CREATE VIEW view_Course_prerequisites AS 
SELECT c.course_id , c.name ,c.credit_hours ,c.is_offered ,c.major ,c.semester ,PC.prerequisite_course_id 
FROM Course c INNER JOIN PreqCourse_course PC on c.course_id = PC.prerequisite_course_id; 
GO
--C)
CREATE  VIEW  Instructors_AssignedCourses AS
Select Instructor.instructor_id, Instructor.name as Instructor, Course.course_id, Course.name As Course
from Instructor inner join Student_Instructor_Course_take t on Instructor.instructor_id = t.instructor_id
inner join Course On Course.course_id = t.course_id 
go
--D)
CREATE VIEW  Student_Payment AS
SELECT P.amount ,P.deadline ,P.fund_percentage ,P.n_installments ,P.payment_id ,P.semester_code ,
		P.start_date ,P.status ,S.f_name ,S.l_name ,S.student_id ,S.email 
FROM Payment P INNER JOIN Student S on S.student_id = P.student_id;
GO 
--E)
CREATE VIEW Courses_Slots_Instructor AS
SELECT c.course_id , c.name AS 'Course name' , S.slot_id , S.day , S.time , S.location , I.name AS 'Instructor name'
FROM (( Course c INNER JOIN Slot S on c.course_id = c.course_id 
                 INNER JOIN Instructor_Course IC on IC.Course_id = c.Course_id)
				 INNER JOIN Instructor I ON I.instructor_id = IC.instructor_id);
GO 
--F)
CREATE VIEW Courses_MakeupExams AS
SELECT c.name , c.semester , ME.course_id ,ME.date ,ME.exam_id ,ME.type
FROM Course c INNER JOIN MakeUp_Exam ME on c.course_id = ME.course_id;

GO
--G)
CREATE VIEW Students_Courses_transcript AS
	SELECT S.student_id , (S.f_name + ' ' +S.l_name) As 'student name' , SC.course_id , c.name AS 'Course name' ,
		   SC.exam_type , SC.grade AS ' course grade' , SC.semester_code AS 'Semester', I.name AS 'Instructor name' 
	FROM (((Student_Instructor_Course_Take SC 
	INNER JOIN Student S on S.student_id = SC.student_id )
	INNER JOIN Course c on SC.course_id = c.course_id )
	INNER JOIN Instructor I on SC.Instructor_id = I.Instructor_id)
	WHERE SC.grade IS NOT NULL
	;
GO
--H)
CREATE  VIEW  Semster_offered_Courses AS
Select Course.course_id, Course.name, Semester.semester_code
from Course inner join Course_Semester on Course.course_id = Course_Semester.course_id
inner join Semester on Course_Semester.semester_code = semester.semester_code
go 
--I)
CREATE VIEW Advisors_Graduation_Plan AS
SELECT GP.expected_grad_date ,GP.student_id ,GP.semester_credit_hours , 
	   GP.semester_code ,GP.plan_id  , A.advisor_id , A.name AS 'Advisor name'
FROM Graduation_Plan GP INNER JOIN Advisor A on A.advisor_id = GP.advisor_id;
GO 
------------------------------------------2.3----------------------------------------------------
--A)
CREATE PROC [Procedures_StudentRegistration]
     @first_name varchar(20), 
     @last_name varchar(20), 
     @password varchar(20), 
     @faculty varchar(20), 
     @email varchar(50), 
     @major varchar(20),
     @Semester int,
     @Student_id int OUTPUT
     AS 
     insert into Student  (f_name,l_name,password, faculty, email, major, semester) 
     values (@first_name, @last_name, @password, @faculty, @email, @major, @Semester)
    
    Select @Student_id =  student_id from Student 
     where f_name = @first_name and
     l_name= @last_name and
     password = @password  and
     email = @email 
    
Go
--B)
CREATE PROC Procedures_AdvisorRegistration
	 @name VARCHAR(40),
	 @password VARCHAR(40), 
	 @email VARCHAR(40), 
	 @office VARCHAR(40),
	 @advisor_id INT OUTPUT
	 AS
	 IF @name IS NULL OR @password IS NULL OR @email IS NULL OR @office IS NULL 
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	 ELSE
		BEGIN 
			 INSERT INTO Advisor(name,password,email,office)
			 VALUES(@name,@password,@email,@office);
			 SET @advisor_id = SCOPE_IDENTITY() ;
		END 
GO
--C)
CREATE PROC Procedures_AdminListStudents
	AS
	SELECT * FROM Student;	
GO 
--D)
CREATE PROC Procedures_AdminListAdvisors
	AS
	SELECT * FROM Advisor;	
GO
--E)
Create Proc [AdminListStudentsWithAdvisors] AS
Select Student.student_id, Student.f_name, Student.l_name, Advisor.advisor_id, Advisor.name
from Student inner join Advisor on Student.advisor_id = Advisor.advisor_id
go
--F)
CREATE PROC [AdminAddingSemester]

    @start_date date,
    @end_date date, 
    @semester_code Varchar(40)

     AS 
     IF @start_date IS NULL or @end_date IS NULL or @semester_code IS NULL 
    print 'One of the inputs is null'
    Else
     insert into Semester(start_date, end_date, semester_code) 
     values (@start_date, @end_date, @semester_code)
     
Go
--G)
CREATE PROC [Procedures_AdminAddingCourse]

    @major varchar(20),
    @semester int, 
    @credit_hours int, 
    @name varchar(30),
    @is_offered bit


     AS 
     IF @major IS NULL or @semester IS NULL or @name IS NULL or @credit_hours is Null or
     @is_offered is Null
    print 'One of the inputs is null'
    Else
     insert into Course(name, major,semester,credit_hours,is_offered) 
     values (@name, @major, @semester,@credit_hours,@is_offered)
     
Go

--H)
CREATE PROC [Procedures_AdminLinkInstructor]
@cours_id int,
@instructor_id int, 
@slot_id int
As

IF @cours_id IS NULL or @instructor_id IS NULL or @slot_id IS NULL 
    print 'One of the inputs is null'

Else
update Slot 
set course_id =@cours_id,
instructor_id =@instructor_id 
where slot_id = @slot_id;

Go
--I)
CREATE PROC [Procedures_AdminLinkStudent]
@cours_id int,
@instructor_id int, 
@studentID int,
@semester_code varchar(40)
As

IF @cours_id IS NULL or @instructor_id IS NULL or @studentID IS NULL or @semester_code IS NULL
    print 'One of the inputs is null'

Else
insert into Student_Instructor_Course_take ( instructor_id, course_id,student_id, semester_code) values (@instructor_id,@cours_id,@studentID,@semester_code) 
go
EXEC AdminListStudentsWithAdvisors
Go
--J)
CREATE PROC [Procedures_AdminLinkStudentToAdvisor]

@studentID int, 
@advisorID int

As
IF @studentID IS NULL or @advisorID IS NULL 
    print 'One of the inputs is null'

Else
update Student 
set advisor_id = @advisorID
where student_id = @studentID
Go
--K)
CREATE PROC Procedures_AdminAddExam
	@Type VARCHAR (40),
	@date DATE,
	@course_id INT
	AS
	IF @Type IS NULL OR @date IS NULL OR @course_id IS NULL
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	ELSE 
		BEGIN
			INSERT INTO MakeUp_Exam(date,type,course_id) 
			VALUES(@date,@Type,@course_id);
		END
GO



--L)
CREATE PROC [Procedures_AdminIssueInstallment]
@payment_id int

As
Declare 
@payment_amount int,
@startdate datetime,
@deadline datetime,
@num_of_installment int,

@installment_amount int,
@num_of_insertions int,
@install_start_date date,
@install_deadline date,
@add_month int

Select @payment_amount = amount from Payment where payment_id = @payment_id
Select @startdate = payment.start_date from Payment where payment_id = @payment_id
Select @deadline = deadline from Payment where payment_id = @payment_id
Select @num_of_installment = n_installments from Payment where payment_id = @payment_id
-------
set @installment_amount = @payment_amount/ @num_of_installment
set @num_of_insertions = @num_of_installment
set @install_start_date =  @startdate
set @add_month =1

while @num_of_insertions > 0
Begin

Set @install_deadline = DATEADD(month, 1, @install_start_date)  

insert into Installment values (@payment_id,@install_deadline,@installment_amount,'NotPaid', @install_start_date)

set @install_start_date = DATEADD(month, 1, @install_start_date) --@install_start_date  +1 
set @num_of_insertions = @num_of_insertions -1

End 
GO
--M)
CREATE PROC Procedures_AdminDeleteCourse @courseID INT
AS
IF @courseID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	UPDATE Slot
	SET course_id = NULL
	WHERE course_id = @courseID;

	DELETE
	FROM Instructor_Course
	Where course_id = @courseID;
	DELETE
	FROM Student_Instructor_Course_Take
	Where course_id = @courseID;
	DELETE
	FROM Course_Semester
	Where course_id = @courseID;
	DELETE
	FROM Request
	Where course_id = @courseID;
	
	DELETE
	FROM Exam_Student
	Where course_id = @courseID OR exam_id in (Select exam_id from MakeUp_Exam where course_id = @courseID);
	DELETE
	FROM MakeUp_Exam
	Where course_id = @courseID;
	DELETE
	FROM GradPlan_Course
	Where course_id = @courseID;
	DELETE
	FROM PreqCourse_course
	Where course_id = @courseID OR prerequisite_course_id = @courseID;

	DELETE
	FROM Course
	WHERE course_id = @courseID;
END
GO
--N) moved before the Tables creation 
--O)
Create View all_Pending_Requests As
	Select * from Request where status = 'Pending';
GO
--P)
CREATE PROC Procedures_AdminDeleteSlots 
@current_semester VARCHAR(40)
AS
IF @current_semester IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	DELETE S
	FROM Slot S
	INNER JOIN Course C ON S.course_id = C.course_id
	INNER JOIN Course_Semester CS ON @current_semester = CS.semester_code
	WHERE C.is_offered = 0
END
GO
--Q)
CREATE FUNCTION FN_AdvisorLogin (
	@ID INT
	,@password VARCHAR(40)
	)
RETURNS BIT
AS
BEGIN
	DECLARE @Success BIT

	IF EXISTS (
			SELECT *
			FROM Advisor
			WHERE Advisor.advisor_id = @ID
				AND Advisor.password = @password
			)
		SET @Success = 1
	ELSE
		SET @Success = 0

	RETURN @Success
END
GO

--R)
--TO BE CHECKED SINCE THE INPUT IS A DATE AND IT SHOULD BE AN INTEGER REPRESENTING THE SEMESTER
--TO BE ASKED IN Q&A
CREATE PROC Procedures_AdvisorCreateGP 
	 @Semestercode VARCHAR(40)
	,@expected_graduation_date DATE
	,@sem_credit_hours INT
	,@advisorid INT
	,@studentid INT
AS
	-- saeed added
	DECLARE @std_acq_hours INT
	SELECT @std_acq_hours= acquired_hours
	FROM Student
	WHERE student_id = @studentid
IF @std_acq_hours <= 157
	BEGIN PRINT 'INVALID ACTION the student dont have enough acquired_hours' END
ELSE IF @Semestercode IS NULL
	OR @expected_graduation_date IS NULL
	OR @sem_credit_hours IS NULL
	OR @advisorid IS NULL
	OR @studentid IS NULL
	BEGIN
		PRINT 'INVALID INPUT'
	END
ELSE
	BEGIN
	
		INSERT INTO Graduation_Plan (
			semester_code
			,semester_credit_hours
			,expected_grad_date
			,advisor_id
			,student_id
			)
		VALUES (
			@Semestercode
			,@sem_credit_hours
			,@expected_graduation_date
			,@advisorid
			,@studentid
			)
	END
GO
--S)
CREATE PROC Procedures_AdvisorAddCourseGP
	 @student_Id INT
	,@Semester_code VARCHAR(40)
	,@course_name VARCHAR(40)
AS
IF  @student_Id IS NULL
	OR @Semester_code IS NULL
	OR @course_name IS NULL
	OR NOT EXISTS (SELECT * FROM Graduation_Plan WHERE student_id = @student_Id)
	OR NOT EXISTS (SELECT * FROM Student WHERE student_id = @student_Id)
	OR NOT EXISTS (SELECT * FROM Course WHERE name = @course_name)
	OR NOT EXISTS (SELECT * FROM Semester WHERE semester_code = @Semester_code)
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	DECLARE @course_id INT

	SELECT @course_id = course_id
	FROM Course
	WHERE Course.name = @course_name

	DECLARE @plan_id INT

	SELECT @plan_id = plan_id
	FROM Graduation_Plan
	WHERE Graduation_Plan.student_id = @student_Id

	INSERT INTO GradPlan_Course (
		plan_id
		,semester_code
		,course_id
		)
	VALUES (
		@plan_id
		,@Semester_code
		,@course_id
		)
END
GO
--T)
CREATE PROC Procedures_AdvisorUpdateGP 
	 @expected_grad_date DATE
	,@studentID INT
AS
IF    @expected_grad_date IS NULL
	OR @studentID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN

	UPDATE Graduation_Plan
	SET expected_grad_date = @expected_grad_date
	WHERE Graduation_Plan.student_id = @studentID
END
GO
--U)
CREATE PROC Procedures_AdvisorDeleteFromGP 
	 @studentID INT
	,@semesterCode VARCHAR(40)
	,@courseID INT
AS
IF  @studentID IS NULL
	OR @semesterCode IS NULL
	OR @courseID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	DECLARE @planid  INT ;
	SELECT @planid = plan_id
	FROM Graduation_Plan
	WHERE student_id= @studentID
	
	DELETE 
	FROM GradPlan_Course
	WHERE plan_id= @planid AND
		  course_id =@courseID AND
		  semester_code = @semesterCode
END
GO


/* V Handle what to show when type = course and when type = CH*/
CREATE FUNCTION FN_Advisors_Requests (@advisorID INT)
	RETURNS TABLE
	AS
	RETURN (
		SELECT *
		FROM Request
		WHERE advisor_id = @advisorID
	);
GO

/*                     W                          */
Create PROC Procedures_AdvisorApproveRejectCHRequest
	@RequestID int,
	@Current_semester_code varchar (40)
	AS
	Declare @stID INT
	Declare @ch INT
	IF @RequestID IS NULL OR @Current_semester_code IS NULL OR Not EXISTS (Select * from Request WHERE type LIKE 'credit%' AND @RequestID = request_id AND status = 'pending')
		Print 'No such pending request'

	ELSE IF Exists (Select s.student_id from Request R INNER JOIN Student S on r.student_id = s.student_id AND r.type LIKE 'credit%' /*is type like this?*/
		AND @RequestID = request_id And s.gpa <= 3.7 AND r.credit_hours <= 3 And r.credit_hours + s.assigned_hours <= 34) 
	Begin
	----
		UPDATE Request 
		Set status = 'approved'
		where @RequestID = request_id

		------
		SET @stID = (SELECT student_id from Request where @RequestID = request_id)
		SET @ch = (SELECT credit_hours from Request where @RequestID = request_id)
		UPDATE Student
		SET assigned_hours = (SELECT assigned_hours + @ch
							from Student where student_id = @stID)
		where student_id = @stID
		-----
		Declare @InstID1 INT
		Declare @InstID2 DATE
		SELECT TOP 1 @InstID1 = i.payment_id, @InstID2 = i.deadline
				from Installment i JOIN Payment p on i.payment_id = p.payment_id AND p.student_id = @stID 
				AND p.semester_code = @Current_semester_code AND i.status = 'notPaid'
				Order by i.deadline 
		
		UPDATE Installment
		SET amount = amount + @ch*1000
		where payment_id = @InstID1 AND deadline = @InstID2
	End
	ELSE
		UPDATE Request
		Set status = 'rejected'
		where @RequestID = request_id
	GO
/*X*/
CREATE PROC Procedures_AdvisorViewAssignedStudents
	@AdvisorID int,
	@major varchar (40)
	AS
	Select s.student_id as 'Student id', Concat(s.f_name, ' ', s.l_name) as 'Student name' , s.major as 'Student major', c.name as 'Course name'
				from student s INNER JOIN Student_Instructor_Course_Take t on s.student_id = t.student_id
				INNER JOIN Course c on t.course_id = c.course_id
				AND s.advisor_id = @AdvisorID And s.major = @major;
	GO
/*                              Y              */
CREATE PROC Procedures_AdvisorApproveRejectCourseRequest
	@RequestID int,
	@current_semester_code varchar(40)
	AS
	IF @RequestID IS NULL OR @current_semester_code IS NULL OR Not EXISTS (Select * from Request WHERE type = 'course' AND @RequestID = request_id AND status='pending')
	BEGIN
		Print 'ERROR' 
		RETURN
	END
	DECLARE @prereq_taken BIT
	SET @prereq_taken = CASE
		WHEN EXISTS (
			SELECT p.prerequisite_course_id
			FROM PreqCourse_course p
			INNER JOIN Request r ON p.course_id = r.course_id AND r.request_id = @RequestID
			LEFT JOIN Student_Instructor_Course_Take sic ON p.prerequisite_course_id = sic.course_id AND sic.student_id = r.student_id
			WHERE sic.course_id IS NULL OR sic.grade IS NULL OR sic.grade = 'FA'
		) THEN 0
		ELSE 1
		END;
	Declare @enough_hours BIT
	SET @enough_hours  = CASE
		WHEN EXISTS ( Select c.credit_hours from Request r JOIN Course c on r.course_id = c.course_id AND r.request_id = @RequestID
			JOIN Student s on r.student_id = s.student_id AND s.assigned_hours >= c.credit_hours
			) THEN 1
			ELSE 0
			END;
	Declare @already_taken BIT 
	SET @already_taken= CASE 
				WHEN EXISTS (Select * from Request r JOIN Student_Instructor_Course_Take sic 
				on r.student_id = sic.student_id AND r.course_id = sic.course_id AND r.request_id = @RequestID
				AND sic.semester_code = @current_semester_code) THEN 1 ELSE 0 END
	Declare @studentID INT
	Declare @course_hours INT
	Declare @courseID INT
	Select @studentID = r.student_id, @course_hours = c.credit_hours, @courseID = c.course_id
	from Request r JOIN Course c on r.course_id = c.course_id AND r.request_id = @RequestID

	IF @prereq_taken = 1 AND @enough_hours = 1 AND @already_taken = 0
	BEGIN
		UPDATE Request
		SET status = 'approved'
		WHERE @RequestID = request_id

		UPDATE Student
		SET assigned_hours = assigned_hours - @course_hours
		WHERE student_id = @studentID

		INSERT INTO Student_Instructor_Course_Take(student_id, course_id, semester_code) VALUES
		(@studentID, @courseID, @current_semester_code)
	END
	ELSE
	BEGIN
		UPDATE Request
		SET status = 'rejected'
		WHERE @RequestID = request_id
	END

	GO
/*Z*/
CREATE PROC Procedures_AdvisorViewPendingRequests
	@AdvisorID int
	AS
	Select * from request 
		where status = 'pending' AND student_id in (Select student_id from student where advisor_id = @AdvisorID);
	GO


/* AA  */
CREATE FUNCTION [FN_StudentLogin]
(@Student_id int, @password varchar(40))     --Define Function Input
Returns bit   	  --Define Function Output

AS
Begin
Declare
@success bit,
@pass varchar(40)

if(@Student_id is null or @password is null)
return 0

select @pass = password from Student where Student.student_id = @Student_id and Student.financial_status = 1
if(@pass = @password)
set @success = 1 
else 
set @success = 0

Return @success
END
Go

/*BB*/
Create PROC [Procedures_StudentaddMobile]
@StudentID int, @mobile_number varchar(40)
As
Insert into Student_Phone values (@StudentID, @mobile_number)
Go
/*CC*/
CREATE FUNCTION [FN_SemsterAvailableCourses]
     (@semstercode varchar(40))
   RETURNs table
   AS
   RETURN (
   Select Course.name, Course.course_id 
   from Course inner join Course_Semester 
   on Course.course_id = Course_Semester.course_id and Course_Semester.semester_code = @semstercode
   )
GO
/*DD*/
Create PROC [Procedures_StudentSendingCourseRequest]
@courseID int, 
@StudentID int, 
@type varchar(40), 
@comment varchar(40)
AS
declare
@advisorID int

Select @advisorID = Student.advisor_id from student where Student.student_id = @StudentID

Insert into Request (type,comment,course_id, student_id,advisor_id) values (@type, @comment, @courseID, @StudentID, @advisorID)
Go
/*EE*/
CREATE PROC Procedures_StudentSendingCHRequest
	@StudentID int, 
	@credit_hours int, 
	@type varchar (40),
	@comment varchar (40) 
	AS
	IF @StudentID IS NULL OR @credit_hours IS NULL OR @type NOT LIKE 'credit%'
	BEGIN
		PRINT 'ERROR';
	END
	ELSE
	BEGIN
	declare
	@advisorID int

	Select @advisorID = Student.advisor_id from student where Student.student_id = @StudentID
		INSERT INTO request (student_id, credit_hours, type, comment, advisor_id) values (@StudentID ,@credit_hours ,@type ,@comment, @advisorID) 
	END
	GO

---------------------------------------------------------------HELPER FUNCTIONS-------------------------------------------------------
GO
CREATE FUNCTION FN_IS_COURSE_OFFERED_HELPER (@CourseID INT , @Current_Semester_Code VARCHAR(40) )
	RETURNS BIT 
	AS
	BEGIN 
	DECLARE @Is_offered BIT ,
			@course_semester INT 
		SELECT @course_semester=semester  FROM Course WHERE course_id = @CourseID
		IF( @course_semester % 2 = 0 AND( @Current_Semester_Code LIKE 'Spring%' OR @Current_Semester_Code LIKE '%Round 2%'  OR @Current_Semester_Code LIKE '%R2%' OR @Current_Semester_Code LIKE 'S%[^R]%') )
			BEGIN  SET @Is_offered = 1 END
		ELSE IF( @course_semester % 2 <> 0 AND( @Current_Semester_Code LIKE 'Winter%' OR @Current_Semester_Code LIKE '%Round 1%' OR @Current_Semester_Code LIKE '%R1%' OR @Current_Semester_Code LIKE 'W%' ) )
		    BEGIN  SET @Is_offered = 1 END
		ELSE
			BEGIN  SET @Is_offered  = 0 END
	RETURN @Is_offered ;
END
GO
CREATE FUNCTION FN_IS_prerequisite_Courses_TAKEN_HELPER (@StudentID INT , @CourseID INT ) 
	RETURNS BIT 
	AS
	BEGIN 
	DECLARE @Is_ALL_PRE_TAKEN BIT ,
			@num_pre_courses_not_taken INT 
		SELECT @num_pre_courses_not_taken =COUNT(*)
		FROM (
				(SELECT c.course_id , c.name , c.major ,c.is_offered ,c.credit_hours ,c.semester
				FROM PreqCourse_course PC INNER JOIN Course c ON PC.course_id = c.course_id  WHERE c.course_id = @CourseID)
				EXCEPT
				(SELECT c.course_id , c.name , c.major ,c.is_offered ,c.credit_hours ,c.semester
				FROM ( PreqCourse_course PC INNER JOIN Course c ON PC.course_id = c.course_id
											INNER JOIN Student_Instructor_Course_Take SC ON SC.course_id = PC.prerequisite_course_id )
				WHERE SC.student_id  = @StudentID AND
					  c.course_id = @CourseID ) 
		      )T_Pre_Courses_Not_Taken
		
		IF @num_pre_courses_not_taken <> 0  --if didnt take all prerequisites
			BEGIN SET @Is_ALL_PRE_TAKEN =0 END
		ELSE	
			BEGIN SET @Is_ALL_PRE_TAKEN =1 END
										
		
	RETURN @Is_ALL_PRE_TAKEN ;
	END ;
GO
CREATE FUNCTION FN_FIND_REQ_Courses_HELPER (@Student_ID int  , @Current_semester_code Varchar (40) , @CourseID INT) 
	RETURNS TABLE
	AS
	RETURN 
		 SELECT c1.course_id , c1.name , c1.major ,c1.is_offered ,c1.credit_hours ,c1.semester
		 FROM ( Course c1 INNER JOIN Student_Instructor_Course_Take SC ON c1.course_id = SC.course_id
						  INNER JOIN Student S ON SC.student_id = S.student_id )
		 WHERE  S.student_id = @Student_ID AND
				c1.course_id = @CourseID AND
				c1.semester <= S.semester AND
				( SC.grade = 'F' OR SC.grade ='FF' OR SC.grade='FA' OR SC.grade IS NULL ) AND               -- check for grade
				dbo.FN_IS_COURSE_OFFERED_HELPER(c1.course_id , @Current_semester_code) = 1 	
GO

CREATE FUNCTION FN_FIND_OPTIONAL_Courses_HELPER (@Student_ID int  , @Current_semester_code Varchar (40) , @CourseID Varchar (40) ) 
	RETURNS TABLE
	AS
	RETURN 
	SELECT c.course_id , c.name , c.major ,c.is_offered ,c.credit_hours ,c.semester
	FROM Course c 
	WHERE dbo.FN_IS_COURSE_OFFERED_HELPER(c.course_id , @Current_semester_code) = 1 AND  -- course is offered 
		  dbo.FN_IS_prerequisite_Courses_TAKEN_HELPER(@Student_ID , c.course_id) =1 AND  -- Took all prerequisite
		  NOT EXISTS  ( SELECT * FROM dbo.FN_FIND_REQ_Courses_HELPER (@Student_ID   , @Current_semester_code  , c.course_id) )
GO

CREATE FUNCTION FN_num_of_falied_courses_HELPER (@Season1 VARCHAR(40) , @Season4 VARCHAR(40), @Season2 VARCHAR(40) , @Season3 VARCHAR(40),@CourseID INT , @StudentID INT)
	RETURNS INT
	AS
	BEGIN
	DECLARE @Num_of_falied_courses INT
			
		SELECT @Num_of_falied_courses=COUNT(*)
		FROM   Student_Instructor_Course_Take 
		WHERE	course_id = @CourseID AND
				student_id = @StudentID AND
				(semester_code LIKE @Season1 OR semester_code LIKE @Season2  OR semester_code LIKE @Season3 OR
				semester_code LIKE @Season4) AND  
				(grade = 'F' OR grade = 'FF')

	RETURN @Num_of_falied_courses ;
	END
GO
-------------------------------------------------------------------------------------------------------------------------------------------
--FF) 
CREATE FUNCTION FN_StudentViewGP (@student_ID int) 
RETURNS TABLE
AS
RETURN
    SELECT 
		S.student_id                    AS 'Student Id',
		CONCAT(S.f_name, ' ', S.l_name) AS 'Student_name', 
		GP.plan_id                      AS 'graduation Plan Id', 
		GP.semester_code                AS 'Semester code', 
		GP.expected_grad_date           AS 'expected graduation date',
		GP.semester_credit_hours        AS 'Semester credit hours', 
		GP.advisor_id                   AS 'advisor id',
		c.course_id                     AS 'Course id',
		c.name                          AS 'Course name'
    FROM (Student S INNER JOIN Graduation_Plan GP ON S.student_id = GP.student_id
					INNER JOIN GradPlan_Course GPC ON (GP.plan_id = GPC.plan_id AND GP.semester_code = GPC.semester_code ) )
					INNER JOIN Course c ON GPC.course_id = c.course_id
	WHERE S.student_id = @student_ID

-- GG)
GO
SELECT * FROM FN_StudentViewGP(1) WHERE [advisor id] = 1
GO
CREATE FUNCTION FN_StudentUpcoming_installment (@StudentID INT)
	RETURNS DATE 
	AS
	BEGIN 
	DECLARE @first_instalment_deadline DATE

	SELECT @first_instalment_deadline  = MIN(I.deadline)
	FROM Payment P INNER JOIN Installment I ON P.payment_id = I.payment_id 
	WHERE P.student_id = @StudentID AND
		  P.status = 'notPaid' AND
		  I.status = 'notPaid'
	RETURN @first_instalment_deadline ;
END


--HH)
GO
CREATE FUNCTION  FN_StudentViewSlot (@CourseID INT , @InstructorID INT) 
RETURNS TABLE
AS
RETURN
    SELECT SL.slot_id AS 'Slot ID', 
			SL.location AS'location', 
			SL.time AS'time', 
			SL.day AS 'day' , 
		    c.name AS'course name' ,
		    ISC.name AS'Instructor name' 
    FROM (Course c INNER JOIN Slot SL ON c.course_id = SL.course_id
				   INNER JOIN Instructor ISC ON SL.instructor_id = ISC.instructor_id)
	WHERE c.course_id = @CourseID AND
		  ISC.instructor_id = @InstructorID

GO
--II) what is the date of first or secound makeup
Create PROC [Procedures_StudentRegisterFirstMakeup]
@StudentID int, @courseID int, @studentCurrentsemester varchar(40)
AS
declare 
@exam_id int,
@instructor_id int


If(not exists( Select * from Student_Instructor_Course_take where Student_Instructor_Course_take.student_id = @StudentID and Student_Instructor_Course_take.course_id
= @courseID and Student_Instructor_Course_take.exam_type in ('First_makeup','Second_makeup')))
begin 
    If(exists(Select * from Student_Instructor_Course_take where Student_Instructor_Course_take.student_id = @StudentID and Student_Instructor_Course_take.course_id
    = @courseID  and Student_Instructor_Course_take.exam_type = 'Normal' and Student_Instructor_Course_take.grade in ('F','FF',null)))
    begin 
        Select @exam_id = MakeUp_Exam.exam_id from MakeUp_Exam where MakeUp_Exam.course_id = @courseID
        Select @instructor_id = Student_Instructor_Course_take.instructor_id from Student_Instructor_Course_take 
        where Student_Instructor_Course_take.student_id = @StudentID and Student_Instructor_Course_take.course_id = @courseID 
        insert into Exam_Student values (@exam_id, @StudentID, @courseID)
        Update Student_Instructor_Course_take 
        Set exam_type = 'first_makeup' , grade= null
        where  student_id = @StudentID and course_id = @courseID and
         semester_code = @studentCurrentsemester
    end
end
GO
-- JJ) 
CREATE FUNCTION  FN_StudentCheckSMEligiability (@CourseID INT, @StudentID INT)
	RETURNS BIT 
	AS
	BEGIN
	DECLARE @IS_Eligible BIT ,
			@num_failed_courses_Even INT ,
			@num_failed_courses_Odd INT ,
			@IF_course_firstMakeup INT ,
			@CurrentSemesterCode VARCHAR(40)
			
		SELECT @CurrentSemesterCode=semester_code FROM Course_Semester WHERE course_id = @CourseID

		SET  @num_failed_courses_Even  = dbo.FN_num_of_falied_courses_HELPER ('Spring%' ,'S%[^R]%' ,'%Round 2%'  ,'%R2%' ,  @CourseID  , @StudentID )
		SET  @num_failed_courses_Odd   = dbo.FN_num_of_falied_courses_HELPER ('Winter%'  ,'W%','%Round 1%'  ,'%R1%', @CourseID , @StudentID )

		SELECT @IF_course_firstMakeup=COUNT(*)
		FROM  Student_Instructor_Course_Take 
		WHERE course_id = @CourseID AND
			  student_id = @StudentID AND
			  semester_code = @CurrentSemesterCode AND
			  exam_type = 'First_makeup' AND
			  (NOT (grade IS NULL OR grade
   					 LIKE 'FF' OR grade LIKE 'F' OR grade LIKE 'FA'))
 
		IF @IF_course_firstMakeup <> 0

			BEGIN SET @IS_Eligible =0 END

		ELSE IF ( @CurrentSemesterCode LIKE 'Spring%' OR @CurrentSemesterCode LIKE '%Round 2%' OR 
				  @CurrentSemesterCode LIKE '%R2%' OR @CurrentSemesterCode LIKE 'S%[^R]%' )
		BEGIN
			IF ( @num_failed_courses_Even < 2  )
				BEGIN SET @IS_Eligible = 1 END
			ELSE 
				BEGIN   
					SET @IS_Eligible = 0 
				END
		END
		ELSE IF ( @CurrentSemesterCode LIKE 'Winter%' OR @CurrentSemesterCode LIKE '%Round 1%' 
				OR @CurrentSemesterCode LIKE '%R1%' )
		BEGIN
			IF ( @num_failed_courses_Odd < 2  )
				BEGIN SET @IS_Eligible = 1 END
			ELSE 
				BEGIN 
					SET @IS_Eligible = 0 
				END
		END
    RETURN @IS_Eligible ;
END;

-- KK)
GO
Create PROC [Procedures_StudentRegisterSecondMakeup]
@StudentID int, @courseID int, @Student_Current_Semester varchar(40)
AS
declare 
@exam_id int,
@instructor_id int
if dbo.FN_StudentCheckSMEligibility(@StudentID, @courseID) = 0
    Print 'Your are not eligible to take 2nd makeup'

else
begin
    IF @Student_Current_Semester IN (SELECT semester_code
			FROM Student_Instructor_Course_Take
			WHERE student_id = @StudentID AND
				  exam_type = 'First_makeup' AND
				  course_id = @courseID     )
    BEGIN
        Select @exam_id = MakeUp_Exam.exam_id from MakeUp_Exam where MakeUp_Exam.course_id = @courseID
        Select @instructor_id = Student_Instructor_Course_take.instructor_id from Student_Instructor_Course_take 
        where Student_Instructor_Course_take.student_id = @StudentID and Student_Instructor_Course_take.course_id = @courseID
        insert into Exam_Student values (@exam_id, @StudentID, @courseID)
        Update Student_Instructor_Course_take 
        Set exam_type = 'Second_makeup' , grade= null
        where  student_id = @StudentID and course_id = @courseID and
         semester_code = @Student_Current_Semester
    END
end
Go--------------------------------------------------Courses Procedures---------------------------------------------------------------------------
-- LL) 
GO
Create PROC [Procedures_ViewRequiredCourses]
@StudentID int,
@current_semester_code varchar(40)
As
declare @student_semester int

select @student_semester = Student.semester FROM Student where Student.student_id = @StudentID
select Course.name, Course.course_id
from Course 
where Course.course_id in (select * from dbo.FN_StudentFailedAndNotEligibleCourse(@StudentID,@current_semester_code)) 
or Course.course_id in (select * from dbo.FN_StudentUnattendedCourses(@StudentID,@current_semester_code,@student_semester))
GO
CREATE FUNCTION [FN_StudentUnattendedCourses]
     (@StudentID int,@current_semester_code varchar(40),@student_semester int)
   RETURNs table
   AS
   RETURN ( select Course_Semester.course_id
from Course_Semester inner join Course on Course_Semester.course_id = Course.course_id 
inner join Student on Student.major = Course.major
where  Student.student_id= @StudentID and   Course_Semester.semester_code = @current_semester_code and course.semester < @student_semester and Course_Semester.course_id Not In (
select Student_Instructor_Course_take.course_id
from Student_Instructor_Course_take
where Student_Instructor_Course_take.student_id = @StudentID
   ) or Course_Semester.course_id
   In (select Student_Instructor_Course_take.course_id
from Student_Instructor_Course_take
where Student_Instructor_Course_take.student_id = @StudentID and Student_Instructor_Course_take.grade = 'FA' ))
go
CREATE FUNCTION [FN_StudentCheckSMEligibility]
     (@CourseID int, @StudentID int)
   RETURNs bit
Begin
declare 
@eligable bit,
@countOfRows int,
@Student_semester int,
@course_semester varchar(40),
@StudentSemesterCode varchar(40),
@failedGradesCount int

select @countOfRows = COUNT(*) 
from Student_Instructor_Course_take where Student_Instructor_Course_take.exam_type In ( 'First_Makeup', 'Normal') and
Student_Instructor_Course_take.grade in ('F','FF',NULL) 
AND Student_Instructor_Course_take.course_id = @CourseID
AND Student_Instructor_Course_take.student_id = @StudentID

if @countOfRows = 0
return 0

else

begin
select @Student_semester = Student.semester from Student where  Student.student_id = @StudentID

if (@Student_semester % 2) = 0
set @StudentSemesterCode = 'Even'
Else 
set @StudentSemesterCode = 'Odd'

select @failedGradesCount = count(*)
from Student_Instructor_Course_take
where dbo.FN_SemesterCodeCheck(Student_Instructor_Course_take.semester_code) = @StudentSemesterCode and 
Student_Instructor_Course_take.student_id = @StudentID and Student_Instructor_Course_take.grade in ('F','FF')
group by Student_Instructor_Course_take.grade

end

if @failedGradesCount <=2
begin
set @eligable = 1
end
else
set @eligable = 0

return @eligable
END
go
CREATE FUNCTION [FN_StudentFailedAndNotEligibleCourse]
     (@StudentID int, @current_semester_code varchar(40))
   RETURNs table
   AS
   RETURN ( select Student_Instructor_Course_take.course_id
    from Student_Instructor_Course_take inner join Course_Semester on Student_Instructor_Course_take.course_id = Course_Semester.course_id
    where Student_Instructor_Course_take.student_id = @StudentID and 
    Student_Instructor_Course_take.grade in ('F','FF') and
    dbo.FN_StudentCheckSMEligibility(@StudentID,Student_Instructor_Course_take .course_id) = 0 
    and Course_Semester.semester_code = @current_semester_code
    )
go
CREATE FUNCTION [FN_SemesterCodeCheck]
     (@SemesterCode varchar(40))
   RETURNs varchar(40)
   begin
   declare @output varchar(40)
if @SemesterCode like '%R1%' or  @SemesterCode like '%W%'
set @output = 'Odd'
else 
set @output =  'Even'
return @output
end

go
-- MM) Check again
Create PROC [Procedures_ViewOptionalCourse]
@StudentID int,
@current_semester_code varchar(40)
As
declare @student_semester int
select @student_semester = Student.semester FROM Student where Student.student_id = @StudentID

select Course_Semester.course_id, Course.name
from Course_Semester inner join Course on Course_Semester.course_id = Course.course_id
where Course_Semester.semester_code = @current_semester_code AND  (Course.semester >= @student_semester and dbo.FN_check_prerequiste(@StudentID, Course_Semester.course_id) = 1 )
GO 

CREATE FUNCTION [FN_check_prerequiste]
(@studentid int, @requestcourse_id varchar(40))
returns bit
Begin
declare 
@success bit,
@student_id_target int

set @student_id_target = -1

Select @student_id_target = Student.student_id
from Student 
where Student.student_id = @studentid AND  Student.student_id In(
SELECT Student.student_id
FROM Student
WHERE NOT EXISTS (
    (SELECT PreqCourse_course.prerequisite_course_id
    FROM PreqCourse_course
    WHERE PreqCourse_course.course_id = @requestcourse_id)

    EXCEPT

    (SELECT Student_Instructor_Course_take.course_id
    FROM Student_Instructor_Course_take
    INNER JOIN PreqCourse_course ON Student_Instructor_Course_take.course_id = PreqCourse_course.prerequisite_course_id
    where Student_Instructor_Course_take.student_id =  Student.student_id)
)
)
if @student_id_target = -1
set @success = 0
else
set @success = 1
return @success
End
Go
-- NN) 
Create PROC [Procedures_ViewMS]
@StudentID int
As
declare @student_major varchar(40)
Select @student_major = major from Student where student_id = @StudentID 

select Course.course_id, Course.name
from Course 
where  Course.major = @student_major and   Course.course_id not in (select Student_Instructor_Course_take.course_id
from Student_Instructor_Course_take
where Student_Instructor_Course_take.student_id = @StudentID) OR course.course_id in (select Student_Instructor_Course_take.course_id
from Student_Instructor_Course_take
where Student_Instructor_Course_take.student_id = @StudentID AND grade in ('F','FF'))
GO

-- OO)
CREATE PROCEDURE Procedures_ChooseInstructor
	 @StudentID int, 
	 @InstructorID int,
	 @CourseID int ,
	 @current_semester_code varchar(40) 
	 AS
	 UPDATE Student_Instructor_Course_Take
	 SET instructor_id = @InstructorID
	 WHERE student_id =@StudentID AND course_id = @CourseID AND semester_code = @current_semester_code
GO
----------------------------------------