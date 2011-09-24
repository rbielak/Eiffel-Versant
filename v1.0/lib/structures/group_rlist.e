-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--

-- Set of lists.
-- The sub-lists are not copied. So there is no-need to update the
-- GROUP_RLIST when one of the sub-lists is changed.

class GROUP_RLIST [T]

inherit

	RLIST [T]
		undefine
			has, tags, item_from_tag
		redefine
			generator
		end

	SUBSCRIBER
		redefine
			generator
		end

	TAGABLE
		undefine
			copy, is_equal
		redefine
			generator
		end

creation

	init

feature

	generator: STRING is
		do
			Result := "GROUP_RLIST[ANY]"
		end

	set_name (lname: STRING) is
			-- Change the list name
		do
			name := lname
		end

	name: STRING
			-- List name

	tag: STRING is
			-- List tag displayed on screen.
			-- If `set_name' has not been called.
			-- From TAGABLE.
		do
			if name = void then
				Result := generator
			else
				Result := name
			end
		end

	rlists: ARRAY [RLIST [T]]
			-- Sub-list of `Current'.

	init (rls: like rlists) is
		local
			i, j, void_count, rlists_count: INTEGER
		do
			debug
				io.putstring ("GROUP_RLIST.init (...)%N")
			end
			-- Count the number of void references.
			from
				i := 1
			until
				i > rls.count
			loop
				if rls.item (i) = void then
					void_count := void_count+1
				end
				i := i+1
			end
			if void_count = 0 then
				-- If there is no void reference, use the initial parameter.
				rlists := rls
			else
				-- If there is void references, copy the not void references only.
				from
					i := 1
					j := 1
					!!rlists.make (1, rls.count-void_count)
				until
					i > rls.count
				loop
					if rls.item (i) /= void then
						rlists.put (rls.item (i), j)
						j := j+1
					end
					i := i+1
				end
			end
			-- Subscribe to all sub-lists.
			from
				i := 1
				rlists_count := rlists.count
			until
				i > rlists_count
			loop
				subscribe (rlists.item (i))
				i := i+1
			end
		end;

	has (element: T): BOOLEAN is
			-- From RLIST.
		local
			i, rlists_count: INTEGER
		do
			from
				i := 1
				rlists_count := rlists.count
			until
				(i > rlists_count) or Result
			loop
				Result := Result or rlists.item (i).has (element)
				i := i+1
			end
			debug
				io.putstring ("GROUP_RLIST.has (...) = ")
				io.putbool (Result)
				io.putstring ("%N")
			end
		end;

	remove_item (item: T) is
			-- From RLIST.
			-- In GROUP_RLIST, do nothing.
		do
		end

	extend (new: T) is
			-- From RLIST.
			-- In GROUP_RLIST, do nothing.
		do
		end

	remove_all is
			-- From RLIST.
			-- In GROUP_RLIST, do nothing.
		do
		end
	
	i_th (i: INTEGER): T is
			-- From RLIST.
		local
			j, k, rlists_count: INTEGER
			rlists_item_k: RLIST [T]
			rlists_item_k_count: INTEGER
		do
			from
				k := 1
				j := 1
				rlists_count := rlists.count
			until
				(k > rlists_count) or (Result /= void)
			loop
				rlists_item_k := rlists.item (k)
				rlists_item_k_count := rlists_item_k.count
				j := j + rlists_item_k_count
				if j > i then
					Result := rlists_item_k.i_th (1+i-(j-rlists_item_k_count))
				end
				k := k+1
			end
			debug
				io.putstring ("GROUP_RLIST.i_th (")
				io.putint (i)
				io.putstring (") = ")
				if Result = void then
					io.putstring ("void%N")
				else
					io.putstring ("...%N")
				end
			end
		end

	tags: RLIST [STRING] is
			-- From RLIST.
			-- Dangerous.
		local
			i, k, rlists_count: INTEGER
			rlists_item_i_tags: RLIST [STRING]
			rlists_tags: ARRAY [RLIST [STRING]]
			rlists_item_i_count: INTEGER
			tags_list: BOUNDED_RLIST [STRING]
			no_tags: BOOLEAN
		do
			!!tags_list.make (count)
			rlists_count := rlists.count
			!!rlists_tags.make (1, rlists_count)
			from
				i := 1
			until
				(i > rlists_count) or no_tags
			loop
				if rlists.item (i).count > 0 then
					rlists_item_i_tags := rlists.item (i).tags
					if rlists_item_i_tags = void then
						no_tags := true
					else
						rlists_tags.put (rlists_item_i_tags, i)
					end
				end
				i := i+1
			end
			if not no_tags then
				from 
					i := 1
				until
					i > rlists_count
				loop
					rlists_item_i_tags := rlists_tags.item (i)
					if rlists_item_i_tags /= void then
						rlists_item_i_count := rlists_item_i_tags.count
						from
							k := 1
						until
							k > rlists_item_i_count
						loop
							tags_list.arrayed_list_extend (rlists_item_i_tags.i_th (k))
							k := k+1
						end
					end
					i := i+1
				end
				Result := tags_list
			end
		end

	item_from_tag (a_tag: STRING): T is
			-- From RLIST.
		local
			i, rlists_count: INTEGER
		do
			from
				i := 1
				rlists_count := rlists.count
			until
				(i > rlists_count) or (Result /= void)
			loop
				Result := rlists.item (i).item_from_tag (a_tag)
				i := i+1
			end
		end

	count: INTEGER is
			-- From RLIST.
		local
			i, rlists_count: INTEGER
		do
			from
				i := 1
				rlists_count := rlists.count
			until
				i > rlists_count
			loop
				Result := Result + rlists.item (i).count
				i := i+1
			end
			debug
				io.putstring ("GROUP_RLIST.count = ")
				io.putint (Result)
				io.putstring ("%N")
			end
		end

	update_subscriber (p: PUBLISHER; info: ANY) is
			-- Publish the modification.
		do
			publish (info)
		end

	recursive_rlist_from_item (element: T): RLIST [T] is
			-- The RLIST who contains element.
			-- Warning: it ignores the intermediate GROUP_RLIST.
		require
			element_not_void: element /= void
		local
			rlists_count, i: INTEGER
			other_group: GROUP_RLIST [T]
		do
			rlists_count := rlists.count
			from
				i := 1
			until
				(i > rlists_count) or (Result /= void)
			loop
				other_group ?= rlists.item (i)
				if other_group /= void then
					Result := other_group.recursive_rlist_from_item (element)
				else
					if rlists.item (i).has (element) then
						Result := rlists.item (i)
					end
				end
				i := i+1
			end
		end

end
