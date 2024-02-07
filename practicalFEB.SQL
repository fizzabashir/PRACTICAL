CREATE DATABASE PRACTICAL;
USE PRACTICAL;
-- Create Orders table--
Create table customers(
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    PhoneNumber VARCHAR(20)
);
-- Create Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
-- Create OrderDetails table
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Create Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    UnitPrice DECIMAL(10, 2),
    InStockQuantity INT
);

--  now insert into data into Customers
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, PhoneNumber)
VALUES (1, 'John', 'Doe', 'john.doe@example.com', '1234567890'),
       (2, 'Jimmy', 'Dsanil', 'jon.doe@example.com', '123457890'),
       (3, 'fiza', 'bashir', 'fizza.smith@example.com', '9873210'),
       (4, 'Jiya', 'Smth', 'iya.smith@example.com', '9876543210');
--now insert into data Products--
INSERT INTO Products (ProductID, ProductName, UnitPrice, InStockQuantity)
VALUES (1, 'milk', 10.99, 50),
       (2, 'juice', 20.49, 100),
       (3, 'chips', 15.99, 75);
 --now insert into data Orders tables
INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES (1, 1, '2024-02-01', 35.97),
       (2, 2, '2024-02-02', 45.48);
	   --now insert into data Orderdetails tables
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice)
VALUES
    (1, 1, 1, 2, 10.99),
    (2, 1, 2, 1, 5.99),
    (3, 2, 3, 3, 8.49);



 select*from orders
 select*from products
 select*from customers
 
-- 1) Create a new user named Order_Clerk with permission to insert new orders and update order details in the Orders and OrderDetails tables.--

 CREATE LOGIN Order_Clerk WITH PASSWORD = 'order';
CREATE USER Order_Clerk FOR LOGIN Order_Clerk;
GRANT INSERT, UPDATE ON dbo.Orders TO Order_Clerk;
GRANT INSERT, UPDATE ON dbo.OrderDetails TO Order_Clerk;



--2) Create a trigger named Update_Stock_Audit that logs any updates made to the InStockQuantity column of the Products table into a Stock_Update_Audit table.--

CREATE TABLE Stock_Update_Audit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT,
    OldQuantity INT,
    NewQuantity INT,
    UpdateDate DATETIME
);
CREATE TRIGGER Update_Stock_Audit
ON Products
After update
AS
Begin
    IF UPDATE(InStockQuantity)
    BEGIN
        INSERT INTO Stock_Update_Audit (ProductID, OldQuantity, NewQuantity, UpdateDate)
        SELECT 
          i.ProductID,
       d.InStockQuantity AS OldQuantity,
         i.InStockQuantity AS NewQuantity,
         GETDATE() AS UpdateDate
      FROM inserted i
      JOIN deleted d ON i.ProductID = d.ProductID
    END
END;


--3) Write a SQL query that retrieves the FirstName, LastName, OrderDate, and TotalAmount of orders along with the customer details by joining the Customers and Orders tables--
SELECT c.FirstName, c.LastName, o.OrderDate, o.TotalAmount FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID;

--5) Create a stored procedure named GetOrdersByCustomer that takes a CustomerID as input and returns all orders placed by that customer along with their details.--
CREATE PROCEDURE GetOrdersByCustomer
    @CustomerID INT
AS
begin
    Select O.OrderID, O.CustomerID, O.OrderDate, O.TotalAmount,
           OD.OrderDetailID, OD.ProductID, OD.Quantity, OD.UnitPrice
    FROM Orders O
    JOIN OrderDetails OD ON O.OrderID = OD.OrderID
    WHERE O.CustomerID = @CustomerID;
END;

--4) Write a SQL query that retrieves the ProductName, Quantity, and TotalPrice of products ordered in orders with a total amount greater than the average total amount of all orders.--
Select P.ProductName, OD.Quantity, (OD.Quantity * OD.UnitPrice) AS TotalPrice
From Products P
JOIN OrderDetails OD ON P.ProductID = OD.ProductID
JOIN Orders O ON OD.OrderID = O.OrderID WHERE O.TotalAmount > (SELECT AVG(TotalAmount) FROM Orders);

--6) Write a SQL query to create a view named OrderSummary that displays the OrderID, OrderDate, CustomerID, and TotalAmount from the Orders table--

CREATE VIEW OrderSummary AS
SELECT OrderID, OrderDate, CustomerID, TotalAmount
FROM Orders;
--7) Create a view named ProductInventory that shows the ProductName and InStockQuantity from the Products table--
CREATE VIEW ProductInventory as SELECT ProductName, InStockQuantity
FROM Products;

--8) Write a SQL query that joins the OrderSummary view with the Customers table to retrieve the customer's first name and last name along with their order details--
CREATE VIEW OrderSummary AS
  Select OrderID, OrderDate, CustomerID, TotalAmount
FROM Orders;
SELECT OS.OrderID, OS.OrderDate, C.FirstName, C.LastName, OD.ProductID, OD.Quantity, OD.UnitPrice
FROM OrderSummary OS JOIN Customers C ON OS.CustomerID = C.CustomerID
JOIN OrderDetails OD ON OS.OrderID = OD.OrderID;
