-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- List of access rights 
--

class ROOT_RIGHTS_SET

inherit
	
	POBJECT

creation
	
	make, make_with_rights_list

feature
	
	add_rights_list (list: like RIGHTS) is
		require
			list_exists: list /= Void
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > list.count
			loop	
				add_rights (list.item (i))
				i := i + 1
			end
		end

	add_rights (item : ROOT_RIGHTS) is
		require
			rights_present: item /= Void
		do
			rights.extend (item);
			sort_rights_list
		ensure
			has_it: rights.has (item);
		end
	
	remove_rights (item : ROOT_RIGHTS) is
		require
			rights_present: item /= Void
		do
			if rights.has (item) then
				rights.remove_item (item)
			end
		ensure
			removed: not rights.has(item);
		end
	
	get_root_rights_stamp (root_name : STRING) : INTEGER is
			-- Get the rights stamp for a particular
			-- persistency root
		require
			name_ok: root_name /= Void
		local
			rrights: ROOT_RIGHTS
			done: BOOLEAN
			i: INTEGER
		do
			Result := -1
			-- Scan the rights list for a matching entry
			from  i := 1
			until (i > rights.count) or done
			loop
				rrights := rights.i_th (i);
				if match (root_name, rrights.root_name) then
					Result := rrights.root_rights_stamp;
					done := True
				end
				i := i + 1
			end
		end

	get_root_rights (root_name: STRING): ROOT_RIGHTS is
		require
			name_ok: root_name /= Void
		local
			rrights: ROOT_RIGHTS
			done: BOOLEAN
			i: INTEGER
		do
			from  i := 1
			until (i > rights.count) or done
			loop
				rrights := rights.i_th (i);
				if match (root_name, rrights.root_name) then
					Result := rrights
					done := True
				end
				i := i + 1
			end
		end
	
	
	rights : PLIST [ROOT_RIGHTS]
			-- list of rights
	
feature {NONE}
	

	make is
		do
			!!rights.make ("PLIST[ROOT_RIGHTS]");
		end
	
	make_with_rights_list (list: like RIGHTS) is
		do
			make
			add_rights_list (list)
		end

	sort_rights_list is
			-- Sort the list by priority
		do
			sorter.sort_list (rights);
		end
	
	match (name, pattern : STRING) : BOOLEAN is
		local
			t1, t2 : ANY;
		do
			t1 := name.to_c;
			t2 := pattern.to_c;
			Result := match_wild_card ($t1, $t2);
		end
	
	sorter : SORTER [ROOT_RIGHTS] is
		once
			!!Result.make (<<"priority">>);
		end

	
	match_wild_card (str, pattern : POINTER) : BOOLEAN is
		external "C"
		end


end -- ROOT_RIGHTS_SET
