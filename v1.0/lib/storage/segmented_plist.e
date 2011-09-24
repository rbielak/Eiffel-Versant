-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "SEGMENTED_PLIST - a persistent list that is %
                 %implemented with segmented storage to make handling %
                 %of big list more efficient"


class SEGMENTED_PLIST [T -> POBJECT]

inherit

	RLIST [T]
		redefine
			generator
		end

	POBJECT
		undefine
			is_equal,
			copy
		redefine
			generator,
			make_transient
		end

creation

	make,
	make_from_list 

feature -- creation

	make (lgenerator: STRING; lseg_size: INTEGER) is
		require
			generator_not_void: lgenerator /= Void
			size_valid: lseg_size > 1
		local
			i: INTEGER
		do
			generator := lgenerator.twin
			generator.prune_all (' ')
			max_segment_size := lseg_size
			i := generator.index_of ('_', 1)
			area_item_generator := generator.substring (i + 1, generator.count)
			area_generator := "PLIST["
			area_generator.append (area_item_generator)
			area_generator.append ("]")
			!!area.make (area_generator)
		end

	make_from_list (other: RLIST [T]) is
		require
			other_not_void: other /= Void
		do
			except.raise ("not implemented")
		end

	generator: STRING

feature -- access and modification

	count: INTEGER 

	extend (it: T) is
		local
			seg: PLIST[T]
		do
			seg := area.last
			-- add to the end of the list
			if (seg = Void) or else seg.count = max_segment_size then
				-- Create a new segment
				!!seg.make (area_item_generator)
				area.extend (seg)
			end
			seg.extend (it)
			count := count + 1
		end

	remove_item (it: T) is
		local
			i: INTEGER
			removed: BOOLEAN
			seg: PLIST[T]
		do
			from i := 1
			until (i > area.count) or removed
			loop
				seg := area.i_th (i)
				if seg.has (it) then
					seg.remove_item (it)
					removed := True
				end
				i := i + 1
			end
			if removed then
				count := count - 1
			end
		end

	remove_all is
		do
			area.remove_all
			count := 0
		end

	i_th (i: INTEGER): T is
		local
			n, m: INTEGER
			seg: PLIST [T]
			temp_cell: CELL [T]
			pcell: CELL [POBJECT]
		do
			-- figure out which segment the item is in
			n := i
			from 
				m := 2
				seg := area.first
			until (m > area.count) or (n <= seg.count)
			loop
				if n > seg.count then
					n := n - seg.count
					seg := area.i_th (m)
					m := m + 1
				end
			end
			-- stupid cell trick
--			!!temp_cell.put (Void)
--			pcell := temp_cell
--			pcell.put (seg.area.i_th (n))
--			Result := temp_cell.item
			-- Want to do this:
			Result := seg.i_th (n)
		end

feature -- segmenting

	max_segment_size: INTEGER
			-- number of items in each segment

	resegment (new_max_segment_size: INTEGER) is
			-- rebuild accourding to new segment size
		require
			segment_size_positive: new_max_segment_size > 1
		do
			if max_segment_size /= new_max_segment_size then
				max_segment_size := new_max_segment_size 
				-- TODO: rebuild the list
				except.raise ("not implemented")
			end
		end

feature {NONE} -- implementation

	area_generator: STRING
	
	area_item_generator: STRING

	area: PLIST [PLIST[T]]

	make_transient is
		local
			i: INTEGER 
		do
			-- set generator
			generator := pobject_class.eiffel_name.twin
			i := generator.index_of ('_', 1)
			area_item_generator := generator.substring (i + 1, generator.count)
			area_generator := "PLIST["
			area_generator.append (area_item_generator)
			area_generator.append ("]")
		end

invariant
	
	valid_max_segment_size: max_segment_size > 1
	valid_count: count >= 0
	area_not_void: area /= Void
end

