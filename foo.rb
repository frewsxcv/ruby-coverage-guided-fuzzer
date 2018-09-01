def run(num)
  if num == '0'
    a = 0
  elsif num == '1'
    a = 1
  else
    a = nil
  end
end

def fuzz(bytes)
  run(bytes[0])
end
