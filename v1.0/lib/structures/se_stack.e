-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- SE_STACK - simple and efficient STACK. Implemented as a
-- LINKED_STACK of ARRAYs
--

class SE_STACK [T]

creation
	
	make

feature
	
	
	put (it : T) is
			-- Put item on top of the stack
		do
			top := top + 1;
			if top > chunk_size then
				stack_area.put_front (top_array);
				!!top_array.make (1, chunk_size);
				top := 1
			end
			top_array.put (it, top);
			valid_iteration := False
		ensure
			not_empty: not empty
			bigger: count = old count + 1
			top_is_new_item: item = it
			iteration_stopped: not valid_iteration
		end
	

	remove is
			-- Remove top item from the stack
		require
			not_empty: not empty
		local
			default_value: T
		do
			top_array.area.put (default_value, top - 1)
			top := top - 1
			if top = 0 then
				if not stack_area.empty then
					stack_area.start
					top_array := stack_area.item;
					stack_area.remove;
					top := chunk_size
				end
			end
			valid_iteration := False
		ensure
			smaller: count = old count - 1
			iteration_stopped: not valid_iteration
		end
	
	item : T is
			-- Top element of the stack
		require
			not_empty: not empty
		do
			Result := top_array @ top
		end
	
	empty : BOOLEAN is
			-- True if there isnothin on the stack
		do
			Result := top = 0
		end
	
	count : INTEGER is
			-- Number of elements in the stack
		do
			Result := top + stack_area.count * chunk_size
		end
	
	wipe_out is
		do
			top := 0
			!!top_array.make (1, chunk_size)
			stack_area.wipe_out
		end

feature -- iteration
	
	start is
			-- start iteration at the top of the stack
		require
			not_empty: not empty
		do
			stack_area.start
			element := top
			it_array := top_array
			valid_iteration := true
		ensure
			stack_unchanged: valid_iteration
		end
	
	iterated_item: T is
			-- current item
		local
			arr: ARRAY [T]
		do
			Result := it_array @ element
		end
	
	forth is
			-- move to next item
		require
			stack_unchanged: valid_iteration
		do
			element := element - 1
			if element = 0 then
				if not (stack_area.empty or stack_area.off) then
					it_array := stack_area.item
					element := chunk_size
					stack_area.forth
				end
			end
		end
	
	off: BOOLEAN is
			-- true if iteration is at the end
		require
			stack_unchanged: valid_iteration
		do
			Result := (element = 0) and (stack_area.empty or stack_area.off)
		end
	
	valid_iteration: BOOLEAN
			-- if a put or pop is done in the middle of iteration this
			-- will become false
	
feature {NONE} -- iteration implementation
	
	element: INTEGER
			-- index of the element we're looking at
	
	it_array: ARRAY [T]
			-- the array we are looking at

feature {NONE}	
	
	make (new_chunk_size : INTEGER) is
		require
			chunk_size_reasonable: new_chunk_size >= 10
		do
			chunk_size := new_chunk_size;
			!!stack_area.make;
			!!top_array.make (1, chunk_size)
		ensure
			is_empty: empty;
			first_array_there: top_array /= Void;
			chunk_defined: new_chunk_size = chunk_size
		end

	chunk_size : INTEGER
			-- Size of each piece
	
	stack_area : LINKED_LIST [ARRAY [T]]
			-- list of arrays making up the stack
	
	top : INTEGER
			-- top element in the current array
	
	top_array : ARRAY [T]
			-- top array

invariant
	
	empty implies (count = 0)

end -- SE_STACK
