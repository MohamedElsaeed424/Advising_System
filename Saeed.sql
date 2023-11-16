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
	DECLARE @num_failed_courses INT ,
	        @IF_course_firstMakeup INT ,
	        @sdate DATE ,
            @edate DATE ,
	        @IS_SecoundMakeup_Eligible BIT 

	SET @IS_SecoundMakeup_Eligible = dbo.FN_StudentCheckSMEligiability(@courseID,@StudentID  )

	IF @IS_SecoundMakeup_Eligible = 0
		BEGIN PRINT('YOU CANT REGISTER FOR THE SECOUND MAKEUP ') END
	ELSE
		BEGIN
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


















--------------------------------------------------Courses Procedures---------------------------------------------------------------------------

-- LL) 
CREATE PROCEDURE  Procedures_ViewRequiredCourses
	 @Student_ID int,
	 @Current_semester_code Varchar (40)
	 AS 
	 SELECT c1.course_id , c1.name , c1.major ,c1.is_offered ,c1.credit_hours ,c1.semester
	 FROM ( Course c1 INNER JOIN Student_Instructor_Course_Take SC ON c1.course_id = SC.course_id
					  INNER JOIN Student S ON SC.student_id = S.student_id )
	 WHERE  S.student_id = @Student_ID AND
			c1.semester <= S.semester AND
		    ( SC.grade = 'F' OR SC.grade ='FF' OR SC.grade IS NULL ) AND               -- check for grade
			dbo.FN_IS_COURSE_OFFERED_HELPER(c1.course_id , @Current_semester_code) = 1 --check if course offered in current semester
GO 
EXEC Procedures_ViewRequiredCourses @Student_ID = 1 , @Current_semester_code= 'Spring 2023 à S23'  ;
GO

GO
-- MM) Check again
CREATE PROCEDURE Procedures_ViewOptionalCourse
	 @Student_ID int,
	 @Current_semester_code Varchar(40)
	AS
	SELECT c.course_id , c.name , c.major ,c.is_offered ,c.credit_hours ,c.semester
	FROM Course c 
	WHERE dbo.FN_IS_COURSE_OFFERED_HELPER(c.course_id , @Current_semester_code) = 1 AND  -- course is offered 
		  dbo.FN_IS_prerequisite_Courses_TAKEN_HELPER(@Student_ID , c.course_id) =1 AND  -- Took all prerequisite
		  NOT EXISTS  ( SELECT * FROM dbo.FN_FIND_REQ_Courses_HELPER (@Student_ID   , @Current_semester_code  , c.course_id))  --not required
GO
EXEC Procedures_ViewOptionalCourse @Student_ID = 1 , @Current_semester_code= 'Spring 2023 à S23'  ;
GO

-- NN) 
CREATE PROCEDURE Procedures_ViewMS
	@StudentID int
	AS
	(SELECT * FROM Course c ) 
	EXCEPT 
	(SELECT c1.course_id , c1.credit_hours ,c1.is_offered ,c1.major ,c1.name ,c1.semester
	 FROM   Student_Instructor_Course_Take SC INNER JOIN Student S ON S.student_id = SC.student_id 
											  INNER JOIN Course c1 ON c1.course_id = SC.course_id
	 WHERE  SC.student_id = @StudentID AND
			c1.major = S.major
	)	  
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

---------------------------------------------------------------HELPER FUNCTIONS-------------------------------------------------------


GO
CREATE FUNCTION FN_IS_COURSE_OFFERED_HELPER (@CourseID INT , @Current_Semester_Code VARCHAR(40) )
	RETURNS BIT 
	AS
	BEGIN 
	DECLARE @Is_offered BIT ,
			@course_semester INT 
		SELECT @course_semester=semester  FROM Course WHERE course_id = @CourseID
		IF( @course_semester % 2 = 0 AND( @Current_Semester_Code LIKE 'Spring%' OR @Current_Semester_Code LIKE 'Summer%Round 2%' ) )
			BEGIN  SET @Is_offered = 1 END
		ELSE IF( @course_semester % 2 <> 0 AND( @Current_Semester_Code LIKE 'Winter%' OR @Current_Semester_Code LIKE 'Summer%Round 1%' ) )
		    BEGIN  SET @Is_offered = 1 END
		ELSE
			BEGIN  SET @Is_offered  = 0 END
	RETURN @Is_offered ;
END
GO


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
				( SC.grade = 'F' OR SC.grade ='FF' OR SC.grade IS NULL ) AND               -- check for grade
				dbo.FN_IS_COURSE_OFFERED_HELPER(c1.course_id , @Current_semester_code) = 1 
		
GO
SELECT * FROM FN_FIND_prerequisite_Courses_HELPER(1);
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
										INNER JOIN Student_Instructor_Course_Take SC ON SC.course_id = c.course_id )
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