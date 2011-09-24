-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "Simple class to time things. This one should be %
                 %portable among Unixes."

class SIMPLE_TIMER

feature

	active : BOOLEAN;
			-- true, if we're in the middle of timing something

	start is
			-- start the timer
		require
			not_running: not active;
		do
			-- Note that conversion to DOUBLE happens automatically
			active := True;
			time1 := clock;
			start_seconds := time (default_pointer)
		ensure
			active
		end;
	
	stop is
			-- stop the timer
		require
			running: active
		do
			-- Note that conversion to DOUBLE happens automatically
			time2 := clock;
			active := False;
			end_seconds := time (default_pointer) 
		ensure
			not active
		end;

	seconds_used : DOUBLE is
			-- seconds used since timer was started, or if stoped 
			-- seconds used between start and stop.
		do
			if active then
				time2 := clock				
			end
			Result := (time2 - time1) / 1000000.0
		end;

	elapsed_seconds: INTEGER is
			-- seconds elapsed between "start" and now
		do
			if not active then
				Result := end_seconds - start_seconds
			else
				Result := time (default_pointer) - start_seconds
			end
		end

	print_time is
		do
			io.putdouble (seconds_used)
			io.putstring (" CPU secs / ")
			io.putint (elapsed_seconds)
			io.putstring (" elapsed secs. %N")
		end

feature {NONE} -- implementation

	time1, time2: DOUBLE

	start_seconds, end_seconds: INTEGER

	clock: INTEGER is
		external "C"
		end

	time (dummy: POINTER) : INTEGER is
		external "C | <time.h>"
		end

end
