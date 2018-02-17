function table.map(array, func)
  local new_array = {}
  for i,v in ipairs(array) do
    new_array[i] = func(v)
  end
  return new_array
end

function table.compare(array, compare_func)
  local highest = nil

  for i, v in ipairs(array) do
    if (highest == nil or compare_func(v, highest)) then
      highest = v
    end
  end

  return highest
end

function table.find_index(match, array)
  for i, v in ipairs(array) do
    if v == match then return i end
  end

  return -1
end
