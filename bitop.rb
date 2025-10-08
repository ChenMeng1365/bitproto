
module BitOp
  module_function

  def stack num
    sequence, left = [], num
    until left==0
      rest = left & 0b11111111
      left = left >> 8
      sequence.unshift rest
    end
    return sequence
  end

  def hextack num
    sequence, left = [], num
    until left==0
      rest = left & 0b1111
      left = left >> 4
      sequence.unshift rest
    end
    return sequence
  end

  def hex2bin num
    return self.stack(num).map{|c|"%08b"%c}.join              if num.is_a?(Integer)
    return num.each_char.map{|c|"%04b" % (eval("0x#{c}"))}.join if num.is_a?(String)
  end

  def bitval num
    eval("0b"+num)
  end

  def bin2hex num
    return self.hextack(num).map{|c|"%0x"%c}.join                   if num.is_a?(Integer)
    return num.split('').each_slice(4).map{|c|"%0x"%eval("0b#{c.join}")}.join if num.is_a?(String)
  end

  def hexval num
    eval("0x"+num)
  end

  def seek bitstream, head_index=nil, tail_index=nil, full=false
    q = bitstream.val(:seq, full).select{|c|c!='...'}.map{|c|"%08b"%c}.join
    s = 0                     if head_index==:first        || head_index==nil
    s = q.length + head_index if head_index.is_a?(Integer) && head_index < 0
    s = head_index            if head_index.is_a?(Integer) && head_index >= 0
    s = q.length - 1          if head_index.is_a?(Integer) && head_index >= q.length
    e = -1                    if tail_index==:last
    e = q.length + tail_index if tail_index.is_a?(Integer) && tail_index < 0
    e = tail_index            if tail_index.is_a?(Integer) && tail_index >= 0
    e = q.length - 1          if tail_index.is_a?(Integer) && tail_index >= q.length
    e = s                     if tail_index==nil           || (e.is_a?(Integer) && s.is_a?(Integer) && e < s)
    # p [q, s, e]
    q[s..e]
  end
end
