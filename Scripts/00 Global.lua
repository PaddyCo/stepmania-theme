GLOBAL = {
  input_stack = {}
}

function GLOBAL.GetCurrentInputFocus()
  return GLOBAL.input_stack[#GLOBAL.input_stack]
end

function GLOBAL.PushInputFocus(name)
  GLOBAL.input_stack[#GLOBAL.input_stack+1] = name
end

function GLOBAL.DropCurrentInputFocus()
  table.remove(GLOBAL.input_stack, #GLOBAL.input_stack)
end

