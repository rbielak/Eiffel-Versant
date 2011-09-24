-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "Tester for SPLIT_STRING"
	date: "$Date: $"
	revision: "$Revision: $"
	reference: kosamed


deferred class SPLIT_STRING

inherit

	ASCII

feature

	separator: CHARACTER is
		deferred
		end

	split_into_parameters (full_string: STRING): ARRAY [STRING] is
		local
			i, j, pointer: INTEGER
			str, loc_full_string: STRING
		do
			loc_full_string := full_string.twin
			j := loc_full_string.occurrences (separator)
			!!Result.make (1, j + 1)

			from
				i := 1
			until
				i > j
			loop
				pointer := loc_full_string.index_of (separator, 1)
				if pointer /= 1 then
					!!str.make (pointer - 1)
					str.append (loc_full_string.substring (1, pointer - 1))
					Result.put (str, i)
				else
					Result.put ("", i)
				end
				--io.put_string (str)
				--io.new_line
				loc_full_string.replace_substring ("", 1, pointer)
				i := i + 1
			end
			Result.put (loc_full_string, j + 1)
			--io.put_string (loc_full_string)
			--io.new_line
		end

	trim_old (s: STRING): STRING is
		do
			Result := s.twin
			Result.prune_all_leading (' ')
			Result.prune_all_trailing (' ')
		end

	trim (str: STRING): STRING is
			-- Remove all leading or trailing whitespace
			-- White space is a tab or a blank
		local
			s, e: INTEGER
		do
			from
				s := 1
			until
				s > str.count or else (str.item (s).code /= Tabulation and str.item (s).code /= Blank)
			loop
				s := s + 1
			end
			from
				e := str.count
			until
				e < 1 or else (str.item (e).code /= Tabulation and str.item (e).code /= Blank)
			loop
				e := e - 1
			end
			if s > e then
				!!Result.make (1)
			else
				Result := str.substring (s, e)
			end
		end

end -- end of class SPLIT_STRING
