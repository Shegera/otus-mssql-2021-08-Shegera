

-- Изначальный запрос

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
Ход мыслей.
1. Построить план запроса и посмотреть его в SQL Senrty Plan Explorer и статистику
2. С помощью парсера статистики обнаружил, что таблица CustomerTransactions не влияет на результат запроса.
3. SQL Senrty Plan Explorer показал узкое место в таблице Invoces, которое давало 30% нагрузки, при выполнении запроса.
Причина была в использовании keylookup. Решил эту проблему созданием индекса в включенными колонками.
4. Функция DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0 давала небольшое проседание при обработке. Т.к. типы данных
в колонках Inv.InvoiceDate и ord.OrderDate одинаковые (Date), то их можно сравнивать напрямую
5. Разбил запрос на 3 CTE для простоты чтения и смысл запроса стал более понятен, а сам запрос читабельнее (Мнение автора может не совпадать с мнением редакции :) )
6. Хинты не использовал, т.к. все мои попытки приводили только к ухудшению произолдительности и повышали риск поломки в будущем
*/

-- Создаю индекс для таблицы Invoices с включенными колонками, т.к. много ресурсов отъедалось на KeyLookup

SET STATISTICS IO, TIME ON;

CREATE NONCLUSTERED INDEX [IX_Sales_Invoices_INC_OrderID_CustomerID_BillToCustomerID_InvoiceDate] ON [Sales].[Invoices] ([InvoiceID] ASC) INCLUDE (OrderID, CustomerID, BillToCustomerID, InvoiceDate)
CREATE NONCLUSTERED INDEX [IX_Sales_Orders_INC_OrderID_CustomerID_OrderDate] ON [Sales].[Orders] ([OrderID] ASC) INCLUDE (CustomerID, OrderDate)

go
;
WITH 
-- Счета, связанные с ними заказы и позиции, 
-- созданные в один день и имеющие разных заказчиков
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
-- Отдельно вывел покупателей, с суммой покупок больше 250000
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
-- Товары от поставщика с ID 12 и транзакции по этим товарам
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

-- Убрал в отдельную CTE для удобства
--Sales.Orders AS ord
--    JOIN Sales.OrderLines AS det
--        ON det.OrderID = ord.OrderID
--    JOIN Sales.Invoices AS Inv 
--        ON Inv.OrderID = ord.OrderID

-- Ни на что не влияет
--JOIN 
--	Sales.CustomerTransactions AS Trans ON 
--	Trans.InvoiceID = Inv.InvoiceID

-- Убрал в CTE

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
	-- Улучшилась читабельность и немного производительность
	-- DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
	
GROUP BY Orders.OrderCustomerID, Orders.StockItemID
ORDER BY Orders.OrderCustomerID, Orders.StockItemID
