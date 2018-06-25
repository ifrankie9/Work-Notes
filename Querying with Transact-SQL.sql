
-------------------------------------------------------------------------------------------------------------------
-----------------------------------    1.   Introduction to Transact-SQL    ---------------------------------------
-------------------------------------------------------------------------------------------------------------------

-- select all columns
-- from the SalesLT.Customer table
SELECT * FROM SalesLT.Customer;


-- select the Title, FirstName, MiddleName, LastName and Suffix columns
-- from the Customer table
SELECT Title, FirstName, MiddleName, LastName, Suffix
FROM SalesLT.Customer;


-- finish the query
SELECT SalesPerson, Title + ' ' + LastName AS CustomerName, Phone
FROM SalesLT.Customer;


-- if you want to build a string with an integer (e.g. id) you can use: CAST(id AS VARCHAR)
-- cast the CustomerID column to a VARCHAR and concatenate with the CompanyName column
SELECT CAST(CustomerID AS VARCHAR) + ': ' + CompanyName AS CustomerCompany
FROM SalesLT.Customer;


-- The sales order number and revision number in the format e.g. SO71774 (2)
-- The order date converted to ANSI standard format yyyy.mm.dd (e.g. 2015.01.31)
SELECT SalesOrderNumber + ' (' + STR(RevisionNumber, 1) + ')' AS OrderRevision,
	   CONVERT(NVARCHAR(30), OrderDate, 102) AS OrderDate
FROM SalesLT.SalesOrderHeader;


-- use ISNULL to check for middle names and concatenate with FirstName and LastName
SELECT FirstName + ' ' + ISNULL(MiddleName + ' ', '') + LastName
AS CustomerName
FROM SalesLT.Customer;


-- COALESCE(A,B) return B if A is unknown
-- select the CustomerID, and use COALESCE with EmailAddress and Phone columns
-- PrimaryContact that contains the email address if known, and otherwise the phone number.
SELECT CustomerID, COALESCE(EmailAddress, Phone) AS PrimaryContact
FROM SalesLT.Customer;

-------------------------------------------------------------------------------------------------------------------
-----------------------------------    2.   Querying Tables with SELECT     ---------------------------------------
-------------------------------------------------------------------------------------------------------------------

-- Create new ShippingStatus depends on different cases
SELECT SalesOrderID, OrderDate,
  CASE
    WHEN ShipDate IS NULL THEN 'Awaiting Shipment'
    ELSE 'Shipped'
  END AS ShippingStatus
FROM SalesLT.SalesOrderHeader;


-- select unique cities, and state province
SELECT DISTINCT City, StateProvince
FROM SalesLT.Address;

-- select the top 10 percent from the Name column
SELECT TOP 10 PERCENT Name
FROM SalesLT.Product
-- order by the weight in descending order
ORDER BY Weight DESC
-- offset 10 rows and get the next 100
OFFSET 10 ROWS FETCH NEXT 100 ROWS ONLY;


-- select the Name, Color, and Size columns
SELECT Name, Color, Size
FROM SalesLT.Product
-- check ProductModelID is 1
WHERE ProductModelID = 1;

-- select the ProductNumber and Name columns
SELECT ProductNumber, Name
FROM SalesLT.Product
-- check that Color is one of 'Black', 'Red' or 'White'
-- check that Size is one of 'S' or 'M'
WHERE Color IN ('Black', 'Red', 'White') AND Size IN ('S', 'M');


-- select the ProductNumber, Name, and ListPrice columns
SELECT ProductNumber, Name, ListPrice
FROM SalesLT.Product
-- filter for product numbers beginning with BK- using LIKE
WHERE ProductNumber LIKE 'BK%';

-- select the ProductNumber, Name, and ListPrice columns
SELECT ProductNumber, Name, ListPrice
FROM SalesLT.Product
-- filter for ProductNumbers 
-- beginning with 'BK-' followed by any character other than 'R', and ending with a '-' followed by any two numerals.
WHERE ProductNumber LIKE 'BK-[^R]%-[0-9][0-9]';


-------------------------------------------------------------------------------------------------------------------
----------------------------------- 3.  Querying Multiple Tables with Joins   -------------------------------------
-------------------------------------------------------------------------------------------------------------------

-- select the CompanyName, SalesOrderId, and TotalDue columns from the appropriate tables
SELECT c.CompanyName, oh.SalesOrderId, oh.TotalDue
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS oh
-- join tables based on CustomerID
ON c.CustomerID = oh.CustomerID;


SELECT c.CompanyName, a.AddressLine1, ISNULL(a.AddressLine2, '') AS AddressLine2, a.City, 
a.StateProvince, a.PostalCode, a.CountryRegion, oh.SalesOrderID, oh.TotalDue
FROM SalesLT.Customer AS c
-- join the SalesOrderHeader table
JOIN SalesLT.SalesOrderHeader AS oh
ON oh.CustomerID = c.CustomerID
-- join the CustomerAddress table
JOIN SalesLT.CustomerAddress AS ca
-- filter for where the AddressType is 'Main Office'
ON c.CustomerID = ca.CustomerID AND AddressType = 'Main Office'
JOIN SalesLT.Address AS a
ON ca.AddressID = a.AddressID;

-----
-- The LEFT JOIN keyword returns all records from the left table (table1), 
-- and the matched records from the right table (table2). 
-- The result is NULL from the right side, if there is no match.
-----

-- select the CompanyName, FirstName, LastName, SalesOrderID and TotalDue columns
-- from the appropriate tables
SELECT c.CompanyName, c.FirstName, c.LastName, oh.SalesOrderID, oh.TotalDue
FROM SalesLT.Customer AS c
LEFT JOIN SalesLT.SalesOrderHeader AS oh
-- join based on CustomerID
ON c.CustomerID = oh.CustomerID
-- order the SalesOrderIDs from highest to lowest
ORDER BY oh.SalesOrderID DESC;


--Write a query that returns a list of customer IDs, company names, contact names (first name and last name), 
-- and phone numbers for customers with no address stored in the database.
SELECT c.CompanyName, c.FirstName, c.LastName, c.Phone
FROM SalesLT.Customer AS c
LEFT JOIN SalesLT.CustomerAddress AS ca
-- join based on CustomerID
ON c.CustomerID = ca.CustomerID
-- filter for when the AddressID doesn't exist
WHERE ca.AddressID IS NULL;


SELECT c.CustomerID, p.ProductID
FROM SalesLT.Customer AS c
FULL JOIN SalesLT.SalesOrderHeader AS oh
ON c.CustomerID = oh.CustomerID
FULL JOIN SalesLT.SalesOrderDetail AS od
-- join based on the SalesOrderID
ON od.SalesOrderID = oh.SalesOrderID
FULL JOIN SalesLT.Product AS p
-- join based on the ProductID
ON p.ProductID = od.ProductID
-- filter for nonexistent SalesOrderIDs
WHERE oh.SalesOrderID IS NULL
ORDER BY ProductID, CustomerID;
--REFERENCE START--
SalesLT.SalesOrderHeader as oh
SalesOrderID, CustomerID
---
SalesLT.SalesOrderDetail as od
SalesOrderID, ProductID
--REFERENCE END--


-------------------------------------------------------------------------------------------------------------------
-----------------------------------       4.    Using Set Operators         ---------------------------------------
-------------------------------------------------------------------------------------------------------------------

-- select the CompanyName, AddressLine1 columns
-- alias as per the instructions
SELECT c.CompanyName, a.AddressLine1, a.City, 'Billing' AS AddressType
FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca
-- join based on CustomerID
ON c.CustomerID = ca.CustomerID
-- join another table
JOIN SalesLT.Address AS a
-- join based on AddressID
ON ca.AddressID = a.AddressID
-- filter for where the correct AddressType
WHERE ca.AddressType = 'Main Office';
--REFERENCE START--
SalesLT.Customer AS c
c.CompanyName
c.CustomerID
--
SalesLT.CustomerAddress AS ca
ca.AddressType
ca.CustomerID
ca.AddressID
--
SalesLT.Address AS a
a.AddressLine1
a.AddressID
a.City
--REFERENCE END--


SELECT c.CompanyName, a.AddressLine1, a.City, 'Shipping' AS AddressType
FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca
ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address AS a
ON ca.AddressID = a.AddressID
WHERE ca.AddressType = 'Shipping';
--REFERENCE START--
SalesLT.Customer AS c
c.CompanyName
c.CustomerID
--
SalesLT.Address AS a
a.AddressLine1
a.City
a.AddressID
--
SalesLT.CustomerAddress AS ca
ca.CustomerID
ca.AddressID
ca.AddressType
--REFERENCE END--


--Combine two table
UNION ALL (combine all the combination), 
EXCEPT (not including part two), 
INTERSECT (the union part for both parts),


-------------------------------------------------------------------------------------------------------------------
-----------------------------------  5.  Using Functions and Aggregating Data   -----------------------------------
-------------------------------------------------------------------------------------------------------------------

-- select ProductID and use the appropriate functions with the appropriate columns
SELECT ProductId, UPPER(Name) AS ProductName, ROUND(Weight, 0) AS ApproxWeight
FROM SalesLT.Product;


SELECT ProductID, UPPER(Name) AS ProductName, ROUND(Weight, 0) AS ApproxWeight,
       -- get the year of the SellStartDate
       YEAR(SellStartDate) as SellStartYear,
       -- get the month datepart of the SellStartDate
       DATENAME(m, SellStartDate) as SellStartMonth
FROM SalesLT.Product;


SELECT ProductID, UPPER(Name) AS ProductName, ROUND(Weight, 0) AS ApproxWeight,
       YEAR(SellStartDate) as SellStartYear,
       DATENAME(m, SellStartDate) as SellStartMonth,
       -- use the appropriate function to extract substring from ProductNumber
       SUBSTRING(ProductNumber, 0, 3) AS ProductType --contains the leftmost two characters from the product number
FROM SalesLT.Product;


SELECT ProductID, UPPER(Name) AS ProductName, ROUND(Weight, 0) AS ApproxWeight,
       YEAR(SellStartDate) as SellStartYear,
       DATENAME(m, SellStartDate) as SellStartMonth,
       LEFT(ProductNumber, 2) AS ProductType
FROM SalesLT.Product
-- filter for numeric product size data
WHERE ISNUMERIC(Size) = 1;


-- select the Name column and use the appropriate function with the appropriate column
SELECT Name, SUM(LineTotal) AS TotalRevenue
FROM SalesLT.SalesOrderDetail AS SOD
-- use the appropriate join
JOIN SalesLT.Product AS P
-- join based on ProductID
ON SOD.ProductID = P.ProductID
GROUP BY P.Name
ORDER BY SUM(LineTotal) DESC;


SELECT Name, SUM(LineTotal) AS TotalRevenue
FROM SalesLT.SalesOrderDetail AS SOD
JOIN SalesLT.Product AS P
ON SOD.ProductID = P.ProductID
-- filter as per the instructions
WHERE P.ListPrice > 1000
GROUP BY P.Name
ORDER BY TotalRevenue DESC;


SELECT Name, SUM(LineTotal) AS TotalRevenue
FROM SalesLT.SalesOrderDetail AS SOD
JOIN SalesLT.Product AS P
ON SOD.ProductID = P.ProductID
WHERE P.ListPrice > 1000
GROUP BY P.Name
-- add having clause as per instructions
HAVING SUM(LineTotal) > 20000
ORDER BY TotalRevenue DESC;

-------------------------------------------------------------------------------------------------------------------
-----------------------------------     6.     Using Subqueries and APPLY     - -----------------------------------
-------------------------------------------------------------------------------------------------------------------

-- select the ProductID, Name, and ListPrice columns
SELECT ProductID, Name, ListPrice
FROM SalesLT.Product
-- filter based on ListPrice
WHERE ListPrice >
-- get the average UnitPrice
(SELECT AVG(UnitPrice) FROM SalesLT.SalesOrderDetail)
ORDER BY ProductID;


SELECT ProductID, Name, ListPrice
FROM SalesLT.Product
WHERE ProductID IN
  -- select ProductID from the appropriate table
  (SELECT ProductID FROM SalesLT.SalesOrderDetail
   WHERE UnitPrice < 100)
AND ListPrice >= 100
ORDER BY ProductID;


SELECT ProductID, Name, StandardCost, ListPrice,
(SELECT AVG(UnitPrice)
 FROM SalesLT.SalesOrderDetail AS SOD
 WHERE P.ProductID = SOD.ProductID) AS AvgSellingPrice
FROM SalesLT.Product AS P
-- filter based on StandardCost
WHERE StandardCost >
-- get the average UnitPrice
(SELECT AVG(UnitPrice)
 -- from the appropriate table aliased as SOD
 FROM SalesLT.SalesOrderDetail AS SOD
 -- filter when the appropriate ProductIDs are equal
 WHERE P.ProductID = SOD.ProductID)
ORDER BY P.ProductID;


-- select SalesOrderID, CustomerID, FirstName, LastName, TotalDue from the appropriate tables
SELECT SalesOrderID, CI.CustomerID, FirstName, LastName, TotalDue
FROM SalesLT.SalesOrderHeader AS SOH
-- cross apply as per the instructions
CROSS APPLY dbo.ufnGetCustomerInformation(SOH.CustomerID) AS CI
-- finish the clause
ORDER BY SOH.SalesOrderID;


-- select the CustomerID, FirstName, LastName, Addressline1, and City columns from the appropriate tables
SELECT CA.CustomerID, FirstName, LastName, A.Addressline1, A.City
FROM SalesLT.Address AS A
JOIN SalesLT.CustomerAddress AS CA
-- join based on AddressID
ON A.AddressID = CA.AddressID
-- cross apply as per instructions
CROSS APPLY dbo.ufnGetCustomerInformation(CA.CustomerID) AS CI
ORDER BY CA.CustomerID;

-------------------------------------------------------------------------------------------------------------------
-----------------------------------     7.     Using Table Expressions       --------------------------------------
-------------------------------------------------------------------------------------------------------------------

-- select the appropriate columns from the appropriate tables
SELECT P.ProductID, P.Name AS ProductName, PM.Name AS ProductModel, PM.Summary
FROM SalesLT.Product AS P
JOIN SalesLT.vProductModelCatalogDescription AS PM
-- join based on ProductModelID
ON P.ProductModelID = PM.ProductModelId
ORDER BY ProductID;


-- Create a table variable and populate it with a list of distinct colors from the SalesLT.Product table. 
DECLARE @Colors AS TABLE (Color NVARCHAR(15));

INSERT INTO @Colors
SELECT DISTINCT Color FROM SalesLT.Product;

SELECT ProductID, Name, Color
FROM SalesLT.Product
WHERE Color IN (SELECT Color FROM @Colors);


SELECT C.ParentProductCategoryName AS ParentCategory,
       C.ProductCategoryName AS Category,
       P.ProductID, P.Name AS ProductName
FROM SalesLT.Product AS P
JOIN dbo.ufnGetAllCategories() AS C
ON P.ProductCategoryID = C.ProductCategoryID
ORDER BY ParentCategory, Category, ProductName;


SELECT CompanyContact, SUM(SalesAmount) AS Revenue
FROM
	(SELECT CONCAT(c.CompanyName, CONCAT(' (' + c.FirstName + ' ', c.LastName + ')')), SOH.TotalDue
	 FROM SalesLT.SalesOrderHeader AS SOH
	 JOIN SalesLT.Customer AS c
	 ON SOH.CustomerID = c.CustomerID) AS CustomerSales(CompanyContact, SalesAmount)
GROUP BY CompanyContact
ORDER BY CompanyContact;


-------------------------------------------------------------------------------------------------------------------
-----------------------------------   8.  Grouping Sets and Pivoting Data    --------------------------------------
-------------------------------------------------------------------------------------------------------------------

SELECT a.CountryRegion, a.StateProvince, SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
JOIN SalesLT.CustomerAddress AS ca
ON a.AddressID = ca.AddressID
JOIN SalesLT.Customer AS c
ON ca.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderHeader as soh
ON c.CustomerID = soh.CustomerID
-- Modify GROUP BY to use ROLLUP
GROUP BY ROLLUP (a.CountryRegion, a.StateProvince)
ORDER BY a.CountryRegion, a.StateProvince;
-- "rolls up" the results into subtotals and grand totals.
-- To do this, it moves from right to left decreasing the number of column expressions over 
-- which it creates groups and the aggregation(s).


SELECT a.CountryRegion, a.StateProvince,
IIF(GROUPING_ID(CountryRegion) = 1 AND GROUPING_ID(a.StateProvince) = 1, 'Total', 
IIF(GROUPING_ID(StateProvince) = 1, a.CountryRegion + ' Subtotal', a.StateProvince + ' Subtotal')) AS Level,
SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
JOIN SalesLT.CustomerAddress AS ca
ON a.AddressID = ca.AddressID
JOIN SalesLT.Customer AS c
ON ca.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderHeader as soh
ON c.CustomerID = soh.CustomerID
GROUP BY ROLLUP(a.CountryRegion, a.StateProvince)
ORDER BY a.CountryRegion, a.StateProvince;


SELECT a.CountryRegion, a.StateProvince, a.City,
CHOOSE (1 + GROUPING_ID(CountryRegion) + GROUPING_ID(StateProvince) + GROUPING_ID(City),
        a.City + ' Subtotal', a.StateProvince + ' Subtotal',
        a.CountryRegion + ' Subtotal', 'Total') AS Level,
SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
JOIN SalesLT.CustomerAddress AS ca
ON a.AddressID = ca.AddressID
JOIN SalesLT.Customer AS c
ON ca.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderHeader as soh
ON c.CustomerID = soh.CustomerID
GROUP BY ROLLUP(a.CountryRegion, a.StateProvince, a.City)
ORDER BY a.CountryRegion, a.StateProvince, a.City;


SELECT * FROM
(SELECT cat.ParentProductCategoryName, CompanyName, LineTotal
 FROM SalesLT.SalesOrderDetail AS sod
 JOIN SalesLT.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
 JOIN SalesLT.Customer AS cust ON soh.CustomerID = cust.CustomerID
 JOIN SalesLT.Product AS prod ON sod.ProductID = prod.ProductID
 JOIN SalesLT.vGetAllCategories AS cat ON prod.ProductcategoryID = cat.ProductCategoryID) AS catsales
PIVOT (SUM(LineTotal) FOR ParentProductCategoryName
IN ([Accessories], [Bikes], [Clothing], [Components])) AS pivotedsales
ORDER BY CompanyName;


-------------------------------------------------------------------------------------------------------------------
-----------------------------------        9.       Modifying Data         ----------------------------------------
-------------------------------------------------------------------------------------------------------------------

-- Finish the INSERT statement
INSERT INTO SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
VALUES
('LED Lights', 'LT-L123', 2.56, 12.99, 37, GETDATE());

-- Get last identity value that was inserted
SELECT SCOPE_IDENTITY();

-- Finish the SELECT statement
SELECT * FROM SalesLT.Product
WHERE ProductID = SCOPE_IDENTITY();



-- Insert product category
INSERT INTO SalesLT.ProductCategory (ParentProductCategoryID, Name)
VALUES
(4, 'Bells and Horns');

-- Insert 2 products
INSERT INTO SalesLT.Product (Name, ProductNumber, 	StandardCost, ListPrice, ProductCategoryID, SellStartDate)
VALUES
('Bicycle Bell', 'BB-RING', 2.47, 4.99, IDENT_CURRENT('SalesLT.ProductCategory'), GETDATE()),
('Bicycle Horn', 'BB-PARP', 1.29, 3.75, IDENT_CURRENT('SalesLT.ProductCategory'), GETDATE());

-- Check if products are properly inserted
SELECT c.Name As Category, p.Name AS Product
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory as c ON p.ProductCategoryID = c.ProductCategoryID
WHERE p.ProductCategoryID = IDENT_CURRENT('SalesLT.ProductCategory');


-- Update the SalesLT.Product table
UPDATE SalesLT.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductCategoryID =
  (SELECT ProductCategoryID FROM SalesLT.ProductCategory WHERE Name = 'Bells and Horns');

-- You can add a SELECT statement to check the update
SELECT ProductCategoryID 
FROM SalesLT.Product


-- Finish the UPDATE query
UPDATE SalesLT.Product
SET DiscontinuedDate = GETDATE()
WHERE ProductCategoryID = 37
AND ProductNumber <> 'LT-L123';


-- Delete records from the SalesLT.Product table
DELETE FROM SalesLT.Product
WHERE ProductCategoryID =
	(SELECT ProductCategoryID FROM SalesLT.ProductCategory WHERE Name = 'Bells and Horns');



-------------------------------------------------------------------------------------------------------------------
-----------------------------------   10.  Programming with Transact-SQL   ----------------------------------------
-------------------------------------------------------------------------------------------------------------------

DECLARE @OrderDate datetime = GETDATE();
DECLARE @DueDate datetime = DATEADD(dd, 7, GETDATE());
DECLARE @CustomerID int = 1;

INSERT INTO SalesLT.SalesOrderHeader (OrderDate, DueDate, CustomerID, ShipMethod)
VALUES (@OrderDate, @DueDate, @CustomerID, 'CARGO TRANSPORT 5');

PRINT SCOPE_IDENTITY();



-- Code from previous exercise
DECLARE @OrderDate datetime = GETDATE();
DECLARE @DueDate datetime = DATEADD(dd, 7, GETDATE());
DECLARE @CustomerID int = 1;
INSERT INTO SalesLT.SalesOrderHeader (OrderDate, DueDate, CustomerID, ShipMethod)
VALUES (@OrderDate, @DueDate, @CustomerID, 'CARGO TRANSPORT 5');
DECLARE @OrderID int = SCOPE_IDENTITY();

-- Additional script to complete
DECLARE @ProductID int = 760;
DECLARE @Quantity int = 1;
DECLARE @UnitPrice money = 782.99;

IF EXISTS (SELECT * FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @OrderID)
BEGIN
	INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice)
	VALUES (@OrderID, @Quantity, @ProductID, @UnitPrice)
END
ELSE
BEGIN
	PRINT 'The order does not exist'
END



DECLARE @MarketAverage money = 2000;
DECLARE @MarketMax money = 5000;
DECLARE @AWMax money;
DECLARE @AWAverage money;

SELECT @AWAverage = AVG(ListPrice), @AWMax = MAX(ListPrice)
FROM SalesLT.Product
WHERE ProductCategoryID IN
	(SELECT DISTINCT ProductCategoryID
	 FROM SalesLT.vGetAllCategories
	 WHERE ParentProductCategoryName = 'Bikes');

WHILE @AWAverage < @MarketAverage
BEGIN
   UPDATE SalesLT.Product
   SET ListPrice = ListPrice * 1.1
   WHERE ProductCategoryID IN
	(SELECT DISTINCT ProductCategoryID
	 FROM SalesLT.vGetAllCategories
	 WHERE ParentProductCategoryName = 'Bikes');

	SELECT @AWAverage = AVG(ListPrice), @AWMax = MAX(ListPrice)
	FROM SalesLT.Product
	WHERE ProductCategoryID IN
	(SELECT DISTINCT ProductCategoryID
	 FROM SalesLT.vGetAllCategories
	 WHERE ParentProductCategoryName = 'Bikes');

   IF @AWMax >= @MarketMax
      BREAK
   ELSE
      CONTINUE
END

PRINT 'New average bike price:' + CONVERT(VARCHAR, @AWAverage);
PRINT 'New maximum bike price:' + CONVERT(VARCHAR, @AWMax);



-------------------------------------------------------------------------------------------------------------------
-----------------------------------  11.  Error Handling and Transactions  ----------------------------------------
-------------------------------------------------------------------------------------------------------------------
---- 1 ----
DECLARE @OrderID int = 0

-- Declare a custom error if the specified order doesn't exist
DECLARE @error VARCHAR(30) = 'Order #' + cast(@OrderID as VARCHAR) + ' does not exist';

IF NOT EXISTS (SELECT * FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID)
BEGIN
  THROW 50001, @error, 0;
END
ELSE
BEGIN
  DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @OrderID;
  DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID;
END


---- 2 ----
DECLARE @OrderID int = 71774
DECLARE @error VARCHAR(30) = 'Order #' + cast(@OrderID as VARCHAR) + ' does not exist';

-- Wrap IF ELSE in a TRY block
BEGIN TRY
  IF NOT EXISTS (SELECT * FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID)
  BEGIN
    THROW 50001, @error, 0
  END
  ELSE
  BEGIN
    DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @OrderID;
    DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID;
  END
END TRY
-- Add a CATCH block to print out the error
BEGIN CATCH
  PRINT ERROR_MESSAGE();
END CATCH


---- 3 ----
DECLARE @OrderID int = 0
DECLARE @error VARCHAR(30) = 'Order #' + cast(@OrderID as VARCHAR) + ' does not exist';

BEGIN TRY
  IF NOT EXISTS (SELECT * FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID)
  BEGIN
    THROW 50001, @error, 0
  END
  ELSE
  BEGIN
    BEGIN TRANSACTION
    DELETE FROM SalesLT.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;
    DELETE FROM SalesLT.SalesOrderHeader
    WHERE SalesOrderID = @OrderID;
    COMMIT TRANSACTION
  END
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0
  BEGIN
    ROLLBACK TRANSACTION;
  END
  ELSE
  BEGIN
    PRINT ERROR_MESSAGE();
  END
END CATCH



-------------------------------------------------------------------------------------------------------------------
-----------------------------------        Final Assessment Exercises      ----------------------------------------
-------------------------------------------------------------------------------------------------------------------

---- 1 ----
-- Select the quantity per unit for all products in the Products table.
SELECT QuantityPerUnit FROM Dbo.Products

---- 2 ----
-- Select the unique category IDs from the Products table.
SELECT DISTINCT CategoryID FROM Dbo.Products

---- 3 ----
-- Select the names of products from the Products table which have more than 20 units left in stock.
SELECT ProductName FROM Dbo.Products
WHERE UnitsInStock > 20;

---- 4 ----
-- Select the product ID, product name, and unit price of the 10 most expensive products from the Products table.
SELECT TOP 10 ProductID, ProductName, UnitPrice FROM Dbo.Products
ORDER BY UnitPrice DESC;

---- 5 ----
-- Select the product ID, product name, and quantity per unit for all products in the Products table. 
-- Sort your results alphabetically by product name (where A comes first).
SELECT ProductID, ProductName, QuantityPerUnit FROM Dbo.Products
ORDER BY ProductName;

---- 6 ----
-- Select the product ID, product name, and unit price of all products in the Products table. 
-- Sort your results by number of units in stock, from greatest to least.
-- Skip the first 10 results and get the next 5 after that.
SELECT DISTINCT CategoryID FROM Dbo.ProductsSELECT ProductID, ProductName, UnitPrice FROM Dbo.Products
ORDER BY UnitsInStock DESC
OFFSET 10 ROWS FETCH FIRST 5 ROW ONLY

---- 7 ----
-- display the first name, employee ID and birthdate (as Unicode in ISO 8601 format) 
-- for each employee in the Employees table.
SELECT FirstName + 
' has an EmployeeID of ' + 
CAST(EmployeeID AS VarChar(5)) + 
' and was born '
+ CONVERT(NVARCHAR(30), BirthDate, 126) AS Employees 
FROM Employees

---- 8 ----
-- <<ShipName>> is from <<ShipCity or ShipRegion or ShipCountry>>
SELECT ShipName + ' is from ' + COALESCE(ShipCity, ShipRegion, ShipCountry) AS Destination
FROM Dbo.Orders

---- 9 ----
-- Select the ship name and ship postal code from the Orders table. If the postal code is missing, display 'unknown'.
SELECT ShipName, ISNULL(ShipPostalCode, 'unknown') FROM Dbo.Orders

---- 10 ----
-- Using the Suppliers table, select the company name, 
-- and use a simple CASE expression to display 'outdated' if the company has a fax number, 
-- or 'modern' if it doesn't. Do this by specifying IS NULL in your conditional statement.
SELECT CompanyName,
CASE
   WHEN Fax IS NULL THEN 'modern'
   ELSE 'outdated'
END AS FaxStatus
FROM Dbo.Suppliers