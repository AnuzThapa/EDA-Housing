-- postgresql queries 


-- SELECT *
-- FROM house

-- SELECT SaleDate,CONVERT(date,SaleDate)
-- FROM house

-- ALTER TABLE house
-- ADD "SaleDateConverted" date;

-- for mysql
-- UPDATE house
-- SET SaleDateConverted = CONVERT(date,SaleDate);

-- for psql
-- UPDATE house
-- SET "SaleDateConverted"="SaleDate"::date;

-- ALTER TABLE house
-- DROP COLUMN SaleDateConverted;


-- for mysql
-- SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
-- ISNULL(a.PropertyAddress,b.PropertyAddress)
-- FROM house as a
-- JOIN house as b
--      ON a.parcelID=b.ParcelID
-- 	 and a.[UniqueID]<>b.[UniqueID]
-- WHERE a.PropertyAddress IS NULL

-- for psql
-- SELECT 
--     a."ParcelID", 
--     a."PropertyAddress",
--     b."ParcelID",
--     b."PropertyAddress",
--     COALESCE(a."PropertyAddress", b."PropertyAddress") AS filled_address   --return a.PropertyAddress if it is not null else second one else null
-- FROM house AS a
-- JOIN house AS b
--     ON a."ParcelID" = b."ParcelID"
--    AND a."UniqueID" <> b."UniqueID"
-- WHERE a."PropertyAddress" IS NULL; 

 --only taking a's row with property address null and b will have no restriction.
 -- so while coalesing a's add will be null and b's addr will be real addr in case of same parcel id,so the actual addr is choosen
 -- a."UniqueID" <> b."UniqueID" this denote only if they are different rows not same one

-- UPDATE "house" AS a
-- SET "PropertyAddress" = b."PropertyAddress"
-- FROM "house" AS b
-- WHERE a."PropertyAddress" IS NULL
--   AND a."ParcelID" = b."ParcelID"
--   AND a."UniqueID" <> b."UniqueID";
-- find other row in the same table with same paracel id and replace the null address of same parcel id with that address.

-- SELECT "PropertyAddress"
-- FROM house
-- WHERE "PropertyAddress" IS NULL;

-- breaking out address into individual address,city and state

-- ALTER TABLE "house"
-- ADD COLUMN "PropertySplitAddress" VARCHAR(255);

-- ALTER TABLE "house"
-- ADD COLUMN "PropertySplitCity" VARCHAR(255);

-- UPDATE house
-- SET "PropertySplitAddress" = SUBSTRING(
-- "PropertyAddress" FROM 1 FOR (POSITION (',' IN "PropertyAddress") - 1)
-- )
-- SUBSTRING(string FROM start_position FOR length)

-- UPDATE "house"
-- SET "PropertySplitCity" = SUBSTRING(
--     "PropertyAddress" FROM (POSITION(',' IN "PropertyAddress") + 1) FOR LENGTH("PropertyAddress")
-- );

-- ALTER TABLE "house"
-- ADD COLUMN "OwnerSplitAddress" VARCHAR(255);

-- ALTER TABLE "house"
-- ADD COLUMN "OwnerSplitCity" VARCHAR(255);

-- ALTER TABLE "house"
-- ADD COLUMN "OwnerSplitState" VARCHAR(255);

-- UPDATE "house"
-- SET "OwnerSplitAddress" = TRIM(split_part("OwnerAddress", ',', 1));

-- UPDATE "house"
-- SET "OwnerSplitCity" = TRIM(split_part("OwnerAddress", ',', 2));

-- UPDATE "house"
-- SET "OwnerSplitState" = TRIM(split_part("OwnerAddress", ',', 3));

-- SELECT DISTINCT "SoldAsVacant", COUNT("SoldAsVacant")
-- FROM "house"
-- GROUP BY "SoldAsVacant";

-- SELECT 
--     "SoldAsVacant",
--     CASE 
--         WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
--         WHEN "SoldAsVacant" = 'N' THEN 'No'
--         ELSE "SoldAsVacant"
--     END AS SoldAsVacantFixed
-- FROM "house";

-- UPDATE "house"
-- SET "SoldAsVacant" = CASE
--     WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
--     WHEN "SoldAsVacant" = 'N' THEN 'No'
--     ELSE "SoldAsVacant"
-- END;

-- removing duplicates in table

-- WITH RowNumCTE AS (
--     SELECT *,
--         ROW_NUMBER() OVER (
--             PARTITION BY "ParcelID",
--                          "PropertyAddress",
--                          "SaleDate",
--                          "SalePrice",
--                          "LegalReference"
--             ORDER BY "UniqueID"
--         ) AS row_num
--     FROM "house"
-- )
-- SELECT *
-- FROM RowNumCTE
-- WHERE row_num > 1;

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY "ParcelID",
                         "PropertyAddress",
                         "SaleDate",
                         "SalePrice",
                         "LegalReference"
            ORDER BY "UniqueID"
        ) AS row_num
    FROM "house"
)
DELETE FROM "house"
USING RowNumCTE
WHERE "house"."UniqueID" = RowNumCTE."UniqueID"
  AND RowNumCTE.row_num > 1;
