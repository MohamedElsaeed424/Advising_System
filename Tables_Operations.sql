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
	office               VARCHAR(40)
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
	password          VARCHAR(40)
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
	financial_status      AS dbo.CALC_STUDENT_FINANTIAL_STATUS_HELPER(student_id)  ,		
	semester              INT, 
	acquired_hours        INT, 
	assigned_hours        INT DEFAULT NULL, 
	advisor_id            INT ,
	CONSTRAINT FK_advisor1 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) --ON DELETE SET NULL
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
	CONSTRAINT FK_PreqCourse_course FOREIGN KEY (prerequisite_course_id ) REFERENCES Course (course_id ) ON DELETE CASCADE ,
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
	CONSTRAINT FK_course4 FOREIGN KEY (course_id) REFERENCES Course (course_id) ,--ON DELETE SET NULL,
	CONSTRAINT FK_instructor3 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) ,--ON DELETE SET NULL
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
	CONSTRAINT FK_course6 FOREIGN KEY (course_id) REFERENCES Course (course_id) ,--ON DELETE CASCADE
	);

	CREATE TABLE MakeUp_Exam (
	exam_id        INT IDENTITY PRIMARY KEY, 
	date           DATE, 
	type           VARCHAR(40), 
	course_id      INT ,
	CONSTRAINT FK_course7 FOREIGN KEY (course_id) REFERENCES Course (course_id) ,--ON DELETE CASCADE,
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
	deadline        DATE,
	n_installments  INT DEFAULT 0,
	status          VARCHAR(40) DEFAULT 'notPaid',
	fund_percentage DECIMAL(5,2), 
	student_id      INT, 
	semester_code   VARCHAR(40), 
	start_date      DATE,
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