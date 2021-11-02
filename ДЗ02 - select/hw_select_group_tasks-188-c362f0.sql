/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT
	t.StockItemID,
	t.StockItemName
FROM
	Warehouse.StockItems AS t WITH (NOLOCK)
WHERE
	t.StockItemName LIKE '%urgent%' OR
	t.StockItemName LIKE 'Animal%'



/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT
	s.SupplierID,
	s.SupplierName
FROM
	Purchasing.Suppliers AS s WITH (NOLOCK)
LEFT JOIN
	Purchasing.PurchaseOrders AS po WITH (NOLOCK) ON
	po.SupplierID = s.SupplierID
WHERE
	po.SupplierID IS NULL


/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT
	o.OrderID,
	FORMAT (o.OrderDate, 'dd.MM.yyyy')	AS OrderDate,
	DATENAME (MONTH, o.OrderDate)		AS OrderMonth,
	DATENAME (QUARTER, o.OrderDate)		AS OrderQuarter,
	CASE
		WHEN
			DATEPART (MONTH, o.OrderDate) BETWEEN 1 AND 4
		THEN
			1
		WHEN
			DATEPART (MONTH, o.OrderDate) BETWEEN 5 AND 8
		THEN
			2
		ELSE
			3
	END	AS OrderThird,
	c.CustomerName
FROM
	Sales.Orders AS o WITH (NOLOCK)
JOIN
	Sales.OrderLines AS ol WITH (NOLOCK) ON
	ol.OrderID = o.OrderID AND
	(
		ol.UnitPrice > 100 OR
		ol.Quantity > 20
	)
JOIN
	Sales.Customers AS c WITH (NOLOCK) ON
	c.CustomerID = o.CustomerID
WHERE
	o.PickingCompletedWhen IS NOT NULL
ORDER BY
	OrderQuarter,
	OrderThird,
	o.OrderDate


SELECT
	o.OrderID,
	FORMAT (o.OrderDate, 'dd.MM.yyyy')	AS OrderDate,
	DATENAME (MONTH, o.OrderDate)		AS OrderMonth,
	DATENAME (QUARTER, o.OrderDate)		AS OrderQuarter,
	CASE
		WHEN
			DATEPART (MONTH, o.OrderDate) BETWEEN 1 AND 4
		THEN
			1
		WHEN
			DATEPART (MONTH, o.OrderDate) BETWEEN 5 AND 8
		THEN
			2
		ELSE
			3
	END	AS OrderThird,
	c.CustomerName
FROM
	Sales.Orders AS o WITH (NOLOCK)
JOIN
	Sales.OrderLines AS ol WITH (NOLOCK) ON
	ol.OrderID = o.OrderID AND
	(
		ol.UnitPrice > 100 OR
		ol.Quantity > 20
	)
JOIN
	Sales.Customers AS c WITH (NOLOCK) ON
	c.CustomerID = o.CustomerID
WHERE
	o.PickingCompletedWhen IS NOT NULL
ORDER BY
	OrderQuarter	ASC,
	OrderThird		ASC,
	o.OrderDate		ASC
OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY;

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT
	dm.DeliveryMethodName,
	po.ExpectedDeliveryDate,
	s.SupplierName,
	p.PreferredName
FROM
	Purchasing.PurchaseOrders AS po WITH (NOLOCK)
JOIN
	[Application].DeliveryMethods AS dm WITH (NOLOCK) ON
	dm.DeliveryMethodID = po.DeliveryMethodID AND
	dm.DeliveryMethodName IN ('Air Freight', 'Refrigerated Air Freight')
LEFT JOIN
	Purchasing.Suppliers AS s WITH (NOLOCK) ON
	s.SupplierID = po.SupplierID
LEFT JOIN
	[Application].People AS p WITH (NOLOCK) ON
	p.PersonID = po.ContactPersonID
WHERE
	po.ExpectedDeliveryDate BETWEEN '20130101' AND '20130131' AND
	po.IsOrderFinalized = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT
TOP 10
	i.OrderID,
	c.CustomerName,
	p.PreferredName
FROM
	Sales.Invoices AS i WITH (NOLOCK)
JOIN
	Sales.Customers AS c WITH (NOLOCK) ON
	c.CustomerID = i.CustomerID
JOIN
	[Application].People AS p WITH (NOLOCK) ON
	p.PersonID = i.SalespersonPersonID
ORDER BY
	i.InvoiceDate DESC

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT
	DISTINCT 
	c.CustomerID,
	c.CustomerName,
	c.PhoneNumber
FROM
	Sales.Invoices AS i WITH (NOLOCK)
JOIN
	Sales.InvoiceLines AS il WITH (NOLOCK) ON
	il.InvoiceID = i.InvoiceID
JOIN
	Warehouse.StockItems AS si WITH (NOLOCK) ON
	si.StockItemID = il.StockItemID AND
	si.StockItemName = 'Chocolate frogs 250g'
JOIN
	Sales.Customers AS c WITH (NOLOCK) ON
	c.CustomerID = i.CustomerID

/*
7. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	YEAR (i.InvoiceDate)	AS [Year],
	MONTH (i.InvoiceDate)	AS [Month],
	CAST (AVG (il.ExtendedPrice) AS DECIMAL (12,2))		AS AveragePrice,
	SUM (il.ExtendedPrice)		AS Price
FROM
	Sales.Invoices AS i WITH (NOLOCK)
JOIN
	Sales.InvoiceLines AS il WITH (NOLOCK) ON
	il.InvoiceID = i.InvoiceID
WHERE
	i.InvoiceDate IS NOT NULL
GROUP BY
	i.InvoiceDate

/*
8. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	YEAR (i.InvoiceDate)	AS [Year],
	MONTH (i.InvoiceDate)	AS [Month],
	SUM (il.ExtendedPrice)	AS Price
FROM
	Sales.Invoices AS i WITH (NOLOCK)
JOIN
	Sales.InvoiceLines AS il WITH (NOLOCK) ON
	il.InvoiceID = i.InvoiceID
GROUP BY
	i.InvoiceDate
HAVING 
	SUM (il.ExtendedPrice) > 10000

/*
9. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	YEAR (i.InvoiceDate)	AS [Year],
	MONTH (i.InvoiceDate)	AS [Month],
	si.StockItemName,
	SUM (il.ExtendedPrice)	AS Price,
	MIN (i.InvoiceDate)		AS FirstInvoiceDate,
	SUM (il.Quantity)		AS Quantity
FROM
	Sales.Invoices AS i WITH (NOLOCK)
JOIN
	Sales.InvoiceLines AS il WITH (NOLOCK) ON
	il.InvoiceID = i.InvoiceID
JOIN
	Warehouse.StockItems AS si WITH (NOLOCK) ON
	si.StockItemID = il.StockItemID
GROUP BY
	i.InvoiceDate,
	si.StockItemName
HAVING
	SUM (il.Quantity) < 50
ORDER BY
	i.InvoiceDate,
	si.StockItemName
-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 8-9 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
