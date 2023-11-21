EXEC Procedures_StudentRegisterFirstMakeup 
@StudentID = 1 ,  
@courseID= 1 ,
@studentCurrentsemester = 'Spring 2023 à S23'  ;
EXEC Procedures_StudentRegisterSecondMakeup 
@StudentID = 1 ,  
@courseID= 1 ,
@Student_Current_Semester = 'Spring 2023 à S23'  ;
EXEC Procedures_ViewRequiredCourses 
@Student_ID = 1 , 
@Current_semester_code= 'Spring 2023 à S23'  ;
EXEC Procedures_ViewOptionalCourse 
@Student_ID = 1 , 
@Current_semester_code= 'Spring 2023 à S23'  ;
EXEC Procedures_ViewMS 
@StudentID=1 ;
EXEC Procedures_ChooseInstructor  
@StudentID=1, 
@InstructorID=1 ,
@CourseID=1 ;

DROP FUNCTION FN_StudentViewGP ;
DROP FUNCTION FN_StudentUpcoming_installment ;
DROP FUNCTION FN_StudentViewSlot ;
DROP PROCEDURE Procedures_StudentRegisterFirstMakeup ;
DROP FUNCTION FN_StudentCheckSMEligiability
DROP PROCEDURE Procedures_StudentRegisterSecondMakeup
DROP PROCEDURE  Procedures_ViewRequiredCourses ;
DROP PROCEDURE Procedures_ViewOptionalCourse
DROP PROCEDURE Procedures_ViewMS
DROP PROCEDURE Procedures_ChooseInstructor
DROP FUNCTION FN_IS_COURSE_OFFERED_HELPER
DROP FUNCTION FN_FIND_REQ_Courses_HELPER
DROP FUNCTION FN_IS_prerequisite_Courses_TAKEN_HELPER
DROP FUNCTION FN_num_of_falied_courses_HELPER