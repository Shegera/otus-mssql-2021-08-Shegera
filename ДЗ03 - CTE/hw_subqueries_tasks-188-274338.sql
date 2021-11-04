/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/


;
WITH t
AS
(
	SELECT
		i.SalespersonPersonID
	FROM
		Sales.Invoices AS i WITH (NOLOCK)
	WHERE
		i.InvoiceDate = '20150704'
)
SELECT
	p.PersonID,
	p.FullName
FROM
	[Application].People AS p WITH (NOLOCK)
WHERE
	p.IsSalesperson = 1 AND
	p.PersonID NOT IN 
	(
		SELECT 
			*
		FROM
			t
	)


SELECT
	p.PersonID,
	p.FullName
FROM
	[Application].People AS p WITH (NOLOCK)
WHERE
	p.IsSalesperson = 1 AND
	p.PersonID NOT IN
	(
		SELECT
			i.SalespersonPersonID
		FROM
			Sales.Invoices AS i WITH (NOLOCK)
		WHERE
			i.InvoiceDate = '20150704'
	)




/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

SELECT
	si.StockItemID,
	si.StockItemName,
	si.UnitPrice
FROM
	Warehouse.StockItems AS si WITH (NOLOCK)
WHERE
	si.UnitPrice = 
	(
		SELECT
			MIN (si.UnitPrice)
		FROM
			Warehouse.StockItems AS si WITH (NOLOCK)
	)

SELECT
	si.StockItemID,
	si.StockItemName,
	si.UnitPrice
FROM
	Warehouse.StockItems AS si WITH (NOLOCK)
WHERE
	si.UnitPrice <= ALL
	(
		SELECT
			si.UnitPrice
		FROM
			Warehouse.StockItems AS si WITH (NOLOCK)
	)



/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

SELECT
	c.CustomerID,
	c.CustomerName
FROM
	Sales.Customers AS c WITH (NOLOCK)
WHERE
	c.CustomerID IN (
		SELECT
			TOP 5
			ct.CustomerID
		FROM
			Sales.CustomerTransactions AS ct WITH (NOLOCK)
		ORDER BY
			ct.TransactionAmount DESC
	)

SELECT
	c.CustomerID,
	c.CustomerName
FROM
	Sales.Customers AS c WITH (NOLOCK)
WHERE
	c.CustomerID = ANY (
		SELECT
			TOP 5
			ct.CustomerID
		FROM
			Sales.CustomerTransactions AS ct WITH (NOLOCK)
		ORDER BY
			ct.TransactionAmount DESC
	)

SELECT
	TOP 5
	ct.CustomerID,
	c.CustomerName,
	ct.TransactionAmount
FROM
	Sales.CustomerTransactions AS ct WITH (NOLOCK)
JOIN
	Sales.Customers AS c WITH (NOLOCK) ON
	c.CustomerID = ct.CustomerID
ORDER BY
	ct.TransactionAmount DESC
;
WITH t
AS
(
	SELECT
		TOP 5
		ct.CustomerID,
		ct.TransactionAmount
	FROM
		Sales.CustomerTransactions AS ct WITH (NOLOCK)
	ORDER BY	
		ct.TransactionAmount DESC
)
SELECT
	c.CustomerID,
	c.CustomerName,
	t.TransactionAmount
FROM
	Sales.Customers AS c WITH (NOLOCK)
JOIN
	t ON
	t.CustomerID = c.CustomerID


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

SELECT
	DISTINCT
	TOP 3
	cc.CityID,
	cc.CityName,
	p.FullName
FROM
	Sales.Invoices AS i WITH (NOLOCK)
JOIN
	(
		SELECT
			DISTINCT
			TOP 3
			il.ExtendedPrice,
			il.InvoiceID
		FROM
			Sales.InvoiceLines AS il WITH (NOLOCK)
		ORDER BY
			il.ExtendedPrice DESC
	) AS il
	 ON
	il.InvoiceID = i.InvoiceID
JOIN
	Sales.Customers AS c WITH (NOLOCK) ON
	c.CustomerID = i.CustomerID
JOIN
	[Application].Cities AS cc WITH (NOLOCK) ON
	cc.CityID = c.DeliveryCityID
JOIN
	[Application].People AS p WITH (NOLOCK) ON
	p.PersonID = i.PackedByPersonID


;
WITH il
AS
(
	SELECT
		DISTINCT
		TOP 3
		il.ExtendedPrice,
		il.InvoiceID
	FROM
		Sales.InvoiceLines AS il WITH (NOLOCK)
	ORDER BY
		il.ExtendedPrice DESC
)

SELECT
	DISTINCT
	TOP 3
	cc.CityID,
	cc.CityName,
	p.FullName
FROM
	Sales.Invoices AS i WITH (NOLOCK)
JOIN
	il ON
	il.InvoiceID = i.InvoiceID
JOIN
	Sales.Customers AS c WITH (NOLOCK) ON
	c.CustomerID = i.CustomerID
JOIN
	[Application].Cities AS cc WITH (NOLOCK) ON
	cc.CityID = c.DeliveryCityID
JOIN
	[Application].People AS p WITH (NOLOCK) ON
	p.PersonID = i.PackedByPersonID


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос


SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC


-- --


;
WITH SalesTotals
AS
(
	SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000
)

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	TotalSummForPickedItems.TotalSummForPickedItems
FROM 
	Sales.Invoices 
JOIN
	SalesTotals AS SalesTotals ON 
	Invoices.InvoiceID = SalesTotals.InvoiceID
JOIN
	Application.People ON
	People.PersonID = Invoices.SalespersonPersonID
CROSS APPLY
	(
		SELECT 
			SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice) AS TotalSummForPickedItems
		FROM 
			Sales.Orders
		JOIN
			Sales.OrderLines ON
			OrderLines.OrderId = Orders.OrderId 
		WHERE
			Orders.PickedByPersonID IS NOT NULL	
	) AS TotalSummForPickedItems
ORDER BY TotalSumm DESC

/*
Вывести ID заказа, Дату заказа, ФИО менеджера, 
стоимость позиций по счету (без налога) и стоимость позиций по заказу (без налога),
у которых сумма без налога больше 27000
*/
