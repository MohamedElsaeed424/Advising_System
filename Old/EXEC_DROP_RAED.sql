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
	@start_date = '2003-01-24',
	@end_date = '2075-01-24' ,
	@semester_code = 'W23sdd3';
EXEC Procedures_AdminAddingCourse
	@major = 'MET',
	@semester = 1,
	@credit_hours = 4,
	@name ='dodo',
	@is_offered =0;
EXEC Procedures_AdminLinkInstructor
	@instructor_id = 1,
	@course_id = 1,
	@slot_id = 1;
EXEC Procedures_AdminLinkStudent
	@instructor_id = 1,
	@student_id = 1,
	@course_id = 1,
	@semester_code = 'W43d3';
EXEC Procedures_AdminLinkStudentToAdvisor
	@student_id =1,
	@advisor_id =1;
EXEC Procedures_AdminAddExam 
	@Type = 'EXAM',
	@date = '2023-11-23' ,
	@course_id =1;

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

