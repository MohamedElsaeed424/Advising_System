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
		   (SE.end_date < @enddate AND SE.start_date > @sdate))	 --course in current semester 
GO
EXEC Procedures_ViewOptionalCourse @Student_ID = 1 , @Current_semester_code= 'Spring 2023 à S23'  ;

GO

-- NN)
CREATE PROCEDURE Procedures_ViewMS
	@Student_ID int
	AS
	SELECT c.course_id , c.name , c.major ,c.is_offered ,c.credit_hours ,c.semester
	FROM ((Course c LEFT JOIN Student_Instructor_Course_Take SC ON c.course_id = SC.course_id)
		   INNER JOIN Student S ON S.student_id = SC.student_id)  
	WHERE SC.student_id IS NULL AND
		  SC.student_id = @Student_ID AND
		  S.major = c.major 	  
GO
EXEC Procedures_ViewMS @Student_ID=1 ;


GO



-- OO)
CREATE PROCEDURE Procedures_ChooseInstructor
	 @Student_ID int, 
	 @Instructor_ID int,
	 @Course_ID int
	 AS
	 INSERT INTO Student_Instructor_Course_Take (student_id ,course_id ,instructor_id) 
	 VALUES (@Student_ID ,@Course_ID , @Instructor_ID) ;
GO
EXEC Procedures_ChooseInstructor  @Student_ID=1, @Instructor_ID=1 ,@Course_ID=1 ;


GO

