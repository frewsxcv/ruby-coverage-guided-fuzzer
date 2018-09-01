def run(num)
  if num == 45
    p :ok
  else
    p :ng
  end
end

def fuzz(bytes)
  run(bytes[0])
end
