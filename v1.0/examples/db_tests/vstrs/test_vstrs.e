-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class TEST_VSTRS

creation
	make

feature

	sess: DB_SESSION is
		once
			!!Result
		end
	
	v1, v2, v3: VSTR

	make_tested is
		local
			i: INTEGER
		do
			!!v1.make_empty (4 * 100)
			from i := 1
			until i > 100
			loop
				v1.extend_integer (i*13)
				i := i + 1
			end
		end

	find_index_test (item: INTEGER): INTEGER is
		do
			Result := v1.index_of_integer (item)
		end


	make is 
		local
			j, idx: INTEGER
		do
			sess.begin ("people@sioux")
			io.putstring ("Connected to database%N")
			make_tested
			io.putstring ("Test finding index of and removing ...%N")
			io.putstring ("Count= ")
			io.putint (v1.integer_count)
			io.new_line
			timer.start
			from j := 1 
			until j > 1000
			loop
				idx := find_index_test (j)
				if idx /= 0 then
					v1.remove_i_th_integer (idx)
				end
				j := j + 1
			end
			timer.stop
			timer.print_time
			io.putstring ("Count= ")
			io.putint (v1.integer_count)
			io.new_line
			
			io.putstring ("Testing just index_of..%N")
			make_tested
			timer.start
			from j := 1 
			until j > 1000
			loop
				idx := find_index_test (1300)
				j := j + 1
			end
			timer.stop
			timer.print_time
			sess.finish
		end
	
	timer: TIMER is
		once
			!!Result
		end

end
