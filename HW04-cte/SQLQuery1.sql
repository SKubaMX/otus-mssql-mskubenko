USE WideWorldImporters

/*
1. �������� ����������� (Application.People), ������� �������� ������������ (IsSalesPerson), 
� �� ������� �� ����� ������� 04 ���� 2015 ����. 
������� �� ���������� � ��� ������ ���. 
������� �������� � ������� Sales.Invoices.
*/
select p.personid, p.fullname from [Application].[People] p
where p.IsSalesperson = 1 and p.personid not in (select i.salespersonpersonid from [Sales].[Invoices] i where i.InvoiceDate = '2015-07-04')
/*
2. �������� ������ � ����������� ����� (�����������). �������� ��� �������� ����������. 
�������: �� ������, ������������ ������, ����.
*/
select top 1 il.StockItemID, il.Description, il.UnitPrice from Sales.InvoiceLines il
where il.UnitPrice = (select MIN(UnitPrice) from Sales.InvoiceLines)
/*
3. �������� ���������� �� ��������, ������� �������� �������� ���� ������������ �������� 
�� Sales.CustomerTransactions. 
����������� ��������� �������� (� ��� ����� � CTE). 
*/ 
;with TopPayments as (
    select top 5 *
    from Sales.CustomerTransactions
    order by AmountExcludingTax desc
)
select c.CustomerID, c.CustomerName, tp.AmountExcludingTax
from TopPayments tp
inner join [Sales].[Customers] C on c.CustomerID = tp.CustomerID
/*
4. �������� ������ (�� � ��������), � ������� ���� ���������� ������, 
�������� � ������ ����� ������� �������, � ����� ��� ����������, 
������� ����������� �������� ������� (PackedByPersonID).
*/
;with TopItems AS (
    select TOP 3 StockItemID
    from Warehouse.StockItems
    order by UnitPrice desc
),
DeliveriesWithTopItems AS (
    select 
        i.CustomerID,
        i.PackedByPersonID
    from Sales.Invoices i
    join Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
    where il.StockItemID IN (select StockItemID from TopItems)
),
Result AS (
    select 
        cu.DeliveryCityID,
        c.CityName,
        d.PackedByPersonID,
        p.FullName AS PackedByEmployee
    from DeliveriesWithTopItems d
    join Sales.Customers cu ON d.CustomerID = cu.CustomerID
    join Application.Cities c ON cu.DeliveryCityID = c.CityID
    join Application.People p ON d.PackedByPersonID = p.PersonID
)
select distinct DeliveryCityID, CityName, PackedByEmployee
from Result;
