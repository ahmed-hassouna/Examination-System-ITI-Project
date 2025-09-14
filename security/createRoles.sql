--============================================================================================================
-- -------------1- login to sql server as Admin and Create the four roles in the database system==============
--============================================================================================================
-- Drop roles if they already exist (safe re-run)
If Exists (Select * From sys.database_principals Where name = 'SuperManagerRole')
    Drop Role SuperManagerRole;
If Exists (Select * From sys.database_principals Where name = 'BranchManagerRole')
    Drop Role BranchManagerRole;
If Exists (Select * From sys.database_principals Where name = 'InstructorRole')
    Drop Role InstructorRole;
If Exists (Select * From sys.database_principals Where name = 'StudentRole')
    Drop Role StudentRole;
Go

-- Create roles
Create Role SuperManagerRole;
Go
Create Role BranchManagerRole;
Go
Create Role InstructorRole;
Go
Create Role StudentRole;