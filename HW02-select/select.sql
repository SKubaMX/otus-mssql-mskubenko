USE WideWorldImporters

/*
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".
�������: �� ������ (StockItemID), ������������ ������ (StockItemName).
�������: Warehouse.StockItems.
*/
select SI.StockItemID, SI.StockItemName from [Warehouse].[StockItems] SI
where SI.StockItemName like '%urgent%' or SI.StockItemName like 'Animal%'
/*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
������� ����� JOIN, � ����������� ������� ������� �� �����.
�������: �� ���������� (SupplierID), ������������ ���������� (SupplierName).
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
�� ����� �������� ������ JOIN ��������� ��������������.
*/
select S.SupplierID, S.SupplierName from [Purchasing].[PurchaseOrders] PO
full join [Purchasing].[Suppliers] S ON S.SupplierID = PO.SupplierID
where PO.SupplierID is null
/*
3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).
�������:
* OrderID
* ���� ������ (OrderDate) � ������� ��.��.����
* �������� ������, � ������� ��� ������ �����
* ����� ��������, � ������� ��� ������ �����
* ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������,
��������� ������ 1000 � ��������� ��������� 100 �������.

���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).

�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
select O.OrderID, O.OrderDate, month(O.OrderDate) as "Month", DATEPART(QUARTER,O.OrderDate) as "Quarter",  CEILING( MONTH(O.OrderDate) / 4.0 ) as "thirdOfYear", C.CustomerName from [Sales].[Orders] O
inner join [Sales].[Customers] C on c.CustomerID = o.CustomerID
Inner join [Sales].[OrderLines] OL on ol.OrderID = O.OrderID
where (Ol.UnitPrice > 100 or ol.Quantity > 20) and ol.PickingCompletedWhen is not null
order by "Quarter", "thirdOfYear", O.OrderDate ASC
offset (1000) rows
fetch next 100 rows only
/*
4. ������ ����������� (Purchasing.Suppliers),
������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).
�������:
* ������ �������� (DeliveryMethodName)
* ���� �������� (ExpectedDeliveryDate)
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)

�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/
select DM.DeliveryMethodName as "DelieveryType", po.ExpectedDeliveryDate as "DelieveryDate", S.SupplierName as "NameSupplier", ap.FullName as "ContactPerson" from [Purchasing].[Suppliers] S
left join [Application].[DeliveryMethods] DM ON dm.DeliveryMethodID = S.DeliveryMethodID
inner join Purchasing.PurchaseOrders PO on po.SupplierID = s.SupplierID
inner join Application.People AP on ap.PersonID = PO.ContactPersonID
where (PO.ExpectedDeliveryDate >= '2013-01-01' and PO.ExpectedDeliveryDate <= '2013-01-31')
and DM.DeliveryMethodName in ('Air Freight','Refrigerated Air Freight') and PO.IsOrderFinalized = 1
/*
5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������,
������� ������� ����� (SalespersonPerson).
������� ��� �����������.
*/
select top 10 P.FullName as "SalesName", P1.FullName as "ClientName" from [Sales].[Orders] O
inner join [Application].[People] P on P.PersonID = o.SalespersonPersonID
inner join [Application].[People] P1 on P1.PersonID = o.ContactPersonID
order by O.ExpectedDeliveryDate desc
/*
6. ��� �� � ����� �������� � �� ���������� ��������,
������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems.
*/
select P.PersonID, P.FullName, P.PhoneNumber from [Application].[People] P
inner join [Warehouse].[StockItemTransactions] SIT on sit.CustomerID = P.PersonID
Inner join [Warehouse].[StockItems] SI on si.StockItemID = sit.StockItemID
where si.StockItemName = 'Chocolate frogs 250g'