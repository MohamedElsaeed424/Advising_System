-- Adding 10 records to the Course table
INSERT INTO Course VALUES
(1, 'Mathematics', 'Science', 1, 3, 1),
(2, 'Computer Science', 'Engineering', 1, 4, 1),
(3, 'History', 'Arts', 1, 3, 2),
(4, 'Physics', 'Science', 0, 4, 2),
(5, 'Literature', 'Arts', 1, 3, 1),
(6, 'Chemistry', 'Science', 1, 4, 2),
(7, 'Programming', 'Engineering', 1, 3, 1),
(8, 'Philosophy', 'Arts', 0, 3, 2),
(9, 'Economics', 'Social Science', 1, 4, 2),
(10, 'Psychology', 'Social Science', 1, 3, 1);


-- Adding 10 records to the Instructor table
INSERT INTO Instructor VALUES
(1, 'Professor Smith', 'prof.smith@example.com', 'Computer Science', 'Office A'),
(2, 'Professor Johnson', 'prof.johnson@example.com', 'Computer Science', 'Office B'),
(3, 'Professor Brown', 'prof.brown@example.com', 'Literature', 'Office C'),
(4, 'Professor White', 'prof.white@example.com', 'Physics', 'Office D'),
(5, 'Professor Taylor', 'prof.taylor@example.com', 'Computer Science', 'Office E'),
(6, 'Professor Black', 'prof.black@example.com', 'Philosophy', 'Office F'),
(7, 'Professor Lee', 'prof.lee@example.com', 'Chemistry', 'Office G'),
(8, 'Professor Miller', 'prof.miller@example.com', 'Psychology', 'Office H'),
(9, 'Professor Davis', 'prof.davis@example.com', 'Fine Arts', 'Office I'),
(10, 'Professor Moore', 'prof.moore@example.com', 'Mathematics', 'Office J');

-- Adding 10 records to the Semester table
INSERT INTO Semester VALUES
('W23', '2023-01-01', '2023-03-31'),
('S23', '2023-04-01', '2023-06-30'),
('S23R1', '2023-07-01', '2023-07-15'),
('S23R2', '2023-07-16', '2023-07-31'),
('F23', '2023-08-01', '2023-12-31'),
('W24', '2024-01-01', '2024-03-31'),
('S24', '2024-04-01', '2024-06-30'),
('S24R1', '2024-07-01', '2024-07-15'),
('S24R2', '2024-07-16', '2024-07-31'),
('F24', '2024-08-01', '2024-12-31');

-- Adding 10 records to the Advisor table
INSERT INTO Advisor VALUES
(1, 'Dr. Anderson', 'anderson@example.com', 'Office A', 'password1'),
(2, 'Prof. Baker', 'baker@example.com', 'Office B', 'password2'),
(3, 'Dr. Carter', 'carter@example.com', 'Office C', 'password3'),
(4, 'Prof. Davis', 'davis@example.com', 'Office D', 'password4'),
(5, 'Dr. Evans', 'evans@example.com', 'Office E', 'password5'),
(6, 'Prof. Foster', 'foster@example.com', 'Office F', 'password6'),
(7, 'Dr. Green', 'green@example.com', 'Office G', 'password7'),
(8, 'Prof. Harris', 'harris@example.com', 'Office H', 'password8'),
(9, 'Dr. Irving', 'irving@example.com', 'Office I', 'password9'),
(10, 'Prof. Johnson', 'johnson@example.com', 'Office J', 'password10');

-- Adding 10 records to the Student table
INSERT INTO Student VALUES
(1, 'John', 'Doe', 3.5, 'Computer Science', 'john.doe@example.com', 'CS', 'password123', 1, 1, 90, NULL, 1),
(2, 'Jane', 'Smith', 3.8, 'Mathematics', 'jane.smith@example.com', 'Math', 'password456', 1, 2, 85, NULL, 2),
(3, 'Mike', 'Johnson', 3.2, 'Physics', 'mike.johnson@example.com', 'Physics', 'password789', 1, 3, 75, NULL, 3),
(4, 'Emily', 'White', 3.9, 'Computer Science', 'emily.white@example.com', 'CS', 'passwordabc', 0, 4, 95, NULL, 4),
(5, 'David', 'Lee', 3.4, 'Psychology', 'david.lee@example.com', 'Psych', 'passworddef', 1, 5, 80, NULL, 5),
(6, 'Grace', 'Brown', 3.7, 'Literature', 'grace.brown@example.com', 'Lit', 'passwordghi', 0, 6, 88, NULL, 6),
(7, 'Robert', 'Miller', 3.1, 'Chemistry', 'robert.miller@example.com', 'Chem', 'passwordjkl', 1, 7, 78, NULL, 7),
(8, 'Sophie', 'Clark', 3.6, 'Psychology', 'sophie.clark@example.com', 'Psych', 'passwordmno', 1, 8, 92, NULL, 8),
(9, 'Daniel', 'Wilson', 3.3, 'Fine Arts', 'daniel.wilson@example.com', 'Fine Arts', 'passwordpqr', 1, 9, 87, NULL, 9),
(10, 'Olivia', 'Anderson', 3.7, 'Computer Science', 'olivia.anderson@example.com', 'CS', 'passwordstu', 0, 10, 89, NULL, 10);


-- Adding 10 records to the Student_Phone table
INSERT INTO Student_Phone VALUES
(1, '123-456-7890'),
(2, '234-567-8901'),
(3, '345-678-9012'),
(4, '456-789-0123'),
(5, '567-890-1234'),
(6, '678-901-2345'),
(7, '789-012-3456'),
(8, '890-123-4567'),
(9, '901-234-5678'),
(10, '012-345-6789');


-- Adding 10 records to the PreqCourse_course table
INSERT INTO PreqCourse_course VALUES
(1, 2),
(3, 5),
(2, 4),
(5, 6),
(4, 7),
(6, 8),
(7, 9),
(8, 10),
(9, 1),
(10, 3);


-- Adding 10 records to the Instructor_Course table
INSERT INTO Instructor_Course VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);


-- Adding 10 records to the Student_Instructor_Course_Take table
INSERT INTO Student_Instructor_Course_Take VALUES
(1, 1, 1, 'W23', 'Normal', 'A'),
(2, 2, 2, 'S23', 'First_makeup', 'B'),
(3, 3, 3, 'S23R1', 'Second_makeup', 'C'),
(4, 4, 4, 'S23R2', 'Normal', 'B+'),
(5, 5, 5, 'F23', 'Normal', 'A-'),
(6, 6, 6, 'W24', 'First_makeup', 'B'),
(7, 7, 7, 'S24', 'Second_makeup', 'C+'),
(8, 8, 8, 'S24R1', 'Normal', 'A+'),
(9, 9, 9, 'S24R2', 'Normal', 'A'),
(10, 10, 10, 'F24', 'First_makeup', 'B-');



-- Adding 10 records to the Course_Semester table
INSERT INTO Course_Semester VALUES
(1, 'W23'),
(2, 'S23'),
(3, 'S23R1'),
(4, 'S23R2'),
(5, 'F23'),
(6, 'W24'),
(7, 'S24'),
(8, 'S24R1'),
(9, 'S24R2'),
(10, 'F24');

-- Adding 10 records to the Slot table
INSERT INTO Slot VALUES
(1, 'Monday', '10:00 AM', 'Room A', 1, 1),
(2, 'Tuesday', '02:00 PM', 'Room B', 2, 2),
(3, 'Wednesday', '11:30 AM', 'Room C', 3, 3),
(4, 'Thursday', '01:00 PM', 'Room D', 4, 4),
(5, 'Friday', '09:00 AM', 'Room E', 5, 5),
(6, 'Monday', '03:30 PM', 'Room F', 6, 6),
(7, 'Tuesday', '12:00 PM', 'Room G', 7, 7),
(8, 'Wednesday', '02:30 PM', 'Room H', 8, 8),
(9, 'Thursday', '10:30 AM', 'Room I', 9, 9),
(10, 'Friday', '04:00 PM', 'Room J', 10, 10);


-- Adding 10 records to the Graduation_Plan table
INSERT INTO Graduation_Plan VALUES
(1, 'W23', 90, 'S24', 1, 1),
(2, 'S23', 85, 'F24', 2, 2),
(3, 'S23R1', 75, 'W24', 3, 3),
(4, 'S23R2', 95, 'S24R1', 4, 4),
(5, 'F23', 80, 'S24R2', 5, 5),
(6, 'W24', 88, 'F24', 6, 6),
(7, 'S24', 78, 'S24R1', 7, 7),
(8, 'S24R1', 92, 'S24R2', 8, 8),
(9, 'S24R2', 87, 'F24', 9, 9),
(10, 'F24', 89, 'W24', 10, 10);

-- Adding 10 records to the GradPlan_Course table
INSERT INTO GradPlan_Course VALUES
(1, 'W23', 1),
(2, 'S23', 2),
(3, 'S23R1', 3),
(4, 'S23R2', 4),
(5, 'F23', 5),
(6, 'W24', 6),
(7, 'S24', 7),
(8, 'S24R1', 8),
(9, 'S24R2', 9),
(10, 'F24', 10);

-- Adding 10 records to the Request table
INSERT INTO Request VALUES
(1, 'course', 'Request for additional course', 'pending', 3, 1, 1, NULL),
(2, 'course', 'Need to change course', 'approved', 4, 2, 2, 2),
(3, 'credit hours', 'Request for extra credit hours', 'pending', 6, 3, 3, NULL),
(4, 'credit hours', 'Request for reduced credit hours', 'approved', 9, 4, 4, NULL),
(5, 'course', 'Request for special course', 'rejected', 3, 5, 5, 5),
(6, 'credit hours', 'Request for extra credit hours', 'pending', 4, 6, 6, NULL),
(7, 'course', 'Request for course withdrawal', 'approved', 3, 7, 7, 7),
(8, 'course', 'Request for course addition', 'rejected', 4, 8, 8, 8),
(9, 'credit hours', 'Request for reduced credit hours', 'approved', 5, 9, 9, NULL),
(10, 'course', 'Request for course substitution', 'pending', 4, 10, 10, 10);

-- Adding 10 records to the MakeUp_Exam table
INSERT INTO MakeUp_Exam VALUES
(1, '2023-05-10', 'Midterm', 1),
(2, '2023-06-15', 'Final', 2),
(3, '2023-07-05', 'Midterm', 3),
(4, '2023-07-25', 'Final', 4),
(5, '2023-09-05', 'Midterm', 5),
(6, '2024-03-10', 'Final', 6),
(7, '2024-05-20', 'Midterm', 7),
(8, '2024-06-05', 'Final', 8),
(9, '2024-07-10', 'Midterm', 9),
(10, '2024-12-15', 'Final', 10);

-- Adding 10 records to the Exam_Student table
INSERT INTO Exam_Student VALUES (1, 1, 1);
INSERT INTO Exam_Student VALUES (1, 2, 1);
INSERT INTO Exam_Student VALUES (1, 3, 1);
INSERT INTO Exam_Student VALUES (2, 2, 1);
INSERT INTO Exam_Student VALUES (2, 3, 1);
INSERT INTO Exam_Student VALUES (2, 4, 1);
INSERT INTO Exam_Student VALUES (3, 3, 2);
INSERT INTO Exam_Student VALUES (3, 4, 2);
INSERT INTO Exam_Student VALUES (3, 5, 2);
INSERT INTO Exam_Student VALUES (4, 4, 2);

-- Adding 10 records to the Payment table
INSERT INTO Payment VALUES
(1, 500, '2023-11-22', 3, 'notPaid', 50.00, 1, 'W23', '2023-11-22'),
(2, 700, '2023-11-23', 4, 'notPaid', 60.00, 2, 'S23', '2023-11-23'),
(3, 600, '2023-11-24', 2, 'notPaid', 40.00, 3, 'S23R1', '2023-11-24'),
(4, 800, '2023-11-25', 3, 'notPaid', 70.00, 4, 'S23R2', '2023-11-25'),
(5, 550, '2023-11-26', 4, 'notPaid', 45.00, 5, 'F23', '2023-11-26'),
(6, 900, '2023-11-27', 2, 'notPaid', 80.00, 6, 'W24', '2023-11-27'),
(7, 750, '2023-11-28', 3, 'notPaid', 65.00, 7, 'S24', '2023-11-28'),
(8, 620, '2023-11-29', 4, 'notPaid', 55.00, 8, 'S24R1', '2023-11-29'),
(9, 720, '2023-11-30', 2, 'notPaid', 75.00, 9, 'S24R2', '2023-11-30'),
(10, 580, '2023-12-01', 3, 'notPaid', 47.00, 10, 'F24', '2023-12-01');


-- Adding 10 records to the Installment table
INSERT INTO Installment VALUES
(1, '2023-12-01', 50, 'pending', '2023-12-01'),
(2, '2023-12-02', 70, 'pending', '2023-12-02'),
(3, '2023-12-03', 60, 'pending', '2023-12-03'),
(4, '2023-12-04', 80, 'pending', '2023-12-04'),
(5, '2023-12-05', 55, 'pending', '2023-12-05'),
(6, '2023-12-06', 90, 'pending', '2023-12-06'),
(7, '2023-12-07', 75, 'pending', '2023-12-07'),
(8, '2023-12-08', 62, 'pending', '2023-12-08'),
(9, '2023-12-09', 72, 'pending', '2023-12-09'),
(10, '2023-12-10', 58, 'pending', '2023-12-10');