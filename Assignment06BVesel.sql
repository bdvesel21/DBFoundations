--*************************************************************************--
-- Title: Assignment06
-- Author: Brittany Vesel
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-11-23,Brittany Vesel,Created File
-- 2021-11-23,Brittany Vesel,Questions 1-10
-- 2021-11-23,Brittany Vesel,Question 11
-- 2021-11-23,Brittany Vesel,Finished File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_BrittanyVesel')
	 Begin 
	  Alter Database [Assignment06DB_BrittanyVesel] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_BrittanyVesel;
	 End
	Create Database Assignment06DB_BrittanyVesel;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_BrittanyVesel;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


--Show current column headings
Select * From Categories;
go


go
Create View vCategories
AS
	SELECT CategoryID, CategoryName
	FROM Categories;
go


--Show current column headings
Select * From Products;
go


go
Create View vProducts
AS
	SELECT ProductID, ProductName, CategoryID, UnitPrice
	FROM Products;
go


--Show current column headings
Select * From Inventories;
go


go
Create View vInventories
AS
	SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
	FROM Inventories;
go


--Show current column headings
Select * From Employees;
go


go
Create View vEmployees
AS
	SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	FROM Employees;
go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?


Deny Select On Categories to Public;
Grant Select On vCategories to Public;


Deny Select On Products to Public;
Grant Select On vProducts to Public;


Deny Select On Inventories to Public;
Grant Select On vInventories to Public;


Deny Select On Employees to Public;
Grant Select On vEmployees to Public;


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


--Query from Assignment 05
--SELECT CategoryName, ProductName, UnitPrice
--FROM Categories AS c
--INNER JOIN Products AS p ON c.CategoryID = p.CategoryID
--ORDER BY CategoryName, ProductName;
--go


--Add Top 100000
--SELECT Top 100000 CategoryName, ProductName, UnitPrice
--FROM Categories AS c
--INNER JOIN Products AS p ON c.CategoryID = p.CategoryID
--ORDER BY CategoryName, ProductName;
--go


--Create View
go
Create View vProductsByCategories
AS
	SELECT Top 100000 CategoryName, ProductName, UnitPrice
	FROM Categories AS c
	INNER JOIN Products AS p ON c.CategoryID = p.CategoryID
	ORDER BY CategoryName, ProductName;
go


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33


--Query from Assignment 05
--SELECT ProductName, InventoryDate, Count
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--ORDER BY InventoryDate, ProductName, Count;
--go


--Switch Order By
--SELECT ProductName, InventoryDate, Count
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--ORDER BY ProductName, InventoryDate, Count;
--go


--Add Top 100000
--SELECT Top 100000 ProductName, InventoryDate, Count
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--ORDER BY ProductName, InventoryDate, Count;
--go


--CreateView
go
Create View vInventoriesByProductsByDates
AS 
	SELECT Top 100000 ProductName, InventoryDate, Count
	FROM Products AS p
	INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
	ORDER BY ProductName, InventoryDate, Count;
go


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth


--Query from Assignment 05
--SELECT DISTINCT InventoryDate, (EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName
--FROM Employees
--INNER JOIN Inventories ON Employees.EmployeeID = Inventories.EmployeeID
--ORDER BY InventoryDate;
--go


--Add Top 100000
--SELECT DISTINCT Top 100000 InventoryDate, (EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName
--FROM Employees
--INNER JOIN Inventories ON Employees.EmployeeID = Inventories.EmployeeID
--ORDER BY InventoryDate;
--go

go
Create View vInventoriesByEmployeesByDates
AS
	SELECT DISTINCT Top 100000 InventoryDate, (EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName
	FROM Employees
	INNER JOIN Inventories ON Employees.EmployeeID = Inventories.EmployeeID
	ORDER BY InventoryDate;
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


--Query from Assignment 05
--SELECT CategoryName, ProductName, InventoryDate, Count 
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
--ORDER BY CategoryName, ProductName, InventoryDate, Count;
--go


--Add Top 100000
--SELECT Top 100000 CategoryName, ProductName, InventoryDate, Count 
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
--ORDER BY CategoryName, ProductName, InventoryDate, Count;
--go


go
Create View vInventoriesByProductsByCategories
AS
	SELECT Top 100000 CategoryName, ProductName, InventoryDate, Count 
	FROM Products AS p
	INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
	INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
	ORDER BY CategoryName, ProductName, InventoryDate, Count;
go


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan


--Query from Assignment 05
--SELECT 
--	CategoryName, 
--	ProductName, 
--	InventoryDate, 
--	Count, 
--	(EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
--INNER JOIN Employees AS e ON i.EmployeeID = e.EmployeeID
--ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
--go


--Add Top 100000
--SELECT Top 100000
--	CategoryName, 
--	ProductName, 
--	InventoryDate, 
--	Count, 
--	(EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
--INNER JOIN Employees AS e ON i.EmployeeID = e.EmployeeID
--ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
--go


go
Create View vInventoriesByProductsByEmployees
AS
	SELECT Top 100000 
		CategoryName, 
		ProductName, 
		InventoryDate, 
		Count, 
		(EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName
	FROM Products AS p
	INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
	INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
	INNER JOIN Employees AS e ON i.EmployeeID = e.EmployeeID
	ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


--Query from Assignment 05
--SELECT 
--	CategoryName, 
--	ProductName, 
--	InventoryDate, 
--	Count, 
--	(EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
--INNER JOIN Employees AS e ON i.EmployeeID = e.EmployeeID
--WHERE p.ProductID IN (SELECT ProductID 
--						FROM Products
--						WHERE ProductName IN ('Chai', 'Chang'))
--ORDER BY InventoryDate, CategoryName, ProductName;
--go


--Add Top 100000
--SELECT Top 100000 
--	CategoryName, 
--	ProductName, 
--	InventoryDate, 
--	Count, 
--	(EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
--INNER JOIN Employees AS e ON i.EmployeeID = e.EmployeeID
--WHERE p.ProductID IN (SELECT ProductID 
--						FROM Products
--						WHERE ProductName IN ('Chai', 'Chang'))
--ORDER BY InventoryDate, CategoryName, ProductName;
--go


go
Create View vInventoriesForChaiAndChangByEmployees
AS
	SELECT Top 100000 
		CategoryName, 
		ProductName, 
		InventoryDate, 
		Count, 
		(EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName
	FROM Products AS p
	INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
	INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
	INNER JOIN Employees AS e ON i.EmployeeID = e.EmployeeID
	WHERE p.ProductID IN (SELECT ProductID 
							FROM Products
							WHERE ProductName IN ('Chai', 'Chang'))
	ORDER BY InventoryDate, CategoryName, ProductName;
go


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are the rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King


--Query from Assignment 05
--SELECT 
--	(e2.EmployeeFirstName + ' '+ e2.EmployeeLastName) AS Manager, 
--	(e1.EmployeeFirstName + ' '+ e1.EmployeeLastName) AS Employee
--FROM Employees e1, Employees E2
--WHERE e1.ManagerID = e2.EmployeeID
--ORDER BY Manager, Employee;
--go


--Add Top 100000
--SELECT Top 100000
--	(e2.EmployeeFirstName + ' '+ e2.EmployeeLastName) AS Manager, 
--	(e1.EmployeeFirstName + ' '+ e1.EmployeeLastName) AS Employee
--FROM Employees e1, Employees E2
--WHERE e1.ManagerID = e2.EmployeeID
--ORDER BY Manager, Employee;
--go


go
Create View vEmployeesByManager
AS
	SELECT Top 100000
		(e2.EmployeeFirstName + ' '+ e2.EmployeeLastName) AS Manager, 
		(e1.EmployeeFirstName + ' '+ e1.EmployeeLastName) AS Employee
	FROM Employees e1, Employees E2
	WHERE e1.ManagerID = e2.EmployeeID
	ORDER BY Manager, Employee;
go


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth

--Show data from all tables
--Select * From Categories;
--go
--Select * From Products;
--go
--Select * From Employees;
--go
--Select * From Inventories;
--go


--Start with Assignment 05 Queries
--SELECT 
--	CategoryName, 
--	ProductName, 
--	InventoryDate, 
--	Count, 
--	(EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
--INNER JOIN Employees AS e ON i.EmployeeID = e.EmployeeID
--WHERE p.ProductID IN (SELECT ProductID 
--						FROM Products
--						WHERE ProductName IN ('Chai', 'Chang'))
--ORDER BY InventoryDate, CategoryName, ProductName;
--go
--SELECT 
--	(e2.EmployeeFirstName + ' '+ e2.EmployeeLastName) AS Manager, 
--	(e1.EmployeeFirstName + ' '+ e1.EmployeeLastName) AS Employee
--FROM Employees e1, Employees E2
--WHERE e1.ManagerID = e2.EmployeeID
--ORDER BY Manager, Employee;
--go


--add columns
--SELECT 
--	c.CategoryID,
--	CategoryName, 
--	p.ProductID,
--	ProductName,
--	UnitPrice,
--	i.InventoryID,
--	InventoryDate, 
--	Count,
--	e.EmployeeID,
--	(EmployeeFirstName + ' '+ EmployeeLastName) AS Employee
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
--INNER JOIN Employees AS e ON i.EmployeeID = e.EmployeeID;
--go


--Add order by
--SELECT 
--	c.CategoryID,
--	CategoryName, 
--	p.ProductID,
--	ProductName,
--	UnitPrice,
--	i.InventoryID,
--	InventoryDate, 
--	Count,
--	e.EmployeeID,
--	(EmployeeFirstName + ' '+ EmployeeLastName) AS Employee
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
--INNER JOIN Employees AS e ON i.EmployeeID = e.EmployeeID
--ORDER BY CategoryName, ProductName, InventoryID, Employee;
--go


--Add manager name
--SELECT 
--	c.CategoryID,
--	CategoryName, 
--	p.ProductID,
--	ProductName,
--	UnitPrice,
--	i.InventoryID,
--	InventoryDate, 
--	Count,
--	EmployeeResult.EmployeeID,
--	EmployeeResult.Employee,
--	EmployeeResult.Manager
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
--INNER JOIN
--(SELECT e1.EmployeeID,
--	(e1.EmployeeFirstName + ' '+ e1.EmployeeLastName) AS Employee,
--	(e2.EmployeeFirstName + ' '+ e2.EmployeeLastName) AS Manager
--FROM Employees e1, Employees E2
--WHERE e1.ManagerID = e2.EmployeeID) AS EmployeeResult
--ON i.EmployeeID = EmployeeResult.EmployeeID
--ORDER BY CategoryName, ProductName, InventoryID, Employee;
--go


--Add Top 100000
--SELECT Top 100000
--	c.CategoryID,
--	CategoryName, 
--	p.ProductID,
--	ProductName,
--	UnitPrice,
--	i.InventoryID,
--	InventoryDate, 
--	Count,
--	EmployeeResult.EmployeeID,
--	EmployeeResult.Employee,
--	EmployeeResult.Manager
--FROM Products AS p
--INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
--INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
--INNER JOIN
--(SELECT e1.EmployeeID,
--	(e1.EmployeeFirstName + ' '+ e1.EmployeeLastName) AS Employee,
--	(e2.EmployeeFirstName + ' '+ e2.EmployeeLastName) AS Manager
--FROM Employees e1, Employees E2
--WHERE e1.ManagerID = e2.EmployeeID) AS EmployeeResult
--ON i.EmployeeID = EmployeeResult.EmployeeID
--ORDER BY CategoryName, ProductName, InventoryID, Employee;
--go


go
Create View vInventoriesByProductsByCategoriesByEmployees
AS 
	SELECT Top 100000
		c.CategoryID,
		CategoryName, 
		p.ProductID,
		ProductName,
		UnitPrice,
		i.InventoryID,
		InventoryDate, 
		Count,
		EmployeeResult.EmployeeID,
		EmployeeResult.Employee,
		EmployeeResult.Manager
	FROM Products AS p
	INNER JOIN Inventories AS i ON p.ProductID = i.ProductID
	INNER JOIN Categories AS c ON p.CategoryID = c.CategoryID
	INNER JOIN
	(SELECT e1.EmployeeID,
		(e1.EmployeeFirstName + ' '+ e1.EmployeeLastName) AS Employee,
		(e2.EmployeeFirstName + ' '+ e2.EmployeeLastName) AS Manager
	FROM Employees e1, Employees E2
	WHERE e1.ManagerID = e2.EmployeeID) AS EmployeeResult
	ON i.EmployeeID = EmployeeResult.EmployeeID
	ORDER BY CategoryName, ProductName, InventoryID, Employee;
go

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/