USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
Select YEAR(I.InvoiceDate) as "Year", MONTH(I.InvoiceDate) as "Month", AVG(OL.UnitPrice*ol.Quantity) as "MeanPrice", SUM(ol.UnitPrice*ol.Quantity) as "TotalPrice" from Sales.Invoices I
Inner join Sales.InvoiceLines OL ON ol.InvoiceID = I.InvoiceID
group by YEAR(I.InvoiceDate), MONTH(I.InvoiceDate)
Order by Year, Month ASC 
/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
Select YEAR(I.InvoiceDate) as "Year", MONTH(I.InvoiceDate) as "Month", SUM(ol.UnitPrice*ol.Quantity) as "TotalPrice" from Sales.Invoices I
Inner join Sales.InvoiceLines OL ON ol.InvoiceID = I.InvoiceID
group by YEAR(I.InvoiceDate), MONTH(I.InvoiceDate)
having SUM(ol.UnitPrice*ol.Quantity) >= 4600000
Order by Year, Month ASC 
/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
Select YEAR(I.InvoiceDate) as "Year", MONTH(I.InvoiceDate) as "Month", OL.description, SUM(ol.UnitPrice*ol.Quantity) as "TotalPrice", Min(I.InvoiceDate) as "minDateSale", COUNT(OL.Quantity) as "count" from Sales.Invoices I
Inner join Sales.InvoiceLines OL ON ol.InvoiceID = I.InvoiceID
group by YEAR(I.InvoiceDate), MONTH(I.InvoiceDate), OL.Description
Having COUNT(OL.Quantity) < 50
Order by Year, Month ASC 
-- --------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
