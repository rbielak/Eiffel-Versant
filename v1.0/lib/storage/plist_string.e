-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class PLIST_STRING

inherit

	POBJECT
	
	RLIST [STRING]
		undefine
			is_equal, copy
		redefine
			has
		end;
	
creation

	make,
	make_from_list,
	make_from_array

feature
	
	make is
		do
			!!area.make ("PLIST[PSTRING_OBJECT]");
		end

	make_from_list (lstrings : FAST_LIST [STRING]) is
		require
			valid_call : lstrings /= Void
		do
			make
			from
				lstrings.start
			until
				lstrings.after
			loop
				extend (lstrings.item)
				lstrings.forth
			end
		end

	make_from_array (lstrings : ARRAY [STRING]) is
		require
			valid_call : lstrings /= Void
		local
			i, sz : INTEGER
		do
			make
			from
				i := 1
				sz := lstrings.count
			until
				i > sz
			loop
				extend (lstrings.item (i))
				i := i + 1
			end
		end

feature
	
	count: INTEGER is
		do
			Result := area.count;
		end;
	
--	append (new_value: STRING) is
--		obsolete "Use extend instead. append will be removed soon !"
--		do
--			extend (new_value)
--		end

	extend (new_value: STRING) is
		local
			str_obj: PSTRING_OBJECT
		do
			!!str_obj.make (clone(new_value))
			area.extend (str_obj)
		end
	
	i_th (i: INTEGER): STRING is
		local
			str_obj : PSTRING_OBJECT;
		do
			str_obj := area.i_th (i);
			Result := str_obj.value;
		end

	i_th_pstring_object (i : INTEGER) : PSTRING_OBJECT is
		do
			Result := area.i_th (i)
		end
	
	remove_item (item: STRING) is
		local
			str_obj: PSTRING_OBJECT;
			i: INTEGER;
			found: BOOLEAN;
		do
			from i := 1
			until (i > count) or found
			loop
				str_obj := area.i_th(i);
				found := equal (item, str_obj.value);
				i := i + 1;
			end;
			if found then
				-- "i" was one too many after the loop
				area.remove_item (area.i_th (i-1));
			end;
		end;
	
	remove_all is
		do
			area.remove_all
		end
	
	has (item: STRING): BOOLEAN is
		local
			str_obj: PSTRING_OBJECT
			i: INTEGER
		do
			from i := 1
			until (i > count) or Result
			loop
				str_obj := area.i_th(i);
				Result := equal (item, str_obj.value);
				i := i + 1
			end;
		end

feature{NONE}
	
	area: PLIST [PSTRING_OBJECT]

end -- PLIST_STRING
