-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--

class MEMORY_SORTER [T]
	
inherit

	ABSTRACT_SORTER [T]
	
	SHARED_INTERNAL_INFOS
	
creation
	
	make

feature
	
	make (criteria : ARRAY[STRING]) is
		require
			(criteria /= Void) and then (criteria.count > 0)
		local
			one_path : ATTR_PATH;
			i : INTEGER;
			typer : ATTR_TYPER;
		do
			!!typer;
			-- Create sort_key_paths
			!!sort_key_paths.make (1, criteria.upper);
			from i := 1
			until i > criteria.upper
			loop
				!!one_path.make (criteria @ i);
				sort_key_paths.put (one_path, i);
				i := i + 1
			end;
		end;
	
	sort_list (a_list : RLIST[T]) is
		do
			-- List with only one element is already sorted
			if a_list.count > 1 then
				-- Create the array to hold keys from the
				-- objects in the list
				!!key_array.make (1, a_list.count)
				!!object_array.make (1, a_list.count)
				load_keys_array (a_list)
				sort_keys (1, a_list.count)
				reload_list (a_list)
			end
		end
	
feature {NONE}	
	
	key_array: ARRAY [ARRAY [COMPARABLE]]
			-- Array of keys extracted from
	
	object_array: ARRAY [T]
	
	sort_key_paths: ARRAY[ATTR_PATH]
			-- names of fields in which we sort

	load_keys_array (a_list : RLIST[T]) is
			-- Create an array with the values of sort attributes
		local
			i: INTEGER
			object: T
		do
			from
				i := 1
			until
				i > a_list.count
			loop
				object := a_list.i_th (i);
				key_array.put (create_key_entry (object), i)
				object_array.put (object, i)
				i := i + 1
			end
		end
	
	create_key_entry (object: ANY): ARRAY [COMPARABLE] is
		require
			object_ok: object /= void
		local
			i: INTEGER
			value: COMPARABLE
			path: ATTR_PATH
		do
			!!Result.make (1, sort_key_paths.upper)
			-- Now retrieve the values of the named attributes
			-- and plunk them into the array
			from
				i := 1
			until
				i > Result.upper
			loop
				path := sort_key_paths @ i
				value ?= value_of_attr (object, path)
				Result.put (value, i)
				i := i + 1
			end
		end
	
	
	
	
	sort_keys (lower, upper: INTEGER) is
			-- Sort the array between "lower" and "upper". If the
			-- number of elements is less than the "cut_off" value use
			-- insertion sort, otherwise use "quick_sort"
		require
			consistent_args: lower <= upper
		local
			pivot, j, i: INTEGER
		do
			-- If lower=upper then the array has size of 1, so it is
			-- already sorted. 
			if lower < upper then
				-- If the array has fewer than 15 elements it is
				-- faster to sort using insertion sort. I tested it,
				-- plus see "Programming Pearls" by John Bentley for
				-- the same result
				if (upper - lower) <= 15 then
					-- Insertion sort
					from 
						i := lower
					until 
						(i > upper) 
					loop
						from j := i + 1
						until j > upper
						loop
							if less_than (key_array @ j, key_array @ i) then 
								-- Swap items
								swap (i, j)
							end
							j := j + 1
						end
						i := i + 1
					end
				else
					-- First swap the first element of the array with
					-- a middle one, to deal with the horrible case of
					-- already sorted array
					pivot := (upper + lower) // 2
					swap (lower, pivot)
					-- Quick sort here (we pivot on the first element of the array)
					from 
						i := lower + 1
						j := upper
					variant
						converging: j - i + 2
					until
						i > j
					loop
						if less_than (key_array @ i, key_array @ lower) then 
							i := i + 1
						elseif not less_than (key_array @ j, key_array @ lower) then 
							j := j - 1
						else
							swap (i, j)
							i := i + 1
							j := j - 1
						end -- if
					end -- loop
					-- place the pivot element where it's supposed to be
					swap (lower, j) 
					if lower < j - 1 then
						sort_keys (lower, j - 1)
					end
					if j + 1 < upper then
						sort_keys (j + 1, upper)
					end
				end
			end
		ensure
			is_sorted (lower, upper)
		end
	
	swap (i, j: INTEGER) is
		local
			temp: ARRAY [COMPARABLE]
			temp_object: T
		do
			temp := key_array @ j
			key_array.put (key_array @ i, j)
			key_array.put (temp, i)
			temp_object := object_array @ j
			object_array.put (object_array @ i, j)
			object_array.put (temp_object, i)
		end
	
	is_sorted (lower, upper: INTEGER) : BOOLEAN is
			-- True if the array is already sorted (only used for testing)
		local
			i: INTEGER
		do
			Result := True
			from i := lower
			until (i + 1 > upper) or not Result
			loop
				Result := less_than (key_array @ i, key_array @ (i + 1))
				i := i + 1
			end
		end
	
	
--	sort_keys (low, high: INTEGER) is
--			-- Sort the keys array using Quick sort
--		local
--			pivot: ARRAY[COMPARABLE]
--			object_pivot: T
--			swapped: BOOLEAN
--			i, j: INTEGER
--		do
--			-- Do some stupid sort for now and update later
--			from 
--				i := low
--				swapped := True
--			until
--				(i > high) or not swapped
--			loop
--				from
--					j := i
--				until
--					j > high
--				loop
--					if not less_than (key_array @ i, key_array @ j) then
--						swapped := True
--						pivot := key_array.item (i)
--						key_array.put (key_array.item (j), i)
--						key_array.put (pivot, j)
--						object_pivot := object_array.item (i)
--						object_array.put (object_array.item (j), i)
--						object_array.put (object_pivot, j)
--					end
--					j := j + 1
--				end
--				i := i + 1
--			end
--		end
	
	reload_list (a_list: RLIST[T]) is
			-- Rebuild `a_list' from `object_array'.
		require
			has_list: a_list /= void
		local
			i: INTEGER
		do
			from
				i := 1
				a_list.remove_all
			until
				i > object_array.count
			loop
				a_list.extend (object_array.item (i))
				i := i + 1
			end
		end;
	
	less_than (key1, key2 : ARRAY [COMPARABLE]) : BOOLEAN is
			-- lexical comparison of two keys
		require
			(key1 /= Void) and (key2 /= Void)
		local
			val1, val2 : COMPARABLE;
			i : INTEGER;
			done : BOOLEAN;
		do
			from i := 1 
			until (i > key1.upper) or done
			loop
				val1 := key1 @ i;
				val2 := key2 @ i;
				-- At least one key is not Void
				if (val1 /= Void) or (val2 /= Void) then
					-- Void keys are considered less than
					-- non-void keys
					if val1 = Void then -- so val2 /= Void
						Result := True
						done := True;
					elseif val2 = Void then -- so val1 /= Void
						Result := false
						done := True
					elseif val1 < val2 then
						Result := True;
						done := True
					elseif val1 > val2 then
						Result := False
						done := True
					end;
				end
				-- These are equal, try next one
				i := i + 1
			end
		end
  
	value_of_attr (current_object: ANY; path : ATTR_PATH) : ANY is
			-- Value of `object.path'.
		require
			object_ok : current_object /= void
			path_ok: path /= Void
		local
			i: INTEGER
			object: like current_object
			attr_index: INTEGER
		do
			from
				i := 1
				object := current_object
			until 
				(i > path.count) or (object = Void)
			loop
				attr_index := attribute_index_of (object, path.i_th (i))
				if attr_index = 0 then
					exceptions.raise ("Query on a attribute who doesn't exist")
				else
					if i = path.count then
						inspect field_type (attr_index, object)
						when Boolean_type then
							Result := boolean_field (attr_index, object)
						when Character_type then
							Result := character_field (attr_index, object)
						when Double_type then
							Result := double_field (attr_index, object)
						when Integer_type then
							Result := integer_field (attr_index, object)
						when Reference_type then
							Result := field (attr_index, object)
						when Real_type, Expanded_type, Bit_type, Pointer_type then
							exceptions.raise ("Query on a illegal type")
						end
					else
						object := field (attr_index, object)
					end
				end
				i := i + 1
			end
		end

end -- MEMORY_SORTER
