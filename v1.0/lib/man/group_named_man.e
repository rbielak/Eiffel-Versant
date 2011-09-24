-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Man that hold together many NAMED_MANs
--

class GROUP_NAMED_MAN [T -> NAMED_MANAGEABLE]

inherit
	
	NAMED_MAN [T]
		undefine
			item_from_tag, tags, has, extend, count, get_item,
			is_acceptable, i_th, type_from_tag, generator, force_item,
			remove_item, remove_all, has_item, available, store_differences
		redefine
			update, preload
		end
	
	GROUP_RLIST [T]
		rename
			init as group_rlist_init
		undefine
			generator, remove_item, remove_all, is_valid_element
		redefine
			rlists, tags, extend
		end


creation
	
	init

feature
	
	extend (item: T) is
		do
			if is_acceptable (item) then
				add_target.extend (item)
			else
				except.raise ("Cannot add item to GROUP_NAMED_MAN")
			end
		end
	
	update (item: T) is
		do
			item.store_difference
		end
	
	is_acceptable (item: T): BOOLEAN is
		local
			i: INTEGER
		do
			Result := True
			from i := rlists.lower
			until i > rlists.upper
			loop
				Result := Result and rlists.item (i).is_acceptable (item)
				i := i + 1
			end
		end
	
	available: BOOLEAN is
		do
			Result := True
		end
	
	force_item (item: T) is 
		do
			add_target.force_item (item)
		end
	
	get_item (lname: STRING): T is
		do
			Result := item_from_tag (lname)
		end
	
	has_item (lname: STRING): BOOLEAN is 
		do
			Result := (item_from_tag (lname) /= Void)
		end
	
	remove_item (item: T) is
		local
			one_man: NAMED_MAN [T]
			done: BOOLEAN
			i: INTEGER
		do
			from i := rlists.lower
			until (i > rlists.upper) or done
			loop
				one_man := rlists.item (i)
				if one_man.has (item) then
					one_man.remove_item (item)
					done := True
				end
				i := i + 1
			end
		end
	
	remove_all is
		local
			i: INTEGER
		do
			db_interface.start_transaction
			from i := rlists.lower
			until (i > rlists.upper) 
			loop
				rlists.item (i).remove_all
				i := i + 1
			end
			db_interface.end_transaction
		end
	
	store_differences is
		local
			i: INTEGER
		do
			db_interface.start_transaction
			from i := rlists.lower
			until (i > rlists.upper) 
			loop
				rlists.item (i).store_differences
				i := i + 1
			end
			db_interface.end_transaction
		end
			
	
	tags: BOUNDED_RLIST [STRING] is
		local
			i: INTEGER
			rlists_tags: like tags
		do
			!!Result.make (count)
			from i := rlists.lower
			until (i > rlists.upper) 
			loop
				rlists_tags := rlists.item (i).tags
				if rlists_tags /= void then
					Result.append (rlists_tags)
				end
				i := i + 1
			end
		end

	
	init (other_man: ARRAY [NAMED_MAN [T]]) is
		require
			other_man_ok: (other_man /= Void) and (other_man.count > 0)
		local
			i: INTEGER
		do
			group_rlist_init (other_man)
			root_name := "("
			from i := other_man.lower
			until i > other_man.upper
			loop
				if other_man.item (i) = Void then
					root_name.append ("Unknown!! ")
				else
					root_name.append (other_man.item(i).root_name)
				end
				root_name.append (" ")
				i := i + 1
			end
			root_name.append (")")
			name := root_name
			contents_type := "NAMED_MAN [NAMED_MANAGEABLE]"
			rights_stamp := db_interface.read_write_allowed
		end
	
	generator: STRING is
		do
			Result := "GROUP_NAMED_MAN [NAMED_MANAGEABLE]"
		end
	
	set_add_target (new_target: NAMED_MAN [T]) is
			-- set man which will be the target for "extend" calls
		local
			i: INTEGER
			found: BOOLEAN
		do
			from i := rlists.lower
			until (i > rlists.upper) or found
			loop
				found := new_target = rlists @ i 
				i := i + 1
			end
			if found then
				add_target := new_target
			else
				except.raise ("Target not in GROUP_NAMED_MAN")
			end
		end

	preload is
		local
			i: INTEGER
		do
			from 
				i := rlists.lower
			until 
				i > rlists.upper
			loop
				rlists.item (i).preload
				i := i + 1
			end
		end


feature {NONE}

	rlists: ARRAY [NAMED_MAN [T]]
			-- members of this group
	
	add_target: NAMED_MAN [T]
			-- adds go in here
	

end -- GROUP_NAMED_MAN
