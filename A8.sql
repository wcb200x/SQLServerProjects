--William Brown
--CIS 310-02
--A8
--11/2/16
--
--Nested Queries required when comparing max or min or using an aggregate
--1)List the customers from California who bought red mountain bikes in September 2003. Use order date as date bought.
select DISTINCT C.CustomerID, C.LastName, C.FirstName, B.ModelType, P.ColorList, B.OrderDate, B.SaleState
from Customer C Inner Join City I on c.cityid = i.cityid
	 Inner Join Bicycle B  on c.customerid = b.customerid 
	 Inner Join Paint P on b.paintid = p.paintid 
	where (year(B.orderdate)= 2003 AND Month(B.OrderDate) = 09) AND I.State = 'CA' AND p.colorlist = 'red' 
		   And B.ModelType = 'mountain'

--2)List the employees who sold race bikes shipped to Wisconsin without the help of a retail store in 2001
select E.EmployeeID, E.LastName, B.SaleState, B.ModelType, B.StoreID, B.OrderDate
from Employee E Inner Join Bicycle B on E.employeeID = B.employeeID
where Year(B.OrderDate) = 2001  
	  AND B.SaleState = 'WI'
	  AND B.StoreID IN (1,2)
	  AND B.ModelType = 'Race'

        
--3)List all of the (distinct) rear derailleurs installed on road bikes sold in Florida in 2002.
select DISTINCT C.ComponentID, M.ManufacturerName, C.ProductNumber
from Component C Inner Join Manufacturer M on c.ManufacturerID = m.ManufacturerID 
	 inner join BikeParts BP on BP.ComponentID = C.ComponentID
	 inner join Bicycle B on B.SerialNumber = BP.SerialNumber
where C.Category = 'Rear Derailleur' 
	  AND B.ModelType = 'road' 
	  AND B.SaleState = 'FL'
	  AND Year(B.OrderDate) = 2002


--4)Who bought the largest (frame size) full suspension mountain bike sold in Georgia in 2004?
select C.CustomerID, C.LastName, C.FirstName, B.ModelType, B.SaleState, B.FrameSize, B.OrderDate
from Customer C Inner Join Bicycle B on c.customerid = b.customerid Inner Join ModelType M on 
m.modeltype = b.modeltype
where B.ModelType = 'mountain full'
AND B.SaleState = 'GA'
AND Year(B.OrderDate)= 2004
AND B.FrameSize = (select Max(FrameSize)
				   from Bicycle
				   where ModelType = 'mountain full')
				   
--5)Which manufacturer gave us the largest discount on an order in 2003?
select M.ManufacturerID, M.ManufacturerName
from Manufacturer M Inner Join PurchaseOrder P on m.ManufacturerID = p.ManufacturerID
where p.Discount = (select Max(Discount)
					from PurchaseOrder
					where year(orderdate) = 2003)

--6)What is the most expensive road bike component we stock that has a quantity on hand greater than 200 units?
select C.ComponentID, M.ManufacturerName, C.ProductNumber, C.Road, C.Category, C.ListPrice, C.QuantityOnHand
from Component C inner join Manufacturer m on c.ManufacturerID = m.ManufacturerID
where C.ListPrice = (select Max(ListPrice)
					 from Component
					 where QuantityOnHand > 200
					 AND Road = 'Road')
AND C.QuantityOnHand > 200  
AND C.Road = 'Road'
					 
--7)Which inventory item represents the most money sitting on the shelf—based on estimated cost?
select C.ComponentID, M.ManufacturerName, C.ProductNumber, C.Category, C.Year, (C.EstimatedCost * C.QuantityOnHand) as [Value]
from Component C inner join Manufacturer M on c.ManufacturerID = m.ManufacturerID
where (C.EstimatedCost* C.QuantityOnHand) in (select MAX(Value)
										 	from (select C.ComponentID, M.ManufacturerName, C.ProductNumber, C.Category, C.Year, (C.EstimatedCost * C.QuantityOnHand) as [Value]
											from Component C inner join Manufacturer M on c.ManufacturerID = m.ManufacturerID) as Value)
													
--select C.ComponentID, M.ManufacturerName, C.ProductNumber, C.Category, C.Year, SUM(C.EstimatedCost * C.QuantityOnHand) as [Value]
--from Component C inner join Manufacturer M on c.ManufacturerID = m.ManufacturerID
--Group By C.ComponentId, M.ManufacturerName, C.ProductNumber, C.Category, C.year 
--Having Sum(C.EstimatedCost * C.QuantityonHand) = (select Max(Value)
--												  from (select C.ComponentID, M.ManufacturerName, C.ProductNumber, C.Category, C.Year, SUM(C.EstimatedCost * C.QuantityOnHand) as [Value]
--from Component C inner join Manufacturer M on c.ManufacturerID = m.ManufacturerID
--Group By C.ComponentId, M.ManufacturerName, C.ProductNumber, C.Category, C.year) as Value) 

--8)What is the greatest number of components ever installed in one day by one employee?
select E.EmployeeID, E.LastName, BP.DateInstalled, Count(BP.ComponentID) as CountofComponents
from Employee E Inner Join BikeParts BP on e.EmployeeID = bp.EmployeeID
Group by E.EmployeeID, E.LastName, BP.DateInstalled
Having Count(BP.ComponentID) in (select top 1 count(Bp.componentID)
							  from Employee E Inner Join BikeParts BP on e.EmployeeID = bp.EmployeeID
							  where DateInstalled is not null
							  Group By E.EmployeeID, E.LastName, BP.DateInstalled
							  Order By Count(BP.componentID) desc)

--select E.EmployeeId, E.LastName, BP.DateInstalled, Sum(Bp.Quantity) as CountofComponents
--from Employee E Inner Join BikeParts BP on e.EmployeeId = bp.EmployeeID
--where BP.DateInstalled is not null
--Group By E.EmployeeID, E.LastName, BP.DateInstalled
--Having Sum(BP.Quantity) = (select Max(CountofComponents)
--						   from (select E.employeeId, E.LastName, BP.DateInstalled, Sum(Bp.Quantity) as CountofComponents
--					       from Employee E Inner Join BikeParts BP on e.EmployeeId = bp.EmployeeID
--						   where BP.DateInstalled is not null
--						   Group By E.EmployeeID, E.LastName, BP.DateInstalled) as CountofComponents)

--9)What was the most popular letter style on race bikes in 2003?
select LetterStyleID, Count(*) as CountofSerialNumber
from Bicycle
where Year(OrderDate) = 2003 
AND ModelType = 'race'
Group By LetterStyleID
Having Count(*) = (select top 1 Count(*)
				   from Bicycle
				   where Year(OrderDate) = 2003 
				   AND ModelType = 'race'
				   Group By LetterStyleID
				   Order By Count(*) desc)

--select LetterStyleID, Count(*) as CountofSerialNumber
--from Bicycle
--where Year(OrderDate) = 2003 
--AND ModelType = 'race'
--Group By LetterStyleID
--Having Count(*) = (select Max(CountofSerialNumber)
--				   from (select LetterStyleID, Count(*) as CountofSerialNumber
--						 from Bicycle
--						 where Year(OrderDate) = 2003 
--						 AND ModelType = 'race'
--						 Group By LetterStyleID) as CountofSerialNumber)
--10)Which customer spent the most money with us and how many bicycles did that person buy in 2002?
select C.CustomerID, C.LastName, C.FirstName, Count(*) as [Number of Bikes], Sum(B.SalePrice + B.SalesTax) as AmountSpent
from Customer C Inner Join Bicycle B on C.CustomerID = B.CustomerID 
where Year(OrderDate) = 2002
Group By C.CustomerID, C.LastName, C.FirstName
Having Sum(B.SalePrice + B.SalesTax) = (select Max(AmountSpent)
										From (select C.CustomerID, C.LastName, C.FirstName, Count(*) as [Number of Bikes], Sum(B.SalePrice + B.SalesTax) as AmountSpent
										from Customer C Inner Join Bicycle B on C.CustomerID = B.CustomerID
										where Year(OrderDate) = 2002
										Group By C.CustomerID, C.LastName, C.FirstName) as AmountSpent) 

										
--11)Have the sales of mountain bikes (full suspension or hard tail) increased or decreased from 2000 to 2004 (by count not by value)?
select Year(OrderDate) as [SaleYear], Count(SerialNumber) as [CountofSerialNumber]
from Bicycle
where Year(OrderDate) between 2000 AND 2004
AND (ModelType like '%mountain%')
Group By Year(OrderDate) 
Order By Year(OrderDate) desc


--12)Which component did the company spend the most money on in 2003?
select C.ComponentID, M.ManufacturerName, C.ProductNumber, C.Category, Sum(Pu.PricePaid) [Value]
from Manufacturer M Inner Join Component C on M.ManufacturerID = C.ManufacturerID
					Inner Join PurchaseItem Pu on C.ComponentID = Pu.ComponentID
					Inner Join PurchaseOrder Po on Pu.PurchaseID = Po.PurchaseID
where Year(Po.OrderDate) = 2003
Group By C.ComponentID, M.ManufacturerName, C.ProductNumber, C.Category
Having Sum(Pu.PricePaid) = (select Max(Value) 
							From (select C.ComponentID, M.ManufacturerName, C.ProductNumber, C.Category, Sum(Pu.PricePaid) [Value]
									From Manufacturer M Inner Join Component C on M.ManufacturerID = C.ManufacturerID
									Inner Join PurchaseItem Pu on C.ComponentID = Pu.ComponentID
									Inner Join PurchaseOrder PO on Po.PurchaseID = Pu.PurchaseID
							Where Year(Po.OrderDate) = 2003
							Group By C.ComponentID, M.ManufacturerName, C.ProductNumber, C.Category) as Value)


--13)Which employee painted the most red race bikes in May 2003?
select E.EmployeeID, E.LastName, Count(B.SerialNumber) [NumberPainted]
from Employee E Inner Join Bicycle B On E.EmployeeID = B.Painter
where B.ModelType = 'Race' AND B.PaintID = 14 AND Year(OrderDate) = 2003 AND Month(OrderDate) = 05
Group By E.EmployeeID, E.LastName
Having Count(SerialNumber) = (Select Max(NumberPainted) 
								From (Select E.EmployeeID, E.LastName, Count(B.SerialNumber)
									  As NumberPainted From Employee E Inner Join Bicycle B On E.EmployeeID = B.Painter
									  Where B.ModelType = 'Race' AND B.PaintID = 14 AND Year(OrderDate) = 2003 AND Month(OrderDate) = 05
									  Group By E.EmployeeID, E.LastName) as NumberPainted)
					
--14)Which California bike shop helped sell the most bikes (by value) in 2003?
select Rs.StoreID, C.CityID, RS.CityID
from (City C Right Join RetailStore RS On C.CityID = RS.CityID) Inner Join Bicycle B on RS.StoreID = B.StoreID
-- RetailStore RS Inner Join City C on RS.CityID = C.CityID 
--					Inner Join Bicycle B on B.StoreID = RS.StoreID
where C.State = 'CA' AND Year(B.OrderDate) = 2003 
Group By RS.StoreID, C.CityID, RS.CityID
Having Sum(SalePrice) = (select top 1 Sum(SalePrice)
						 from RetailStore RS Inner Join Bicycle B on Rs.StoreID = B.StoreID
					     Inner Join City C on C.CityID = RS.CityID
                         where C.State = 'CA' AND Year(B.OrderDate) = 2003
                         Group By Rs.StoreID, C.CityID, RS.CityID
						 Order By Sum(SalePrice) desc)

--	Having Count(*) = (select top 1 Count(*)
--					   from RetailStore RS Inner Join City C on RS.CityID = C.CityID 
--						Inner Join Bicycle B on B.StoreID = RS.StoreID
--						where Year(OrderDate) = 2003
--						Group By RS.StoreID
--						Order By Count(*) desc)

--AND Sum(B.SalePrice) = (select top 1 Sum(B.SalePrice)
--						from RetailStore RS Inner Join City C on RS.CityID = C.CityID 
--						Inner Join Bicycle B on B.StoreID = RS.StoreID
--						where C.State = 'CA' 
--						AND YEAR(B.OrderDate) = 2003
--						Group By Rs.StoreID
--						Order By Sum(SalePrice) desc) 

--15)What is the total weight of the components on bicycle 11356?
select (SUM(C.Weight * BP.Quantity)) as TotalWeight
from Component C Inner Join BikeParts BP on BP.ComponentID = C.ComponentID
where BP.SerialNumber = 11356

--16)What is the total list price of all items in the 2002 Campy Record groupo?
select G.GroupName, SUM(C.ListPrice) as SumofListPrice
from Groupo G Inner Join GroupComponents GC on G.ComponentGroupID = GC.GroupID 
			  Inner Join Component C on C.ComponentID = GC.ComponentID
where G.GroupName like '%Campy Record 2002%'
Group By G.GroupName

--17)In 2003, were more race bikes built from carbon or titanium (based on the down tube)?
select TM.Material, Count(B.SerialNumber) as CountofSerialNumber
from TubeMaterial TM Inner Join BicycleTubeUsage TU on TM.TubeID = TU.TubeID
					 Inner Join Bicycle B on B.SerialNumber = TU.SerialNumber
					 Inner Join BikeTubes BT on BT.SerialNumber = B.SerialNumber
where Year(B.StartDate) = 2003 AND B.ModelType = 'race' 
							   AND BT.TubeName = 'down'
							   AND (TM.Material like '%carbon%' 
							   Or TM.Material like '%titanium%')
Group By TM.Material
Order By Count(*) desc

--18)What is the average price paid for the 2001 Shimano XTR rear derailleurs?
select Convert(Money, AVG(Pu.PricePaid), 1) as AvgOfPricePaid
from Component C Inner Join PurchaseItem Pu on pu.ComponentID = c.ComponentID 
				 Inner Join GroupComponents GC on GC.ComponentID = C.ComponentID
				 Inner Join Groupo G on G.ComponentGroupID = GC.GroupID
where G.GroupName like '%Shimano XTR 2001%' AND C.Category like '%rear derailleur%'

--19)What is the average top tube length for a 54 cm (frame size) road bike built in 1999?
select AVG(B.TopTube) as AvgOfTopTube
from BikeTubes BT Inner Join Bicycle B on B.SerialNumber = BT.SerialNumber 
				  Inner Join BikeParts BP on BP.SerialNumber = B.SerialNumber
				  Inner Join PurchaseItem Pu on Pu.ComponentID = BP.ComponentID
				  Inner Join Component C on c.ComponentID = Pu.ComponentID
where B.FrameSize = '54' 
AND B.ModelType = 'road' 
AND Year(B.StartDate) = 1999
AND BT.TubeName = 'top'

--20)On average, which costs (list price) more: road tires or mountain bike tires?
select Road, AVG(ListPrice) as AvgOfListPrice 
from Component
where category = 'tire'
And (road = 'road' 
or road = 'mtb')
Group By Road
Order By AvgOfListPrice desc


--21)In May 2003, which employees sold road bikes that they also painted?
select Distinct E.EmployeeID, E.LastName
from Bicycle B Inner Join Employee E on B.EmployeeID = E.EmployeeID
where Year(B.OrderDate) = 2003 
AND Month(B.OrderDate) = 05 
AND B.ModelType = 'road'
AND B.Painter = B.EmployeeID


--22)In 2002, was the Old English letter style more popular with some paint jobs?
select P.PaintID, P.ColorName, Count(*) as [Number of Bikes Painted]
from Paint P Inner Join Bicycle B on P.PaintID = B.PaintID
where B.LetterStyleID = 'English' AND Year(B.StartDate) = 2002 
Group By P.PaintID, P.ColorName 
Order By [Number of Bikes Painted] desc

--23)Which race bikes in 2003 sold for more than the average price of race bikes in 2002?
select SerialNumber, ModelType, OrderDate, SalePrice
from Bicycle
where ModelType = 'race' 
	  AND Year(OrderDate) = 2003
	  AND SalePrice > (select AVG(SalePrice)e
					   from Bicycle
					   where ModelType = 'race' 
					   AND Year(OrderDate) = 2002)

--24)Which component that had no sales (installations) in 2004 has the highest inventory value (cost basis)?
select DISTINCT M.ManufacturerName, C.ProductNumber, C.Category,  (C.EstimatedCost*C.QuantityOnHand) as HighestInventoryValue
from BikeParts BP Inner Join Component C on BP.ComponentID = C.ComponentID Inner Join Manufacturer M on m.ManufacturerID = c.ManufacturerID
where Year(BP.DateInstalled) <> 2004  AND C.EstimatedCost*C.QuantityOnHand = (select Max(C.EstimatedCost*C.QuantityOnHand)
																				 from BikeParts BP Inner Join Component C on BP.ComponentID = C.ComponentID
																				 where Year(BP.DateInstalled) <> 2004   )

--25)Create a vendor contacts list of all manufacturers and retail stores in California. Include only the columns for VendorName and Phone. The retail stores should only include stores that participated in the sale of at least one bicycle in 2004
select M.ManufacturerName, M.Phone
from Manufacturer M Inner Join City C on M.CityID = C.CityID
where C.State = 'CA'
Union select Rs.StoreName, RS.Phone
from RetailStore RS Inner Join City C on RS.CityID = C.CityID 
Inner Join Bicycle B on B.StoreID = RS.StoreID Inner Join Manufacturer M on M.CityID = rs.StoreID
where C.State = 'CA' AND Year(B.OrderDate) = 2004 

--26)List all of the employees who report to Venetiaan.
select E.CurrentManager as [Manager Name], EM.EmployeeID, E.LastName, E.FirstName, E.Title
from Employee E Inner Join Employee EM on E.CurrentManager = Em.EmployeeID
where EM.LastName = 'Venetiaan'


--27)List the components where the company purchased at least 25 percent more units than it used through June 30, 2000.
--run in individual database
Create View TotalReceived as 
select p.ComponentID, SUM(p.QuantityReceived) as TotalReceived
from bike..PurchaseItem P Inner Join bike..PurchaseOrder Pu on p.purchaseID = pu.purchaseID
where Pu.OrderDate <= 'June 30, 2000'
Group By P.ComponentID

Create View TotalInstalled as
select BP.ComponentID, SUM(BP.Quantity) as TotalUsed
from bike..BikeParts BP
where BP.DateInstalled <= 'June 30, 2000'
Group By BP.ComponentID

select C.ComponentID, M.ManufacturerName, C.ProductNumber, C.Category, TR.TotalReceived, TI.TotalUsed, (TR.TotalReceived - TI.TotalUsed) as NetGain,
 1-(TI.TotalUSed/(TR.TotalReceived +0.0)) as NetPct, C.ListPrice
from TotalReceived TR Inner Join TotalInstalled TI on TI.ComponentID = TR.ComponentID 
	 Inner Join bike..Component C on C.ComponentID = TI.ComponentID
	 Inner Join bike..Manufacturer M on M.ManufacturerID = C.ManufacturerID
where (1-(TI.TotalUsed/(TR.TotalReceived +0.0))) > .25
Order By C.ComponentID


--28)In which years did the average build time for the year exceed the overall average build time for all years? The build time is the difference between order date and ship date.
select Year(B.ShipDate) as buildYear, AVG(DateDiff(Day, B.OrderDate, B.ShipDate)) as BuildTime
from Bicycle B
Group By Year(B.ShipDate)
Having AVG(DateDiff(Day, B.OrderDate, B.ShipDate)) > (Select AVG(DATEDIFF(Day, B.OrderDate, B.ShipDate)) From Bicycle B)

--order by OrderDate, ShipDate


