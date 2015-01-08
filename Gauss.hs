module Gauss where

import Fraction

type Row = [ Frac Integer ]
type Matrix = [ Row ]

-- 1. Sort rows by count of leading zeros
-- 2. Make zero in each row at its index position and add it to others making zero in that position from top to bottom
-- 3. Do the same from bottom to the top

gaussConvertMatrix :: [ [ Integer ] ] -> Matrix
gaussConvertMatrix [] = []
gaussConvertMatrix (r:rs) = (map (\e -> e % 1) r) : (gaussConvertMatrix rs)

quicksort :: (Ord a) => [a] -> (a -> a -> Int) -> [a]
quicksort [] _ = []
quicksort (x:xs) cmp = (quicksort lesser cmp) ++ [x] ++ (quicksort greater cmp)
	where
		lesser = filter (\i -> (cmp x i) < 0) xs
		greater = filter (\i -> (cmp x i) >= 0) xs

leadingZeros :: Row -> Int
leadingZeros = length . takeWhile (== 0)

gaussCompareRows :: Row -> Row -> Int
gaussCompareRows r1 r2 = leadingZeros r2 - leadingZeros r1

gaussSortMatrix :: Matrix -> Matrix
gaussSortMatrix = (flip quicksort) gaussCompareRows

-- here, guaranteed that r1 has less leading zeros than r2
gaussMakeZero :: Row -> Row -> Row
gaussMakeZero r1 r2 = map (\pair -> ((fst pair) * factor) + (snd pair)) (zip r1 r2)
	where
		index = leadingZeros r1
		r1_elt = r1 !! index
		r2_elt = r2 !! index
		factor = -r2_elt / r1_elt

gaussReduce :: Matrix -> Matrix
gaussReduce [] = []
gaussReduce (r1:rs) = r1 : (gaussReduce (map (gaussMakeZero r1) rs))

gaussFixCoefficients :: Matrix -> Matrix
gaussFixCoefficients [] = []
gaussFixCoefficients (r:rs) = (map (\e -> e / factor) r) : (gaussFixCoefficients rs)
	where
		index = leadingZeros r
		factor = r !! index

gaussShowVars :: Row -> String
gaussShowVars r = if (length other_coefficients) > 0 then (var_str ++ other_vars_str) else var_str
	where
		index = leadingZeros r
		koefficient = r !! index
		value = head (reverse r)
		raw_row = reverse (drop 1 (reverse r))
		elements_count = length raw_row
		other_coefficients = filter (\pair -> (fst pair) /= 0 && ((snd pair) - 1) /= index) (zip raw_row [1..elements_count])
		subtract_coefficient = (\k -> if k < 0 then (" + " ++ show (-k)) else (" - " ++ (show k)))
		other_vars_str = concat (map (\pair -> (subtract_coefficient (fst pair)) ++ " * var_" ++ (show (snd pair))) other_coefficients)
		var_str = "var_" ++ (show (index + 1)) ++ " = " ++ (show (value / koefficient))

gaussExtractResults :: Matrix -> String
gaussExtractResults [] = []
gaussExtractResults (r:rs) = (gaussShowVars r) ++ "\n" ++ gaussExtractResults rs

gaussSolve :: Matrix -> Matrix
gaussSolve mat = gaussFixCoefficients (reverse (gaussReduce (reverse (gaussReduce mat))))

gaussSolveList :: [[Integer]] -> Matrix
gaussSolveList mat = gaussSolve (gaussConvertMatrix mat)