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
	email                VARCHAR(40),
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
	email             VARCHAR(40), 
	office            VARCHAR(40), 
	password          VARCHAR(40)
	);



	CREATE TABLE Student (
	student_id            INT PRIMARY KEY ,
	f_name                VARCHAR (40) ,
	l_name                VARCHAR (40) , 
	gpa	                  DECIMAL (3,2) , 
	faculty               VARCHAR (40), 
	email                 VARCHAR (40), 
	major                 VARCHAR (40),
	password              VARCHAR (40), 
	financial_status      AS (SELECT          --CURRENT_TIMESTAMP > i.deadline AND i.status = 1 
								CASE
									WHEN CURRENT_TIMESTAMP > i.deadline AND i.status = 1 
									THEN 1 ELSE 0 END
								from Installment i INNER JOIN Payment p on p.payment_id = i.payment_id 
									 AND p.student_id = Student.student_id),
	semester              INT, 
	acquired_hours        VARCHAR (40), 
	assigned_hours        VARCHAR (40) DEFAULT NULL, 
	advisor_id            INT ,
	FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) 
	);

	CREATE TABLE Student_Phone (
	student_id            INT  ,
	phone_number          VARCHAR(40) ,
	CONSTRAINT PK_Student_Phone PRIMARY KEY (student_id, phone_number),
    FOREIGN KEY (student_id) REFERENCES Student (student_id) 
   	);



	CREATE TABLE PreqCourse_course (
	prerequisite_course_id  INT ,
	course_id               INT NOT NULL ,
	CONSTRAINT PK_PreqCourse_course PRIMARY KEY (prerequisite_course_id, course_id),
	CONSTRAINT FK_PreqCourse_course FOREIGN KEY (prerequisite_course_id ) REFERENCES Course (course_id )  ,
	CONSTRAINT FK_PreqCourse_course2 FOREIGN KEY (course_id ) REFERENCES Course (course_id)  
	);

	CREATE TABLE Instructor_Course ( 
	course_id            INT ,
	instructor_id        INT ,
	CONSTRAINT PK_Instructor_Course PRIMARY KEY (course_id, instructor_id),
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ,
	FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) 
	);

	CREATE TABLE Student_Instructor_Course_Take (
	student_id          INT ,
	course_id           INT ,
	instructor_id       INT , 
    semester_code       VARCHAR(40),
	exam_type           VARCHAR(40) DEFAULT 'Normal',
	grade               DECIMAL (5,2)  DEFAULT Null ,
	CONSTRAINT PK_Student_Instructor_Course_Take PRIMARY KEY (student_id, course_id ,instructor_id),
	FOREIGN KEY (student_id) REFERENCES Student (student_id) ,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ,
	FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id)  ,
	FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) 
	); 

	CREATE TABLE Course_Semester (
	course_id          INT ,
	semester_code      VARCHAR(40) ,
	CONSTRAINT PK_Course_Semester PRIMARY KEY (course_id, semester_code),
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ,
	FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) ,
	);

	CREATE TABLE Slot (
	slot_id           INT PRIMARY KEY,
	day               VARCHAR(40), 
	time              VARCHAR(40), 
	location          VARCHAR(40), 
	course_id         INT , 
	instructor_id     INT,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ,
	FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) 
	);

CREATE TABLE Graduation_Plan (
  plan_id                INT, 
  semester_code          VARCHAR(40), 
  semester_credit_hours  INT, 
  expected_grad_semester INT, 
  advisor_id             INT, 
  student_id             INT,
  CONSTRAINT PK_Graduation_Plan PRIMARY KEY (plan_id, semester_code),
  FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id),
  FOREIGN KEY (student_id) REFERENCES Student (student_id)
);

CREATE TABLE GradPlan_Course (
  plan_id                INT, 
  semester_code          VARCHAR(40), 
  course_id              INT,
  CONSTRAINT PK_GradPlan_Course PRIMARY KEY (plan_id, semester_code, course_id),
  FOREIGN KEY (plan_id, semester_code) REFERENCES Graduation_Plan (plan_id, semester_code),
  FOREIGN KEY (semester_code)          REFERENCES Semester (semester_code),
  FOREIGN KEY (course_id)              REFERENCES Course (course_id)
);
	/*is type not null since a request is either course or credit hours*/
	CREATE TABLE Request (
	request_id             INT IDENTITY(1,1) PRIMARY KEY, 
	type                   VARCHAR(40) ,
	comment                VARCHAR(40), 
	status                 VARCHAR(40) DEFAULT 'pending', 
	credit_hours           INT , 
	student_id             INT , 
	advisor_id             INT, 
	course_id              INT ,
	FOREIGN KEY (student_id) REFERENCES Student (student_id)  ,
	FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) ,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) 
	);

	CREATE TABLE MakeUp_Exam (
	exam_id        INT PRIMARY KEY, 
	date           DATETIME, 
	type           VARCHAR(40), 
	course_id      INT ,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ,
	);

	CREATE TABLE Exam_Student (
	exam_id         INT , 
	student_id      INT , 
	course_id       INT ,
	CONSTRAINT PK_Exam_Student PRIMARY KEY (exam_id ,student_id ,course_id ),
	FOREIGN KEY (student_id) REFERENCES Student (student_id)  ,
	FOREIGN KEY (exam_id) REFERENCES MakeUp_Exam (exam_id)  ,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) 
	);

	CREATE TABLE Payment(
	payment_id      INT PRIMARY KEY, 
	amount          DECIMAL(7,2), 
	deadline        DATE,
	n_installments  INT DEFAULT 0,
	status          VARCHAR(40) DEFAULT 'notPaid',
	fund_percentage DECIMAL(5,2), 
	student_id      INT, 
	semester_code   VARCHAR(40), 
	start_date      DATE,
	FOREIGN KEY (student_id) REFERENCES Student (student_id)  ,
	FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) ,
	);

	CREATE TABLE Installment (
	payment_id     INT PRIMARY KEY, 
	deadline       DATE, 
	amount         DECIMAL(7,2), 
	status         BIT  ,
	start_date     DATE ,
	CONSTRAINT  PK_Installment PRIMARY KEY (payment_id, deadline),
	FOREIGN KEY (payment_id) REFERENCES Payment (payment_id) ,
	);

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
	DROP TABLE Student ;
	DROP TABLE Advisor;
	DROP TABLE Semester;
	DROP TABLE Instructor;
	DROP TABLE Course;

GO
EXEC DropAllTables;
GO

CREATE PROCEDURE clearAllTables AS
	TRUNCATE TABLE Installment;
	TRUNCATE TABLE Payment;
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
EXEC clearAllTables;
GO
