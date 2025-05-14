USE WideWorldImporters

/*
1. ��������� ������� ���� ������, ����� ����� ������� �� �������.
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ������� ���� �� ����� �� ���� �������
* ����� ����� ������ �� �����

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/
Select YEAR(I.InvoiceDate) as "Year", MONTH(I.InvoiceDate) as "Month", AVG(OL.UnitPrice*ol.Quantity) as "MeanPrice", SUM(ol.UnitPrice*ol.Quantity) as "TotalPrice" from Sales.Invoices I
Inner join Sales.InvoiceLines OL ON ol.InvoiceID = I.InvoiceID
group by YEAR(I.InvoiceDate), MONTH(I.InvoiceDate)
Order by Year, Month ASC 
/*
2. ���������� ��� ������, ��� ����� ����� ������ ��������� 4 600 000

�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ����� ����� ������

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/
Select YEAR(I.InvoiceDate) as "Year", MONTH(I.InvoiceDate) as "Month", SUM(ol.UnitPrice*ol.Quantity) as "TotalPrice" from Sales.Invoices I
Inner join Sales.InvoiceLines OL ON ol.InvoiceID = I.InvoiceID
group by YEAR(I.InvoiceDate), MONTH(I.InvoiceDate)
having SUM(ol.UnitPrice*ol.Quantity) >= 4600000
Order by Year, Month ASC 
/*
3. ������� ����� ������, ���� ������ �������
� ���������� ���������� �� �������, �� �������,
������� ������� ����� 50 �� � �����.
����������� ������ ���� �� ����,  ������, ������.

�������:
* ��� �������
* ����� �������
* ������������ ������
* ����� ������
* ���� ������ �������
* ���������� ����������

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/
Select YEAR(I.InvoiceDate) as "Year", MONTH(I.InvoiceDate) as "Month", OL.description, SUM(ol.UnitPrice*ol.Quantity) as "TotalPrice", Min(I.InvoiceDate) as "minDateSale", COUNT(OL.Quantity) as "count" from Sales.Invoices I
Inner join Sales.InvoiceLines OL ON ol.InvoiceID = I.InvoiceID
group by YEAR(I.InvoiceDate), MONTH(I.InvoiceDate), OL.Description
Having COUNT(OL.Quantity) < 50
Order by Year, Month ASC 
-- --------------------------------------------------------------------------
-- �����������
-- ---------------------------------------------------------------------------
/*
�������� ������� 2-3 ���, ����� ���� � �����-�� ������ �� ���� ������,
�� ���� ����� ����� ����������� �� � �����������, �� ��� ���� ����.
*/
