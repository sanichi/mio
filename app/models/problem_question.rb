class ProblemQuestion
  attr_reader :error

  def initialize(param = nil)
    @data = Hash.new
    if param
      begin
        # Try to pase the data and then check it.
        data = JSON.parse(param)
        raise "parameter data is not a hash" unless data.is_a?(Hash)
        data.each do |k, v|
          raise "key (#{k}) is not a positive integer" unless k.to_s.match(/\A[1-9]\d*\z/)
          unless v.nil?
            raise "value (#{v}) is not a non-empty array" unless v.is_a?(Array) && !v.empty?
            v.each do |i|
              raise "array entry (#{i}) is not a positive integer" unless i.is_a?(Integer) && i > 0
            end
          end
        end
        # OK, it passes muster, store it (remember to convert the key type from JSON string).
        data.each { |k, v| @data[k.to_i] = v }
      rescue => e
        @error = e.message
      end
    end
  end

  def available?
    !@data.empty?
  end

  def unavailable?
    @data.empty?
  end

  def pids
    @data.keys
  end

  def qids(pid)
    @data[pid]
  end

  def filter(pids)
    data = Hash.new
    pids.each do |pid|
      data[pid] = @data[pid] if @data.has_key?(pid)
    end
    @data = data
  end

  def serialize
    return if unavailable?
    JSON.generate(@data)
  end

  def add(pid, qid = nil)
    if qid
      @data[pid] = [] unless @data.has_key?(pid)
      @data[pid].push(qid)
    else
      @data[pid] = nil unless @data.has_key?(pid)
    end
  end
end
