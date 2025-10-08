
class BitStream
  def initialize option={}
    option.each do|type, value|
      case type.to_s.downcase.to_sym
      when :hex; @stream = BitOp.stack( eval("0x#{value}") )
      when :bin; @stream = BitOp.stack( eval("0b#{value}") )
      when :dec; @stream = BitOp.stack( value.to_i )
      when :raw; @stream = value[0].is_a?(String)  ? value.each_byte.map{|c|c.ord} : value
      when :seq; @stream = value[0].is_a?(Integer) ? value : value.each_char.map{|c|c.ord}
      else; @stream = []    
      end
    end
  end

  def val format='hex', full=false # := number of bytes
    return []  if full.is_a?(Integer) && full <= 0
    e = full+1 if full.is_a?(Integer) && full > 0
    e = 1024   if full==false
    t = @stream.length >= e ? '...' : nil
    return case format.to_s.downcase.to_sym
    when :hex; @stream[0..e].map{|c|"%02x"%c} + (t ? [t] : [])
    when :bin; @stream[0..e].map{|c|"%08b"%c} + (t ? [t] : [])
    when :dec; eval("0b"+@stream[0..e].map{|c|"%08b"%c}.join).to_s + (t ? t : '')
    when :raw; @stream[0..e].map{|c|c.chr}.join + (t ? ' '+t : '')
    when :seq; @stream[0..e] + (t ? [t] : [])
    end
  end
end
