CREATE DATABASE Advising_Team_13 ;
DROP DATABASE Advising_Team_13 ;

EXEC CreateAllTables;
EXEC DropAllTables;
EXEC clearAllTables;


DROP PROCEDURE CreateAllTables;
DROP PROC DropAllTables;
DROP PROC clearAllTables;
DROP FUNCTION CALC_STUDENT_FINANTIAL_STATUS_HELPER
DROP PROC Procedure_AdminUpdateStudentStatus

EXEC Procedure_AdminUpdateStudentStatus 
@StudentID =1


EXEC Procedures_StudentRegisterFirstMakeup 
@StudentID = 1 ,  
@courseID= 1 ,
@studentCurrentsemester = 'W23'  ;
EXEC Procedures_StudentRegisterSecondMakeup 
@StudentID = 1 ,  
@courseID= 1 ,
@Student_Current_Semester = 'W23'  ;
EXEC Procedures_ViewRequiredCourses 
@Student_ID = 1 , 
@Current_semester_code= 'W23'  ;
EXEC Procedures_ViewOptionalCourse 
@Student_ID = 2 , 
@Current_semester_code= 'W23'  ;
EXEC Procedures_ViewMS 
@StudentID=1 ;
EXEC Procedures_ChooseInstructor  
@StudentID=1, 
@InstructorID=1 ,
@CourseID=1 ,
@current_semester_code ='W23';



DROP FUNCTION FN_IS_COURSE_OFFERED_HELPER
DROP FUNCTION FN_FIND_OPTIONAL_Courses_HELPER
DROP FUNCTION FN_FIND_REQ_Courses_HELPER
DROP FUNCTION FN_IS_prerequisite_Courses_TAKEN_HELPER
DROP FUNCTION FN_num_of_falied_courses_HELPER
DROP FUNCTION FN_StudentViewGP ;
DROP FUNCTION FN_StudentUpcoming_installment ;
DROP FUNCTION FN_StudentViewSlot ;
DROP FUNCTION FN_StudentCheckSMEligiability
DROP PROCEDURE Procedures_StudentRegisterFirstMakeup ;
DROP PROCEDURE Procedures_StudentRegisterSecondMakeup
DROP PROCEDURE  Procedures_ViewRequiredCourses ;
DROP PROCEDURE Procedures_ViewOptionalCourse
DROP PROCEDURE Procedures_ViewMS
DROP PROCEDURE Procedures_ChooseInstructor
