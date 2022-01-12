/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
set statistics time, io on
SELECT
	Invoices.InvoiceID,
	Customers.CustomerName,
	Invoices.InvoiceDate
	,InvoiceLines.ExtendedPrice
	,x.ExtendedPriceInMonth
FROM
	Sales.Customers
JOIN
	Sales.Invoices ON
	Invoices.CustomerID = Customers.CustomerID
CROSS APPLY
	(
		SELECT
			SUM(InvoiceLines.ExtendedPrice) AS ExtendedPrice
		FROM
			Sales.InvoiceLines
		WHERE
			InvoiceLines.InvoiceID = Invoices.InvoiceID
	) AS InvoiceLines
CROSS APPLY
	(
		SELECT
			SUM(InvS.ExtendedPrice) AS ExtendedPriceInMonth
		FROM
			Sales.Invoices AS I
		JOIN
			Sales.InvoiceLines AS InvS ON
			InvS.InvoiceID = I.InvoiceID
		WHERE
			I.InvoiceDate >= '20150101' AND
			FORMAT(I.InvoiceDate, 'yyyyMM01') <= FORMAT(Invoices.InvoiceDate, 'yyyyMM01') 
	) AS x

WHERE
	Invoices.InvoiceDate >= '20150101' AND
	Invoices.InvoiceDate < '20150401' 
ORDER BY
	Invoices.InvoiceDate,
	Invoices.InvoiceID

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

SELECT
	DISTINCT
	Invoices.InvoiceID,
	Customers.CustomerName,
	Invoices.InvoiceDate
	,SUM (InvoiceLines.ExtendedPrice) OVER (PARTITION BY Invoices.InvoiceID) AS InvoicePrice
	,SUM (InvoiceLines.ExtendedPrice) OVER (ORDER BY FORMAT(Invoices.InvoiceDate, 'yyyyMM01')) AS InvoicePrice
FROM
	Sales.Customers
JOIN
	Sales.Invoices ON
	Invoices.CustomerID = Customers.CustomerID
JOIN
	Sales.InvoiceLines ON
	InvoiceLines.InvoiceID = Invoices.InvoiceID
WHERE
	Invoices.InvoiceDate >= '20150101' AND
	Invoices.InvoiceDate < '20150401' 	

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/
;
WITH t AS 
(
	SELECT
		FORMAT (Invoices.InvoiceDate, 'MM-yyyy') AS InvoiceMonth,
		InvoiceLines.StockItemID,
		SUM(InvoiceLines.Quantity) AS Quantity,
		RANK() OVER (PARTITION BY 
			FORMAT (Invoices.InvoiceDate, 'MM-yyyy')
			ORDER BY SUM(InvoiceLines.Quantity) DESC) AS n
	FROM
		Sales.Invoices
	JOIN
		Sales.InvoiceLines ON
		InvoiceLines.InvoiceID = Invoices.InvoiceID
	WHERE
		Invoices.InvoiceDate BETWEEN '20160101' AND '20170101'
	GROUP BY
		FORMAT (Invoices.InvoiceDate, 'MM-yyyy'),
		InvoiceLines.StockItemID
)
SELECT 
	t.InvoiceMonth,
	t.StockItemID,
	T.Quantity
FROM
	t
WHERE
	t.n <= 2
ORDER BY
	t.InvoiceMonth,
	t.n


/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT
	StockItems.StockItemID,
	StockItems.StockItemName,
	StockItems.UnitPrice,
	StockItems.Brand,
	ROW_NUMBER () OVER (PARTITION BY LEFT(StockItems.StockItemName, 1) ORDER BY StockItems.StockItemName) AS a,
	COUNT(StockItems.StockItemID) OVER () AS b,
	COUNT(StockItems.StockItemID) OVER (PARTITION BY LEFT(StockItems.StockItemName, 1)) AS c,
	LAG(StockItems.StockItemID) OVER (ORDER BY StockItems.StockItemName) AS d,
	LEAD(StockItems.StockItemID) OVER (ORDER BY StockItems.StockItemName) AS e,
	LAG(CAST (StockItems.StockItemID AS VARCHAR (100)), 2, 'No items') OVER (ORDER BY StockItems.StockItemName) AS f,
	StockItems.TypicalWeightPerUnit,
	NTILE(30) OVER (PARTITION BY StockItems.TypicalWeightPerUnit ORDER BY StockItems.StockItemName) AS g

FROM
Warehouse.StockItems

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
;
WITH t AS
(
	SELECT
		SalesPerson.PersonID AS SalesPersonID,
		SalesPerson.FullName AS SalesFullName,
		Customer.CustomerID AS CustomerID,
		Customer.CustomerName AS CustomerName,
		Invoices.InvoiceDate,
		SUM(InvoiceLines.ExtendedPrice) OVER (PARTITION BY Invoices.InvoiceID) AS a,
		ROW_NUMBER() OVER(PARTITION BY SalesPerson.PersonID ORDER BY Invoices.InvoiceDate DESC) AS b
	FROM
		Sales.Invoices
	JOIN
		Sales.InvoiceLines ON
		InvoiceLines.InvoiceID = Invoices.InvoiceID
	JOIN
		Application.People AS SalesPerson ON
		SalesPerson.PersonID = Invoices.SalespersonPersonID
	JOIN
		Sales.Customers AS Customer ON
		Customer.CustomerID = Invoices.CustomerID
)
SELECT
	t.SalesPersonID,
	t.SalesFullName,
	t.CustomerID,
	t.CustomerName,
	t.a
FROM
	t
WHERE
	t.b = 1

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

;
WITH t AS
(
	SELECT
		Customers.CustomerID,
		Customers.CustomerName,
		DENSE_RANK() OVER (
			PARTITION BY 
			Customers.CustomerID
			--,	InvoiceLines.StockItemID 
			ORDER BY InvoiceLines.ExtendedPrice DESC) AS m,
		InvoiceLines.StockItemID,
		InvoiceLines.ExtendedPrice,
		Invoices.InvoiceDate
	FROM
		Sales.Customers
	JOIN
		Sales.Invoices ON
		Invoices.CustomerID = Customers.CustomerID
	JOIN
		Sales.InvoiceLines ON
		InvoiceLines.InvoiceID = Invoices.InvoiceID
)
SELECT
	t.CustomerID,
	t.CustomerName,
	t.StockItemID,
	t.ExtendedPrice,
	t.InvoiceDate
FROM
	t
WHERE
	t.m <= 2
ORDER BY 
	t.CustomerID,
	t.m,
	t.InvoiceDate
