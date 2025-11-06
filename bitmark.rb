
module BitOp
  module_function

  # USAGE: BitOp.mark '1001(a1b)_1001|100{daf]1,1001|1 101[1] 111 0|'
  def mark stream
    stream.holder
  end
end

class String
  def holder
    stream, cursor, flag = [], '', :close
    self.split('').each do|char|
      if [48,49].include?(char.ord)
        cursor += char
      elsif [40,60,91,123].include?(char.ord) && flag==:close
        stream << cursor
        cursor = char
        flag = :open
      elsif [41,62,93,125].include?(char.ord) && flag==:open
        temp = ')' if cursor[0].ord == 40
        temp = '>' if cursor[0].ord == 60
        temp = ']' if cursor[0].ord == 91
        temp = '}' if cursor[0].ord == 123
        cursor += temp
        stream << cursor
        cursor = ''
        flag = :close
      elsif flag == :open
        cursor << char
      else
        stream << cursor
        cursor = ''
      end
    end
    stream << cursor
    stream.delete ''
    return stream
  end
end
