﻿CREATE DATABASE Advising_Team_13 ;
USE Advising_Team_13;


EXEC CreateAllTables;
EXEC DropAllTables;
EXEC clearAllTables;



EXEC Procedure_AdminUpdateStudentStatus 
@StudentID =1
--------------------------------------------

SELECT * FROM  view_Students ;
SELECT * FROM  view_Course_prerequisites;
SELECT * FROM  Instructors_AssignedCourses;
SELECT * FROM  Student_Payment;
SELECT * FROM  Courses_Slots_Instructor;
SELECT * FROM  Courses_MakeupExams;
SELECT * FROM  Students_Courses_transcript;
SELECT * FROM  Semster_offered_Courses;
SELECT * FROM  Advisors_Graduation_Plan;

DECLARE 
	 @Student_id INT;
EXEC Procedures_StudentRegistration 
	 @first_name = 'mohammed' ,
	 @last_name = 'saeed' ,
	 @password = 'password321' ,
	 @faculty = 'Engineering' ,
	 @email  = 'dasf@gam.to' ,
	 @major = 'MET' ,
	 @Semester = 1 ,
	 @student_id = @Student_id OUTPUT;
Print @Student_id



------------------------------------------

DECLARE 
	 @result INT;
EXEC Procedures_AdvisorRegistration 
	 @name = 'RAEDD',
	 @password = 'JOUMAA',
	 @email = 'HOTMdddwwddddAIL@gmail.com',
	 @office = 'C6205',
	 @advisor_id = @result OUTPUT;

EXEC Procedures_AdminListStudents;
EXEC Procedures_AdminListAdvisors;
EXEC AdminListStudentsWithAdvisors;
EXEC AdminAddingSemester
	@start_date = '2013-01-24',
	@end_date = '2075-01-24' ,
	@semester_code = 'W30';
EXEC Procedures_AdminAddingCourse
	@major = 'MET',
	@semester = 4,
	@credit_hours = 4,
	@name ='CSEN 40',
	@is_offered =0;
EXEC Procedures_AdminLinkInstructor
	@instructor_id = 1,
	@course_id = 1,
	@slot_id = 1;
EXEC Procedures_AdminLinkStudent
	@instructor_id = 1,
	@student_id = 1,
	@course_id = 1,
	@semester_code = 'W23';
EXEC Procedures_AdminLinkStudentToAdvisor
	@student_id =1,
	@advisor_id =1;
EXEC Procedures_AdminAddExam 
	@Type = 'Normal',
	@date = '2023-11-23' ,
	@course_id =1;


EXEC Procedures_AdminIssueInstallment
@paymentID = 11 ;
EXEC Procedures_AdminDeleteCourse
@courseID = 5;
EXEC Procedure_AdminUpdateStudentStatus
@StudentID = 5 ;
SELECT * FROM all_Pending_Requests
EXEC Procedures_AdminDeleteSlots
@current_semester = 'W23'
PRINT 'CHECK' -----------------------------------------

DECLARE @y BIT
SET @y = dbo.FN_AdvisorLogin(2,'password')
Print @y

EXEC Procedures_AdvisorCreateGP
@expected_graduation_date = '2003-4-1',
@sem_credit_hours= 2 ,
@Semestercode = 'W23',
@advisorid = 1 ,
@studentid = 11 ;

EXEC Procedures_AdvisorAddCourseGP
@student_Id = 11 ,
@Semester_code = 'W23' ,
@course_name = 'CSEN 2' ;

--next precedure will cause an error 
--waiting for the Q&A response
EXEC Procedures_AdvisorUpdateGP
@studentID = 3 ,
@expected_grad_date = '2003-4-1'

EXEC Procedures_AdvisorDeleteFromGP
@studentID = 2 ,
@semesterCode = 'W23' ,
@courseID = 2 ;
PRINT 'MID' ----------------------------------

-----------------------------------------------

--V
SELECT * FROM FN_Advisors_Requests(8)
--W
EXEC Procedures_AdvisorApproveRejectCHRequest @RequestID=3, @current_semester_code = 'W24'
--X
EXEC Procedures_AdvisorViewAssignedStudents @AdvisorID=10, @major='Mechatronics'
--Y
EXEC Procedures_AdvisorApproveRejectCourseRequest @RequestID=1, @current_semester_code = 'W24'
--Z
EXEC Procedures_AdvisorViewPendingRequests @AdvisorID=1
--AA
DECLARE @x INT
SET @x = dbo.FN_StudentLogin(1, 'password123')
PRINT @x
--BB
EXEC Procedures_StudentaddMobile @StudentID=1, @mobile_number='54374'
--CC
SELECT * FROM FN_SemsterAvailableCourses('S23')
--DD
EXEC Procedures_StudentSendingCourseRequest @StudentID=3, @courseID=4, @type='course', @comment='null ba3d keda'
--EE
EXEC Procedures_StudentSendingCHRequest @StudentID=5, @credit_hours=1, @type='credit', @comment='null ba3d keda'



----------------------------------------------------------
SELECT * FROM dbo.FN_StudentViewGP(1)
DECLARE @z DATE
SET @z = dbo.FN_StudentUpcoming_installment(1)
PRINT @z
SELECT * FROM dbo.FN_StudentViewSlot(1,1)
EXEC Procedures_StudentRegisterFirstMakeup
@StudentID = 1 ,  
@courseID= 1 ,
@studentCurrentsemester = 'W23'  ;
DECLARE @a BIT
SET @a = dbo.FN_StudentCheckSMEligiability(1,1)
PRINT @a
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

PRINT 'END' ----------------------------------------

DROP DATABASE Advising_Team_13 ;
--------------------------------------
DROP PROCEDURE CreateAllTables;
DROP PROC DropAllTables;
DROP PROC clearAllTables;
DROP FUNCTION CALC_STUDENT_FINANTIAL_STATUS_HELPER
DROP PROC Procedure_AdminUpdateStudentStatus
---------------------------------
DROP VIEW view_Students ;
DROP VIEW view_Course_prerequisites;
DROP VIEW Instructors_AssignedCourses;
DROP VIEW Student_Payment;
DROP VIEW Courses_Slots_Instructor;
DROP VIEW Courses_MakeupExams;
DROP VIEW Students_Courses_transcript;
DROP VIEW Semster_offered_Courses;
DROP VIEW Advisors_Graduation_Plan;
DROP PROCEDURE Procedures_StudentRegistration;
---------------------------
DROP PROC Procedures_AdvisorRegistration
DROP PROC Procedures_AdminListStudents
DROP PROC Procedures_AdminListAdvisors
DROP PROC AdminListStudentsWithAdvisors
DROP PROC AdminAddingSemester
DROP PROC Procedures_AdminAddingCourse
DROP PROC Procedures_AdminLinkInstructor
DROP PROC Procedures_AdminLinkStudent
DROP PROC Procedures_AdminLinkStudentToAdvisor
DROP PROC Procedures_AdminAddExam
--------------------------
DROP PROC Procedures_AdminIssueInstallment
DROP PROC Procedures_AdminDeleteCourse
DROP VIEW all_Pending_Requests
DROP PROC Procedures_AdminDeleteSlots
DROP PROC Procedures_AdvisorCreateGP
DROP PROC Procedures_AdvisorAddCourseGP
DROP PROC Procedures_AdvisorUpdateGP
DROP PROC Procedures_AdvisorDeleteFromGP
DROP FUNCTION FN_AdvisorLogin 
------------------------
DROP FUNCTION FN_Advisors_Requests
DROP PROC Procedures_AdvisorApproveRejectCHRequest
DROP PROC Procedures_AdvisorViewAssignedStudents
DROP PROC Procedures_AdvisorApproveRejectCourseRequest
DROP PROC Procedures_AdvisorViewPendingRequests
DROP FUNCTION FN_StudentLogin
DROP FUNCTION FN_SemsterAvailableCourses
DROP PROC Procedures_StudentaddMobile
DROP PROC Procedures_StudentSendingCourseRequest
DROP PROC Procedures_StudentSendingCHRequest
---------------------------------------------
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
