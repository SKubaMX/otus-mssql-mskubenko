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

DECLARE @DML AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX) 

SELECT @ColumnName = ISNULL(@ColumnName + ',','') + QUOTENAME(A.CustomerName)
FROM (SELECT DISTINCT CustomerName
		FROM Sales.Customers
	) AS A

SET @DML=
N'SELECT InvoiceMonth, ' +@ColumnName + '
FROM (
	SELECT DISTINCT
		CustomerName,
		convert(varchar,DATEADD(dd,-(day(InvoiceDate)-1),InvoiceDate), 104) as InvoiceMonth,
		OrderID
	FROM Sales.Customers as SC
		JOIN Sales.Invoices AS SI 
			ON SC.CustomerID=SI.CustomerID
		JOIN Sales.InvoiceLines AS SIL
			ON SI.InvoiceID=SIL.InvoiceID
	) AS Cust

PIVOT (COUNT(OrderID) FOR CustomerName  in (' +@ColumnName + ')) AS PVT
ORDER BY year(InvoiceMonth), month(InvoiceMonth) '

EXEC sp_executesql @dml