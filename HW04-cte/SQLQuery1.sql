USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/
select p.personid, p.fullname from [Application].[People] p
where p.IsSalesperson = 1 and p.personid not in (select i.salespersonpersonid from [Sales].[Invoices] i where i.InvoiceDate = '2015-07-04')
/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/
select top 1 il.StockItemID, il.Description, il.UnitPrice from Sales.InvoiceLines il
where il.UnitPrice = (select MIN(UnitPrice) from Sales.InvoiceLines)
/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
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
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
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
