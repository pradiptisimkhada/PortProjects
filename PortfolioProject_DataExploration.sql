/* 
Cleaning data in SQL
*/
select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null

--Stadardize Date Format
select SaleDate,Cast(SaleDate as date),SaleDateConverted
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted=convert(date,SaleDate)

--populate property address data

select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID 
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress =isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID 
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address into Individual Columns(address,city,ctate)

select PropertyAddress
from NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as City,
CHARINDEX(',',PropertyAddress)
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress))


select *
from NashvilleHousing

-- now for owner address easier way 

select OwnerAddress
from NashvilleHousing

select 
PARSENAME(Replace(OwnerAddress,',','.'),1) --does parse backwards 
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),3)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)

select *
from NashvilleHousing

--change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant='Y' then 'Yes'
	   when SoldAsVacant='N' then 'No'
	   else SoldAsVacant
	   end
from NashvilleHousing
--where SoldAsVacant='N' or SoldAsVacant = 'Y'

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
	   when SoldAsVacant='N' then 'No'
	   else SoldAsVacant
	   end

--remove the Duplicates
with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) as row_num
from NashvilleHousing
--order by ParcelID
)
Select *
from RowNumCTE
where row_num > 1-----maile yo bujina

--delete Unused Columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop Column OwnerAddress,PropertyAddress


alter table NashvilleHousing
drop Column SaleDate


