

-- ����������� ������

Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM Sales.Orders AS ord
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans
        ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

/*
��� ������.
1. ��������� ���� ������� � ���������� ��� � SQL Senrty Plan Explorer � ����������
2. � ������� ������� ���������� ���������, ��� ������� CustomerTransactions �� ������ �� ��������� �������.
3. SQL Senrty Plan Explorer ������� ����� ����� � ������� Invoces, ������� ������ 30% ��������, ��� ���������� �������.
������� ���� � ������������� keylookup. ����� ��� �������� ��������� ������� � ����������� ���������.
4. ������� DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0 ������ ��������� ���������� ��� ���������. �.�. ���� ������
� �������� Inv.InvoiceDate � ord.OrderDate ���������� (Date), �� �� ����� ���������� ��������
5. ������ ������ �� 3 CTE ��� �������� ������ � ����� ������� ���� ����� �������, � ��� ������ ����������� (������ ������ ����� �� ��������� � ������� �������� :) )
6. ����� �� �����������, �.�. ��� ��� ������� ��������� ������ � ��������� ������������������ � �������� ���� ������� � �������
*/

-- ������ ������ ��� ������� Invoices � ����������� ���������, �.�. ����� �������� ���������� �� KeyLookup

SET STATISTICS IO, TIME ON;

CREATE NONCLUSTERED INDEX [IX_Sales_Invoices_INC_OrderID_CustomerID_BillToCustomerID_InvoiceDate] ON [Sales].[Invoices] ([InvoiceID] ASC) INCLUDE (OrderID, CustomerID, BillToCustomerID, InvoiceDate)
CREATE NONCLUSTERED INDEX [IX_Sales_Orders_INC_OrderID_CustomerID_OrderDate] ON [Sales].[Orders] ([OrderID] ASC) INCLUDE (CustomerID, OrderDate)

go
;
WITH 
-- �����, ��������� � ���� ������ � �������, 
-- ��������� � ���� ���� � ������� ������ ����������
Orders AS
(
SELECT
	Orders.OrderID,
	Orders.CustomerID		AS OrderCustomerID,
	Invoices.CustomerID		AS InvoiceCustomerID,
	OrderLines.StockItemID,
	OrderLines.UnitPrice,
	OrderLines.Quantity
FROM
	Sales.Orders AS Orders
JOIN 
	Sales.OrderLines AS OrderLines ON 
	OrderLines.OrderID = Orders.OrderID
JOIN 
	Sales.Invoices AS Invoices ON 
	Invoices.OrderID = Orders.OrderID AND
	Invoices.BillToCustomerID != Orders.CustomerID AND
	Invoices.InvoiceDate = Orders.OrderDate
),
-- �������� ����� �����������, � ������ ������� ������ 250000
Customers AS 
(
	SELECT 
		Orders.CustomerID
	FROM 
		Sales.Orders 
	JOIN
		Sales.OrderLines ON 
		Orders.OrderID = OrderLines.OrderID
	GROUP BY 
		Orders.CustomerID
	HAVING 
		SUM(OrderLines.UnitPrice * OrderLines.Quantity) > 250000
),
-- ������ �� ���������� � ID 12 � ���������� �� ���� �������
StockItems AS
(
	SELECT
		StockItems.StockItemID	
	FROM
		Warehouse.StockItems 
	JOIN
		Warehouse.StockItemTransactions  ON 
		StockItemTransactions.StockItemID = StockItems.StockItemID 
	WHERE
		StockItems.SupplierId = 12
)

Select 
	Orders.OrderCustomerID, 
	Orders.StockItemID, 
	SUM(Orders.UnitPrice)	AS UnitPrice, 
	SUM(Orders.Quantity)	AS Quantity, 
	COUNT(Orders.OrderID)		AS OrderID
FROM 
	Orders

-- ����� � ��������� CTE ��� ��������
--Sales.Orders AS ord
--    JOIN Sales.OrderLines AS det
--        ON det.OrderID = ord.OrderID
--    JOIN Sales.Invoices AS Inv 
--        ON Inv.OrderID = ord.OrderID

-- �� �� ��� �� ������
--JOIN 
--	Sales.CustomerTransactions AS Trans ON 
--	Trans.InvoiceID = Inv.InvoiceID

-- ����� � CTE

--JOIN 
--	Warehouse.StockItemTransactions AS ItemTrans ON 
--	ItemTrans.StockItemID = OrderLines.StockItemID 
--JOIN
--	Warehouse.StockItems AS It ON 
--	It.StockItemID = OrderLines.StockItemID AND
--	It.SupplierId = 12
JOIN
	StockItems ON
	StockItems.StockItemID = Orders.StockItemID
JOIN
	Customers ON
	Customers.CustomerID = Orders.InvoiceCustomerID
--WHERE 
	-- ���������� ������������� � ������� ������������������
	-- DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
	
GROUP BY Orders.OrderCustomerID, Orders.StockItemID
ORDER BY Orders.OrderCustomerID, Orders.StockItemID
