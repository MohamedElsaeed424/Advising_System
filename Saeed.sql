--FF) 
CREATE FUNCTION FN_StudentViewGP (@student_ID int) 
RETURNS TABLE
AS
RETURN
    SELECT 
		S.student_id AS 'Student Id',
		CONCAT(S.f_name, ' ', S.l_name) AS ' Student_name', 
		GP.plan_id AS ' graduation Plan Id', 
		c.course_id AS 'Course id',
		c.name AS 'Course name', 
		GP.semester_code AS 'Semester code', 
		SE.end_date AS ' expected graduation date', --IS this correct ??
		GP.semester_credit_hours  AS 'Semester credit hours', 
		GP.advisor_id AS 'advisor id'
    FROM ((Student S INNER JOIN Graduation_Plan GP ON S.student_id = GP.student_id
					INNER JOIN GradPlan_Course GPC ON (GP.plan_id = GPC.plan_id AND GP.semester_code = GPC.semester_code ) )
					INNER JOIN Course c ON GPC.course_id = c.course_id
					INNER JOIN Semester SE ON SE.semester_code = GP.semester_code)
GO
SELECT * FROM FN_StudentViewGP(1);
GO

-- GG)
CREATE FUNCTION FN_StudentUpcoming_installment (@StudentID INT)
	RETURNS DATE 
	AS
	BEGIN 
	DECLARE @first_instalment_deadline DATE


	SELECT @first_instalment_deadline  = MIN(I.deadline)
	FROM (Student S INNER JOIN Payment P ON S.student_id = P.student_id
                    INNER JOIN Installment I ON P.payment_id = I.payment_id ) 
	WHERE P.status = 'notPaid' AND
		  I.status = 0
	RETURN @first_instalment_deadline ;
END
GO

--HH)
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

GO
SELECT * FROM  FN_StudentViewSlot(1 ,1);
GO

--II) what is the date of first or secound makeup
CREATE PROCEDURE   Procedures_StudentRegisterFirstMakeup
	@StudentID int, 
	@courseID int, 
	@studentCurrentsemester varchar (40)
	AS
		INSERT INTO MakeUp_Exam (course_id , type) 
					VALUES (@courseID , 'First_makeup') ;
		INSERT INTO Exam_Student(course_id , student_id) 
					VALUES (@courseID , @StudentID)
		UPDATE Student_Instructor_Course_Take
		SET exam_type = 'First_makeup'
		WHERE student_id = @StudentID AND
			  course_id= @courseID
GO
EXEC Procedures_StudentRegisterFirstMakeup @StudentID = 1 ,  @courseID= 1 ,@studentCurrentsemester = 'Spring 2023 à S23'  ;
GO

-- JJ) How will i check for time of student makeup
CREATE FUNCTION  FN_StudentCheckSMEligiability (@CourseID INT, @StudentID INT)
	RETURNS BIT 
	AS
	BEGIN
	DECLARE @IS_Eligible BIT ;
	DECLARE @num_failed_courses INT ;
	DECLARE @IF_course_firstMakeup INT ;
    DECLARE @CurrentSemesterCode VARCHAR(40);
	DECLARE @sdate DATE ;
	DECLARE @edate DATE ;
		SELECT @sdate=SE.start_date , @edate=SE.end_date
		FROM (( Course c INNER JOIN Course_Semester CS ON c.course_id = CS.course_id)
					     INNER JOIN Semester SE ON CS.semester_code = SE.semester_code )

		-- take reqired courses from Procedures_ViewRequiredCourses
		CREATE TABLE TMP_REQUIRED_COURSES (course_id INT , name VARCHAR(40) , major VARCHAR(40),is_offered BIT ,credit_hours INT ,semester INT)
		--INSERT INTO TMP_REQUIRED_COURSES EXEC Procedures_ViewRequiredCourses @Student_ID = @StudentID , @Current_semester_code= @Student_Current_Semester ;
		INSERT INTO TMP_REQUIRED_COURSES EXEC Procedures_ViewRequiredCourses @Student_ID = @StudentID , @Current_semester_code= @CurrentSemesterCode ;
		
		--SELECT @sdate=start_date , @edate=end_date FROM Semester WHERE semester_code = @Student_Current_Semester ;

		-- select num of faied or require courses
		SELECT @num_failed_courses=COUNT(*)
		FROM TMP_REQUIRED_COURSES

		--  check if 
		SELECT @IF_course_firstMakeup=COUNT(*)
		FROM (((MakeUp_Exam ME INNER JOIN Course c ON ME.course_id = c.course_id)
							   INNER JOIN Course_Semester CS ON c.course_id = CS.course_id )
							   INNER JOIN Semester SE ON CS.semester_code = SE.semester_code)
		WHERE c.course_id = @courseID AND
			  ME.type = 'First_makeup'AND
			  SE.start_date >= @sdate AND SE.end_date <=@edate -- in same semester


		IF @num_failed_courses > 2 AND  @IF_course_firstMakeup <> 0 
		BEGIN
			SET @IS_Eligible = 0
		END
		ELSE
		BEGIN 
			SET @IS_Eligible =1 
		END
		DROP TABLE TMP_REQUIRED_COURSES ;
    RETURN @IS_Eligible ;
END;

-- KK) what tables should i insert into  and how to get table from anotehr procedure
GO;
CREATE PROCEDURE  Procedures_StudentRegisterSecondMakeup
	@StudentID int, 
	@courseID int, 
	@Student_Current_Semester Varchar (40)
	AS
	DECLARE @num_failed_courses INT ;
	DECLARE @IF_course_firstMakeup INT ;
	DECLARE @sdate DATE ;
    DECLARE @edate DATE ;
	DECLARE @IS_SecoundMakeup_Eligible BIT ;

	SET @IS_SecoundMakeup_Eligible = dbo.FN_StudentCheckSMEligiability(@courseID,@StudentID  )

	IF @IS_SecoundMakeup_Eligible = 0
	BEGIN
		PRINT('YOU CANT REGISTER FOR THE SECOUND MAKEUP ')
	END
	ELSE
	BEGIN
	PRINT('here')
		INSERT INTO MakeUp_Exam (course_id , type) 
					VALUES (@courseID , 'Second_makeup') ;
		INSERT INTO Exam_Student(course_id , student_id) 
					VALUES (@courseID , @StudentID)
		UPDATE Student_Instructor_Course_Take
		SET exam_type = 'Second_makeup'
		WHERE student_id = @StudentID AND
			  course_id= @courseID
	END
	
GO
	EXEC Procedures_StudentRegisterSecondMakeup @StudentID = 1 ,  @courseID= 1 ,@Student_Current_Semester = 'Spring 2023 à S23'  ;
GO
	

-- LL) When course consider as failed
CREATE PROCEDURE  Procedures_ViewRequiredCourses
	 @Student_ID int,
	 @Current_semester_code Varchar (40)
	 AS 
	 DECLARE @sdate DATE ;
	 DECLARE @edate DATE ;
	 SELECT @sdate=start_date , @edate=end_date FROM Semester WHERE semester_code = @Current_semester_code ;

	 SELECT c1.course_id , c1.name , c1.major ,c1.is_offered ,c1.credit_hours ,c1.semester
	 FROM 
	 -- Select all courses that student didnt take
	 (	SELECT c.course_id , c.name , c.major ,c.is_offered ,c.credit_hours ,c.semester, SC.grade , SE.start_date , SE.end_date
		FROM ((((Course c LEFT JOIN Student_Instructor_Course_Take SC ON c.course_id = SC.course_id)
						  INNER JOIN Student S ON S.student_id = SC.student_id)                   
						  INNER JOIN Course_Semester CS ON c.course_id = CS.course_id ) 
						  INNER JOIN Semester SE ON CS.semester_code = SE.semester_code )
		WHERE SC.student_id IS NULL AND
			  SC.student_id = @Student_ID AND
		      S.major = c.major 
	 ) AS c1
	   WHERE (c1.start_date < @sdate AND c1.end_date < @edate )   OR   -- course based
			  c1.grade < 50                                            -- failed
	   
GO 
EXEC Procedures_ViewRequiredCourses @Student_ID = 1 , @Current_semester_code= 'Spring 2023 à S23'  ;

GO

-- MM) Check again
CREATE PROCEDURE Procedures_ViewOptionalCourse
	 @Student_ID int,
	 @Current_semester_code Varchar(40)
	AS
	DECLARE @sdate DATE ;
	DECLARE @edate DATE ;
	SELECT @sdate=start_date , @edate=end_date FROM Semester WHERE semester_code = @Current_semester_code ;
 
	
	SELECT c.course_id , c.name , c.major ,c.is_offered ,c.credit_hours ,c.semester
	FROM (((((Course c LEFT JOIN PreqCourse_course PC ON c.course_id = PC.course_id )
					   LEFT JOIN Student_Instructor_Course_Take SC ON SC.course_id = c.course_id)
			           INNER JOIN Student S ON S.student_id = SC.student_id )
			           INNER JOIN Course_Semester CS ON c.course_id = CS.course_id)
			           INNER JOIN Semester SE ON CS.semester_code = SE.semester_code )
	WHERE SC.student_id IS NULL AND
	      ( PC.prerequisite_course_id IS NULL OR PC.prerequisite_course_id IN 
												 (
													SELECT course_id
													FROM  Student_Instructor_Course_Take
													WHERE student_id = @Student_ID
												 )
          ) AND
		  S.major = c.major AND
		  (SE.end_date > @edate OR --course in later semetser
		   (SE.end_date < @edate AND SE.start_date > @sdate))	 --course in current semester 
GO
EXEC Procedures_ViewOptionalCourse @Student_ID = 1 , @Current_semester_code= 'Spring 2023 à S23'  ;

GO

-- NN) 
CREATE PROCEDURE Procedures_ViewMS
	@StudentID int
	AS
	DECLARE @s_major VARCHAR(20) ;
	SELECT @s_major = major FROM Student WHERE student_id = @StudentID

	(SELECT * FROM Course c WHERE c.major = @s_major ) 
	EXCEPT 
	(SELECT c1.course_id , c1.credit_hours ,c1.is_offered ,c1.major ,c1.name ,c1.semester
	 FROM Student_Instructor_Course_Take SC INNER JOIN Student S ON S.student_id = SC.student_id 
		  INNER JOIN Course c1 ON c1.course_id = SC.course_id
	 WHERE c1.major  = S.major AND SC.student_id = @StudentID 
	)

	--SELECT c.course_id , c.name , c.major ,c.is_offered ,c.credit_hours ,c.semester
	--FROM ((Course c LEFT JOIN Student_Instructor_Course_Take SC ON c.course_id = SC.course_id)
	--	   INNER JOIN Student S ON S.student_id = SC.student_id)  
	--WHERE SC.student_id IS NULL AND
	--	  SC.student_id = @Student_ID AND
	--	  S.major = c.major 	  
GO
EXEC Procedures_ViewMS @StudentID=1 ;
GO

-- OO)
CREATE PROCEDURE Procedures_ChooseInstructor
	 @StudentID int, 
	 @InstructorID int,
	 @CourseID int
	 AS
	 INSERT INTO Student_Instructor_Course_Take (student_id ,course_id ,instructor_id) 
	 VALUES (@StudentID ,@CourseID , @InstructorID) ;
GO
EXEC Procedures_ChooseInstructor  @StudentID=1, @InstructorID=1 ,@CourseID=1 ;
GO

