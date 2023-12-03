--FF) 
CREATE FUNCTION FN_StudentViewGP (@student_ID int) 
RETURNS TABLE
AS
RETURN
    SELECT 
		S.student_id                    AS 'Student Id',
		CONCAT(S.f_name, ' ', S.l_name) AS ' Student_name', 
		GP.plan_id                      AS ' graduation Plan Id', 
		c.course_id                     AS 'Course id',
		c.name                          AS 'Course name', 
		GP.semester_code                AS 'Semester code', 
		SE.end_date                     AS 'expected graduation date', --IS this correct ??
		GP.semester_credit_hours        AS 'Semester credit hours', 
		GP.advisor_id                   AS 'advisor id'
    FROM ((Student S INNER JOIN Graduation_Plan GP ON S.student_id = GP.student_id
					INNER JOIN GradPlan_Course GPC ON (GP.plan_id = GPC.plan_id AND GP.semester_code = GPC.semester_code ) )
					INNER JOIN Course c ON GPC.course_id = c.course_id
					INNER JOIN Semester SE ON SE.semester_code = GP.semester_code)
	WHERE S.student_id = @student_ID
-- GG)
GO
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

GO
--II) what is the date of first or secound makeup
CREATE PROCEDURE   Procedures_StudentRegisterFirstMakeup
	@StudentID int, 
	@courseID int, 
	@studentCurrentsemester varchar (40)
	AS
	DECLARE @InstructorID INT ,
			@Grade_Normal_Exam VARCHAR(40) ,
			@IF_course_firstMakeup INT

		SELECT @IF_course_firstMakeup=COUNT(*)
		FROM  Student_Instructor_Course_Take 
		WHERE course_id = @CourseID AND
			  student_id = @StudentID AND
			  semester_code = @studentCurrentsemester AND
			  exam_type LIKE '%makeup%' 
		IF @IF_course_firstMakeup <> 0
			BEGIN PRINT ('YOU CANT REGISTER FOR THE FIRST MAKEUP YOU REGISTERED BEFOR FOR A MAKEUP EXAM') END
		ELSE 
			BEGIN
				SELECT @Grade_Normal_Exam = grade 
				FROM Student_Instructor_Course_Take
				WHERE student_id = @StudentID AND
					  course_id = @courseID AND
					  exam_type = 'Normal' AND
					  semester_code = @studentCurrentsemester 
				IF @Grade_Normal_Exam <> 'FF' OR @Grade_Normal_Exam <> 'F' OR @Grade_Normal_Exam <> 'NULL'
					BEGIN PRINT('YOUR GRADE NOT FF OR F TO REGISTER ON THIS EXAM') END
				ELSE
					BEGIN

						SELECT  @InstructorID = instructor_id 
						FROM Student_Instructor_Course_Take
						WHERE course_id = @courseID  AND
							  student_id = @StudentID
			
						INSERT INTO Student_Instructor_Course_Take (student_id ,course_id ,instructor_id ,semester_code ,exam_type ,grade) 
							   VALUES (@StudentID ,@CourseID , @InstructorID ,@studentCurrentsemester , 'First_makeup' ,  NULL ) ;
					END
			END
-- JJ) 
GO
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

		SET  @num_failed_courses_Even  = dbo.FN_num_of_falied_courses_HELPER ('Spring%' , '%Round 2%'  ,'%R2%' ,  @CourseID  , @StudentID )
		SET  @num_failed_courses_Odd   = dbo.FN_num_of_falied_courses_HELPER ('Winter%'  , '%Round 1%'  ,'%R1%', @CourseID , @StudentID )

		SELECT @IF_course_firstMakeup=COUNT(*)
		FROM  Student_Instructor_Course_Take 
		WHERE course_id = @CourseID AND
			  student_id = @StudentID AND
			  semester_code = @CurrentSemesterCode AND
			  exam_type = 'First_makeup' AND
			  grade IS NOT NULL 

		IF @IF_course_firstMakeup <> 0

			BEGIN SET @IS_Eligible =0 END

		ELSE IF ( @CurrentSemesterCode LIKE 'Spring%' OR @CurrentSemesterCode LIKE '%Round 2%' OR @CurrentSemesterCode LIKE '%R2%'  )
		BEGIN
			IF ( @num_failed_courses_Even < 2  )
				BEGIN SET @IS_Eligible = 1 END
			ELSE 
				BEGIN   
					SET @IS_Eligible = 0 
					-- add course to required courses
				END
				 
		END
		ELSE IF ( @CurrentSemesterCode LIKE 'Winter%' OR @CurrentSemesterCode LIKE '%Round 1%' OR @CurrentSemesterCode LIKE '%R1%' )
		BEGIN
			IF ( @num_failed_courses_Odd < 2  )
				BEGIN SET @IS_Eligible = 1 END
			ELSE 
				BEGIN 
					SET @IS_Eligible = 0 
					-- add course to required courses
				END
		END
    RETURN @IS_Eligible ;
END;

-- KK)
GO
CREATE PROCEDURE  Procedures_StudentRegisterSecondMakeup
	@StudentID int, 
	@courseID int, 
	@Student_Current_Semester Varchar (40)
	AS
	DECLARE @num_failed_courses INT ,
	        @IS_SecoundMakeup_Eligible BIT 
	SET @IS_SecoundMakeup_Eligible = dbo.FN_StudentCheckSMEligiability(@courseID,@StudentID  )

	IF @IS_SecoundMakeup_Eligible = 0
		BEGIN PRINT('YOU CANT REGISTER FOR THE SECOUND MAKEUP ') END
	ELSE
		BEGIN

		-- insert in exam_student and in reg for fisrt makeup

		UPDATE Student_Instructor_Course_Take
		SET exam_type = 'Second_makeup'
		WHERE semester_code = @Student_Current_Semester AND
			  student_id = @StudentID AND
			  course_id = @courseID 
  
		--INSERT INTO Student_Instructor_Course_Take (student_id ,course_id ,instructor_id ,semester_code ,exam_type ,grade) 
		--	   VALUES (@StudentID ,@CourseID , @InstructorID ,@Student_Current_Semester , 'Second_makeup' ,  NULL ) ;
		END	
--------------------------------------------------Courses Procedures---------------------------------------------------------------------------
-- LL) 
GO
CREATE PROCEDURE  Procedures_ViewRequiredCourses
	 @Student_ID int,
	 @Current_semester_code Varchar (40)
	 AS 
	 SELECT c1.course_id , c1.name , c1.major ,c1.is_offered ,c1.credit_hours ,c1.semester
	 FROM ( Course c1 INNER JOIN Student_Instructor_Course_Take SC ON c1.course_id = SC.course_id
					  INNER JOIN Student S ON SC.student_id = S.student_id )
	 WHERE  S.student_id = @Student_ID AND
			c1.semester <= S.semester AND
		    ( SC.grade = 'F' OR SC.grade ='FF' OR SC.grade = 'FA' OR  SC.grade IS NULL ) AND               -- check for grade
			dbo.FN_IS_COURSE_OFFERED_HELPER(c1.course_id , @Current_semester_code) = 1 --check if course offered in current semester
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
-- NN) 
CREATE PROCEDURE Procedures_ViewMS
	@StudentID int
	AS
	(SELECT * FROM Course c ) 
	EXCEPT 
	(SELECT c1.*
	 FROM   Student_Instructor_Course_Take SC INNER JOIN Student S ON S.student_id = SC.student_id 
											  INNER JOIN Course c1 ON c1.course_id = SC.course_id
	 WHERE  SC.student_id = @StudentID AND
			c1.major = S.major
	)
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

---------------------------------------------------------------HELPER FUNCTIONS-------------------------------------------------------
GO
CREATE FUNCTION FN_IS_COURSE_OFFERED_HELPER (@CourseID INT , @Current_Semester_Code VARCHAR(40) )
	RETURNS BIT 
	AS
	BEGIN 
	DECLARE @Is_offered BIT ,
			@course_semester INT 
		SELECT @course_semester=semester  FROM Course WHERE course_id = @CourseID
		IF( @course_semester % 2 = 0 AND( @Current_Semester_Code LIKE 'Spring%' OR @Current_Semester_Code LIKE '%Round 2%'  OR @Current_Semester_Code LIKE '%R2%' ) )
			BEGIN  SET @Is_offered = 1 END
		ELSE IF( @course_semester % 2 <> 0 AND( @Current_Semester_Code LIKE 'Winter%' OR @Current_Semester_Code LIKE '%Round 1%' OR @Current_Semester_Code LIKE '%R1%'  ) )
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

CREATE FUNCTION FN_num_of_falied_courses_HELPER (@Season1 VARCHAR(40) , @Season2 VARCHAR(40) , @Season3 VARCHAR(40),@CourseID INT , @StudentID INT)
	RETURNS INT
	AS
	BEGIN
	DECLARE @Num_of_falied_courses INT
			
		SELECT @Num_of_falied_courses=COUNT(*)
		FROM   Student_Instructor_Course_Take 
		WHERE	course_id = @CourseID AND
				student_id = @StudentID AND
				semester_code LIKE @Season1 OR semester_code LIKE @Season2  OR semester_code LIKE @Season3 AND  
				(grade = 'F' OR grade = 'FF')

	RETURN @Num_of_falied_courses ;
	END  
