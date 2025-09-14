--==================================================================================================
-- Function: GetCurrentManagerID  
-- Returns the ManagerID for the logged-in user or 1 for Admin/SuperManager  
--==================================================================================================
Create Or Alter Function dbo.GetCurrentManagerID()
Returns Int
As
Begin
    Declare @ManagerID Int;

    -- Get ManagerID based on logged-in SQL user
    Select @ManagerID = M.ManagerID
    From Manager M
    Join Person P On M.PersonID = P.PersonID
    Join UserAccount U On U.UserID = P.UserID
    Where U.UserName = Suser_Sname();

    -- Return 1 if user is Admin
    If Exists (
        Select 1
        From UserAccount U
        Where U.UserName = Suser_Sname()
          And U.UserID = 1
    )
        Return 1;

    -- Return 1 for special ManagerID = 2
    If @ManagerID = 2
        Return 1;

    -- Otherwise return actual ManagerID
    Return @ManagerID;
End;
Go  




-- =================================================
-- Function to get current instructor ID
-- =================================================
Create Or Alter Function dbo.GetCurrentInstructorID()
Returns Int
As
Begin
    Declare @InstructorID Int;

    Select @InstructorID = I.InstructorID
    From Instructor I
    Join Person P On I.PersonID = P.PersonID
    Join UserAccount U On P.UserID = U.UserID
    Where SUSER_SNAME() = U.UserName;

    Return @InstructorID;
End;
Go




--============================================================================
-- Function: GetCurrentStudentID
-- Purpose: Return the current logged-in student's ID based on SQL Server login
-- ===========================================================================
Create Or Alter Function dbo.GetCurrentStudentID()
Returns Int
As
Begin
    Declare @StudentID Int;

    -- Select the student ID by joining Student, Person, and UserAccount
    Select @StudentID = S.StudentID
    From Student S
    Join Person P On S.PersonID = P.PersonID
    Join UserAccount U On P.PersonID = U.UserID
    Where Suser_sname() = U.UserName;

    Return @StudentID;
End;
Go

-- ===============================================
-- Function: fn_CompareTextAnswer
-- Purpose: Compare a student's text answer with model answer and return 1 if ≥50% words match
-- ===============================================
Create Or Alter Function dbo.fn_CompareTextAnswer
(
    @QuestionID Int,
    @StudentQAnswer Nvarchar(Max)
)
Returns Bit
As
Begin
    Declare @ModelAnswer Nvarchar(Max);
    Declare @WordCount Int;
    Declare @MatchedWords Int;
    Declare @Result Bit = 0;

    -- Get the correct model answer
    Select @ModelAnswer = BestTextAnswer
    From TextQuestion
    Where QuestionID = @QuestionID;

    -- Return 0 if model answer or student answer is empty
    If @ModelAnswer Is Null Or Ltrim(Rtrim(@StudentQAnswer)) = ''
        Return 0;

    -- Count total words in the model answer
    Select @WordCount = Count(*)
    From String_Split(@ModelAnswer, ' ') 
    Where Ltrim(Rtrim(Value)) <> '';

    -- Count matched words (case-insensitive)
    Select @MatchedWords = Count(*)
    From String_Split(@ModelAnswer, ' ') As m
    Where Ltrim(Rtrim(m.Value)) <> ''
      And Exists (
          Select 1
          From String_Split(@StudentQAnswer, ' ') As s
          Where Lower(Ltrim(Rtrim(s.Value))) = Lower(Ltrim(Rtrim(m.Value)))
      );

    -- If ≥50% words match, mark as correct
    If @WordCount > 0 And @MatchedWords * 2 >= @WordCount
        Set @Result = 1;

    Return @Result;
End;
Go

