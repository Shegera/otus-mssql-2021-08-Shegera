
USE WideWorldImporters

DECLARE
	@CustomerId INT = 547,
	@DateFrom DATE = '20130101',
	@DateTo DATE = '20140101'

SELECT * FROM [ReportCustomerOrders]

SELECT 
	CustomerID, COUNT (OrderID) 
FROM 
	Sales.Orders 
WHERE
	CustomerID = @CustomerId AND
	OrderDate BETWEEN @DateFrom AND @DateTo
GROUP BY 
	CustomerID


-- Ручной привод
-- Отправка сообщения
EXEC Sales.GetCountOrdersByCustomerAndPeriod
	@CustomerID = @CustomerId, @DateFrom = @DateFrom, @DateTo = @DateTo;

SELECT CAST(message_body AS XML),*
FROM dbo.TargetQueueWWI;

SELECT CAST(message_body AS XML),*
FROM dbo.InitiatorQueueWWI;



--Обработка сообщения и ответ инициатору
EXEC Sales.SendCountOrdersByCustomerAndPeriod;

--Завершение диалога
EXEC Sales.ConfirmCountOrdersByCustomerAndPeriod;


