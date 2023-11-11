-- NN)
CREATE PROCEDURE Procedures_ViewOptionalCourse
	 @StudentID int,
	 @Current_semester_code Varchar(40)
	AS
	  
GO
EXEC Procedures_ViewOptionalCourse  ;

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

