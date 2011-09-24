-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Access to `environment variables'.
 
class ENVIRONMENT_VARIABLES

inherit

	SHARED_EXCEPTIONS

feature
	
	get (var_name: STRING): STRING is
			-- Lookup the value of the environment variable `var_name'. 
		require
			name_not_void: var_name /= Void; 
		local
			tmp2: POINTER
		do
			tmp2 := c_getenv ($(var_name.to_c))
			if tmp2 /= default_pointer then
				!!Result.make (0)
				Result.from_c (tmp2)
			end
		end

	get_home_directory: STRING is
		once
			-- Let's try Unix variable
			Result := get ("HOME")
			if Result = void then
				-- This is not Unix
				-- Let's try NT variable
				Result := get ("HOMEDRIVE")
				if Result = void then
					-- This is not NT
					-- Mac is not yet supported
					raise_1 ("Unknown home directory")
				else
					Result.append (get ("HOMEPATH"))
				end
			end
		end

	is_running_on_nt: BOOLEAN is
		once
			Result := get ("PLATFORM").is_equal ("w32msc")
		end

	is_running_on_solaris: BOOLEAN is
		once
			Result := get ("PLATFORM").is_equal ("solaris")
		end

	is_running_on_linux: BOOLEAN is
		once
			-- for ISS PLATFORM="linux" for ISE PLATFORM="linux-glibc"
			Result := get ("PLATFORM").fuzzy_index ("linux", 1, 0) > 0
		end

feature {NONE}
	
	frozen c_getenv (var_name: POINTER): POINTER is
		external
			"C"
		alias
			"getenv"
		end
	
end -- class ENVIRONMENT_VARIABLES
