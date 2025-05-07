USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/
select SI.StockItemID, SI.StockItemName from [Warehouse].[StockItems] SI
where SI.StockItemName like '%urgent%' or SI.StockItemName like 'Animal%'
/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/
select S.SupplierID, S.SupplierName from [Purchasing].[PurchaseOrders] PO
full join [Purchasing].[Suppliers] S ON S.SupplierID = PO.SupplierID
where PO.SupplierID is null
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
select O.OrderID, O.OrderDate, month(O.OrderDate) as "Month", DATEPART(QUARTER,O.OrderDate) as "Quarter",  CEILING( MONTH(O.OrderDate) / 4.0 ) as "thirdOfYear", C.CustomerName from [Sales].[Orders] O
inner join [Sales].[Customers] C on c.CustomerID = o.CustomerID
Inner join [Sales].[OrderLines] OL on ol.OrderID = O.OrderID
where (Ol.UnitPrice > 100 or ol.Quantity > 20) and ol.PickingCompletedWhen is not null
order by "Quarter", "thirdOfYear", O.OrderDate ASC
offset (1000) rows
fetch next 100 rows only
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
select DM.DeliveryMethodName as "DelieveryType", po.ExpectedDeliveryDate as "DelieveryDate", S.SupplierName as "NameSupplier", ap.FullName as "ContactPerson" from [Purchasing].[Suppliers] S
left join [Application].[DeliveryMethods] DM ON dm.DeliveryMethodID = S.DeliveryMethodID
inner join Purchasing.PurchaseOrders PO on po.SupplierID = s.SupplierID
inner join Application.People AP on ap.PersonID = PO.ContactPersonID
where (PO.ExpectedDeliveryDate >= '2013-01-01' and PO.ExpectedDeliveryDate <= '2013-01-31')
and DM.DeliveryMethodName in ('Air Freight','Refrigerated Air Freight') and PO.IsOrderFinalized = 1
/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/
select top 10 P.FullName as "SalesName", P1.FullName as "ClientName" from [Sales].[Orders] O
inner join [Application].[People] P on P.PersonID = o.SalespersonPersonID
inner join [Application].[People] P1 on P1.PersonID = o.ContactPersonID
order by O.ExpectedDeliveryDate desc
/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/
select P.PersonID, P.FullName, P.PhoneNumber from [Application].[People] P
inner join [Warehouse].[StockItemTransactions] SIT on sit.CustomerID = P.PersonID
Inner join [Warehouse].[StockItems] SI on si.StockItemID = sit.StockItemID
where si.StockItemName = 'Chocolate frogs 250g'