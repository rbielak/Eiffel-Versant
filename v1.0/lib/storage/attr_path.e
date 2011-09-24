-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- This class allows the manipulation of atributes paths. Things like
-- "foo.bar.junk"
--

class ATTR_PATH

creation
	make

feature
	
	make (new_path : STRING) is
			-- make new path object
		require
			new_path /= Void
		do
			parse_path (new_path);
			path := new_path;
		end;
	
	count : INTEGER is
		do
			Result := path_items.count;
		end;
	
	i_th (i : INTEGER) : STRING is
			-- The i_th part
		require
			index_ok: (i > 0) and (i <= count)
		do
			Result := path_items @ i
		end;
	
	path : STRING;
			-- the actual path


feature{NONE}
	
	path_items : ARRAY[STRING];
	
	parse_path (some_path : STRING) is
		local
			one_name : STRING;
			dot_pos, start_pos, i : INTEGER;
		do
			!!path_items.make (1, some_path.occurrences ('.') + 1);
			from  
				dot_pos := 1;
				start_pos := 1 
				i := 1;
			until 
				(dot_pos = 0) 
			loop
				dot_pos := some_path.index_of ('.', start_pos);
				if dot_pos /= 0 then
					one_name := some_path.substring (start_pos, dot_pos - 1);
					start_pos := dot_pos + 1;
				else
					one_name := some_path.substring (start_pos, some_path.count);
				end;
				path_items.put (one_name, i);
				i := i + 1;
			end;
		end;

invariant

end -- ATTR_PATH
