/* ============================================================================
   Index on Student.PersonID
   - PersonID is a foreign key referencing Person(PersonID)
   - This index improves Join performance between Student and Person tables
============================================================================ */
CREATE NONCLUSTERED INDEX IX_Student_PersonID
ON dbo.Student (PersonID)
ON FG_Index;


/* ============================================================================
   Composite Index on Student.FirstName + LastName
   - Optimizes queries that search by full name:
     SELECT * FROM Student WHERE FirstName = 'Ahmed' AND LastName = 'Hassouna'
============================================================================ */
CREATE NONCLUSTERED INDEX IX_Student_FullName
ON dbo.Person(FName, LName)
ON FG_Index;


/* ============================================================================
   Index on Branch.BranchName
   - Speeds up queries filtering by branch name:
     SELECT * FROM Branch WHERE BranchName = 'Cairo Branch'
============================================================================ */
CREATE NONCLUSTERED INDEX IX_Branch_BranchName
ON dbo.Branch(BranchName)
ON FG_Index;

