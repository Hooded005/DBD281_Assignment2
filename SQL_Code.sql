USE AdventureWorks2019
--Question 1
GO
--Display only certain column data
SELECT EmployeeDepartmentHistory.BusinessEntityID, NationalIDNumber, FirstName, LastName, Name AS Department, JobTitle
--Join all the necessary tables together so that each column data can be retrieved
FROM HumanResources.EmployeeDepartmentHistory
INNER JOIN HumanResources.Employee ON EmployeeDepartmentHistory.BusinessEntityID = Employee.BusinessEntityID
INNER JOIN Person.Person ON EmployeeDepartmentHistory.BusinessEntityID = Person.BusinessEntityID
INNER JOIN HumanResources.Department ON EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID
--The IS NULL condition is to make sure that this is the current department the employee is working in
WHERE EndDate IS NULL AND OrganizationLevel = 1;

--Question 2
GO
--First common table expresion - Gets the total purchases
WITH Purchases_CTE (ShipMethodID, TotalPurchases)
AS 
(
	SELECT ShipMethodID, ROUND(SUM(PurchaseOrderHeader.TotalDue),2) AS TotalPurchases
	FROM Purchasing.PurchaseOrderHeader
	GROUP BY ShipMethodID
),
--Second common table expresion - Gets the total sales
Sales_CTE (ShipMethodID, TotalSales)
AS 
(
	SELECT ShipMethodID, ROUND(SUM(SalesOrderHeader.TotalDue),2) AS TotalSales
	FROM Sales.SalesOrderHeader
	GROUP BY ShipMethodID
)
--Displays the name of the shipmethod, the total sales and total purchases done through that shipmethod
SELECT ShipMethod.ShipMethodID, Name, TotalSales, TotalPurchases
FROM Purchasing.ShipMethod
--Left join because even if there are null values it still needs to be displayed
LEFT JOIN Sales_CTE ON ShipMethod.ShipMethodID = Sales_CTE.ShipMethodID
LEFT JOIN Purchases_CTE ON ShipMethod.ShipMethodID = Purchases_CTE.ShipMethodID;

--Question 3
GO
--Select the title, firstname and lastname of each contact person
SELECT Title, FirstName, LastName,
--CASE statement to turn PersonType code into what the code stands for
'Person Type' = CASE PersonType
	WHEN 'EM' THEN 'Employee'
	WHEN 'SC' THEN 'Store Contact'
	WHEN 'IN' THEN 'Individual Customer'
	WHEN 'SP' THEN 'Sales Person'
	WHEN 'VC' THEN 'Vendor Contact'
	WHEN 'GC' THEN 'General Contact'
	ELSE 'Not Valid'
	END
FROM Person.Person;

--Question 4
GO
--Declare variables that will be used by the cursor
DECLARE @Name nvarchar(50)
DECLARE @ProdNumber nvarchar(25)
DECLARE @Start date
DECLARE @Finish date
DECLARE @Description nvarchar(255)

--Declare the cursor and the query it will search through
DECLARE special_cursor CURSOR FOR
SELECT Name, ProductNumber, StartDate, EndDate, Description
FROM Sales.SpecialOfferProduct
INNER JOIN  Sales.SpecialOffer ON SpecialOfferProduct.SpecialOfferID = SpecialOffer.SpecialOfferID
INNER JOIN Production.Product ON SpecialOfferProduct.ProductID = Product.ProductID
WHERE Product.ProductID = 707;

--Activate cursor and give it instruction for where to put the values in
OPEN special_cursor
FETCH NEXT FROM special_cursor INTO @Name, @ProdNumber, @Start, @Finish, @Description

--Print this information before the loop starts
PRINT CONCAT('Product Number:', @ProdNumber)
PRINT CONCAT('Product Name:', @Name)
PRINT 'Special Offers:'

--While there are still records left the loop will run
WHILE @@FETCH_STATUS = 0
BEGIN
	--Print this information as it is found in the loop
	PRINT CONCAT(@Start, ' to ', @Finish, ' ', @Description)
	--Assign new values to the variables
	FETCH NEXT FROM special_cursor INTO @Name, @ProdNumber, @Start, @Finish, @Description
END

--Close and deactivate the cursor
CLOSE special_cursor
DEALLOCATE special_cursor

--Question 5
--This statemet will give error because it needs to be the only code in the query editor to run successfully
GO
CREATE VIEW vwStoreSales AS

--The query that is stored in the view
SELECT Customer.CustomerID, Name as [Store Name], YEAR(OrderDate) AS [Year], ROUND(SUM(TotalDue),2) AS [YearSales]
FROM Sales.Customer
INNER JOIN Sales.Store ON Customer.StoreID = Store.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader ON Customer.CustomerID = SalesOrderHeader.CustomerID
GROUP BY Customer.CustomerID, YEAR(OrderDate), Name;
--Question 5-1
SELECT *
FROM vwStoreSales
  --Code to test the view created in Question 5
  WHERE YearSales > 100000
  ORDER BY CustomerID, [Year] desc;