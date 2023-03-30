/* 
Cleaning Data
*/

--- standarize date format
select SaleDate, convert(date, SaleDate)
from PortfolioProject..Nashvillehousing

update Nashvillehousing
set SaleDate = convert(date,saledate)

alter table Nashvillehousing
add SaleDateConverted Date

Update Nashvillehousing
set SaleDateConverted = convert(date,saledate)

select SaleDateConverted
from PortfolioProject..Nashvillehousing

--- Populate property address data

select *
from PortfolioProject..Nashvillehousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..Nashvillehousing a
join PortfolioProject..Nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]!=b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..Nashvillehousing a
join PortfolioProject..Nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]!=b.[UniqueID ]
where a.PropertyAddress is null

select PropertyAddress
from Nashvillehousing


---slicing address into individual column(address, city, state)

select PropertyAddress
from Nashvillehousing

select PropertyAddress,
substring (PropertyAddress, 1, CharIndex(',' , PropertyAddress)-1) as PropertySplitAdress
, SUBSTRING(PropertyAddress, CharIndex(',' , PropertyAddress)+1,Len(PropertyAddress)) as PropertySplitCity
from Nashvillehousing

alter table Nashvillehousing
add PropertySplitAdress nvarchar(255)
, PropertySplitCity nvarchar(255)

Update Nashvillehousing
set PropertySplitAdress = substring (PropertyAddress, 1, CharIndex(',' , PropertyAddress)-1),
PropertySplitCity = SUBSTRING(PropertyAddress, CharIndex(',' , PropertyAddress)+1,Len(PropertyAddress))

select propertyAddress,OwnerAddress,PropertySplitAdress,PropertySplitCity
from Nashvillehousing

select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject..Nashvillehousing

alter table Nashvillehousing
add OwnerSplitAdress nvarchar(255)
, OwnerSplitCity nvarchar(255)
, OwnerSplitState nvarchar(255)

Update Nashvillehousing
set OwnerSplitAdress = PARSENAME(replace(OwnerAddress,',','.'),3),
OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2),
OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

select OwnerAddress,OwnerSplitAdress, OwnerSplitCity, OwnerSplitState
from Nashvillehousing

--- change y and n to yes and no in "sold as vacant" column

select SoldAsVacant
from Nashvillehousing

select distinct(SoldAsVacant), count(soldAsVacant)
from Nashvillehousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	End
from Nashvillehousing

Update Nashvillehousing
set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	End
from Nashvillehousing

----Remove Duplicates
WITH rowNumCTE as(
select *,
	ROW_NUMBER() OVER( PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
	Order by uniqueID) row_num
from Nashvillehousing
--order by ParcelID
)
Select * from rowNumCTE
where row_num>1

Delete from rowNumCTE
where row_num>1
--order by PropertyAddress

----DElete unused columns

select *
from Nashvillehousing

alter table Nashvillehousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table Nashvillehousing
Drop column SaleDate
