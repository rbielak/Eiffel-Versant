-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- This class sorts lists of persistent objects. The sort depends on
-- the database a lot, because no Eiffel objects are created for comparisons
--

class SORTER [T->POBJECT]
	
inherit 

	ABSTRACT_SORTER [T]

	DB_GLOBAL_INFO

	DB_CONSTANTS

	VERSANT_EXTERNALS

creation

	make

feature
	
	make (criteria : ARRAY[STRING]) is
		require
			(criteria /= Void) and then (criteria.count > 0)
		local
			one_path : ATTR_PATH;
			i : INTEGER;
		do
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
	
	sort_list (a_list : PLIST[T]) is
		local
			context: DB_OPERATION_CONTEXT
		do
			-- List with only one element is already sorted
			if a_list.count > 1 then
				-- Allocate op context
				!!context.make_for_retrieve
				db_interface.operation_context_stack.put (context)
				-- Find out types of the sort keys
				create_value_extractors (a_list);
				-- Create the array to hold keys from the
				-- objects in the list
				!!key_array.make (1, a_list.count);
				load_keys_array (a_list);
				sort_keys (1, a_list.count);
				reload_list (a_list);
				-- free op context
				context.mark_objects_not_in_progress 
				db_interface.operation_context_stack.remove 
			end;
		end

feature {NONE}	
	
	key_array : ARRAY[SORTER_KEY_ENTRY [T]];
			-- Array of keys extracted from 
	
	sort_key_paths : ARRAY[ATTR_PATH];
			-- names of fields in which we sort

	sort_field_extractors : ARRAY[ATTR_VALUE];
			--- objects for extracting values of the sort fields


	load_keys_array (a_list : PLIST[T]) is
			-- Create an array with the values of sort attributes
		local
			i : INTEGER
			object_id : INTEGER
			key_entry : SORTER_KEY_ENTRY [T]
		do
			from i := 1
			until i > a_list.count
			loop
				object_id := a_list.i_th_object_id (i);
				if object_id = 0 then
					-- object must be in memory
					key_entry := create_key_entry_from_object (a_list.i_th (i))
				else
					key_entry := create_key_entry_from_id (object_id);
				end
				key_array.put (key_entry, i);
				i := i + 1
			end;
		end;
	
	create_key_entry_from_id (object_id : INTEGER) : SORTER_KEY_ENTRY [T] is
		require
			object_id_ok: (object_id /= 0)
		local
			i : INTEGER
			value : COMPARABLE
			path : ATTR_PATH
			extractor : ATTR_VALUE
			keys: ARRAY [COMPARABLE]
		do
			!!keys.make (1, sort_key_paths.upper)
			-- Now retrieve the values of the named attributes
			-- and plunk them into the array
			from i := 1
			until i > keys.upper
			loop
				path := sort_key_paths @ i;
				extractor := sort_field_extractors @ i;
				value ?= extractor.value_of_attr (object_id, path);
				keys.put (value, i);
				i := i + 1
			end
			!!Result
			Result.set_keys (keys)
			Result.set_pobject_id (object_id)
		end;
	
	create_key_entry_from_object (object: T) : SORTER_KEY_ENTRY [T] is
		require
			object_id_ok: (object /= Void)
		local
			i : INTEGER;
			value : COMPARABLE;
			path : ATTR_PATH;
			extractor : ATTR_VALUE;
			keys: ARRAY [COMPARABLE]
		do
			!!keys.make (1, sort_key_paths.upper);
			-- Now retrieve the values of the named attributes
			-- and plunk them into the array
			from i := 1
			until i > keys.upper
			loop
				path := sort_key_paths @ i;
				extractor := sort_field_extractors @ i;
				value ?= extractor.value_of_attr_from_object (object, path);
				keys.put (value, i);
				i := i + 1
			end
			!!Result
			Result.set_keys (keys)
			Result.set_pobject (object)
		end;

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
							if less_than (key_array.item(j).keys, key_array.item (i).keys) then 
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
						if less_than (key_array.item(i).keys, key_array.item (lower).keys) then 
							i := i + 1
						elseif not less_than (key_array.item(j).keys, key_array.item (lower).keys)
						 then 
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
			temp: SORTER_KEY_ENTRY [T]
		do
			temp := key_array @ j
			key_array.put (key_array @ i, j)
			key_array.put (temp, i)
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
				Result := not (less_than (key_array.item(i + 1).keys, key_array.item(i).keys))
				i := i + 1
			end
		end

	reload_list (a_list : PLIST[T]) is
		local
			object_id : INTEGER_REF
			i  : INTEGER;
			key_entry: SORTER_KEY_ENTRY [T]
		do
			from
				i := 1
			until
				i > key_array.count
			loop
				key_entry := key_array.item (i)
				if key_entry.pobject_id /= 0 then
					a_list.put_i_th_object_id (key_entry.pobject_id, i)
				else
					a_list.put_i_th (key_entry.pobject, i)
				end
				i := i + 1
			end
		end
	
	less_than (key1, key2 : ARRAY[COMPARABLE]) : BOOLEAN is
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
			end;
		end;
	
	create_value_extractors (a_list : PLIST [T]) is
		local
			element_class_name : STRING
			typer : ATTR_TYPER
			i: INTEGER
			extractor : ATTR_VALUE
			first_object_id, class_id: INTEGER
			pclass: PCLASS
		do
			if a_list.count >= 1 then
				-- First get element class type from the first object in the PLIST
				-- Do not rely on the the PLIST class_generator but on the real elements
				-- This may be dangerous in the future but it is safe as long as we use
				-- one system (batch server) to perform queries
				element_class_name := a_list.i_th_type (1)
				check
					class_name_ok : element_class_name /= Void
				end

				!!typer
				!!sort_field_extractors.make (1, sort_key_paths.upper)
				from i := 1
				until i > sort_key_paths.count
				loop
					inspect typer.type_of_attr (element_class_name, sort_key_paths @ i)
					when Eiffel_string then
						!ATTR_VALUE_STRING!extractor
					when Eiffel_integer then
						!ATTR_VALUE_INTEGER!extractor
					when Eiffel_char then
						!ATTR_VALUE_CHAR!extractor
					else
						exceptions.raise ("Type not supported")
					end
					sort_field_extractors.put (extractor, i)
					i := i + 1
				end
			end
		end

end -- SORTER
