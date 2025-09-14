--==============================================================================================================
-----------------2- Creating Stored procedure to add SuperManger and assign to SuperManagerRole-----------------
-----------------------That stored procedure can't be executed only by the Admin -------------------------------
--==============================================================================================================
Create or Alter Procedure addSuperManagerUser
    @UserName Nvarchar(100),@Password Nvarchar(100),@FName Nvarchar(50),@LName Nvarchar(50),
    @PhoneNumber Nvarchar(20),@Gender Nvarchar(10),@Email Nvarchar(100),@Address Nvarchar(255),
    @NationalID Varchar(14),@DateOfBirth Date,@Salary Decimal(10,2),@HireDate Date,@ExperienceYears Int
As
Begin
    Set Nocount On;

    Declare @NewUserID Int;
    Declare @sql Nvarchar(Max);

    -----------------------------
    -- 1. Create SQL Server login
    -----------------------------
    Set @sql = 'Create Login [' + @UserName + '] With Password = ''' + @Password + ''';';
    Exec(@sql);

    -- 2. Create database user mapped to login
    Set @sql = 'Create User [' + @UserName + '] For Login [' + @UserName + '];';
    Exec(@sql);

    -- 2b. Add user to SuperManagerRole
    Set @sql = 'Alter Role SuperManagerRole Add Member [' + @UserName + '];';
    Exec(@sql);

    -----------------------------
    -- 3. Insert into UserAccount (identity)
    -----------------------------
    Insert Into UserAccount (UserRole, UserName, Password)
    Values ('SuperManager', @UserName, Convert(Varchar(64), Hashbytes('Sha2_256', @Password), 2));

    Set @NewUserID = Scope_identity();

    -----------------------------
    -- 4. Insert into Person (PersonID = UserID)
    -----------------------------
    Insert Into Person (PersonID, FName, LName, PhoneNumber, Gender, Email, Address, NationalID, DateOfBirth, UserID)
    Values (@NewUserID, @FName, @LName, @PhoneNumber, @Gender, @Email, @Address, @NationalID, @DateOfBirth, @NewUserID);

    -----------------------------
    -- 5. Insert into Manager (ManagerID = PersonID = UserID)
    -----------------------------
    Insert Into Manager (ManagerID, Salary, HireDate, ExperienceYears, PersonID)
    Values (@NewUserID, @Salary, @HireDate, @ExperienceYears, @NewUserID);

    Print 'Super Manager user created successfully!';
End;
Go

--===========================================================================  
-- Procedure: addManagerUser  
-- Adds a new super manager or branch manager including login, user account, person, manager tables  
--===========================================================================  
Create or Alter Procedure addManagerUser
    @UserName Nvarchar(100), @Password Nvarchar(100), @FName Nvarchar(50), @LName Nvarchar(50),
    @PhoneNumber Nvarchar(20), @Gender Nvarchar(10), @Email Nvarchar(100), @Address Nvarchar(255),
    @NationalID Varchar(14), @DateOfBirth Date, @Salary Decimal(10,2), @HireDate Date, @ExperienceYears Int
As
Begin
    Set Nocount On;
    Declare @NewUserID Int;
    Declare @sql Nvarchar(Max);

    -- 1. Create SQL Server login

    Set @sql = 'Create Login [' + @UserName + '] With Password = ''' + @Password + ''';';
    Exec(@sql);

    -- 2. Create database user mapped to login
    Set @sql = 'Create User [' + @UserName + '] For Login [' + @UserName + '];';
    Exec(@sql);

    -- 2b. Add user to BranchManagerRole
    Set @sql = 'Alter Role BranchManagerRole Add Member [' + @UserName + '];';
    Exec(@sql);

    -- 3. Insert into UserAccount
    Insert Into UserAccount (UserRole, UserName, Password)
    Values ('BranchManager', @UserName, Convert(Varchar(64), Hashbytes('Sha2_256', @Password), 2));
    Set @NewUserID = Scope_identity();

    -- 4. Insert into Person table
    Insert Into Person (PersonID, FName, LName, PhoneNumber, Gender, Email, Address, NationalID, DateOfBirth, UserID)
    Values (@NewUserID, @FName, @LName, @PhoneNumber, @Gender, @Email, @Address, @NationalID, @DateOfBirth, @NewUserID);

    -- 5. Insert into Manager table
    Insert Into Manager (ManagerID, Salary, HireDate, ExperienceYears, PersonID)
    Values (@NewUserID, @Salary, @HireDate, @ExperienceYears, @NewUserID);

    Print 'Super Manager user created successfully!';
End;
Go  

-- ==========================================================================================================
-- Add Instructor User
--==========================================================================================================
CREATE OR ALTER PROCEDURE AddInstructorUser
    @UserName NVARCHAR(100),
    @Password NVARCHAR(100),
    @FName NVARCHAR(50),
    @LName NVARCHAR(50),
    @PhoneNumber NVARCHAR(20),
    @Gender NVARCHAR(10),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255),
    @NationalID VARCHAR(14),
    @DateOfBirth DATE,
    @Salary DECIMAL(10,2),
    @HireDate DATE,
    @ExperienceYears INT,
    @DepartmentID INT,
    @BIT_ID INT 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewUserID INT;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @CurrentLogin SYSNAME = SUSER_SNAME();

    -- 1. Create SQL Server login
    SET @sql = 'CREATE LOGIN [' + @UserName + '] WITH PASSWORD = ''' + @Password + ''';';
    EXEC(@sql);

    -- 2. Create database user mapped to login
    SET @sql = 'CREATE
	USER [' + @UserName + '] FOR LOGIN [' + @UserName + '];';
    EXEC(@sql);

    -- 3. Add user to InstructorRole
    SET @sql = 'ALTER ROLE [InstructorRole] ADD MEMBER [' + @UserName + '];';
    EXEC(@sql);

    -- 4. Insert into UserAccount
    INSERT INTO UserAccount (UserRole, UserName, Password)
    VALUES ('Instructor', @UserName, CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Password), 2));

    SET @NewUserID = SCOPE_IDENTITY();

    -- 5. Insert into Person table
    INSERT INTO Person (PersonID, FName, LName, PhoneNumber, Gender, Email, Address, NationalID, DateOfBirth, UserID)
    VALUES (@NewUserID, @FName, @LName, @PhoneNumber, @Gender, @Email, @Address, @NationalID, @DateOfBirth, @NewUserID);

    -- 6. Insert into Instructor table
    INSERT INTO dbo.Instructor (InstructorID, Salary, HireDate, ExperienceYears, DepartmentID, PersonID, BIT_ID)
    VALUES (@NewUserID, @Salary, @HireDate, @ExperienceYears, @DepartmentID, @NewUserID, @BIT_ID);

    PRINT 'Instructor user created and added to InstructorRole successfully by ' + @CurrentLogin;
END;
GO
 
-- ==============================================
-- Add Student Procedure
-- Manager can only add students to their own branch
-- ==============================================
CREATE OR ALTER PROCEDURE addStudentUser
    @UserName NVARCHAR(100),
    @Password NVARCHAR(100),
    @FName NVARCHAR(50),
    @LName NVARCHAR(50),
    @PhoneNumber NVARCHAR(20),
    @Gender NVARCHAR(10),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255),
    @NationalID VARCHAR(14),
    @DateOfBirth DATE,
    @MaritalStatus NVARCHAR(20),
    @GPA DECIMAL(4,2),
    @MilitaryStatus NVARCHAR(20),
    @Faculty NVARCHAR(100),
    @EnrollmentDate DATE,
    @GraduationYear INT,
    @BIT_ID INT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @NewUserID INT;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @CurrentLogin SYSNAME = SUSER_SNAME();


    -- Create login for student
    SET @sql = 'CREATE LOGIN [' + @UserName + '] WITH PASSWORD = ''' + @Password + ''';';
    EXEC(@sql);

    -- Create user mapped to login
    SET @sql = 'CREATE USER [' + @UserName + '] FOR LOGIN [' + @UserName + '];';
    EXEC(@sql);

    -- Add user to StudentRole
    SET @sql = 'ALTER ROLE StudentRole ADD MEMBER [' + @UserName + '];';
    EXEC(@sql);

    -- Insert into UserAccount table
    INSERT INTO UserAccount (UserRole, UserName, Password)
    VALUES ('Student', @UserName, CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Password), 2));

    SET @NewUserID = SCOPE_IDENTITY();

    -- Insert into Person table
    INSERT INTO Person (PersonID, FName, LName, PhoneNumber, Gender, Email, Address, NationalID, DateOfBirth, UserID)
    VALUES (@NewUserID, @FName, @LName, @PhoneNumber, @Gender, @Email, @Address, @NationalID, @DateOfBirth, @NewUserID);

    -- Insert into Student table
    INSERT INTO Student (StudentID, MaritalStatus, GPA, MilitaryStatus, Faculty, EnrollmentDate, GraduationYear, BIT_ID, PersonID)
    VALUES (@NewUserID, @MaritalStatus, @GPA, @MilitaryStatus, @Faculty, @EnrollmentDate, @GraduationYear, @BIT_ID, @NewUserID);

    PRINT 'Student user [' + @UserName + '] created successfully by ' + @CurrentLogin;
END;
GO


--==================================================================================================
--=====================================SuperManager objects=========================================

--===========================================================================  
-- Procedure: updateManagerUser  
-- Updates manager details, executed only by Admin or Super Manager  
--===========================================================================  
Create Or Alter Procedure updateManagerUser
    @ManagerID Int,
    @UserName Nvarchar(100) = Null,
    @Password Nvarchar(100) = Null,
    @FName Nvarchar(50) = Null,
    @LName Nvarchar(50) = Null,
    @PhoneNumber Nvarchar(20) = Null,
    @Gender Nvarchar(10) = Null,
    @Email Nvarchar(100) = Null,
    @Address Nvarchar(255) = Null,
    @NationalID Varchar(14) = Null,
    @DateOfBirth Date = Null,
    @Salary Decimal(10,2) = Null,
    @HireDate Date = Null,
    @ExperienceYears Int = Null
As
Begin
    Set Nocount On;

    -- 1. Update UserAccount table
    If @UserName Is Not Null
        Update UserAccount Set UserName = @UserName Where UserID = @ManagerID;
    If @Password Is Not Null
        Update UserAccount Set Password = Convert(Varchar(64), Hashbytes('SHA2_256', @Password), 2) Where UserID = @ManagerID;

    -- 2. Update Person table
    Update Person
    Set 
        FName = Coalesce(@FName, FName),
        LName = Coalesce(@LName, LName),
        PhoneNumber = Coalesce(@PhoneNumber, PhoneNumber),
        Gender = Coalesce(@Gender, Gender),
        Email = Coalesce(@Email, Email),
        Address = Coalesce(@Address, Address),
        NationalID = Coalesce(@NationalID, NationalID),
        DateOfBirth = Coalesce(@DateOfBirth, DateOfBirth)
    Where PersonID = @ManagerID;

    -- 3. Update Manager table
    Update Manager
    Set
        Salary = Coalesce(@Salary, Salary),
        HireDate = Coalesce(@HireDate, HireDate),
        ExperienceYears = Coalesce(@ExperienceYears, ExperienceYears)
    Where ManagerID = @ManagerID;

    Print 'Manager updated successfully!';
End;
Go  
--===========================================================================  
-- Procedure: addBranch  
-- Adds a new branch to the system  
--===========================================================================  
Create Or Alter Procedure addBranch
    @BranchID Int,
    @BranchName Nvarchar(100),
    @BranchAddress Nvarchar(255),
    @BranchEmail Nvarchar(100),
    @BranchPhone Nvarchar(20),
    @BranchManagerID Int
As
Begin
    Set Nocount On;

    -- Insert new branch into Branch table
    Insert Into Branch (BranchID, BranchName, BranchAddress, BranchEmail, BranchPhone, BranchManagerID)
    Values (@BranchID, @BranchName, @BranchAddress, @BranchEmail, @BranchPhone, @BranchManagerID);

    Print 'Branch added successfully!';
End;
Go

--===========================================================================  
-- Procedure: updateBranch  
-- Updates branch details, only Super Manager or assigned Branch Manager can update  
--===========================================================================  
Create Or Alter Procedure updateBranch
    @BranchID Int,
    @BranchName Nvarchar(100) = Null,
    @BranchAddress Nvarchar(255) = Null,
    @BranchEmail Nvarchar(100) = Null,
    @BranchPhone Nvarchar(20) = Null,
    @BranchManagerID Int = Null
As
Begin
    Set Nocount On;

    Declare @CurrentManagerID Int = dbo.GetCurrentManagerID();
    Declare @BranchManagerID_DB Int;

    -- 1. Check if branch exists
    If Not Exists (Select 1 From dbo.Branch Where BranchID = @BranchID)
    Begin
        Raiserror('Branch with ID %d does not exist.', 16, 1, @BranchID);
        Return;
    End;

    -- 2. Get current branch manager
    Select @BranchManagerID_DB = BranchManagerID From dbo.Branch Where BranchID = @BranchID;

    -- 3. Authorization: Super Manager or assigned manager only
    If @CurrentManagerID <> 1 And @CurrentManagerID <> @BranchManagerID_DB
    Begin
        Raiserror('You are not authorized to update this branch.', 16, 1);
        Return;
    End;

    -- 4. Update branch details
    Update dbo.Branch
    Set
        BranchName      = Isnull(@BranchName, BranchName),
        BranchAddress   = Isnull(@BranchAddress, BranchAddress),
        BranchEmail     = Isnull(@BranchEmail, BranchEmail),
        BranchPhone     = Isnull(@BranchPhone, BranchPhone),
        BranchManagerID = Isnull(@BranchManagerID, BranchManagerID)
    Where BranchID = @BranchID;

    Print 'Branch updated successfully.';
End;
Go

--===========================================================================  
-- Procedure: addIntake  
-- Adds a new intake to the system  
--===========================================================================  
Create Or Alter Procedure addIntake
    @IntakeID Int,
    @IntakeName Nvarchar(100),
    @StartDate Date,
    @EndDate Date,
    @Year Int
As
Begin
    Set Nocount On;

    Insert Into Intake (IntakeID, IntakeName, StartDate, EndDate, Year)
    Values (@IntakeID, @IntakeName, @StartDate, @EndDate, @Year);

    Print 'Intake added successfully!';
End;
Go

--===========================================================================  
-- Procedure: updateIntake  
-- Updates existing intake details  
--===========================================================================  
Create Or Alter Procedure dbo.updateIntake
    @IntakeID Int,
    @IntakeName Nvarchar(100) = Null,
    @StartDate Date = Null,
    @EndDate Date = Null,
    @Year Int = Null
As
Begin
    Set Nocount On;

    -- 1. Check if intake exists
    If Not Exists (Select 1 From dbo.Intake Where IntakeID = @IntakeID)
    Begin
        Raiserror('Intake with ID %d does not exist.', 16, 1, @IntakeID);
        Return;
    End;

    -- 2. Update provided fields
    Update dbo.Intake
    Set
        IntakeName = Isnull(@IntakeName, IntakeName),
        StartDate  = Isnull(@StartDate, StartDate),
        EndDate    = Isnull(@EndDate, EndDate),
        Year       = Isnull(@Year, Year)
    Where IntakeID = @IntakeID;

    Print 'Intake updated successfully!';
End;
Go

--===========================================================================  
-- Procedure: addDepartment  
-- Adds a new department  
--===========================================================================  
Create Or Alter Procedure addDepartment
    @DepartmentID Int,
    @DepartmentName Nvarchar(100)
As
Begin
    Set Nocount On;

    Insert Into Department (DepartmentID, DepartmentName)
    Values (@DepartmentID, @DepartmentName);

    Print 'Department created successfully!';
End;
Go

--===========================================================================  
-- Procedure: updateDepartment  
-- Updates existing department name  
--===========================================================================  
Create Or Alter Procedure updateDepartment
    @DepartmentID Int,
    @DepartmentName Nvarchar(100)
As
Begin
    Set Nocount On;

    -- Check if department exists
    If Not Exists (Select 1 From dbo.Department Where DepartmentID = @DepartmentID)
    Begin
        Raiserror('Department with ID %d does not exist.', 16, 1, @DepartmentID);
        Return;
    End;

    -- Update department name
    Update dbo.Department
    Set DepartmentName = @DepartmentName
    Where DepartmentID = @DepartmentID;

    Print 'Department updated successfully!';
End;
Go

--===========================================================================  
-- Procedure: addTrack  
-- Adds a new track linked to a department  
--===========================================================================  
Create Or Alter Procedure addTrack
    @TrackID Int,
    @TrackName Nvarchar(50),
    @Description Nvarchar(255) = Null,
    @DepartmentID Int
As
Begin
    Set Nocount On;

    -- Validate department exists
    If Not Exists (Select 1 From Department Where DepartmentID = @DepartmentID)
    Begin
        Raiserror('Department with ID %d does not exist.', 16, 1, @DepartmentID);
        Return;
    End;

    -- Insert new track
    Insert Into Track (TrackID, TrackName, Description, DepartmentID)
    Values (@TrackID, @TrackName, @Description, @DepartmentID);

    Print 'Track added successfully!';
End;
Go

--===========================================================================  
-- Procedure: updateTrack  
-- Updates track details  
--===========================================================================  
Create Or Alter Procedure updateTrack
    @TrackID Int,
    @TrackName Nvarchar(50) = Null,
    @Description Nvarchar(255) = Null,
    @DepartmentID Int = Null
As
Begin
    Set Nocount On;

    -- 1. Check if track exists
    If Not Exists (Select 1 From dbo.Track Where TrackID = @TrackID)
    Begin
        Raiserror('Track with ID %d does not exist.', 16, 1, @TrackID);
        Return;
    End;

    -- 2. Validate new DepartmentID if provided
    If @DepartmentID Is Not Null And Not Exists (Select 1 From dbo.Department Where DepartmentID = @DepartmentID)
    Begin
        Raiserror('Department with ID %d does not exist.', 16, 1, @DepartmentID);
        Return;
    End;

    -- 3. Update track
    Update dbo.Track
    Set
        TrackName    = Isnull(@TrackName, TrackName),
        Description  = Isnull(@Description, Description),
        DepartmentID = Isnull(@DepartmentID, DepartmentID)
    Where TrackID = @TrackID;

    Print 'Track updated successfully!';
End;
Go

--===========================================================================  
-- Procedure: deleteTrack  
-- Deletes a track if it is not assigned to any branch intake  
--===========================================================================  
Create Or Alter Procedure deleteTrack
    @TrackID Int
As
Begin
    Set Nocount On;

    -- Check if track exists
    If Not Exists (Select 1 From Track Where TrackID = @TrackID)
    Begin
        Raiserror('Track with ID %d does not exist.', 16, 1, @TrackID);
        Return;
    End;

    -- Check if track is used in BranchIntakeTrack
    If Exists (Select 1 From BranchIntakeTrack Where TrackID = @TrackID)
    Begin
        Raiserror('Cannot delete track. Track is currently assigned to branches.', 16, 1);
        Return;
    End;

    -- Delete track
    Delete From Track Where TrackID = @TrackID;

    Print 'Track deleted successfully!';
End;
Go


--===========================================================================  
-- Procedure: SearchStudents  
-- Search students dynamically by optional filters  
-- Accessible to Super Manager (all branches) or Branch Manager (own branch)  
--===========================================================================  
Create Or Alter Procedure dbo.SearchStudents
    @BranchID Int = Null,
    @DepartmentID Int = Null,
    @TrackID Int = Null,
    @IntakeID Int = Null,
    @StudentID Int = Null,
    @StudentName Nvarchar(100) = Null
As
Begin
    Set Nocount On;

    Declare @CurrentManagerID Int = dbo.GetCurrentManagerID();

    -- Super Manager can see all students
    If @CurrentManagerID = 1
    Begin
        Select *
        From v_StudentDetails 
        Where (@BranchID Is Null Or BranchID = @BranchID)
          And (@DepartmentID Is Null Or DepartmentID = @DepartmentID)
          And (@TrackID Is Null Or TrackID = @TrackID)
          And (@IntakeID Is Null Or IntakeID = @IntakeID)
          And (@StudentID Is Null Or StudentID = @StudentID)
          And (@StudentName Is Null Or StudentName Like '%' + @StudentName + '%');
    End
    Else
    Begin
        -- Branch Manager: only students in own branch
        Select V.*
        From v_StudentDetails V
        Join Branch B On V.BranchID = B.BranchID
        Where B.BranchManagerID = @CurrentManagerID
          And (@DepartmentID Is Null Or V.DepartmentID = @DepartmentID)
          And (@TrackID Is Null Or V.TrackID = @TrackID)
          And (@IntakeID Is Null Or V.IntakeID = @IntakeID)
          And (@StudentID Is Null Or V.StudentID = @StudentID)
          And (@StudentName Is Null Or V.StudentName Like '%' + @StudentName + '%');
    End
End;
Go

--===========================================================================  
-- Procedure: SearchManagers  
-- Search managers dynamically by BranchID, ManagerID, or Name  
--===========================================================================  
Create Or Alter Procedure dbo.SearchManagers
    @BranchID Int = Null,
    @ManagerID Int = Null,
    @ManagerName Nvarchar(100) = Null
As
Begin
    Set Nocount On;

    Declare @CurrentManagerID Int = dbo.GetCurrentManagerID();

    If @CurrentManagerID = 1
    Begin
        -- Super Manager: see all managers
        Select *
        From v_ManagerDetails
        Where (@BranchID Is Null Or BranchID = @BranchID)
          And (@ManagerID Is Null Or ManagerID = @ManagerID)
          And (@ManagerName Is Null Or ManagerName Like '%' + @ManagerName + '%');
    End
    Else
    Begin
        -- Regular manager: see only own info
        Select *
        From v_ManagerDetails V
        Where V.ManagerID = @CurrentManagerID
          And (@BranchID Is Null Or V.BranchID = @BranchID)
          And (@ManagerID Is Null Or V.ManagerID = @ManagerID)
          And (@ManagerName Is Null Or V.ManagerName Like '%' + @ManagerName + '%');
    End
End;
Go

--===========================================================================  
-- Procedure: SearchInstructors  
-- Search instructors dynamically with optional filters  
--===========================================================================  
Create Or Alter Procedure dbo.SearchInstructors
    @BranchID Int = Null,
    @InstructorID Int = Null,
    @InstructorName Nvarchar(100) = Null,
    @DepartmentID Int = Null
As
Begin
    Set Nocount On;

    Declare @CurrentManagerID Int = dbo.GetCurrentManagerID();

    If @CurrentManagerID = 1
    Begin
        -- Super Manager: see all instructors
        Select *
        From v_InstructorDetails
        Where (@BranchID Is Null Or BranchID = @BranchID)
          And (@InstructorID Is Null Or InstructorID = @InstructorID)
          And (@InstructorName Is Null Or InstructorName Like '%' + @InstructorName + '%')
          And (@DepartmentID Is Null Or DepartmentID = @DepartmentID);
    End
    Else
    Begin
        -- Regular manager: see only instructors in own branch
        Select V.*
        From v_InstructorDetails V
        Join Branch B On V.BranchID = B.BranchID
        Where B.BranchManagerID = @CurrentManagerID
          And (@BranchID Is Null Or V.BranchID = @BranchID)
          And (@InstructorID Is Null Or V.InstructorID = @InstructorID)
          And (@InstructorName Is Null Or V.InstructorName Like '%' + @InstructorName + '%')
          And (@DepartmentID Is Null Or V.DepartmentID = @DepartmentID);
    End
End;
Go

--===========================================================================  
-- Procedure: SearchBranches  
-- Search branches dynamically with optional filters  
--===========================================================================  
Create Or Alter Procedure dbo.SearchBranches
    @BranchID Int = Null,
    @DepartmentID Int = Null,
    @TrackID Int = Null,
    @IntakeID Int = Null
As
Begin
    Set Nocount On;

    Declare @CurrentManagerID Int = dbo.GetCurrentManagerID();

    If @CurrentManagerID = 1
    Begin
        -- Super Manager: see all branches
        Select *
        From v_AllBranchesDetails
        Where (@BranchID Is Null Or BranchID = @BranchID)
          And (@DepartmentID Is Null Or DepartmentID = @DepartmentID)
          And (@TrackID Is Null Or TrackID = @TrackID)
          And (@IntakeID Is Null Or IntakeID = @IntakeID);
    End
    Else
    Begin
        -- Regular manager: see only own branch
        Select V.*
        From v_AllBranchesDetails V
        Join Branch B On V.BranchID = B.BranchID
        Where B.BranchManagerID = @CurrentManagerID
          And (@BranchID Is Null Or V.BranchID = @BranchID)
          And (@DepartmentID Is Null Or V.DepartmentID = @DepartmentID)
          And (@TrackID Is Null Or V.TrackID = @TrackID)
          And (@IntakeID Is Null Or V.IntakeID = @IntakeID);
    End
End;
Go
--==================================================================================================
--=====================================BranchManager objects=========================================
--==================================================================================================
-- ==============================================
-- Add Track To Intake Procedure
-- This procedure links a Track to an Intake for the branch of the current manager
-- ==============================================
CREATE OR ALTER PROCEDURE dbo.AddTrackToIntake
    @IntakeID INT,
    @TrackID  INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentManagerID INT = dbo.GetCurrentManagerID();
    DECLARE @BranchID INT;
    DECLARE @NewBIT_ID INT;

    -- Get BranchID managed by current manager
    SELECT @BranchID = BranchID
    FROM dbo.Branch
    WHERE BranchManagerID = @CurrentManagerID;

    -- Validate Branch
    IF @BranchID IS NULL
    BEGIN
        RAISERROR('Current manager does not manage any branch.', 16, 1);
        RETURN;
    END;

    -- Validate Intake
    IF NOT EXISTS (SELECT 1 FROM dbo.Intake WHERE IntakeID = @IntakeID)
    BEGIN
        RAISERROR('Intake %d does not exist.', 16, 1, @IntakeID);
        RETURN;
    END;

    -- Validate Track
    IF NOT EXISTS (SELECT 1 FROM dbo.Track WHERE TrackID = @TrackID)
    BEGIN
        RAISERROR('Track %d does not exist.', 16, 1, @TrackID);
        RETURN;
    END;

    -- Prevent duplicates
    IF EXISTS (
        SELECT 1
        FROM dbo.BranchIntakeTrack
        WHERE BranchID = @BranchID
          AND IntakeID = @IntakeID
          AND TrackID  = @TrackID
    )
    BEGIN
        RAISERROR('This Branch-Intake-Track combination already exists.', 16, 1);
        RETURN;
    END;

    -- Generate new BIT_ID manually (MAX + 1)
    SELECT @NewBIT_ID = ISNULL(MAX(BIT_ID), 0) + 1
    FROM dbo.BranchIntakeTrack;

    -- Insert new record
    INSERT INTO dbo.BranchIntakeTrack (BIT_ID, BranchID, IntakeID, TrackID)
    VALUES (@NewBIT_ID, @BranchID, @IntakeID, @TrackID);

    PRINT 'Track added to intake successfully. New BIT_ID = ' + CAST(@NewBIT_ID AS NVARCHAR(20));
END;
GO

-- ==============================================
-- Delete Student Procedure
-- Manager can only delete students from their own branch
-- ==============================================
CREATE OR ALTER PROCEDURE deleteStudentUser
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentManagerID INT;
    DECLARE @UserName NVARCHAR(100);
    DECLARE @PersonID INT;
    DECLARE @sql NVARCHAR(MAX);

    SET @CurrentManagerID = dbo.GetCurrentManagerID()

    -- Verify student exists
    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
    BEGIN
        RAISERROR('Student %d does not exist.', 16, 1, @StudentID);
        RETURN;
    END

    -- Check branch ownership
    IF @CurrentManagerID <> 1
       AND NOT EXISTS (
            SELECT 1
            FROM Student S
            JOIN BranchIntakeTrack BIT ON S.BIT_ID = BIT.BIT_ID
            JOIN Branch B ON BIT.BranchID = B.BranchID
            WHERE S.StudentID = @StudentID
              AND B.BranchManagerID = @CurrentManagerID
        )
    BEGIN
        RAISERROR('You can only delete students from your own branch.', 16, 1);
        RETURN;
    END

    -- Get UserName and PersonID
    SELECT 
        @PersonID = P.PersonID,
        @UserName = U.UserName
    FROM Student S
    JOIN Person P ON S.PersonID = P.PersonID
    JOIN UserAccount U ON U.UserID = P.UserID
    WHERE S.StudentID = @StudentID;

    -- Delete Student, Person, UserAccount
    DELETE FROM Student WHERE StudentID = @StudentID;
    DELETE FROM Person WHERE PersonID = @PersonID;
    DELETE FROM UserAccount WHERE UserID = @PersonID;

    -- Drop DB user + login if exists
    IF @UserName IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @UserName)
        BEGIN
            SET @sql = 'DROP USER [' + @UserName + ']';
            EXEC(@sql);
        END;

        IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @UserName)
        BEGIN
            SET @sql = 'DROP LOGIN [' + @UserName + ']';
            EXEC(@sql);
        END;
    END

    PRINT 'Student deleted successfully by ' + SUSER_SNAME();
END;
GO

-- ==============================================
-- Update Student Procedure
-- Manager can only update students from their branch
-- ==============================================
CREATE OR ALTER PROCEDURE updateStudentUser
    @StudentID INT,
    @FName NVARCHAR(50) = NULL,
    @LName NVARCHAR(50) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Gender NVARCHAR(10) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(255) = NULL,
    @NationalID VARCHAR(14) = NULL,
    @DateOfBirth DATE = NULL,
    @MaritalStatus NVARCHAR(20) = NULL,
    @GPA DECIMAL(4,2) = NULL,
    @MilitaryStatus NVARCHAR(20) = NULL,
    @Faculty NVARCHAR(100) = NULL,
    @EnrollmentDate DATE = NULL,
    @GraduationYear INT = NULL,
    @BIT_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentManagerID INT;
    SET @CurrentManagerID = dbo.GetCurrentManagerID()

    -- Verify student exists
    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
    BEGIN
        RAISERROR('Student %d does not exist.', 16, 1, @StudentID);
        RETURN;
    END

    -- Check branch ownership
    IF @CurrentManagerID <> 1
       AND NOT EXISTS (
            SELECT 1
            FROM Student S
            JOIN BranchIntakeTrack BIT ON S.BIT_ID = BIT.BIT_ID
            JOIN Branch B ON BIT.BranchID = B.BranchID
            WHERE S.StudentID = @StudentID
              AND B.BranchManagerID = @CurrentManagerID
        )
    BEGIN
        RAISERROR('You can only update students from your branch.', 16, 1);
        RETURN;
    END

    -- Update Person table
    UPDATE Person
    SET FName       = ISNULL(@FName, FName),
        LName       = ISNULL(@LName, LName),
        PhoneNumber = ISNULL(@PhoneNumber, PhoneNumber),
        Gender      = ISNULL(@Gender, Gender),
        Email       = ISNULL(@Email, Email),
        Address     = ISNULL(@Address, Address),
        NationalID  = ISNULL(@NationalID, NationalID),
        DateOfBirth = ISNULL(@DateOfBirth, DateOfBirth)
    WHERE PersonID = @StudentID;

    -- Update Student table
    UPDATE Student
    SET MaritalStatus   = ISNULL(@MaritalStatus, MaritalStatus),
        GPA             = ISNULL(@GPA, GPA),
        MilitaryStatus  = ISNULL(@MilitaryStatus, MilitaryStatus),
        Faculty         = ISNULL(@Faculty, Faculty),
        EnrollmentDate  = ISNULL(@EnrollmentDate, EnrollmentDate),
        GraduationYear  = ISNULL(@GraduationYear, GraduationYear),
        BIT_ID          = ISNULL(@BIT_ID, BIT_ID)
    WHERE StudentID = @StudentID;

    PRINT 'Student updated successfully by ' + SUSER_SNAME();
END;
GO

-- ==========================================================================================================
-- Update Instructor User
--==========================================================================================================

CREATE OR ALTER PROCEDURE UpdateInstructorUser
    @InstructorID INT,
    @Salary DECIMAL(10,2) = NULL,
    @HireDate DATE = NULL,
    @ExperienceYears INT = NULL,
    @DepartmentID INT = NULL,
    @BIT_ID INT = NULL,
    @FName NVARCHAR(50) = NULL,
    @LName NVARCHAR(50) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Gender NVARCHAR(50) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(255) = NULL,
    @NationalID NVARCHAR(14) = NULL,
    @DOB DATE = NULL,
    @UserName NVARCHAR(100) = NULL,
    @Password NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentManagerID INT;
    SET @CurrentManagerID = dbo.GetCurrentManagerID();

    -- 1. Verify instructor exists
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = @InstructorID)
    BEGIN
        RAISERROR('Instructor %d does not exist.', 16, 1, @InstructorID);
        RETURN;
    END;

    -- 2. Check branch ownership if not admin
    IF @CurrentManagerID <> 1
       AND NOT EXISTS (
            SELECT 1
            FROM Instructor I
            JOIN BranchIntakeTrack BIT ON I.BIT_ID = BIT.BIT_ID
            JOIN Branch B ON BIT.BranchID = B.BranchID
            WHERE I.InstructorID = @InstructorID
              AND B.BranchManagerID = @CurrentManagerID
        )
    BEGIN
        RAISERROR('You can only update instructors from your branch.', 16, 1);
        RETURN;
    END;

    -- 3. Update Person table
    UPDATE Person
    SET FName       = ISNULL(@FName, FName),
        LName       = ISNULL(@LName, LName),
        PhoneNumber = ISNULL(@PhoneNumber, PhoneNumber),
        Gender      = ISNULL(@Gender, Gender),
        Email       = ISNULL(@Email, Email),
        Address     = ISNULL(@Address, Address),
        NationalID  = ISNULL(@NationalID, NationalID),
        DateOfBirth = ISNULL(@DOB, DateOfBirth)
    WHERE PersonID = @InstructorID;

    -- 4. Update Instructor table
    UPDATE Instructor
    SET Salary          = ISNULL(@Salary, Salary),
        HireDate        = ISNULL(@HireDate, HireDate),
        ExperienceYears = ISNULL(@ExperienceYears, ExperienceYears),
        DepartmentID    = ISNULL(@DepartmentID, DepartmentID),
        BIT_ID          = ISNULL(@BIT_ID, BIT_ID)
    WHERE InstructorID = @InstructorID;

    -- 5. Update UserAccount if needed
    IF @UserName IS NOT NULL OR @Password IS NOT NULL
    BEGIN
        UPDATE UserAccount
        SET UserName = ISNULL(@UserName, UserName),
            Password = ISNULL(
                CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Password), 2),
                Password
            )
        WHERE UserID = @InstructorID;

        -- Update SQL Server login if password provided
        IF @Password IS NOT NULL AND @UserName IS NOT NULL
        BEGIN
            DECLARE @sql NVARCHAR(MAX);
            SET @sql = 'ALTER LOGIN [' + @UserName + '] WITH PASSWORD = ''' + @Password + ''';';
            EXEC(@sql);
        END
    END

    PRINT 'Instructor updated successfully by ' + SUSER_SNAME();
END;
GO

-- ==========================================================================================================
-- Delete Instructor User
--==========================================================================================================

CREATE OR ALTER PROCEDURE DeleteInstructorUser
    @InstructorID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentManagerID INT;
    DECLARE @UserName NVARCHAR(100);
    DECLARE @sql NVARCHAR(MAX);

    SET @CurrentManagerID = dbo.GetCurrentManagerID();

    -- 1. Verify instructor exists
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = @InstructorID)
    BEGIN
        RAISERROR('Instructor %d does not exist.', 16, 1, @InstructorID);
        RETURN;
    END

    -- 2. Check branch ownership if not admin
    IF @CurrentManagerID IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM Instructor I
            JOIN BranchIntakeTrack BIT ON I.BIT_ID = BIT.BIT_ID
            JOIN Branch B ON BIT.BranchID = B.BranchID
            WHERE I.InstructorID = @InstructorID
              AND B.BranchManagerID = @CurrentManagerID
        )
    BEGIN
        RAISERROR('You can only delete instructors from your own branch.', 16, 1);
        RETURN;
    END

    -- 3. Get username from UserAccount
    SELECT @UserName = UserName
    FROM UserAccount
    WHERE UserID = @InstructorID;

    -- 4. Delete Instructor, Person, and UserAccount
    DELETE FROM Instructor WHERE InstructorID = @InstructorID;
    DELETE FROM Person WHERE PersonID = @InstructorID;
    DELETE FROM UserAccount WHERE UserID = @InstructorID;

    -- 5. Drop database user and login if exists
    IF @UserName IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @UserName)
        BEGIN
            SET @sql = 'DROP USER [' + @UserName + ']';
            EXEC(@sql);
        END;

        IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @UserName)
        BEGIN
            SET @sql = 'DROP LOGIN [' + @UserName + ']';
            EXEC(@sql);
        END;
    END

    PRINT 'Instructor deleted successfully by ' + SUSER_SNAME();
END;
GO

-- ==========================================================================================================
-- Add Course To track
--==========================================================================================================

CREATE OR ALTER PROCEDURE AddCourse
    @CourseID INT,
    @CourseName NVARCHAR(50),
    @CourseDescription NVARCHAR(MAX) = NULL,
    @MinDegree DECIMAL(6,2),
    @MaxDegree DECIMAL(6,2),
    @CourseStatus NVARCHAR(20) = 'Active',
    @InstructorID INT = NULL,
    @TrackID INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Course (CourseID, CourseName, CourseDescription, MinDegree, MaxDegree, CourseStatus, InstructorID, TrackID)
    VALUES (@CourseID, @CourseName, @CourseDescription, @MinDegree, @MaxDegree, @CourseStatus, @InstructorID, @TrackID);

    PRINT 'Course added successfully.';
END;
GO

-- ==========================================================================================================
-- Update Course
--==========================================================================================================

CREATE OR ALTER PROCEDURE UpdateCourse
    @CourseID INT,
    @CourseName NVARCHAR(50) = NULL,
    @CourseDescription NVARCHAR(MAX) = NULL,
    @MinDegree DECIMAL(6,2) = NULL,
    @MaxDegree DECIMAL(6,2) = NULL,
    @CourseStatus NVARCHAR(20) = NULL,
    @InstructorID INT = NULL,
    @TrackID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verify course exists
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
    BEGIN
        RAISERROR('Course does not exist.', 16, 1);
        RETURN;
    END

    -- Update course
    UPDATE Course
    SET CourseName = COALESCE(@CourseName, CourseName),
        CourseDescription = COALESCE(@CourseDescription, CourseDescription),
        MinDegree = COALESCE(@MinDegree, MinDegree),
        MaxDegree = COALESCE(@MaxDegree, MaxDegree),
        CourseStatus = COALESCE(@CourseStatus, CourseStatus),
        InstructorID = COALESCE(@InstructorID, InstructorID),
        TrackID = COALESCE(@TrackID, TrackID)
    WHERE CourseID = @CourseID;

    PRINT 'Course updated successfully.';
END;
GO

-- ==========================================================================================================
-- Delete Course
-- ==========================================================================================================
CREATE OR ALTER PROCEDURE DeleteCourse
    @CourseID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verify course exists
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
    BEGIN
        RAISERROR('Course does not exist.', 16, 1);
        RETURN;
    END

    -- Delete course
    DELETE FROM Course WHERE CourseID = @CourseID;

    PRINT 'Course deleted successfully.';
END;
GO

-- ==========================================================================================================
-- Assign Student to Course
-- ==========================================================================================================

CREATE OR ALTER PROCEDURE AssignStudentToCourse
    @CourseID INT,
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentManagerID INT = dbo.GetCurrentManagerID();
    DECLARE @StudentBITID INT;
    DECLARE @BITManagerID INT;

    -- 1. Check course exists
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
    BEGIN
        RAISERROR('Course does not exist.', 16, 1);
        RETURN;
    END

    -- 2. Get student's BIT_ID
    SELECT @StudentBITID = BIT_ID
    FROM Student
    WHERE StudentID = @StudentID;

    IF @StudentBITID IS NULL
    BEGIN
        RAISERROR('Student does not exist or does not have a BIT assigned.', 16, 1);
        RETURN;
    END

    -- 3. Get manager for student's BIT
    SELECT @BITManagerID = BranchManagerID
    FROM Branch B
    JOIN BranchIntakeTrack BIT ON B.BranchID = BIT.BranchID
    WHERE BIT.BIT_ID = @StudentBITID;

    -- 4. Check manager authority unless admin
    IF @CurrentManagerID IS NOT NULL
       AND @CurrentManagerID <> 1
       AND @CurrentManagerID <> @BITManagerID
    BEGIN
        RAISERROR('You can only assign students from your own branch.', 16, 1);
        RETURN;
    END

    -- 5. Check if already assigned
    IF EXISTS (SELECT 1 FROM StudentCourse WHERE StudentID = @StudentID AND CourseID = @CourseID)
    BEGIN
        RAISERROR('Student is already assigned to this course.', 16, 1);
        RETURN;
    END

    -- 6. Assign student to course
    INSERT INTO StudentCourse (StudentID, CourseID)
    VALUES (@StudentID, @CourseID);

    PRINT 'Student assigned to course successfully.';
END;
GO


-- ==========================================================================================================
--========================================================Instructor objects=================================
--===========================================================================================================

-- =======================
-- Procedure to add MCQ question
-- =======================
Create Or Alter Procedure sp_addMCQQuestion
    @QuestionText NVarChar(Max),
    @DifficultyLevel VarChar(20) = 'Medium',
    @QuestionMark Decimal(6,2) = 5,
    @CourseID Int,
    @Choice1 NVarChar(255),
    @Choice2 NVarChar(255),
    @Choice3 NVarChar(255),
    @Choice4 NVarChar(255),
    @CorrectChoice Char(1)
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = dbo.GetCurrentInstructorID()
    Declare @QID Int;

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to add questions for this course.', 1;

    Insert Into Question (QuestionType, QuestionText, DifficultyLevel, QuestionMark, CourseID)
    Values ('MCQ', @QuestionText, @DifficultyLevel, @QuestionMark, @CourseID);

    Set @QID = Scope_Identity();

    Insert Into Choices (QuestionID, ChoiceText, IsCorrect, ChoiceLetter)
    Values 
        (@QID, @Choice1, Case When @CorrectChoice = 'A' Then 1 Else 0 End, 'A'),
        (@QID, @Choice2, Case When @CorrectChoice = 'B' Then 1 Else 0 End, 'B'),
        (@QID, @Choice3, Case When @CorrectChoice = 'C' Then 1 Else 0 End, 'C'),
        (@QID, @Choice4, Case When @CorrectChoice = 'D' Then 1 Else 0 End, 'D');

    Print 'MCQ question added successfully.';
End;

-- =======================
-- Procedure to add True/False question
-- =======================
Create Or Alter Procedure sp_addTFQuestion
    @QuestionText NVarChar(Max),
    @DifficultyLevel VarChar(20) = 'Medium',
    @QuestionMark Decimal(6,2) = 5,
    @CourseID Int,
    @CorrectChoice Char(1) = 'A' -- 'A' = True, 'B' = False
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = dbo.GetCurrentInstructorID();
    Declare @QID Int;

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to add questions for this course.', 1;

    Insert Into Question (QuestionType, QuestionText, DifficultyLevel, QuestionMark, CourseID)
    Values ('TF', @QuestionText, @DifficultyLevel, @QuestionMark, @CourseID);

    Set @QID = Scope_Identity();

    Insert Into Choices (QuestionID, ChoiceText, IsCorrect, ChoiceLetter)
    Values
        (@QID, 'True', Case When @CorrectChoice = 'A' Then 1 Else 0 End, 'A'),
        (@QID, 'False', Case When @CorrectChoice = 'B' Then 1 Else 0 End, 'B');

    Print 'TF question added successfully.';
End;
Go

-- =======================
-- Procedure to add Text question
-- =======================
Create Or Alter Procedure sp_addTextQuestion
    @QuestionText NVarChar(Max),
    @CourseID Int,
    @DifficultyLevel VarChar(20) = 'Medium',
    @QuestionMark Decimal(6,2) = 5,
    @BestTextAnswer NVarChar(Max) = Null
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = dbo.GetCurrentInstructorID();
    Declare @QID Int;

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to add questions for this course.', 1;

    Insert Into Question (QuestionType, QuestionText, DifficultyLevel, QuestionMark, CourseID)
    Values ('Text', @QuestionText, @DifficultyLevel, @QuestionMark, @CourseID);

    Set @QID = Scope_Identity();

    Insert Into TextQuestion (QuestionID, BestTextAnswer)
    Values (@QID, @BestTextAnswer);

    Print 'Text question added successfully for the course by current instructor.';
End;
Go

-- =======================
-- Procedure to update a question
-- =======================
Create Or Alter Procedure sp_updateQuestion
    @QuestionID Int,
    @QuestionText NVarChar(Max) = Null,
    @DifficultyLevel VarChar(20) = Null,
    @QuestionMark Decimal(6,2) = Null,
    @CourseID Int = Null,
    @QuestionType NVarChar(50) = Null
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = dbo.GetCurrentInstructorID();

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (
        Select 1 
        From Question Q
        Join Course C On Q.CourseID = C.CourseID
        Where Q.QuestionID = @QuestionID And C.InstructorID = @InstructorID
    )
        Throw 51000, 'You are not allowed to update this question.', 1;

    Update Question
    Set
        QuestionText = Coalesce(@QuestionText, QuestionText),
        DifficultyLevel = Coalesce(@DifficultyLevel, DifficultyLevel),
        QuestionMark = Coalesce(@QuestionMark, QuestionMark),
        CourseID = Coalesce(@CourseID, CourseID),
        QuestionType = Coalesce(@QuestionType, QuestionType)
    Where QuestionID = @QuestionID;

    Print 'Question updated successfully.';
End;
Go

-- =======================
-- Procedure to delete a question
-- =======================
Create Or Alter Procedure sp_deleteQuestion
    @QuestionID Int
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = dbo.GetCurrentInstructorID();

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (
        Select 1
        From Question Q
        Join Course C On Q.CourseID = C.CourseID
        Where Q.QuestionID = @QuestionID And C.InstructorID = @InstructorID
    )
        Throw 51000, 'You are not allowed to delete this question.', 1;

    Delete From Question
    Where QuestionID = @QuestionID;

    Print 'Question deleted successfully.';
End;
Go

-- =======================
-- Procedure to create random exam
-- =======================
Create Or Alter Procedure sp_createRandomExam
    @ExamID Int,
    @ExamType NVarChar(50),
    @BIT_ID Int,
    @Duration Int,
    @No_Of_MCQ Int,
    @No_Of_TextQ Int,
    @No_Of_TFQ Int,
    @MaxGrade Decimal(6,2),
    @AllowanceOptions NVarChar(100),
    @CourseID Int,
    @MinGrade Int
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = dbo.GetCurrentInstructorID();

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to create exams for this course.', 1;

    Insert Into Exam (ExamID, ExamType, BIT_ID, Duration, No_Of_MCQ, No_Of_TextQ, No_Of_TFQ, MaxGrade, AllowanceOptions, InstructorID, CourseID, MinGrade)
    Values (@ExamID, @ExamType, @BIT_ID, @Duration, @No_Of_MCQ, @No_Of_TextQ, @No_Of_TFQ, @MaxGrade, @AllowanceOptions, @InstructorID, @CourseID, @MinGrade);

    Insert Into ExamQuestion (ExamID, QuestionID)
    Select Top (@No_Of_MCQ) @ExamID, QuestionID
    From Question
    Where CourseID = @CourseID And QuestionType = 'MCQ'
    Order By NewID();

    Insert Into ExamQuestion (ExamID, QuestionID)
    Select Top (@No_Of_TextQ) @ExamID, QuestionID
    From Question
    Where CourseID = @CourseID And QuestionType = 'Text'
    Order By NewID();

    Insert Into ExamQuestion (ExamID, QuestionID)
    Select Top (@No_Of_TFQ) @ExamID, QuestionID
    From Question
    Where CourseID = @CourseID And QuestionType = 'TF'
    Order By NewID();

    Print 'Exam created successfully and questions assigned.';
End;
Go

-- =======================
-- Procedure to create manual exam
-- =======================
Create Or Alter Procedure sp_createManualExam
    @ExamID Int,
    @ExamType NVarChar(50),
    @BIT_ID Int,
    @Duration Int,
    @MaxGrade Decimal(6,2),
    @AllowanceOptions NVarChar(100),
    @CourseID Int,
    @MinGrade Int,
    @No_Of_MCQ Int,
    @No_Of_TextQ Int,
    @No_Of_TFQ Int,
    @QuestionIDs NVarChar(Max)
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = dbo.GetCurrentInstructorID();

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to create exams for this course.', 1;

    Declare @QuestionTable Table (QuestionID Int);
    Insert Into @QuestionTable (QuestionID)
    Select Try_Cast(value As Int)
    From String_Split(@QuestionIDs, ',');

    If Exists (Select 1 From @QuestionTable qt Left Join Question q On qt.QuestionID = q.QuestionID Where q.QuestionID Is Null Or q.CourseID <> @CourseID)
        Throw 51001, 'One or more QuestionIDs do not exist or do not belong to this course.', 1;

    Insert Into Exam (ExamID, ExamType, BIT_ID, Duration, MaxGrade, AllowanceOptions, InstructorID, CourseID, MinGrade, No_Of_MCQ, No_Of_TextQ, No_Of_TFQ)
    Values (@ExamID, @ExamType, @BIT_ID, @Duration, @MaxGrade, @AllowanceOptions, @InstructorID, @CourseID, @MinGrade, @No_Of_MCQ, @No_Of_TextQ, @No_Of_TFQ);

    Insert Into ExamQuestion (ExamID, QuestionID)
    Select @ExamID, QuestionID
    From @QuestionTable;

    Print 'Manual exam created successfully.';
End;
Go

-- =======================
-- Procedure to update an exam
-- =======================
Create Or Alter Procedure sp_updateExam
    @ExamID Int,
    @ExamType NVarChar(50) = Null,
    @Duration Int = Null,
    @No_Of_MCQ Int = Null,
    @No_Of_TextQ Int = Null,
    @No_Of_TFQ Int = Null,
    @MaxGrade Decimal(6,2) = Null,
    @AllowanceOptions NVarChar(100) = Null
As
Begin
    Declare @InstructorID Int = dbo.GetCurrentInstructorID();
    
    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Exam Where ExamID = @ExamID And InstructorID = @InstructorID)
        Throw 51001, 'You are not allowed to update this exam.', 1;

    Update Exam
    Set ExamType = IsNull(@ExamType, ExamType),
        Duration = IsNull(@Duration, Duration),
        No_Of_MCQ = IsNull(@No_Of_MCQ, No_Of_MCQ),
        No_Of_TextQ = IsNull(@No_Of_TextQ, No_Of_TextQ),
        No_Of_TFQ = IsNull(@No_Of_TFQ, No_Of_TFQ),
        MaxGrade = IsNull(@MaxGrade, MaxGrade),
        AllowanceOptions = IsNull(@AllowanceOptions, AllowanceOptions)
    Where ExamID = @ExamID And InstructorID = @InstructorID;
End;
Go

-- =======================
-- Procedure to delete an exam
-- =======================
Create Or Alter Procedure sp_deleteExam
    @ExamID Int
As
Begin
    Declare @InstructorID Int = dbo.GetCurrentInstructorID();

    If @InstructorID Is Null
        Throw 51020, 'Current instructor not found.', 1;

    If Not Exists (Select 1 From Exam Where ExamID = @ExamID And InstructorID = @InstructorID)
        Throw 51002, 'You are not allowed to delete this exam.', 1;

    Delete From StudentExam Where ExamID = @ExamID;
    Delete From ExamQuestion Where ExamID = @ExamID;
    Delete From Exam Where ExamID = @ExamID And InstructorID = @InstructorID;
End;
Go


-- =======================
-- Procedure to assign exam to students of a course
-- =======================
CREATE OR ALTER PROCEDURE sp_assignExamToCourseStudents
    @ExamID INT,
    @CourseID INT,
    @ExamDate DATE,
    @StartTime TIME,
    @EndTime TIME
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamID = @ExamID)
    BEGIN
        RAISERROR('Exam does not exist.', 16, 1);
        RETURN;
    END

    -- 2. Check if course exists
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
    BEGIN
        RAISERROR('Course does not exist.', 16, 1);
        RETURN;
    END

    -- 3. Assign exam to students enrolled in the course
    INSERT INTO StudentExam (StudentID, ExamID, ExamDate, StartTime, EndTime)
    SELECT S.StudentID, @ExamID, @ExamDate, @StartTime, @EndTime
    FROM Student S
    JOIN StudentCourse SC ON S.StudentID = SC.StudentID
    WHERE SC.CourseID = @CourseID
      AND NOT EXISTS (
          SELECT 1 
          FROM StudentExam SE 
          WHERE SE.StudentID = S.StudentID AND SE.ExamID = @ExamID
      );

    PRINT 'Exam assigned to all enrolled students successfully.';
END;
GO
-- =======================
-- Procedure to manually correct student exam
-- =======================
CREATE OR ALTER PROCEDURE dbo.sp_CorrectExamManually
    @StudentID     INT,
    @ExamID        INT,
    @QuestionID    INT,
    @Grade         DECIMAL(5,2),   -- the grade instructor gives
    @IsValid       BIT = NULL      -- optional: instructor marks valid/invalid
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate that this is a text question
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Question
        WHERE QuestionID = @QuestionID
          AND QuestionType = 'Text'
    )
    BEGIN
        RAISERROR('Only text questions can be corrected manually.', 16, 1);
        RETURN;
    END

    -- Update student’s answer grade
    UPDATE dbo.StudentExamQuestion
    SET 
        StudentQGrade   = @Grade,
        AnswerIsValid   = ISNULL(@IsValid, AnswerIsValid) -- update if provided
    WHERE StudentID  = @StudentID
      AND ExamID     = @ExamID
      AND QuestionID = @QuestionID;
END;
GO
-- =======================
-- Procedure to update total exam grade for a student
-- =======================
Create Or Alter Procedure dbo.sp_UpdateExamTotalGrade
    @StudentID Int,
    @ExamID Int
As
Begin
    Set Nocount On;

    -- Check that the student exists
    If Not Exists (Select 1 From Student Where StudentID = @StudentID)
    Begin
        Raiserror('Student does not exist.', 16, 1);
        Return;
    End;

    -- Check that the exam exists
    If Not Exists (Select 1 From Exam Where ExamID = @ExamID)
    Begin
        Raiserror('Exam does not exist.', 16, 1);
        Return;
    End;

    -- Check that the student is registered for the exam
    If Not Exists (
        Select 1 From StudentExam
        Where StudentID = @StudentID And ExamID = @ExamID
    )
    Begin
        Raiserror('This student is not registered for this exam.', 16, 1);
        Return;
    End;

    -- Check that all text questions are graded
    If Exists (
        Select 1
        From StudentExamQuestion SEQ
        Join Question Q On SEQ.QuestionID = Q.QuestionID
        Where SEQ.StudentID = @StudentID
          And SEQ.ExamID = @ExamID
          And Q.QuestionType = 'Text'
          And SEQ.StudentQGrade Is Null
    )
    Begin
        Raiserror('Some text questions are not graded yet. Please correct them first.', 16, 1);
        Return;
    End;

    -- Calculate the total exam grade
    Declare @ExamTotal Decimal(10,2);

    Select @ExamTotal = Sum(Isnull(SEQ.StudentQGrade,0))
    From StudentExamQuestion SEQ
    Where SEQ.StudentID = @StudentID
      And SEQ.ExamID = @ExamID;

    -- Update the StudentExam table with the total grade
    Update StudentExam
    Set StudentGrade = @ExamTotal
    Where StudentID = @StudentID
      And ExamID = @ExamID;

    -- Get the CourseID related to the exam
    Declare @CourseID Int;
    Select @CourseID = CourseID From Exam Where ExamID = @ExamID;

    -- Update the StudentCourse grade with the same total
    Update StudentCourse
    Set StudGrade = @ExamTotal
    Where StudentID = @StudentID
      And CourseID = @CourseID;

    Print 'Exam total grade and course grade updated successfully.';
End;
Go
-- =======================
-- View to show current instructor courses
-- =======================
CREATE OR ALTER PROCEDURE ShowCurrentInstructorCourses
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentInstructorID INT = dbo.GetCurrentInstructorID();
    --current instructor courses
    SELECT 
        C.CourseID,
        C.CourseName,
        C.CourseDescription,
        C.MinDegree,
        C.MaxDegree,
        C.CourseStatus,
        C.TrackID
    FROM Course C
    WHERE C.InstructorID = @CurrentInstructorID
    ORDER BY C.CourseName;
END;
GO

-- =======================
-- Procedure to show current instructor questions
-- =======================
Create Or Alter Procedure sp_viewInstructorQuestions
    @CourseID Int
As
Begin
    Set Nocount On;

    Declare @InstructorID Int = dbo.GetCurrentInstructorID();

    If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @InstructorID)
        Throw 51000, 'You are not allowed to view questions for this course.', 1;

    Select Q.QuestionID, Q.QuestionType, Q.QuestionText, Q.DifficultyLevel, Q.QuestionMark
    From Question Q
    Where Q.CourseID = @CourseID
    Order By Q.QuestionID;
End;
Go
-- =======================
-- View to show current instructor Exams
-- =======================
CREATE OR ALTER PROCEDURE SP_ShowCourceExams 
	@CourseID Int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentInstructorID INT = dbo.GetCurrentInstructorID();
    --current instructor exams
	If Not Exists (Select 1 From Course Where CourseID = @CourseID And InstructorID = @CurrentInstructorID)
    Throw 51000, 'You are not allowed to view that course exams.', 1;
    SELECT 
        E.ExamID,
		E.CourseID,
		C.CourseName,
		E.ExamType,
		E.MinGrade,
		E.MaxGrade,
		E.No_Of_MCQ,
		E.No_Of_TextQ,
		E.No_Of_TFQ
    FROM Exam E inner join Course C
	ON E.CourseID = C.CourseID
    WHERE C.InstructorID = @CurrentInstructorID
END;
GO
--======================================================================================
/*Purpose: Retrieve all questions for a specific course taught by the current instructor, 
         optionally filtered by difficulty level and/or question type. 
         Also includes choices for each question if applicable.*/
--=====================================================================================
CREATE OR ALTER PROCEDURE sp_viewInstructorQuestions
    @CourseID INT,
    @DifficultyLevel NVARCHAR(20) = NULL,   -- Optional filter
    @QuestionType NVARCHAR(50) = NULL       -- Optional filter
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InstructorID INT =dbo.GetCurrentInstructorID()

    -- Verify instructor exists
    IF @InstructorID IS NULL
        THROW 51020, 'Current instructor not found.', 1;

    -- Verify instructor teaches the course
    IF NOT EXISTS (
        SELECT 1 
        FROM Course 
        WHERE CourseID = @CourseID 
          AND InstructorID = @InstructorID
    )
        THROW 51000, 'You are not allowed to view questions for this course.', 1;

    -- Select questions for the course with optional filters
    SELECT 
        q.QuestionID,
        q.CourseID,
        c.CourseName,
        q.QuestionType,
        q.QuestionText,
        q.DifficultyLevel,
        q.QuestionMark,
        ch.ChoiceLetter,
        ch.ChoiceText,
        ch.IsCorrect
    FROM Question q
    INNER JOIN Course c
        ON q.CourseID = c.CourseID
    LEFT JOIN Choices ch
        ON q.QuestionID = ch.QuestionID
    WHERE q.CourseID = @CourseID
      AND (@DifficultyLevel IS NULL OR q.DifficultyLevel = @DifficultyLevel)
      AND (@QuestionType IS NULL OR q.QuestionType = @QuestionType)
    ORDER BY q.QuestionID, ch.ChoiceLetter;
END;

GO

GO
--===========================================================================================
-- Description : This procedure retrieves student answers from the view dbo.vw_StudentAnswers
--               with optional filters by StudentID, CourseID, ExamID, and QuestionType.
--===========================================================================================
CREATE OR ALTER PROCEDURE dbo.sp_ViewStudentAnswers
    @StudentID    INT  = NULL,
    @CourseID     INT  = NULL,
    @ExamID       INT  = NULL,
    @QuestionType NVARCHAR(50) = NULL   -- 'Text', 'MCQ', 'TF', etc.
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_StudentAnswers
    WHERE (@StudentID IS NULL OR StudentID = @StudentID)
      AND (@CourseID  IS NULL OR CourseID  = @CourseID)
      AND (@ExamID    IS NULL OR ExamID    = @ExamID)
      AND (@QuestionType IS NULL OR QuestionType = @QuestionType);
END;
GO

--=================================================================================================================================
--============================================================Student objects======================================================
--=================================================================================================================================

-- ===============================================
-- Procedure: sp_StudentAnswerQuestion
-- Purpose: Submit an answer for a student for a specific question and grade it if MCQ/TF
-- ===============================================
Create Or Alter Procedure sp_StudentAnswerQuestion
    @QuestionID Int,
    @StudentQAnswer Nvarchar(Max)
As
Begin
    Set Nocount On;

    -- Get current student ID
    Declare @StudentID Int = dbo.GetCurrentStudentID();   
    If @StudentID Is Null
        Throw 51010, 'Current student not found.', 1;

    -- Get the ExamID assigned to this student for the question
    Declare @ExamID Int = (
        Select Top 1 SE.ExamID
        From StudentExam SE
        Inner Join ExamQuestion EQ On SE.ExamID = EQ.ExamID
        Where SE.StudentID = @StudentID
          And EQ.QuestionID = @QuestionID
    );

    If @ExamID Is Null
        Throw 51011, 'No assigned exam found for this question.', 1;

    -- Determine next sequence number for StudentExamQuestion
    Declare @NextSEQ Int;
    Select @NextSEQ = Isnull(Max(SEQ), 0) + 1
    From StudentExamQuestion;

    -- Get question type
    Declare @QType Nvarchar(50) = (Select QuestionType From Question Where QuestionID = @QuestionID);
    Declare @CorrectAnswer Nvarchar(Max);

    -- If question is MCQ or TF, check against correct choice
    If @QType In ('MCQ','TF')
    Begin
        Select @CorrectAnswer = ChoiceLetter 
        From Choices 
        Where QuestionID = @QuestionID And IsCorrect = 1;

        Insert Into StudentExamQuestion(SEQ, StudentID, ExamID, QuestionID, StudentQAnswer, AnswerIsValid, StudentQGrade)
        Values (
            @NextSEQ,
            @StudentID, 
            @ExamID, 
            @QuestionID, 
            @StudentQAnswer,
            Case When @StudentQAnswer = @CorrectAnswer Then 1 Else 0 End,
            Case When @StudentQAnswer = @CorrectAnswer 
                 Then (Select QuestionMark From Question Where QuestionID = @QuestionID) 
                 Else 0 End
        );
    End
    Else If @QType = 'Text'
    Begin
        -- For text questions, validate using fn_CompareTextAnswer
        Declare @IsValid Bit;
        Set @IsValid = dbo.fn_CompareTextAnswer(@QuestionID, @StudentQAnswer);

        Insert Into StudentExamQuestion(SEQ, StudentID, ExamID, QuestionID, StudentQAnswer, AnswerIsValid, StudentQGrade)
        Values (
            @NextSEQ,
            @StudentID,
            @ExamID,
            @QuestionID,
            @StudentQAnswer,
            @IsValid,
            Null
        );
    End
End;
Go
