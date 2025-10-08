namespace :test do
  desc "say whether a top-level method exists or not"
  task :method, [:method] => :environment do |task, args|
    method = args[:method]
    case method
    when nil
      puts "please supply a method name (e.g. bin/rake test:method\\[my_method\\])"
    when /\A\w+\z/
      puts "method #{method} #{self.respond_to?(method.to_sym, true) ? 'exists' : 'does not exist'}"
    else
      puts "invalid method name (#{method})"
    end
  end

  desc "say whether a class exists or not"
  task :class, [:class] => :environment do |task, args|
    klass = args[:class]
    case klass
    when nil
      puts "please supply a class name (e.g. bin/rake test:class\\[MyClass\\])"
    when /\A[A-Z]\w*(::[A-Z]\w*)*\z/
      exists =
        begin
          Object.const_get(klass)
          true
        rescue NameError
          false
        end
      puts "class #{klass} #{exists ? 'exists' : 'does not exist'}"
    else
      puts "invalid class name (#{klass})"
    end
  end
end
