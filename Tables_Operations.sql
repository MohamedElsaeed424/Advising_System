CREATE DATABASE Advising_Team_13 ;


GO
CREATE PROCEDURE CreateAllTables AS
	CREATE TABLE Course (
	course_id             INT PRIMARY KEY,
	name                  VARCHAR(40),
	major                 VARCHAR(40),
	is_offered            BIT,
	credit_hours          INT,
	semester              INT
	);

	CREATE TABLE Instructor (
	instructor_id        INT PRIMARY KEY,
	name                 VARCHAR(40) ,
	email                VARCHAR(40) UNIQUE,
	faculty              VARCHAR(40),
	office               VARCHAR(40)
	) ;

	CREATE TABLE Semester (
	semester_code       VARCHAR(40) PRIMARY KEY ,
	start_date          DATE , 
	end_date            DATE
	);

	CREATE TABLE Advisor (
	advisor_id        INT PRIMARY KEY, 
	name              VARCHAR(40),
	email             VARCHAR(40) UNIQUE, 
	office            VARCHAR(40), 
	password          VARCHAR(40)
	);



	CREATE TABLE Student (
	student_id            INT PRIMARY KEY ,
	f_name                VARCHAR (40) ,
	l_name                VARCHAR (40) , 
	gpa	                  DECIMAL (3,2) , 
	faculty               VARCHAR (40), 
	email                 VARCHAR (40) UNIQUE, 
	major                 VARCHAR (40),
	password              VARCHAR (40), 
	--financial_status      BIT ,
							--AS		(SELECT          --CURRENT_TIMESTAMP > i.deadline AND i.status = 1 
							--		CASE
							--		WHEN CURRENT_TIMESTAMP > i.deadline AND i.status = 1 
							--		THEN 1 ELSE 0 END
							--		from Installment i INNER JOIN Payment p on p.payment_id = i.payment_id 
							--		 AND p.student_id = Student.student_id),
	semester              INT, 
	acquired_hours        INT, 
	assigned_hours        INT DEFAULT NULL, 
	advisor_id            INT ,
	CONSTRAINT FK_advisor FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) --ON DELETE SET NULL
	);
	
	CREATE TABLE Student_Phone (
	student_id            INT  ,
	phone_number          VARCHAR(40) ,
	CONSTRAINT PK_Student_Phone PRIMARY KEY (student_id, phone_number),
    CONSTRAINT FK_student FOREIGN KEY (student_id) REFERENCES Student (student_id) --ON DELETE CASCADE -- do not truncate
   	);



	CREATE TABLE PreqCourse_course (
	prerequisite_course_id  INT ,
	course_id               INT NOT NULL ,
	CONSTRAINT PK_PreqCourse_course PRIMARY KEY (prerequisite_course_id, course_id),
	CONSTRAINT FK_PreqCourse_course FOREIGN KEY (prerequisite_course_id ) REFERENCES Course (course_id ) ON DELETE CASCADE ,
	CONSTRAINT FK_PreqCourse_course2 FOREIGN KEY (course_id ) REFERENCES Course (course_id)  --ON DELETE CASCADE
	);

	CREATE TABLE Instructor_Course ( 
	course_id            INT ,
	instructor_id        INT ,
	CONSTRAINT PK_Instructor_Course PRIMARY KEY (course_id, instructor_id),
	CONSTRAINT FK_course FOREIGN KEY (course_id) REFERENCES Course (course_id), --ON DELETE CASCADE,
	CONSTRAINT FK_course FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id)-- ON DELETE CASCADE
	);

	CREATE TABLE Student_Instructor_Course_Take (
	student_id          INT ,
	course_id           INT ,
	instructor_id       INT , 
    semester_code       VARCHAR(40),
	exam_type           VARCHAR(40) DEFAULT 'Normal',
	grade               VARCHAR(40) ,
	CONSTRAINT PK_Student_Instructor_Course_Take PRIMARY KEY (student_id, course_id ,instructor_id),
	CONSTRAINT FK_student FOREIGN KEY (student_id) REFERENCES Student (student_id), -- ON DELETE CASCADE,
	CONSTRAINT FK_course FOREIGN KEY (course_id) REFERENCES Course (course_id) , --ON DELETE CASCADE,
	CONSTRAINT FK_instructor FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id),--  ON DELETE CASCADE,
	CONSTRAINT FK_semester FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) ,--ON DELETE CASCADE
	); 

	CREATE TABLE Course_Semester (
	course_id          INT ,
	semester_code      VARCHAR(40) ,
	CONSTRAINT PK_Course_Semester PRIMARY KEY (course_id, semester_code),
	CONSTRAINT FK_course FOREIGN KEY (course_id) REFERENCES Course (course_id),-- ON DELETE CASCADE,
	CONSTRAINT FK_semester FOREIGN KEY (semester_code) REFERENCES Semester (semester_code)-- ON DELETE CASCADE,
	);

	CREATE TABLE Slot (
	slot_id           INT PRIMARY KEY,
	day               VARCHAR(40), 
	time              VARCHAR(40), 
	location          VARCHAR(40), 
	course_id         INT , 
	instructor_id     INT,
	CONSTRAINT FK_course FOREIGN KEY (course_id) REFERENCES Course (course_id) ,--ON DELETE SET NULL,
	CONSTRAINT FK_instructor FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) ,--ON DELETE SET NULL
	);

CREATE TABLE Graduation_Plan (
  plan_id                INT, 
  semester_code          VARCHAR(40), 
  semester_credit_hours  INT, 
  expected_grad_semester VARCHAR(40), 
  advisor_id             INT, 
  student_id             INT,
  CONSTRAINT PK_Graduation_Plan PRIMARY KEY (plan_id, semester_code),
  CONSTRAINT FK_advisor FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) ,--ON DELETE SET NULL,
  CONSTRAINT FK_student FOREIGN KEY (student_id) REFERENCES Student (student_id) --ON DELETE CASCADE
);														   

CREATE TABLE GradPlan_Course (
  plan_id                INT, 
  semester_code          VARCHAR(40), 
  course_id              INT,
  CONSTRAINT PK_GradPlan_Course PRIMARY KEY (plan_id, semester_code, course_id),
  CONSTRAINT FK_planSem FOREIGN KEY (plan_id, semester_code) REFERENCES Graduation_Plan (plan_id, semester_code) , --ON DELETE CASCADE,
  CONSTRAINT FK_semester FOREIGN KEY (semester_code)          REFERENCES Semester (semester_code) ,-- ON DELETE CASCADE, -- OR SET NULL???
  CONSTRAINT FK_course FOREIGN KEY (course_id)              REFERENCES Course (course_id),-- ON DELETE CASCADE  -- not FK in schema !!
);
	/*is type not null since a request is either course or credit hours*/
	CREATE TABLE Request (
	request_id             INT PRIMARY KEY, 
	type                   VARCHAR(40) ,
	comment                VARCHAR(40), 
	status                 VARCHAR(40) DEFAULT 'pending', 
	credit_hours           INT , 
	student_id             INT , 
	advisor_id             INT, 
	course_id              INT ,
	CONSTRAINT FK_student FOREIGN KEY (student_id) REFERENCES Student (student_id) ,-- ON DELETE CASCADE , -- ????
	CONSTRAINT FK_advisor FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) ,--ON DELETE SET NULL, --??
	CONSTRAINT FK_course FOREIGN KEY (course_id) REFERENCES Course (course_id) ,--ON DELETE CASCADE
	);

	CREATE TABLE MakeUp_Exam (
	exam_id        INT PRIMARY KEY, 
	date           DATE, 
	type           VARCHAR(40), 
	course_id      INT ,
	CONSTRAINT FK_course FOREIGN KEY (course_id) REFERENCES Course (course_id) ,--ON DELETE CASCADE,
	);

	CREATE TABLE Exam_Student (
	exam_id         INT , 
	student_id      INT , 
	course_id       INT ,
	CONSTRAINT PK_Exam_Student PRIMARY KEY (exam_id ,student_id ,course_id ),
	CONSTRAINT FK_student FOREIGN KEY (student_id) REFERENCES Student (student_id) ,--  ON DELETE CASCADE, 
	CONSTRAINT FK_exam FOREIGN KEY (exam_id) REFERENCES MakeUp_Exam (exam_id),--  ON DELETE CASCADE,
	CONSTRAINT FK_course FOREIGN KEY (course_id) REFERENCES Course (course_id)-- ON DELETE CASCADE
	);

	CREATE TABLE Payment(
	payment_id      INT PRIMARY KEY, 
	amount          INT , 
	deadline        DATETIME,
	n_installments  INT DEFAULT 0,
	status          VARCHAR(40) DEFAULT 'notPaid',
	fund_percentage DECIMAL(5,2), 
	student_id      INT, 
	semester_code   VARCHAR(40), 
	start_date      DATETIME,
	CONSTRAINT FK_student FOREIGN KEY (student_id) REFERENCES Student (student_id) ,-- ON DELETE SET NULL,
	CONSTRAINT FK_semesterFOREIGN KEY (semester_code) REFERENCES Semester (semester_code) --ON DELETE SET NULL,
	);

	CREATE TABLE Installment (
	payment_id     INT , 
	deadline       DATETIME, 
	amount         INT, 
	status         VARCHAR(40)  ,
	start_date     DATETIME ,
	CONSTRAINT PK_Installment PRIMARY KEY (payment_id, deadline),
	CONSTRAINT FK_Payment FOREIGN KEY (payment_id) REFERENCES Payment (payment_id),
	);

	--ALTER TABLE Student
	--ADD financial_status AS		(SELECT          --CURRENT_TIMESTAMP > i.deadline AND i.status = 1 
	--								CASE
	--								WHEN CURRENT_TIMESTAMP > i.deadline AND i.status = 1 
	--								THEN 1 ELSE 0 END
	--								from Installment i INNER JOIN Payment p on p.payment_id = i.payment_id 
	--								 AND p.student_id = Student.student_id);

GO
EXEC CreateAllTables;
DROP PROCEDURE CreateAllTables;
GO

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

DROP PROC DropAllTables;
EXEC DropAllTables;
GO

CREATE PROCEDURE clearAllTables AS
	TRUNCATE TABLE Installment;

	ALTER TABLE Installment DROP CONSTRAINT FK_Payment
	TRUNCATE TABLE Payment;
	ALTER TABLE Installment ADD CONSTRAINT FK_Payment FOREIGN KEY (payment_id) REFERENCES Payment (payment_id)

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


GO

DROP PROC clearAllTables;
EXEC clearAllTables;
GO
