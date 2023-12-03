EXEC Procedures_AdminIssueInstallment
@paymentID = 11 ;
EXEC Procedures_AdminDeleteCourse
@courseID = 5678;
EXEC Procedure_AdminUpdateStudentStatus
@StudentID = 910 ;
SELECT * FROM all_Pending_Requests
EXEC Procedures_AdminDeleteSlots
@current_semester = '7aseb keda'

EXEC Procedures_AdvisorCreateGP
@expected_graduation_date = '2003-4-1',
@sem_credit_hours= 2 ,
@Semestercode = 'W22',
@advisorid = 1 ,
@studentid = 1 ;

EXEC Procedures_AdvisorAddCourseGP
@student_Id = 342 ,
@Semester_code = 'jh322' ,
@course_name = 'lol' ;

EXEC Procedures_AdvisorDeleteFromGP
@student_Id = 342 ,
@Semester_code = 'jh322' ,
@course_name = 'lol' ;
--next precedure will cause an error 
--waiting for the Q&A response
EXEC Procedures_AdvisorUpdateGP
@studentID = 3 ,
@expected_grad_date = '2003-4-1'


DROP PROC Procedures_AdminIssueInstallment
DROP PROC Procedures_AdminDeleteCourse
DROP VIEW all_Pending_Requests
DROP PROC Procedures_AdminDeleteSlots
DROP PROC Procedures_AdvisorCreateGP
DROP PROC Procedures_AdvisorAddCourseGP
DROP PROC Procedures_AdvisorUpdateGP
DROP PROC Procedures_AdvisorDeleteFromGP
DROP FUNCTION FN_AdvisorLogin 


EXEC CreateAllTables