SET STATISTICS TIME ON;
SET STATISTICS IO ON;
--исходный код:
Select ord.CustomerID, 
	   det.StockItemID, 
	   SUM(det.UnitPrice), 
	   SUM(det.Quantity), 
	   COUNT(ord.OrderID)
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
ORDER BY ord.CustomerID, det.StockItemID;

-- Started executing query at Line 1
-- SQL Server parse and compile time: 
--    CPU time = 160 ms, elapsed time = 177 ms.

--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.

--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
-- (3619 rows affected)
-- Table 'StockItemTransactions'. Scan count 1, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 66, lob physical reads 1, lob page server reads 0, lob read-ahead reads 130, lob page server read-ahead reads 0.
-- Table 'StockItemTransactions'. Segment reads 1, segment skipped 0.
-- Table 'OrderLines'. Scan count 4, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 518, lob physical reads 5, lob page server reads 0, lob read-ahead reads 795, lob page server read-ahead reads 0.
-- Table 'OrderLines'. Segment reads 2, segment skipped 0.
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
-- Table 'CustomerTransactions'. Scan count 5, logical reads 261, physical reads 4, page server reads 0, read-ahead reads 253, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
-- Table 'Orders'. Scan count 2, logical reads 883, physical reads 4, page server reads 0, read-ahead reads 849, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
-- Table 'Invoices'. Scan count 1, logical reads 71530, physical reads 2, page server reads 0, read-ahead reads 11606, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
-- Table 'StockItems'. Scan count 1, logical reads 2, physical reads 1, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

--  SQL Server Execution Times:
--    CPU time = 499 ms,  elapsed time = 597 ms.
-- Total execution time: 00:00:00.799

SELECT
    ord.CustomerID,
    det.StockItemID,
    SUM(det.UnitPrice) AS SumUnitPrice,
    SUM(det.Quantity) AS SumQuantity,
    COUNT(ord.OrderID) AS OrderCount
FROM Sales.Orders AS ord
    JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
WHERE
    Inv.BillToCustomerID != ord.CustomerID
    AND EXISTS (
        SELECT 1
        FROM Warehouse.StockItems AS It
        WHERE It.StockItemID = det.StockItemID
          AND It.SupplierID = 12
    )
    AND (
        SELECT SUM(Total.UnitPrice * Total.Quantity)
        FROM Sales.OrderLines AS Total
            JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID
    ) > 250000
    AND DATEDIFF(DAY, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY
    ord.CustomerID, det.StockItemID
ORDER BY
    ord.CustomerID, det.StockItemID


-- Table 'StockItemTransactions'. Scan count 1, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 29, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
-- Table 'StockItemTransactions'. Segment reads 1, segment skipped 0.
-- Table 'OrderLines'. Scan count 4, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 331, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
-- Table 'OrderLines'. Segment reads 2, segment skipped 0.
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
-- Table 'Orders'. Scan count 2, logical reads 883, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
-- Table 'CustomerTransactions'. Scan count 5, logical reads 261, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
-- Table 'Invoices'. Scan count 462, logical reads 162058, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
-- Table 'StockItems'. Scan count 1, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

--  SQL Server Execution Times:
--    CPU time = 317 ms,  elapsed time = 318 ms.
-- Total execution time: 00:00:00.462
