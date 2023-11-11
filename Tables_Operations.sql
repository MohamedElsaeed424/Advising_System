GO
CREATE PROCEDURE CreateAllTables AS
	CREATE TABLE Student (
	student_id            INT PRIMARY KEY ,
	f_name                VARCHAR (40) ,
	l_name                VARCHAR (40) , 
	gpa	                  DECIMAL (3,2) , 
	faculty               VARCHAR (40), 
	email                 VARCHAR (40), 
	major                 VARCHAR (40),
	password              VARCHAR (40), 
	financial_status      BIT CHECK (current_timestamp > Installment.deadline AND Installment.status = 1), 
	semester              INT, 
	acquired_hours        VARCHAR (40), 
	assigned_hours        VARCHAR (40) DEFAULT NULL, 
	advisor_id            INT ,
	FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE Student_Phone (
	student_id            INT PRIMARY KEY ,
	phone_number          VARCHAR(40) PRIMARY KEY,
    FOREIGN KEY (student_id) REFERENCES Student (student_id) ON DELETE CASCADE ON UPDATE CASCADE
   	);

	CREATE TABLE Course (
	course_id             VARCHAR(40) PRIMARY KEY,
	name                  VARCHAR(40),
	major                 VARCHAR(40),
	is_offered            BIT,
	credit_hours          INT,
	semester              INT
	);

	CREATE TABLE PreqCourse_course (
	prerequisite_course_id  INT PRIMARY KEY,
	course_id               INT PRIMARY KEY,
	FOREIGN KEY (prerequisite_course_id) REFERENCES Course (course_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE Instructor (
	instructor_id        INT PRIMARY KEY,
	name                 VARCHAR(40) ,
	email                VARCHAR(40),
	faculty              VARCHAR(40),
	office               VARCHAR(40)
	) ;

	CREATE TABLE Instructor_Course ( 
	course_id            INT PRIMARY KEY,
	instructor_id        INT PRIMARY KEY,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE Student_Instructor_Course_Take (
	student_id          INT PRIMARY KEY,
	course_id           INT PRIMARY KEY,
	instructor_id       INT PRIMARY KEY, 
    semester_code       VARCHAR(40),
	exam_type           VARCHAR(40) DEFAULT 'Normal',
	grade               DECIMAL (5,2)  DEFAULT Null ,
	FOREIGN KEY (student_id) REFERENCES Student (student_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) ON DELETE CASCADE ON UPDATE CASCADE ,
	FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) ON DELETE CASCADE ON UPDATE CASCADE
	); 


	CREATE TABLE Semester (
	semester_code       VARCHAR(40) PRIMARY KEY ,
	start_date          DATE , 
	end_date            DATE
	);


	CREATE TABLE Course_Semester (
	course_id          INT PRIMARY KEY,
	semester_code      VARCHAR(40) PRIMARY KEY,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) ON DELETE CASCADE ON UPDATE CASCADE,
	);

	CREATE TABLE Advisor (
	advisor_id        INT PRIMARY KEY, 
	name              VARCHAR(40),
	email             VARCHAR(40), 
	office            VARCHAR(40), 
	password          VARCHAR(40)
	);

	CREATE TABLE Slot (
	slot_id           INT PRIMARY KEY,
	day               VARCHAR(40), 
	time              VARCHAR(40), 
	location          VARCHAR(40), 
	course_id         INT , 
	instructor_id     INT,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE Graduation_Plan (
	plan_id                INT PRIMARY KEY, 
	semester_code          VARCHAR(40) PRIMARY KEY, 
	semester_credit_hours  INT, 
	expected_grad_semester INT, 
	advisor_id             INT, 
	student_id             INT,
	FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (student_id) REFERENCES Student (student_id) ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE GradPlan_Course (
	plan_id                INT PRIMARY KEY, 
	semester_code          VARCHAR(40) PRIMARY KEY, 
	course_id              INT PRIMARY KEY ,
	FOREIGN KEY (plan_id) REFERENCES Graduation_Plan (plan_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ON DELETE CASCADE ON UPDATE CASCADE,
	);

	CREATE TABLE Request (
	request_id             INT PRIMARY KEY, 
	type                   VARCHAR(40) ,
	comment                VARCHAR(40), 
	status                 VARCHAR(40) DEFAULT 'pending', 
	credit_hours           INT , 
	student_id             INT , 
	advisor_id             INT, 
	course_id              INT ,
	FOREIGN KEY (student_id) REFERENCES Student (student_id) ON DELETE CASCADE ON UPDATE CASCADE ,
	FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE MakeUp_Exam (
	exam_id        INT PRIMARY KEY, 
	date           DATETIME, 
	type           VARCHAR(40), 
	course_id      INT ,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ON DELETE CASCADE ON UPDATE CASCADE,
	);

	CREATE TABLE Exam_Student (
	exam_id         INT PRIMARY KEY, 
	student_id      INT PRIMARY KEY, 
	course_id       INT PRIMARY KEY,
	FOREIGN KEY (student_id) REFERENCES Student (student_id) ON DELETE CASCADE ON UPDATE CASCADE ,
	FOREIGN KEY (exam_id) REFERENCES MakeUp_Exam (exam_id) ON DELETE CASCADE ON UPDATE CASCADE ,
	FOREIGN KEY (course_id) REFERENCES Course (course_id) ON DELETE CASCADE ON UPDATE CASCADE
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
	FOREIGN KEY (student_id) REFERENCES Student (student_id) ON DELETE CASCADE ON UPDATE CASCADE ,
	FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) ON DELETE CASCADE ON UPDATE CASCADE,
	);

	CREATE TABLE Installment (
	payment_id     INT PRIMARY KEY, 
	deadline       DATE, 
	amount         DECIMAL(7,2), 
	status         BIT  ,
	start_date     DATE
	);
GO

EXEC CreateAllTables
GO
