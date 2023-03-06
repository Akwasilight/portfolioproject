/*
---cleaning data  (Housing data )
*/

--loading data all columns 
select *
from [Portfolio project]..Housing

-- formating saledate to date 
select SaleDate, CONVERT(Date,SaleDate)
from [Portfolio project]..Housing

update [Portfolio project]..Housing
set SaleDate= CONVERT(Date,SaleDate)


alter table [Portfolio project]..Housing
add SaleDateCoverte Date;


update [Portfolio project]..Housing
set SaleDateCoverte= CONVERT(Date,SaleDate)
--checking changes
select SaleDateCoverte, CONVERT(Date,SaleDate)
from [Portfolio project]..Housing


---Property Address data 
select *
from [Portfolio project]..Housing
where PropertyAddress is  null
order by ParcelID


---- replacing  same paecelID  address with same with null address @ 0proerty address 
	select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyaddress,b.PropertyAddress)
from [Portfolio project]..Housing a 
join [Portfolio project]..Housing b
on  a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null    


--updating in the dataset 
update  a
set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)  --is null gives vaules if is null
from [Portfolio project]..Housing a
join [Portfolio project]..Housing b
on  a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


---- breaking out  Address into individual column (Address,City,State)
select PropertyAddress
from [Portfolio project]..Housing
---where PropertyAddress is  null
order by ParcelID  

-- breaking Address
select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
---CHARINDEX(',',PropertyAddress) --giving us a number of the coo
from  [Portfolio project]..Housing


--Breaking the city
select
 ---SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as city
from  [Portfolio project]..Housing 


--breaking both on the same table 
select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as city
from  [Portfolio project]..Housing


---Adding the new values to the data set (property slite address )

alter table [Portfolio project]..Housing
add PropertySpliteAddress Nvarchar(255);

update [Portfolio project]..Housing
set PropertySpliteAddress= SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

--- for for city
alter table [Portfolio project]..Housing
add PropertySpliteCity Nvarchar(255);

update [Portfolio project]..Housing
set PropertySpliteCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))


---- checking changes 
select*
from [Portfolio project]..Housing


---- spliting owner Address method 2 by parsename

select OwnerAddress
from [Portfolio project]..Housing
where OwnerAddress is not null

select 
PARSENAME(replace(OwnerAddress,',', '.') ,3),
PARSENAME(replace(OwnerAddress,',', '.') ,2),
PARSENAME(replace(OwnerAddress,',', '.') ,1)
from [Portfolio project]..Housing
where OwnerAddress is not null

----addd new splite names to Housing data set


-- for owner address 
alter table [Portfolio project]..Housing
add OwnerSpliteAddress Nvarchar(255);

update [Portfolio project]..Housing
set OwnerSpliteAddress= PARSENAME(replace(OwnerAddress,',', '.') ,3)

---  for owner  city
alter table [Portfolio project]..Housing
add OwnerSpliteCity Nvarchar(255);

update [Portfolio project]..Housing
set OwnerSpliteCity = PARSENAME(replace(OwnerAddress,',', '.') ,2)

 --- for onwer splite state 
alter table [Portfolio project]..Housing
add OwnerSpliteSate Nvarchar(255);

update [Portfolio project]..Housing
set OwnerSpliteSate = PARSENAME(replace(OwnerAddress,',', '.') ,1)

---- chechking changes 

select *
from  [Portfolio project]..Housing



--- change y to yes and n to N or replacing 

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Portfolio project]..Housing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'y' then	'Yes'
when SoldAsVacant = 'N' then	'No'
ELSE SoldAsVacant
END
from [Portfolio project]..Housing


Update [Portfolio project]..Housing
set SoldAsVacant = case when SoldAsVacant = 'y' then	'Yes'
when SoldAsVacant = 'N' then	'No'
ELSE SoldAsVacant
END 


-- Remove duplicate
with RowNumCTE as(
select*,
ROW_NUMBER() over (
partition by ParcelID,
PropertyAddress,SalePrice,SaleDate,LegalReference
order by UniqueID
)row_num
from [Portfolio project]..Housing

)
delete 
from RowNumCTE
where row_num >1
--order by PropertyAddress


--delete  unused  Columns 
select*
from [Portfolio project]..Housing

alter table [Portfolio project]..Housing
drop column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate,SaleDatecoverted
