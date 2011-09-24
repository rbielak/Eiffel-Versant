-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--

class SHARED_EXCEPTIONS

feature

	exceptions: SAFE_EXCEPTIONS is
		once
			!!Result
		end

	raise (str: STRING) is
		require
			has_str: str /= void
		do
			io.putstring ("EXCEPTION TAG: ")
			io.putstring (str)
			io.new_line
			exceptions.raise (str)
		end

	raise_1 (str: STRING) is
		require
			has_str: str /= void
		do
			raise (str)
		end

	raise_2 (str1, str2: STRING) is
		require
			has_str1: str1 /= void
			has_str2: str2 /= void
		local
			str: STRING
		do
			!!str.make (str1.count+1+str2.count)
			str.append (str1)
			str.append (" ")
			str.append (str2)
			raise (str)
		end

	raise_n (strs: ARRAY [STRING]) is
		require
			has_strs: strs /= void
		local
			str: STRING
			i: INTEGER
		do
			!!str.make (100)
			from
				str.append (strs.item (strs.lower))
				i := strs.lower+1
			until
				i > strs.upper
			loop
				str.append (" ")
				str.append (strs.item (i))
				i := i+1
			end
			raise (str)
		end

end
