GO
CREATE PROC Procedures_AdvisorRegistration
	 @name VARCHAR(40),
	 @password VARCHAR(40), 
	 @email VARCHAR(40), 
	 @office VARCHAR(40),
	 @advisor_id INT OUTPUT
	 AS
	 INSERT INTO Advisor(name,password,email,office) VALUES(@name,@password,@email,@office);
	 SELECT advisor_id 
	 FROM Advisor 
	 WHERE Advisor.name=@name AND Advisor.password=@password AND Advisor.email=@email AND Advisor.office=@office;
	 GO
	 EXEC Procedures_AdvisorRegistration;

GO
CREATE PROC Procedures_AdminListStudents
	AS
	SELECT * FROM Student;
	GO
	EXEC Procedures_AdminListStudents;

GO 
CREATE PROC Procedures_AdminListAdvisors
	AS
	SELECT * FROM Advisor;
	GO
	EXEC Procedures_AdminListAdvisors;

GO
CREATE PROC AdminListStudentsWithAdvisors
	AS
	SELECT Student.name , Advisor.name
	FROM Student INNER JOIN Advisor ON Student.advisor_id = Advisor.advisor_id;
	GO
	EXEC AdminListStudentsWithAdvisors

GO
CREATE PROC AdminAddingSemester 
	@start_date DATE,
	@end_date DATE,
	@semester_code VARCHAR(40)
	AS
	INSERT INTO Semester VALUES(@semester_code,@start_date,@end_date);
	GO
	EXEC AdminAddingSemester;

GO
CREATE PROC Procedures_AdminAddingCourse 
	@major VARCHAR (40), 
	@semester INT, 
	@credit_hours INT, 
	@name VARCHAR (40), 
	@is_offered BIT
	AS
	INSERT INTO Course(name,major,is_offered,credit_hours,semester) VALUES(@name,@major,@is_offered,@credit_hours,@semester);
	GO
	EXEC Procedures_AdminAddingCourse;

GO
CREATE PROC Procedures_AdminLinkInstructor
	@instructor_id INT,
	@course_id INT,
	@slot_id INT
	AS
	INSERT INTO Slot(slot_id,course_id,instructor_id) VALUES(@slot_id,@course_id,@instructor_id);
	GO
	EXEC Procedures_AdminLinkInstructor;

GO 
CREATE PROC Procedures_AdminLinkStudent
	@instructor_id INT,
	@student_id INT,
	@course_id INT,
	@semester_code VARCHAR(40)
	AS
	INSERT INTO Student_Instructor_Course_Take(student_id,course_id,instructor_id,semester_code) VALUES(@student_id,@course_id,@instructor_id,@semester_code);
	GO
	EXEC Procedures_AdminLinkStudent;

GO 
CREATE PROC Procedures_AdminLinkStudentToAdvisor
	@student_id INT,
	@advisor_id INT
	AS
	INSERT INTO Student(student_id,advisor_id) VALUES(@student_id,@advisor_id);
	GO
	EXEC Procedures_AdminLinkStudentToAdvisor

GO
CREATE PROC Procedures_AdminAddExam
	@Type VARCHAR (40),
	@date DATETIME,
	@course_id INT
	AS
	INSERT INTO MakeUp_Exam(date,type,course_id) VALUES(@date,@Type,@course_id);
	GO
	EXEC Procedures_AdminAddExam;

