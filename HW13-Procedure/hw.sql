/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/
CREATE FUNCTION CustomersMaxPayment()
RETURNS nvarchar (100)
AS 
BEGIN
    DECLARE @CustomersMaxPay nvarchar(100);
    
    SELECT TOP 1 
        @CustomersMaxPay = CustomerName
    FROM (
        SELECT 
            SC.CustomerName,
            SUM(SIL.UnitPrice * SIL.Quantity) AS TotalAmount
        FROM Sales.InvoiceLines SIL
        JOIN Sales.Invoices SI ON SIL.InvoiceID = SI.InvoiceID
        JOIN Sales.Customers SC ON SI.CustomerID = SC.CustomerID
        GROUP BY SC.CustomerName
    ) AS SubQuery
    ORDER BY TotalAmount DESC;

    RETURN @CustomersMaxPay;
END
GO
SELECT dbo.CustomersMaxPayment() AS MaxPayingCustomer;

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/
CREATE PROCEDURE SumPay (@CustomerID int)

AS  
    SET NOCOUNT ON; 

	SELECT CustomerName, SUM(UnitPrice*Quantity) AS 'Сумма покупки'
	FROM Sales.InvoiceLines AS SIL
	JOIN Sales.Invoices AS SI ON SIL.InvoiceID=SI.InvoiceID
	JOIN Sales.Customers AS SC ON SI.CustomerID=SC.CustomerID
	WHERE  SC.CustomerID = @customerid 
	GROUP BY CustomerName

	--Проверка работы процедуры
	exec SumPay
	@CustomerID = 10
 
/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
Выберите товары с минимальной ценой
*/
CREATE FUNCTION MinUnitPrice (@StockItemID int, @UnitPrice int)
RETURNS TABLE
AS 
RETURN 
( 
	SELECT [StockItemID],
	   [StockItemName], 
	   [UnitPrice]
FROM Warehouse.StockItems
WHERE UnitPrice = (SELECT MIN(UnitPrice) FROM Warehouse.StockItems where @StockItemID=StockItemID) and @StockItemID=StockItemID
)

CREATE PROCEDURE MinUnitPrice1 
@StockItemID int,
@UnitPrice int
AS  
    SET NOCOUNT ON; 

	SELECT [StockItemID],
		   [StockItemName], 
	       [UnitPrice]
FROM Warehouse.StockItems
WHERE @UnitPrice = (SELECT MIN(UnitPrice) FROM Warehouse.StockItems where @StockItemID=StockItemID) and @StockItemID=StockItemID

SET STATISTICS IO, TIME ON

--Проверка работы функции
SELECT * FROM MinUnitPrice (10, 32)

--Проверка работы процедуры
exec MinUnitPrice1
	@StockItemID = 10,
	@UnitPrice = 32

	Производительность получилась 50/50
/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

CREATE FUNCTION LastOrdersFunction()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        C.CustomerName,
        O.CustomerID
    FROM Sales.Customers C
    CROSS APPLY (
        SELECT TOP 2 
            CustomerID
        FROM Sales.Orders 
        WHERE 
            CustomerID = C.CustomerID
            AND OrderDate < '2014-01-01'
        ORDER BY 
            OrderDate DESC, 
            OrderID DESC
    ) AS O
);
GO
SELECT * 
FROM LastOrdersFunction()
ORDER BY CustomerName;
/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
