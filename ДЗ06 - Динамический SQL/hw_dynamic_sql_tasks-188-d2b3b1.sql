/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/




DECLARE @CustomerString	AS NVARCHAR (MAX) = ''


-- Функция string_agg падает с ошибкой, по этому использовал альтернативный способ
SELECT
	@CustomerString = @CustomerString + Customers.CustomerName + '],['
FROM
	Sales.Customers WITH (NOLOCK)

IF LEN (@CustomerString) > 0
BEGIN
	SET @CustomerString = '[' + LEFT (@CustomerString, LEN (@CustomerString) - 3) + ']'
END


DECLARE @SQL	AS NVARCHAR (MAX) = ''


-- Т.к. входных переменных нет, то использовал exec (@sql), а не exec sp_executesql @sql
SET @SQL = 
'SELECT
	FORMAT (InvoiceDate, ''dd.MM.yyyy'') AS InvoiceDate,
	' + @CustomerString + '
FROM
(
	SELECT
		CAST (FORMAT (Invoices.InvoiceDate, ''01.MM.yyyy'') AS DATE) InvoiceDate,
		Customers.CustomerName,
		Invoices.InvoiceID
	FROM
		Sales.Customers WITH (NOLOCK)
	JOIN
		Sales.Invoices WITH (NOLOCK) ON
		Invoices.CustomerID = Customers.CustomerID
) AS t
PIVOT
(	
	COUNT (InvoiceID) FOR CustomerName IN (' + @CustomerString + ')
) AS pvt
ORDER BY
	CAST (InvoiceDate AS DATE)
'

EXEC (@SQL)
