require 'bitop'
require 'bitstream'

module BitProtocol
  module_function

  def load path
    self.reset unless @_pt_
    path = path[-5..-1]=='.json' ? path : path+'.json'
    @_bp_ = JSON.parse File.read(path)
    return @_bp_, @_pt_
  end

  def parse setting, reset=false
    self.reset if !@_pt_ || reset
    @_bp_ = JSON.parse setting
    return @_bp_, @_pt_
  end

  def reset
    @_pt_ = {}
  end

  def validate env={}
    inst, checks,report = env[:instance], [], []
    (puts "Instance of BitProtocol is nil.";return nil) unless inst
    console_log = env[:log]

    @_bp_.each do|key, set|
      desc = set['description']
      si, ei = set['start-bit'], set['finish-bit']
      type = set['type']
      should = set['value']
      
      bits = BitOp.seek(inst, si, ei)
      actual = self.eval(type, bits)
      
      cond = set['condition'] ? self.expr(set['condition']) : []
      vrfy = verify(set['verification'], should, actual)
      cert = finale(set['criteria'], vrfy)

      @_pt_["$[#{key}]"] = actual if self.evaluate(cond) && vrfy
      checks << [key, desc, si, ei, type, should, actual, cond, vrfy, cert]
    end

    checkz = []
    checks.each do|check|
      key, desc, si, ei, type, should, actual, cond, vrfy, cert = check
      if vrfy && self.evaluate(cond)
        @_pt_["$[#{key}]"] = actual
      end
      checkz << [key, desc, si, ei, type, should, actual, cond, vrfy, cert]
    end

    checkz.each do|check|
      key, desc, si, ei, type, should, actual, cond, vrfy, cert = check

      if self.finale(cert, vrfy) && self.evaluate(cond)
        puts "Field #{key} is #{desc}." if console_log
        show = (vrfy && should[actual]) ? should[actual] : (vrfy && vrfy!=true) ? vrfy : ''
        puts "From #{si} to #{ei} is #{actual}, check should be #{!vrfy ? false : true}. >>>> #{show}" if console_log
        unless cond.empty?
          evar = self.evaluate(cond)
          puts "Condition Expression is #{cond}, evaluation is #{evar}." if console_log
        end
        puts Array.new(128){'='}.join if console_log if console_log

        report << [key.gsub('$[','').gsub(']',''), desc, show, actual, "#{type}[#{si}-#{ei}]"]
      end
    end

    return report, @_pt_
  end

  def eval type, content
    return case type
    when 'HEX'; BitOp.bin2hex(content).to_s.upcase
    when 'BIN'; content
    when 'BIN(4)'; Array.new(4-content.length){'0'}.join+content
    # when 'DEC'; 
    when 'STR'; content
    else; nil
    end
  end

  def expr condition
    vars = self.var(condition)
    opts = self.oprt(condition)
    words = self.words(condition)
    vars = words.include?(vars) ? vars : vars
    vals = words.include?(opts) ? words[(words.index(opts)+1)..-1] : words
    return [vars, opts, vals]
  end

  def var condition
    field = condition.to_s.match(/\$(\[|\{){1}(\w[\d|\_|\w]+)+(\]|\}){1}/).to_s
    name = field.empty? ? nil : field.split('{').last.split('}').first
    return name
  end

  def words condition
    value = condition.to_s.match(/(\(){0,1}.*[\,|.]+.*(\)){0,1}/).to_s
    list = (value.empty? ? condition.split(' ') : value.split('(').last.split(')').first.to_s.split(',')).map{|s|s.strip}
    return list
  end

  def oprt condition
    return '=='    if condition.to_s.include? '=='
    return 'in'    if condition.to_s.include? 'in'
    return 'exist' if condition.to_s.include? 'exist'
    return nil
  end

  def evaluate expr
    vars, opts, vals = expr # vars include $[] here
    # p [vars, @_pt_[vars], opts, vals]
    return case opts
    when '=='; @_pt_[vars] == vals.first
    when 'in'; vals.include?(@_pt_[vars])
    when 'exist'; !!@_pt_[vars]
    else; true
    end
  end

  def verify verification, should, actual, &process
    return case verification
    when '精确匹配'
      should.keys.include? actual
    when '精确查询'
      locate = self.rtrace(should, actual, '')
      locate ? locate.gsub('/',' ').strip : false
    else
      false
    end
  end

  def finale criteria, result
    return case criteria
    when '失败'; result
    when '忽略'; !result
    else; result; end
  end

  def trace tree,rtree,dom=''
    tree.each do|name, node|
      if node.is_a?(Hash)
        rtree = self.trace(node, rtree, "#{dom}/#{name}")
      elsif node.is_a?(Array)
        node.each do|value| # must be an atom
          rtree["#{dom}/#{name}"] = value
        end
      else
        rtree["#{dom}/#{name}"] = node
      end
    end
    return rtree
  end

  def rtrace tree, key, dom=''
    rsort = self.trace(tree, {}, dom)
    rtree = {}
    rsort.each do|path, val|
      rtree[val]=path
    end
    return rtree[key]
  end

  def normal? report, rule
    return true if \
      report.map{|r|r[0]}==['PB','AT','PI1','QoS'] && rule=='一般专线地址' ||
      report.map{|r|r[0]}==['PB','AT','PI2','CC'] && rule=='网吧专线地址'
    return false
  end
end
