/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Опционально - если вы знакомы с insert, update, merge, то загрузить эти данные в таблицу Warehouse.StockItems.
Существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 
*/


BEGIN TRAN

DECLARE @XML	AS XML

SELECT
	@XML = bulkcolumn
FROM
	OPENROWSET
( BULK 'C:\Users\Андрей\Documents\GitHub\otus-mssql-2021-08-Shegera\ДЗ08 - XML JSON\StockItems-188-11a700.xml', SINGLE_CLOB)
AS DATA


DECLARE @docHandle AS INT
EXEC sp_xml_preparedocument @docHandle OUT, @XML



MERGE Warehouse.StockItems AS target
USING
(
	SELECT
		[StockItemName]				,
		[SupplierID]				,
		[UnitPackageID]				,
		[OuterPackageID]			,
		[QuantityPerOuter]			,
		[TypicalWeightPerUnit]		,
		[LeadTimeDays]				,
		[IsChillerStock]			,
		[TaxRate]					,
		[UnitPrice]				
	FROM
		OPENXML (@docHandle, N'/StockItems/Item')
	WITH (
		[StockItemName]			NVARCHAR (100) '@Name',
		[SupplierID]			INT 'SupplierID',
		[UnitPackageID]			INT 'Package/UnitPackageID',
		[OuterPackageID]		INT 'Package/OuterPackageID',
		[QuantityPerOuter]		INT 'Package/QuantityPerOuter',
		[TypicalWeightPerUnit]	DECIMAL (15,3) 'Package/TypicalWeightPerUnit',
		[LeadTimeDays]			INT 'LeadTimeDays',
		[IsChillerStock]		INT 'IsChillerStock',
		[TaxRate]				DECIMAL (15,3) 'TaxRate',
		[UnitPrice]				DECIMAL (14,2) 'UnitPrice'
	)
)
AS SOURCE (
[StockItemName]				  ,
[SupplierID]				   ,
[UnitPackageID]				   ,
[OuterPackageID]			   ,
[QuantityPerOuter]			   ,
[TypicalWeightPerUnit]		   ,
[LeadTimeDays]				   ,
[IsChillerStock]			   ,
[TaxRate]					   ,
[UnitPrice]				
)
ON
	(target.StockItemName = source.StockItemName)
WHEN MATCHED
	THEN
		UPDATE SET 
		[SupplierID]				 = source.[SupplierID]				   ,
		[UnitPackageID]				 = source.[UnitPackageID]			   ,
		[OuterPackageID]			 = source.[OuterPackageID]			   ,
		[QuantityPerOuter]			 = source.[QuantityPerOuter]		   ,
		[TypicalWeightPerUnit]		 = source.[TypicalWeightPerUnit]	   ,
		[LeadTimeDays]				 = source.[LeadTimeDays]			   ,
		[IsChillerStock]			 = source.[IsChillerStock]			   ,
		[TaxRate]					 = source.[TaxRate]					   ,
		[UnitPrice]					 = source.[UnitPrice]			
WHEN NOT MATCHED
	THEN
		INSERT (
			[StockItemName]					,
			[SupplierID]				   ,
			[UnitPackageID]				   ,
			[OuterPackageID]			   ,
			[QuantityPerOuter]			   ,
			[TypicalWeightPerUnit]		   ,
			[LeadTimeDays]				   ,
			[IsChillerStock]			   ,
			[TaxRate]					   ,
			[UnitPrice]	
			,LastEditedBy
		)
	VALUES
		(
			source.[StockItemName]				  ,
			source.[SupplierID]				   ,
			source.[UnitPackageID]			   ,
			source.[OuterPackageID]			   ,
			source.[QuantityPerOuter]		   ,
			source.[TypicalWeightPerUnit]	   ,
			source.[LeadTimeDays]			   ,
			source.[IsChillerStock]			   ,
			source.[TaxRate]				  ,
			source.[UnitPrice]		
			,1
		)
OUTPUT deleted.*, $action, inserted.*;
ROLLBACK		

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT
	TOP 3
	StockItemName			AS '@Name',
	SupplierID,
	UnitPackageID			AS 'Package/UnitPackageID',
	OuterPackageID			AS 'Package/OuterPackageID',
	QuantityPerOuter		AS 'Package/QuantityPerOuter',
	TypicalWeightPerUnit	AS 'Package/TypicalWeightPerUnit',
	LeadTimeDays,
	IsChillerStock,
	TaxRate,
	CAST (UnitPrice AS DECIMAL (18,6))	AS UnitPrice
FROM
	Warehouse.StockItems WITH (NOLOCK)
FOR XML PATH ('Item'), ROOT ('StockItems'), ELEMENTS

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT
	StockItemID,
	StockItemName,
	JSON_VALUE (CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture,
	JSON_VALUE (CustomFields, '$.Tags[0]') AS Tags
FROM
	Warehouse.StockItems WITH (NOLOCK)

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

SELECT
	StockItemID,
	StockItemName,
	CustomFields,
	( 
		SELECT
			STRING_AGG (value, ', ')
		FROM
			OPENJSON (CustomFields, '$.Tags')	
	)	AS CustomFieldsInString1, 
	(
		
		SELECT
			value + ', ' AS 'data()'
		FROM
			OPENJSON (CustomFields, '$.Tags')
		FOR XML PATH ('')
	)	AS CustomFieldsInString2

FROM
	Warehouse.StockItems WITH (NOLOCK)
WHERE
	EXISTS (
		SELECT
			*
		FROM
			OPENJSON (CustomFields, '$.Tags')
		WHERE
			value = 'Vintage'
	)


