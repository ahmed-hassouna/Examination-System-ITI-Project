--===========================================================================  
-- View: v_StudentDetails  
-- Shows all students with branch, department, track, and intake info  
--===========================================================================  
Create Or Alter View dbo.v_StudentDetails
As
Select 
    S.StudentID,
    P.FName + ' ' + P.LName As StudentName,
    S.GPA,
    S.MaritalStatus,
    S.MilitaryStatus,
    S.Faculty,
    S.EnrollmentDate,
    S.GraduationYear,
    B.BranchName,
	B.BranchID,
    D.DepartmentName,
	D.DepartmentID,
    T.TrackName,
	T.TrackID,
    I.IntakeName,
	I.IntakeID
From Student S
Join Person P On S.PersonID = P.PersonID
Join BranchIntakeTrack BIT On S.BIT_ID = BIT.BIT_ID
Join Branch B On BIT.BranchID = B.BranchID
Join Track T On BIT.TrackID = T.TrackID
Join Department D On T.DepartmentID = D.DepartmentID
Join Intake I On BIT.IntakeID = I.IntakeID;
Go




--===========================================================================  
-- View: v_ManagerDetails  
-- Shows all managers with personal info and assigned branch  
--===========================================================================  
Create Or Alter View dbo.v_ManagerDetails
As
Select 
    M.ManagerID,
    P.FName + ' ' + P.LName As ManagerName,
    P.Email,
    P.PhoneNumber,
    M.Salary,
    M.HireDate,
    M.ExperienceYears,
    B.BranchID,
    B.BranchName
From Manager M
Join Person P On M.PersonID = P.PersonID
Join Branch B On B.BranchManagerID = M.ManagerID;
Go



--===========================================================================  
-- View: v_InstructorDetails  
-- Shows all instructors with personal, branch, and department info  
--===========================================================================  
Create Or Alter View v_InstructorDetails
As
Select 
    I.InstructorID,
    P.FName + ' ' + P.LName As InstructorName,
    P.PhoneNumber,
    P.Email,
    P.Gender,
    P.DateOfBirth,
    D.DepartmentID,
    D.DepartmentName,
    B.BranchID,
    B.BranchName,
    I.HireDate,
    I.Salary,
    I.ExperienceYears
From Instructor I
Join Person P On I.PersonID = P.PersonID
Join BranchIntakeTrack BIT On I.BIT_ID = BIT.BIT_ID
Join Branch B On BIT.BranchID = B.BranchID
Join Track T On BIT.TrackID = T.TrackID
Join Department D On T.DepartmentID = D.DepartmentID
Go



--===========================================================================  
-- View: v_AllBranchesDetails  
-- Shows all branches with related department, track, and intake info  
--===========================================================================  
Create Or Alter View v_AllBranchesDetails
As
Select 
    BIT.BIT_ID,
    B.BranchID,
    B.BranchName,
    B.BranchManagerID,
    D.DepartmentID,
    D.DepartmentName,
    T.TrackID,
    T.TrackName,
    I.IntakeID,
    I.IntakeName,
    I.StartDate,
    I.EndDate,
    I.Year
From BranchIntakeTrack BIT
Join Branch B On BIT.BranchID = B.BranchID
Join Track T On BIT.TrackID = T.TrackID
Join Department D On T.DepartmentID = D.DepartmentID
Join Intake I On BIT.IntakeID = I.IntakeID;
Go

--=================================
--view student answers
--=================================
CREATE OR ALTER VIEW dbo.vw_StudentAnswers
AS
SELECT 
    seq.SEQ,
    seq.StudentID,
    CONCAT(p.FName, ' ', p.LName) AS StudentFullName,
    seq.ExamID,
    e.ExamType,
    e.CourseID,
    c.CourseName,
    q.QuestionID,
    q.QuestionText,
    q.QuestionType,
    tq.BestTextAnswer AS ModelAnswer,   -- only applies to text questions
    seq.StudentQAnswer,
    seq.AnswerIsValid,
    seq.StudentQGrade
FROM dbo.StudentExamQuestion AS seq
JOIN dbo.Student          AS s  ON seq.StudentID  = s.StudentID
JOIN dbo.Person           AS p  ON s.PersonID     = p.PersonID
JOIN dbo.Exam             AS e  ON seq.ExamID     = e.ExamID
JOIN dbo.Course           AS c  ON e.CourseID     = c.CourseID
JOIN dbo.Question         AS q  ON seq.QuestionID = q.QuestionID
LEFT JOIN dbo.TextQuestion AS tq ON q.QuestionID  = tq.QuestionID;


-- ===============================================
-- View: vw_CurrentStudentExamQuestions
-- Purpose: Show all questions for the current student's exams including choices (aggregated)
-- ===============================================
Create Or Alter View dbo.vw_CurrentStudentExamQuestions
As
Select 
    Q.QuestionID,
    Q.QuestionText,
    Q.QuestionType,
    Q.QuestionMark,
    String_Agg(Cast(C.ChoiceText As Nvarchar(Max)), ' | ') As Choices
From StudentExam SE
Join Exam E 
    On SE.ExamID = E.ExamID
Join ExamQuestion EQ 
    On E.ExamID = EQ.ExamID
Join Question Q 
    On EQ.QuestionID = Q.QuestionID
Left Join Choices C 
    On Q.QuestionID = C.QuestionID
Where SE.StudentID = dbo.GetCurrentStudentID()                                     
Group By Q.QuestionID, Q.QuestionText, Q.QuestionType, Q.QuestionMark;
Go
