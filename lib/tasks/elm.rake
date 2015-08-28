namespace :elm do
  def compile_and_minify(dir, temp)
    Dir.chdir(dir) do
      target = "../_#{temp}"
      target.sub!(/\.js\z/, ".min.js")
      if system("elm-make Main.elm --output #{temp}")
        File.open(target, "w") do |file|
          file.write(Uglifier.compile(File.read(temp)))
        end
        puts "minified to #{target}"
      end
    end
  end

  desc "make and minify the Elm JS file for Todos"
  task :todos do
    compile_and_minify "app/views/todos/todos", "todos_elm.js"
  end

  desc "make and minify the Elm JS file for Blue PiLL"
  task :pills do
    compile_and_minify "app/views/pages/pills", "pills_elm.js"
  end
end
