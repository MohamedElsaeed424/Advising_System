GO
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
			 INSERT INTO Advisor(advisor_id,name,password,email,office)
			 VALUES(@advisor_id,@name,@password,@email,@office);
			 SET @advisor_id = SCOPE_IDENTITY() ;
		END 
GO
CREATE PROC Procedures_AdminListStudents
	AS
	SELECT * FROM Student;	
GO 
CREATE PROC Procedures_AdminListAdvisors
	AS
	SELECT * FROM Advisor;	
GO
CREATE PROC AdminListStudentsWithAdvisors
	AS
	SELECT Student.f_name,Student.l_name , Advisor.name
	FROM Student INNER JOIN Advisor ON Student.advisor_id = Advisor.advisor_id;
GO
CREATE PROC AdminAddingSemester 
	@start_date DATE,
	@end_date DATE,
	@semester_code VARCHAR(40)
	AS
	IF @start_date IS NULL OR @end_date IS NULL OR @semester_code IS NULL 
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	ELSE
		BEGIN
			INSERT INTO Semester VALUES(@semester_code,@start_date,@end_date);
		END
GO
CREATE PROC Procedures_AdminAddingCourse 
	@major VARCHAR (40), 
	@semester INT, 
	@credit_hours INT, 
	@name VARCHAR (40), 
	@is_offered BIT
	AS
	IF @major IS NULL OR @semester IS NULL OR @credit_hours IS NULL OR @name IS NULL OR @is_offered IS NULL 
		BEGIN
			PRINT('CAN''T DO THIS SERVICE');
		END
	ELSE
		BEGIN
			INSERT INTO Course(name,major,is_offered,credit_hours,semester)
			VALUES(@name,@major,@is_offered,@credit_hours,@semester);
		END
GO
CREATE PROC Procedures_AdminLinkInstructor -- update or insert ??
	@instructor_id INT,
	@course_id INT,
	@slot_id INT
	AS
	IF @instructor_id IS NULL OR @course_id IS NULL OR @slot_id IS NULL 
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	IF 
		not exists(SELECT instructor_id FROM Instructor WHERE instructor_id=@instructor_id) OR
		not exists(SELECT course_id FROM Course WHERE course_id=@course_id)OR
		not exists(SELECT slot_id FROM Slot WHERE slot_id=@slot_id)
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	ELSE
		BEGIN
			UPDATE Slot 
			SET instructor_id =@instructor_id , course_id = @course_id
			WHERE slot_id = @slot_id
		END
GO 
CREATE PROC Procedures_AdminLinkStudent
	@instructor_id INT,
	@student_id INT,
	@course_id INT,
	@semester_code VARCHAR(40)
	AS
	IF @instructor_id IS NULL OR @student_id IS NULL OR @course_id IS NULL OR @semester_code IS NULL  
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	IF 
		not exists(SELECT instructor_id FROM Instructor WHERE instructor_id=@instructor_id) OR
		not exists(SELECT course_id FROM Course WHERE course_id=@course_id)OR
		not exists(SELECT student_id FROM Student WHERE student_id=@student_id)OR
		not exists(SELECT semester_code FROM Semester WHERE semester_code=@semester_code)
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	ELSE
		BEGIN
			INSERT INTO Student_Instructor_Course_Take(student_id,course_id,instructor_id,semester_code)
			VALUES(@student_id,@course_id,@instructor_id,@semester_code);
		END	
GO 
CREATE PROC Procedures_AdminLinkStudentToAdvisor --update or insert ??
	@student_id INT,
	@advisor_id INT
	AS
	IF  @student_id IS NULL OR @advisor_id IS NULL  
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	IF
		not exists(SELECT student_id FROM Student WHERE student_id=@student_id)OR
		not exists(SELECT advisor_id FROM Advisor WHERE advisor_id=@advisor_id)
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	ELSE
		BEGIN
			--INSERT INTO Student(student_id,advisor_id) VALUES(@student_id,@advisor_id);
			UPDATE Student
			SET advisor_id = @advisor_id
			WHERE student_id = @student_id
		END
GO 
CREATE PROC Procedures_AdminAddExam
	@Type VARCHAR (40),
	@date DATETIME,
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

