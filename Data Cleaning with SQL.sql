----- Let see the dataset

select*
from Datacleaning..NashvilleH


----- Let see the column SaleDate

select SaleDate
from Datacleaning..NashvilleH

--- Convert the date format and put it in saledateConverted
select SaleDate, CONVERT(date,SaleDate)
from Datacleaning..NashvilleH

update NashvilleH
set SaleDate= convert (Date, SaleDate)
 
Alter Table NashvilleH
Add SaleDateConverted Date;

update NashvilleH
set SaleDateConverted= convert (Date, SaleDate)

select SaleDateConverted, convert (Date, SaleDate)
from Datacleaning..NashvilleH



--- let us take a look at the column proprety  address
select PropertyAddress
from Datacleaning..NashvilleH

---let see if there are NULL in Property address
select PropertyAddress
from Datacleaning..NashvilleH
where PropertyAddress is null

--- let populate propertyAddress using parcelID and UniqueID 
select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Datacleaning..NashvilleH a
join Datacleaning..NashvilleH b
    on a.ParceLID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Datacleaning..NashvilleH a
join Datacleaning..NashvilleH b
    on a.ParceLID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


--- let break out address into individual Columns using PropertyAddress et OwnerName (Address,City, state)

select PropertyAddress
from Datacleaning..NashvilleH

select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)  -1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
from Datacleaning..NashvilleH

Alter Table NashvilleH
Add PropretySplitAddress Nvarchar(255);

update NashvilleH
set PropretySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)  -1) 

Alter Table NashvilleH
Add PropertySplitCity Nvarchar(255);

update NashvilleH
set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

select*
from Datacleaning..NashvilleH

select OwnerAddress
from Datacleaning..NashvilleH

select
parsename(Replace (OwnerAddress,',', '.') ,3)
,parsename(Replace (OwnerAddress,',', '.') ,2)
,parsename(Replace (OwnerAddress,',', '.') ,1)
From Datacleaning..NashvilleH

Alter Table NashvilleH
Add OwnerSplitAddress Nvarchar(255);

update NashvilleH
set OwnerSplitAddress = parsename(Replace (OwnerAddress,',', '.') ,3)

Alter Table NashvilleH
Add OwnerSplitCity Nvarchar(255);

update NashvilleH
set OwnerSplitCity = parsename(Replace (OwnerAddress,',', '.') ,2)

Alter Table NashvilleH
Add OwnerSplitState Nvarchar(255);

update NashvilleH
set OwnerSplitState = parsename(Replace (OwnerAddress,',', '.') ,1)

select*
from Datacleaning..NashvilleH


--- Let replace values in the column SoldAsVacant (Y to Yes and N to No)

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from Datacleaning..NashvilleH
Group By SoldAsVacant
Order by 2

select SoldAsVacant
, case When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No' 
	   ELSE SoldAsVacant
	   END
From Datacleaning..NashvilleH

Update NashvilleH
set SoldAsVacant= case When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No' 
	   ELSE SoldAsVacant
	   END

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from Datacleaning..NashvilleH
Group By SoldAsVacant
Order by 2


---Remove Duplicates

with rownumCTE AS(
select*,
    row_number() over (
	Partition by ParcelID,
	             PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				     UniqueID
					 )row_num

from Datacleaning..NashvilleH
)
Delete
from rownumCTE
where row_num > 1


select*
from rownumCTE
where row_num > 1
order by PropertyAddress


----Delete unused columns 
select* 
From Datacleaning..NashvilleH

Alter table Datacleaning..NashvilleH
Drop column OwnerAddress,TaxDistrict,PropertyAddress

Alter table Datacleaning..NashvilleH
Drop column SaleDate
